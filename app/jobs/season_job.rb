class SeasonJob < ApplicationJob
  queue_as :default

  def perform
   # Create text body for request
    @text = "Please provide two arrays:
            Array 1: Titles — this array should contain 10 famous or classic book titles that are influenced by vibes of the current season.
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
      first_summary = earliest_book['volumeInfo']['description']
      genre = earliest_book['volumeInfo']['categories']&.join(', ') || Faker::Book.genre
      if first_summary.nil? || first_summary.length < 50
        first_summary =  generate_book_description(title, author, genre)
      end
      summary = first_summary.truncate(500, separator: ' ', omission: '...')
      publication_year = earliest_book['volumeInfo'].dig('publishedDate')&.split('-')&.first

      cover_image_url = earliest_book['volumeInfo']['imageLinks']&.dig('thumbnail')
      if cover_image_url

         # Create only if not already exists
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
        else
          book = Book.find_by(title: book_title, author: book_author)
        end
        unless Season.exists?(book: book)
          Season.create(
            book: book
          )
        end
    end
  end

end


private
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
  def generate_book_description(title, author, genre)
    character = Faker::Fantasy::Tolkien.character
    setting = Faker::Fantasy::Tolkien.location
    adjective = Faker::Adjective.positive
    conflict =  Faker::Fantasy::Tolkien.poem

    description = "

        In the #{genre.downcase} novel '#{title}' by #{author}, readers are introduced to #{character}, a #{adjective} individual living in #{setting}.
        As the story unfolds, #{character} faces an unexpected challenge: #{conflict}.
        This gripping tale explores themes of resilience and the human spirit, offering a thought-provoking journey that will stay with readers long after the final page is turned.

    "
    description.strip
  end
end
