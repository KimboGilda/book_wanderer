require 'httparty'
require 'uri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @books = Book.all

    # Check if we are logged in
    if current_user
      # Get all read books for current user
      @read = ReadBook.where(user_id: current_user.id)
      book_ids = @read.pluck(:book_id) # list of ids
      @user_books = Book.where(id: book_ids)
      book_titles = @user_books.pluck(:title)
      @book_titles_str = book_titles.join(', ')
      # Create text body for request
      @text = "Please provide two arrays:
              Array 1: Titles — this array should contain 6 famous or classic book titles that are influenced by the books I have read: #{@book_titles_str}.
              Array 2: Authors — this array should contain only the last names of the authors of the books from the first array. Response please like **Array 1: Titles**.....**Array 2: Authors** and all titles and last names should be in English and contain only titles or authors?"

      # Call the function
      @random_rec = generate_book_recommendations(@text)

      # Get all recommendations from AI and make an array
      if @random_rec
        books_array = @random_rec.split("\n").map { |book| book.gsub(/(^\d+\.\s*|-)*/, '') }
        @results = books_array
        text = @results.join("\n")
        titles, authors = split_array_text(text)
      else
        @results = "Don't have recommendations."
      end

      @books_for_carousel = []

      # Create books which AI recommends
      @results.each do |data|
        titles.each do |title|
          authors.each do |author|
            search_results = get_books(title, author)

            # Find the earliest book (considering missing publication dates)
            earliest_book = search_results.min_by do |book|
              published_date = book['volumeInfo'].dig('publishedDate')
              published_year = published_date&.split('-')&.first.to_i || Float::INFINITY  # Use infinity for missing dates
            end

            # Skip if no book or invalid publication date
            next if earliest_book.nil?

            # Extract book information
            book_title = earliest_book['volumeInfo']['title'] || title
            book_author = earliest_book['volumeInfo']['authors']&.join(', ') || author
            summary = earliest_book['volumeInfo']['description'] || Faker::Lorem.paragraphs(number: 2).join("\n")
            publication_year = earliest_book['volumeInfo'].dig('publishedDate')&.split('-')&.first
            genre = earliest_book['volumeInfo']['categories']&.join(', ') || Faker::Book.genre
            cover_image_url = earliest_book['volumeInfo']['imageLinks']&.dig('thumbnail')

            # Find or create the book and assign it to the carousel array
            book = Book.find_or_create_by!(title: book_title, author: book_author) do |b|
              b.publication_year = publication_year
              b.summary = summary
              b.short_summary = summary
              b.genre = genre
              b.cover_image_url = cover_image_url
            end

            # Add the found or created book to the carousel array
            @books_for_carousel << book
          end
        end
      end
    end
  end

  private

  def split_array_text(text)
    # Split the text into sections by delimiters
    sections = text.split(/\*\*Array \d: Titles\*\*|\*\*Array \d: Authors\*\*/).map(&:strip)

    # Process sections
    titles_section = sections[1].downcase
    authors_section = sections[2].downcase

    # Convert sections to arrays of strings, removing empty lines
    titles = titles_section.to_s.split("\n").reject(&:empty?).map(&:strip)
    authors = authors_section.to_s.split("\n").reject(&:empty?).map(&:strip)

    [titles, authors]
  end

  def get_books(query, author = nil)
    encoded_query = URI.encode_www_form_component(query)
    encoded_author = URI.encode_www_form_component(author) if author

    if author.nil?
      url = "https://www.googleapis.com/books/v1/volumes?q=#{encoded_query}&key=#{ENV['API_KEY']}&langRestrict=en"
    else
      url = "https://www.googleapis.com/books/v1/volumes?q=#{encoded_query}+inauthor:#{encoded_author}&key=#{ENV['API_KEY']}&langRestrict=en"
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
    # Request
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
