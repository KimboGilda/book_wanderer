require 'httparty'
require 'faker'

puts "Destroying all data"
ReadBook.destroy_all
UserLibrary.destroy_all
Review.destroy_all
Book.destroy_all
User.destroy_all
puts "All data destroyed"

# Function to retrieve books using Google Books API
def get_books(books)
  all_books = []
  start_index = 0

  loop do
    query = books.join('|') # Query multiple books using | as an OR operator
    url = "https://www.googleapis.com/books/v1/volumes?q=#{query}&startIndex=#{start_index}&key=#{ENV['API_KEY']}&langRestrict=en"

    response = HTTParty.get(url)
    if response.success?
      items = response.parsed_response['items']
      break if items.nil? || items.empty?

      all_books += items
      start_index += items.size

      # Stop fetching more books if reaching a limit (e.g., 1000 results)
      break if start_index >= 100
    else
      puts "Error fetching books: #{response.message}"
      break
    end
    sleep(1) # Avoid API rate limiting
  end

  all_books
end

# List of books to retrieve
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

# Retrieve all books
all_books = get_books(books)

# Loop through each book and create entries in the database
all_books.each do |data|
  title = data['volumeInfo']['title']
  author = data['volumeInfo']['authors']&.join(', ')
  summary = data['volumeInfo']['description']
  publication_year = data['volumeInfo']['publishedDate']&.split('-')&.first
  genre = data['volumeInfo']['categories']&.join(', ')
  cover_image_url = data['volumeInfo']['imageLinks']&.dig('thumbnail')

  # Generate random data if missing
  author ||= Faker::Book.author
  genre ||= Faker::Book.genre
  title ||= Faker::Book.title
  summary ||= Faker::Lorem.paragraphs(number: 2).join("\n")
  short_summary = summary

  # Check if the book already exists, if not create a new entry
  unless Book.exists?(title: title, author: author)
    begin
      Book.create!(
        title: title,
        author: author,
        publication_year: publication_year,
        summary: summary,
        short_summary: short_summary,
        genre: genre,
        cover_image_url: cover_image_url
      )
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to save book: #{title}, error: #{e.message}"
    end
  end
end

puts "#{all_books.size} random books added *(change in seeds if you need)"

# Create Users
user_01 = User.create!(email: "mariasarapova@gmail.com", password: "wimbledon13")
user_02 = User.create!(email: "emmagoldman@gmail.com", password: "aa13uk")
user_03 = User.create!(email: "oliviamartin@gmail.com", password: "olivia2024")
user_04 = User.create!(email: "jameson@gmail.com", password: "james23")

users = [user_01, user_02, user_03, user_04]

# Create Read Books
random_read_books = Book.all.sample(5)
random_read_books.each do |data|
  rand(1..10).times do
    ReadBook.create!(
      user_id: users.sample.id,
      book_id: data.id
    )
  end
end
puts "Read books added"

# Create Reviews
content = Faker::Lorem.paragraph
read_books = ReadBook.all

read_books.each do |data|
  Review.create!(
    read_book_id: read_books.sample.id,
    content: content
  )
end
puts "Reviews added"

