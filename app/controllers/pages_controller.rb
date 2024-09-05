require 'httparty'
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @books = Book.all

    if current_user
      @read = ReadBook.where(user_id: current_user.id)
      book_ids = @read.pluck(:book_id) # lists w ids
      @user_books = Book.where(id: book_ids)
      book_titles = @user_books.pluck(:title)
      @book_titles_str = book_titles.join(', ')
      @text = "Give me an array only with 5 titles (without authors, only titles) of books which I can also like if I read #{@book_titles_str}?"

      @random_rec = generate_book_recommendations(@text)

      if @random_rec
        books_array = @random_rec.split("\n").map { |book| book.gsub(/(^\d+\.\s*|-)*/, '') }
        @results = books_array
      else
        @results = "No suitable recommendation found."
      end
    end
  end

  private

  def generate_book_recommendations(text)
    # query
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

      # @recommendations = result["candidates"][0]["content"]["parts"][0]['text']
      @recommendations = result["candidates"].first.dig("content", "parts", 0, "text")
      # "1. The Great Gatsby by F. Scott Fitzgerald\n2. One Hundred Years of Solitude by Gabriel García Márquez\n3. The Adventures of Sherlock Holmes by Sir Arthur Conan Doyle\n4. The Catcher in the Rye by J.D. Salinger\n5. The Short Stories by Edgar Allan Poe"
      return @recommendations
    else
      @recommendations = "Error message: #{response.code}"
      return nil
    end
  end
end