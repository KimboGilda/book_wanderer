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
      #
      @text = "Please provide two arrays: Array 1: Titles — this array should contain 6 famous or classic book titles that are influenced by the books I have read: #{@book_titles_str}.
                Array 2: Authors — this array should contain only the last names of the authors of the books from the first array.response please like **Array 1: Titles**.....**Array 2: Authors** and all titles and last names should be on english ?"

      # "Give me 2  arrays  with 6 new book in first one provide ONLY titles influenced by books i've read: #{@book_titles_str} and in the second one provide me ONLY last names authors of this books, response please like **Array 1: Titles**.....**Array 2: Authors** ?"

      # "Give me array with 5 new book titles influenced by books i've read: #{@book_titles_str}? Provide only titles, not authors nor descriptions"

      # call the func
      @random_rec = generate_book_recommendations(@text)
      # get all recommendations form ai and make an array
      if @random_rec
        books_array = @random_rec.split("\n").map { |book| book.gsub(/(^\d+\.\s*|-)*/, '') }
        @results = books_array
        text = @results.join("\n")
        titles, authors = split_array_text(text)
      else
        @results = "Dont have recommendations."
      end
      @books_for_carousel = []

      # get recommendations books from books api
      # @all_books = @results.flat_map { |book| get_books(book) }
      # create books which ai recommends
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
        title = earliest_book['volumeInfo']['title']
        author = earliest_book['volumeInfo']['authors']&.join(', ')
        summary = earliest_book['volumeInfo']['description']
        publication_year = earliest_book['volumeInfo'].dig('publishedDate')&.split('-')&.first
        genre = earliest_book['volumeInfo']['categories']&.join(', ')
        cover_image_url = earliest_book['volumeInfo']['imageLinks']&.dig('thumbnail')
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
        # @titles_for_carousel << title
      end

        end

      end
      titles.each do |title|

        @books_for_carousel << Book.find_by(title: title)

      end
      raise

    end
  end

  private

  def split_array_text(text)
    # Разделяем текст на секции по разделителям
    sections = text.split(/\*\*Array \d: Titles\*\*|\*\*Array \d: Authors\*\*/).map(&:strip)

    # Обрабатываем секции
    titles_section = sections[1].downcase
    authors_section = sections[2].downcase

    # Преобразуем секции в массивы строк, удаляя пустые строки
    titles = titles_section.to_s.split("\n").reject(&:empty?).map(&:strip)
    authors = authors_section.to_s.split("\n").reject(&:empty?).map(&:strip)

    [titles, authors]
  end

  # Пример входных данных

  # Преобразуем массив в строку


  def get_books(query, author = nil)


    if author.nil?
      url = "https://www.googleapis.com/books/v1/volumes?q=#{query}&key=#{ENV['API_KEY']}&langRestrict=en"
    else
      url = "https://www.googleapis.com/books/v1/volumes?q=#{query}+inauthor:#{author}&key=#{ENV['API_KEY']}&langRestrict=en"
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
