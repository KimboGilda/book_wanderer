require 'httparty'
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @books = Book.all

    # Check are we log in
    if current_user
      # Get all read books for current user
      @read = ReadBook.where(user_id: current_user.id)
      book_ids = @read.pluck(:book_id) # lists w ids
      @user_books = Book.where(id: book_ids)
      book_titles = @user_books.pluck(:title)
      @book_titles_str = book_titles.join(', ')
      # create text body for request
      @text = "Give me array with 5 new book titles influenced by books i've read: #{@book_titles_str}? Provide only titles, not authors nor descriptions"
      # call the func
      @random_rec = generate_book_recommendations(@text)
      # get all recommendations form ai and make an array
      if @random_rec
        books_array = @random_rec.split("\n").map { |book| book.gsub(/(^\d+\.\s*|-)*/, '') }
        @results = books_array
      else
        @results = "Dont have recommendations."
      end

      # get recommendations books from books api
      # @all_books = @results.flat_map { |book| get_books(book) }
      # create books which ai recommends
      @results.each do |data|
        search_results = get_books(data)
        first_book = search_results.first
        next if first_book.nil?
        title = first_book['volumeInfo']['title']
        author = first_book['volumeInfo']['authors']&.join(', ')
        summary = first_book['volumeInfo']['description']
        publication_year = first_book['volumeInfo']['publishedDate']&.split('-')&.first
        genre = first_book['volumeInfo']['categories']&.join(', ')
        cover_image_url = first_book['volumeInfo']['imageLinks']&.dig('thumbnail')
        short_summary = summary
        if author == nil
          author = Faker::Book.author
        end
        if genre == nil
          genre = Faker::Book.genre
        end
        if title == nil
          title = Faker::Book.title
        end
        if summary == nil
          summary = Faker::Lorem.paragraphs(number: 2).join("\n")
        end


        unless Book.exists?(title: title, author: author)

          Book.create!(
            title: title,
            author: author,
            publication_year: publication_year,
            summary: summary,
            short_summary: short_summary,
            genre: genre,
            cover_image_url:cover_image_url
          )
        end
        # take all new created books from db and made the clickable carousel
        @new_books = []
        @results.map do |result|

          book = Book.find_by(title: result)
          @new_books << book
        end
      end
    end
  end

  private


  def get_books(books)
    url = "https://www.googleapis.com/books/v1/volumes?q=#{books}&key=#{ENV['API_KEY']}&langRestrict=en"

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

      # @recommendations = result["candidates"][0]["content"]["parts"][0]['text']
      @recommendations = result["candidates"].first.dig("content", "parts", 0, "text")
      # "1. The Great Gatsby by F. Scott Fitzgerald\n2. One Hundred Years of Solitude by Gabriel García Márquez\n3. The Adventures of Sherlock Holmes by Sir Arthur Conan Doyle\n4. The Catcher in the Rye by J.D. Salinger\n5. The Short Stories by Edgar Allan Poe"
      return @recommendations
    else
      @recommendations = "Error: #{response.code}"
      return nil
    end
  end
end



# if author == nil
#   @text = "Give me only the real name for the author of this book #{title}"
#   author = generate_book_recommendations(@text)
# end
# if genre == nil
#   @text = "Give me only the real genre for this book #{title}"
#   genre = generate_book_recommendations(@text)
# end
# if title == nil
#   @text = "Give me only one real random title of the existing book"
#   title = generate_book_recommendations(@text)
# end
# if summary == nil
#   @text = "Give me summary with 2 or three sentences for this book #{title}"
#   summary = generate_book_recommendations(@text)
# end
