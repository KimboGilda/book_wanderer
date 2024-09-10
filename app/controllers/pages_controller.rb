class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :random_books]

  # Home action for initial page load
  def home
    @books = Book.all
    # if current_user
    #   @twenty_four_recommendations = random_book
    #   @three_recommendations_pro_click = @twenty_four_recommendations.sample(6)
    # else
    #   @three_recommendations_pro_click = []
    # end

    # espond_to do |format|
    #   format.json do
    #     render json: {
    #       books_html: render_to_string(partial: "books/book", collection: @three_recommendations_pro_click, as: :book, formats: [:html])
    #     }, status: :ok
    #   end
    # end
  end

  # Action for fetching random books when clicking the "Random Book" button
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

  # Action for fetching personalized recommendations when clicking the "Our Collection" button
  def our_selection
    if current_user
      @twenty_four_recommendations = random_book
      @three_recommendations_pro_click = @twenty_four_recommendations.sample(6)
    else
      @three_recommendations_pro_click = []
    end

    respond_to do |format|
      format.json do
        render json: {
          books_html: render_to_string(partial: "books/book", collection: @three_recommendations_pro_click, as: :book, formats: [:html])
        }, status: :ok
      end
    end
  end

  # The method that generates recommendations based on the user's read books
  def random_book
    return [] unless current_user

    # Get the read books for the current user
    @read = ReadBook.where(user_id: current_user.id)
    book_ids = @read.pluck(:book_id)
    @user_books = Book.where(id: book_ids)
    book_titles = @user_books.pluck(:title)
    @book_titles_str = book_titles.join(', ')

    # Generate recommendations using an AI model
    @text = "Please provide two arrays: Array 1: 10 book titles influenced by: #{@book_titles_str}. Array 2: Authors."
    @random_rec = generate_book_recommendations(@text)

    if @random_rec
      titles, authors = split_array_text(@random_rec)

      Rails.logger.info("Recommended Titles: #{titles.inspect}")
      Rails.logger.info("Recommended Authors: #{authors.inspect}")

      books_and_authors = titles.zip(authors)

      # Fetch books based on recommendations
      books_and_authors.map do |title, author|
        search_results = get_books(title, author)
        search_results.first # Return the first result found for each title-author pair
      end.compact
    else
      []
    end
  end

  private

  # Method to split the response from AI into arrays of titles and authors
  def split_array_text(text)
    sections = text.split(/\*\*Array \d: Titles\*\*|\*\*Array \d: Authors\*\*/).map(&:strip)

    titles = sections[1].to_s.split("\n").reject(&:empty?).map(&:strip)
    authors = sections[2].to_s.split("\n").reject(&:empty?).map(&:strip)

    [titles, authors]
  end

  # Method to fetch books using the Google Books API
  def get_books(query, author = nil)
    encoded_query = URI.encode_www_form_component(query)
    encoded_author = URI.encode_www_form_component(author) if author

    url = if author.nil?
            "https://www.googleapis.com/books/v1/volumes?q=#{encoded_query}&key=#{ENV['API_KEY']}&langRestrict=en"
          else
            "https://www.googleapis.com/books/v1/volumes?q=#{encoded_query}+inauthor:#{encoded_author}&key=#{ENV['API_KEY']}&langRestrict=en"
          end

    response = HTTParty.get(url)
    return [] unless response.success?

    response.parsed_response['items'] || []
  end

  # Method to generate book recommendations using AI
  def generate_book_recommendations(text)
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
      result["candidates"].first.dig("content", "parts", 0, "text")
    else
      "Error: #{response.code}"
    end
  end
end
