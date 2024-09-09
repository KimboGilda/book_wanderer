require 'httparty'
require 'uri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @books = Book.all
    if current_user
      @twenty_four_recommendations = random_book
      @three_recommendations_pro_click = @twenty_four_recommendations.sample(6)
    else
      @three_recommendations_pro_click = []
    end
  end

  def random_book
    if current_user
      # Get all read books for the current user
      @read = ReadBook.where(user_id: current_user.id)
      book_ids = @read.pluck(:book_id) # list of ids
      @user_books = Book.where(id: book_ids)
      book_titles = @user_books.pluck(:title)
      @book_titles_str = book_titles.join(', ')

      # Create text body for request
      @text = "Please provide two arrays:
              Array 1: Titles — this array should contain 10 famous or classic book titles that are influenced by the books I have read: #{@book_titles_str}.
              Array 2: Authors — this array should contain only the last names of the authors of the books from the first array. Respond like **Array 1: Titles**.....**Array 2: Authors** and all titles and last names should be in English."

      # Call AI to generate recommendations
      @random_rec = generate_book_recommendations(@text)

      if @random_rec
        books_array = @random_rec.split("\n").map { |book| book.gsub(/(^\d+\.\s*|-)*/, '') }
        text = books_array.join("\n")
        titles, authors = split_array_text(text)
      else
        @results = "No recommendations available."
        return []
      end

      # Initialize carousel array
      @books_for_carousel = []

      # Combine titles and authors into pairs
      books_and_authors = titles.zip(authors)

      # Process each title-author pair
      books_and_authors.each do |title, author|
        search_results = get_books(title, author)

        # Find the earliest book (considering missing publication dates)
        earliest_book = search_results.min_by do |book|
          published_date = book['volumeInfo'].dig('publishedDate')
          published_year = published_date&.split('-')&.first.to_i || Float::INFINITY
        end

        next if earliest_book.nil? # Skip if no valid book is found

        # Extract book information
        book_title = earliest_book['volumeInfo']['title'] || title
        book_author = earliest_book['volumeInfo']['authors']&.join(', ') || author
        summary = earliest_book['volumeInfo']['description'] || Faker::Lorem.paragraphs(number: 2).join("\n")
        publication_year = earliest_book['volumeInfo'].dig('publishedDate')&.split('-')&.first
        genre = earliest_book['volumeInfo']['categories']&.join(', ') || Faker::Book.genre
        cover_image_url = earliest_book['volumeInfo']['imageLinks']&.dig('thumbnail')

        if cover_image_url
          # Create only if it doesn't already exist
          unless Book.exists?(title: book_title, author: book_author)
            book = Book.create!(
              title: book_title,
              author: book_author,
              publication_year: publication_year,
              summary: summary,
              short_summary: summary,
              genre: genre,
              cover_image_url: cover_image_url
            )

            # Add to the carousel array
            @books_for_carousel << book
          else
            book = Book.find_by(title: book_title, author: book_author)
            @books_for_carousel << book
          end
        end
      end
    end

    # Return the array of book objects
    @books_for_carousel
  end

  # Method for getting random recommendations after clicking on the random button
  def random_books
    @random_books = Book.order("RANDOM()").limit(6)

    respond_to do |format|
      format.json do
        render json: {
          books_html: render_to_string(partial: "books/book", collection: @random_books, as: :book, formats: [:html])
        }, status: :ok
      end
    end
  end

private

  def split_array_text(text)
    # Split the text into sections by delimiters
    sections = text.split(/\*\*Array \d: Titles\*\*|\*\*Array \d: Authors\*\*/).map(&:strip)

    # Process sections
    titles_section = sections[1]
    authors_section = sections[2]

    # Convert sections to arrays of strings, removing empty lines
    titles = titles_section.to_s.split("\n").reject(&:empty?).map(&:strip)
    authors = authors_section.to_s.split("\n").reject(&:empty?).map(&:strip)

    [titles, authors]
  end

  def get_books(query, author = nil)
    # Request to books API for info
    encoded_query = URI.encode_www_form_component(query)
    encoded_author = URI.encode_www_form_component(author) if author

    url = if author.nil?
            "https://www.googleapis.com/books/v1/volumes?q=#{encoded_query}&key=#{ENV['API_KEY']}&langRestrict=en"
          else
            "https://www.googleapis.com/books/v1/volumes?q=#{encoded_query}+inauthor:#{encoded_author}&key=#{ENV['API_KEY']}&langRestrict=en"
          end

    response = HTTParty.get(url)
    if response.success?
      items = response.parsed_response['items']
      items.nil? ? [] : items
    else
      []
    end
  end

  def generate_book_recommendations(text)
    # Request body
    body = {
      contents: [
        {
          role: "user",
          parts: [{ text: text }]
        }
      ]
    }

    response = HTTParty.post(
      "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=#{ENV['AI_API_KEY']}",
      headers: { 'Content-Type' => 'application/json' },
      body: body.to_json
    )

    if response.success?
      result = JSON.parse(response.body)
      @recommendations = result["candidates"].first.dig("content", "parts", 0, "text")
      return @recommendations
    else
      @recommendations = "Error: #{response.code}"
      return nil
    end
  end
end
