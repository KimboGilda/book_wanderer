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


books = [
  'the lord of the rings',
  'harry potter',
  'game of thrones',
  'dune',
  'to kill a mockingbird',
  '1984',
  'pride and prejudice',
  'moby dick',
  'the hobbit',
  'the great gatsby',
  'jane eyre',
  'wuthering heights',
  'lolita',
  'the picture of dorian gray',
  'dracula',
  'the hobbit',
  'brave new world',
  'crime and punishment',
  'the catcher in the rye',
  'war and peace',
  'the odyssey',
  'ulysses',
  'the brothers karamazov',
  'anna karenina',
  'fahrenheit 451',
  'frankenstein'
]


all_books = books.flat_map { |book| get_books(book) }
# random_books = all_books.sample(10)


# random_books.each do |data|
all_books.each do |data|
  title = data['volumeInfo']['title']
  author = data['volumeInfo']['authors']&.join(', ')
  summary = data['volumeInfo']['description']
  publication_year = data['volumeInfo']['publishedDate']&.split('-')&.first
  genre = data['volumeInfo']['categories']&.join(', ')
  cover_image_url = data['volumeInfo']['imageLinks']&.dig('thumbnail')
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


end
puts "#{all_books.size} random books added *(change in seeds if you need)"



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


random_read_book = Book.all.sample(5)
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
    read_book_id: read_book.sample.id,
    content: content
  )

end
puts "Reviews added"



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
