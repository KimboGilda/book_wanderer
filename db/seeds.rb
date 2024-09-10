require 'httparty'
require 'faker'

puts "Destroying all data"
ReadBook.destroy_all
UserLibrary.destroy_all
Review.destroy_all
Book.destroy_all
User.destroy_all
Bookstore.destroy_all
puts "All data destroyed"

require 'httparty'
require 'faker'

require 'httparty'
require 'faker'
require 'uri'

def get_books(query, author = nil)
  if author.nil?
    url = "https://www.googleapis.com/books/v1/volumes?q=#{query}&key=#{ENV['API_KEY']}&langRestrict=en"
  else
    url = "https://www.googleapis.com/books/v1/volumes?q=#{query}+inauthor:#{author}&key=#{ENV['API_KEY']}&langRestrict=en"
  end
  response = HTTParty.get(url)
  response.success? ? response.parsed_response['items'] || [] : []
end
books_and_authors = [
  { title: 'the lord of the rings', author: 'tolkien' },
  { title: 'harry potter', author: 'rowling' },
  { title: 'game of thrones', author: 'martin' },
  { title: 'dune', author: 'herbert' },
  { title: 'to kill a mockingbird', author: 'lee' },
  { title: '1984', author: 'orwell' },
  { title: 'pride and prejudice', author: 'austen' },
  { title: 'moby dick', author: 'melville' },
  { title: 'the hobbit', author: 'tolkien' },
  { title: 'the great gatsby', author: 'fitzgerald' },
  { title: 'jane eyre', author: 'bronte' },
  { title: 'wuthering heights', author: 'bronte' },
  { title: 'lolita', author: 'nabokov' },
  { title: 'the picture of dorian gray', author: 'wilde' },
  { title: 'dracula', author: 'stoker' },
  { title: 'brave new world', author: 'huxley' },
  { title: 'crime and punishment', author: 'dostoevsky' },
  { title: 'the catcher in the rye', author: 'salinger' },
  { title: 'war and peace', author: 'tolstoy' },
  { title: 'the odyssey', author: 'homer' },
  { title: 'ulysses', author: 'joyce' },
  { title: 'the brothers karamazov', author: 'dostoevsky' },
  { title: 'anna karenina', author: 'tolstoy' },
  { title: 'fahrenheit 451', author: 'bradbury' },
  { title: 'frankenstein', author: 'shelley' }
]


def generate_book_summary(text)
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
    @recommendations = result["candidates"].first.dig("content", "parts", 0, "text")
    return @recommendations
  else
    @recommendations = "Error: #{response.code}"
    return nil
  end
end
def generate_book_description(title, author, genre)
  character = Faker::Fantasy::Tolkien.character
  setting = Faker::Fantasy::Tolkien.location
  conflict = Faker::Fantasy::Tolkien.poem
  adjective = Faker::Adjective.positive

  description = "
    In the #{genre.downcase} novel '#{title}' by #{author}, readers are introduced to #{character}, a #{adjective} individual living in #{setting}.
    As the story unfolds, #{character} faces an unexpected challenge: #{conflict}.
    This gripping tale explores themes of resilience and the human spirit, offering a thought-provoking journey that will stay with readers long after the final page is turned."
  # puts description
  description.strip

end

books_and_authors.each do |entry|
  book_title = entry[:title]
  author_name = entry[:author]

  puts "Searching for Book: #{book_title}, Author: #{author_name}"

  search_results = get_books(book_title, author_name)

  # most earlier book
  earliest_book = search_results.min_by do |book|
    published_date = book['volumeInfo'].dig('publishedDate')
    published_year = published_date&.split('-')&.first.to_i || Float::INFINITY
  end

  next if earliest_book.nil?

  title = earliest_book['volumeInfo']['title'] || Faker::Book.title
  author = earliest_book['volumeInfo']['authors']&.join(', ') || Faker::Book.author
  genre = earliest_book['volumeInfo']['categories']&.join(', ') || Faker::Book.genre
  first_summary = earliest_book['volumeInfo']['description']
  if first_summary.nil? || first_summary.length < 50
    first_summary =  generate_book_description(title, author, genre)
  end
  summary = first_summary.truncate(500, separator: ' ', omission: '...')

  # @text = "Write a description of this #{title} book. This description must be 2 or 3 sentences long?"
  # summary = generate_book_summary(@text)
  # puts "Generating summary for #{title}"


  publication_year = earliest_book['volumeInfo'].dig('publishedDate')&.split('-')&.first

  cover_image_url = earliest_book['volumeInfo']['imageLinks']&.dig('thumbnail')
  short_summary = summary

  if cover_image_url
    unless Book.exists?(title: title, author: author)
      Book.create!(
        title: title,
        author: author,
        publication_year: publication_year,
        summary: summary,
        short_summary: short_summary,
        genre: genre,
        cover_image_url: cover_image_url
      )
    end
  end
end
puts "#{Book.all.size} random books processed (added only the earliest for each search)"



# USER
# ------------------------------------------------



user_01 = User.create!(
  email: "mariasarapova@gmail.com",
  password: "wimbledon13"
)

user_02 = User.create!(
  email: "emmagoldman@gmail.com",
  password: "aa13uk"
)

user_03 = User.create!(
  email: "oliviamartin@gmail.com",
  password: "olivia2024"
)

user_04 = User.create!(
  email: "jameson@gmail.com",
  password: "james23"
)



users = [user_01, user_02, user_03, user_04]


# READ BOOKS


random_read_book = Book.all.sample(10)
random_read_book.each do |data|
  rand(1..10).times do
    ReadBook.create!(
      user_id: users.sample.id,
      book_id: data.id
    )

  end
end
puts "Read books added"



# REVIEWS   -----------------------------------------------------

content = Faker::Lorem.paragraph
read_book = ReadBook.all

read_book.each do |data|
  Review.create!(
    read_book_id: data.id,
    content: content
  )
  temp = Book.find_by(id: data.book_id)
  puts "Reviews for #{temp.title} added"
rescue => e
  puts "Error: #{e.message}"
end



# USER LIBRARY ------------------------------------------
#
random_book_in_library = Book.all.sample(5)
random_book_in_library.each do |data|
  rand(1..10).times do
    UserLibrary.create!(
      user_id: users.sample.id,
      book_id: data.id
    )
  end
end
puts "Book to USER LIBRARY added"


# Bookstores --------------------------------------
bookstore1 = Bookstore.create!(address: "Asklipiou 1-3, Athina 106 79, Greece", name: "Politeia")
bookstore2 = Bookstore.create!(address: "Gravias 3, Athina 106 78, Greece", name: "Protoporia")
bookstore3 = Bookstore.create!(address: "Akadimias 65, Athina 106 78, Greece", name: "Patakis")



puts 'End for now, mb some changes later'
