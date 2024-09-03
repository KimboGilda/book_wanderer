require 'httparty'
require 'faker'

puts "Destroying all data"
# Booking.destroy_all
# Review.destroy_all
Book.destroy_all
User.destroy_all
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
  'the hobbit'
]


all_books = books.flat_map { |book| get_books(book) }
random_books = all_books.sample(10)


random_books.each do |data|
  title = data['volumeInfo']['title']
  author = data['volumeInfo']['authors']&.join(', ')
  summary = data['volumeInfo']['description']
  publication_year = data['volumeInfo']['publishedDate']&.split('-')&.first
  genre = data['volumeInfo']['categories']&.join(', ')
  cover_image_url = data['volumeInfo']['imageLinks']&.dig('thumbnail')
  short_summary = summary
  Book.create!(title: title, author: author, publication_year: publication_year, summary: summary, short_summary: short_summary, genre: genre, cover_image_url:cover_image_url)
  # if title && author
  #   Book.create(title: title, author: author, publication_year: publication_year, summary: summary, short_summary: short_summary, genre: genre, cover_image_url:cover_image_url)
  # end
end
puts "#{random_books.size} random books added"



# USER
# ------------------------------------------------



user_01 = User.create!(
  email: "mariasarapova@gmail.com",
  password: "wimbledon13",
  first_name: 'Maria',
  last_name: "Sarapova",
  profile_picture: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQF1OLdIQ262byvZOwohTsqrBedYYMrwunw7BPelkg3X4-BM7ZW"
)

user_02 = User.create!(
  email: "emmagoldman@gmail.com",
  password: "aa13uk",
  first_name: 'Emma',
  last_name: "Goldman",
  profile_picture: "https://encrypted-tbn2.gstatic.com/licensed-image?q=tbn:ANd9GcR-YjPx0YjDeF6-MEyDHOSr8ZQuhGQaHCdTxy1JXdoxP0W2Pg-BiXotcwC5QPdt_bWowPugRGHjo7MYshY4bs6irlM-WHoXdTIE4_T4sZPhzegThYeKNE6sQka_1dTkWP4MqFCpR5P8"
)

user_03 = User.create!(
  email: "oliviamartin@gmail.com",
  password: "olivia2024",
  first_name: 'Olivia',
  last_name: "Martin",
  profile_picture: "https://cdn.canvasrebel.com/wp-content/uploads/2023/07/c-PersonalOliviaMartin__IMG2706_1688392668767.jpeg"
)

user_04 = User.create!(
  email: "jameson@gmail.com",
  password: "james23",
  first_name: 'James',
  last_name: "On",
)


users = [user_01, user_02, user_03, user_04]
# READ BOOKS


random_read_book = all_books.sample(5)
random_read_book.each do |data|

  ReadBook.create!(user_id: )
  # if title && author
  #   Book.create(title: title, author: author, publication_year: publication_year, summary: summary, short_summary: short_summary, genre: genre, cover_image_url:cover_image_url)
  # end
end
puts "#{random_books.size} random books added"
