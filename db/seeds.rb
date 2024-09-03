require 'httparty'


puts "Destroying all data"
# Booking.destroy_all
# Review.destroy_all
Book.destroy_all
# User.destroy_all
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


