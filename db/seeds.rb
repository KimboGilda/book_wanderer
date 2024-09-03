puts "Destroying all data"
UserLibrary.destroy_all
Review.destroy_all
Book.destroy_all
ReadBook.destroy_all
User.destroy_all
puts "All data destroyed"


    # USER /-
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

# BOOK /-----------------------------------------------------------------------------------------------------------------------------------------------------------

book_01 = Book.create!(
  title: 'The Hobbit',
  genre: 'Fantasy',
  author: 'John Ronald Reuel Tolkien',
  cover_image_url: "https://covers.openlibrary.org/b/isbn/9788595086081-M.jpg",
  summary: "The Hobbit is set in Middle-earth and follows home-loving Bilbo Baggins, the hobbit of the title, who joins the wizard Gandalf and the thirteen dwarves of Thorin's Company, on a quest to reclaim the dwarves' home and treasure from the dragon Smaug.",
  short_summary: "The Hobbit is set in Middle-earth",
  publication_year: "1937",
)

book_02 = Book.create!(
  title: 'The Master and Margarita',
  genre: 'Fantasy',
  author: 'M.Bulgakov',
  cover_image_url: "https://covers.openlibrary.org/b/isbn/9781440674082-M.jpg",
  summary: "One hot spring, the devil arrives in Moscow, accompanied by a retinue that includes a beautiful naked witch and an immense talking black cat with a fondness for chess and vodka. The visitors quickly wreak havoc in a city that refuses to believe in either God or Satan.",
  short_summary: "One hot spring",
  publication_year: "1967"

)

book_03 = Book.create!(
  title: 'The Impossible',
  genre: 'Action',
  author: 'Erri De Luca',
  cover_image_url: "https://media.s-bol.com/BNVKyBw5lqGN/550x830.jpg",
  summary: "One morning, high in the Dolomite mountains, two hikers are some distance apart. The path in places is narrow and perilous. One man falls to his death. The other sounds the alarm. But these men are not strangers. Members of the same revolutionary group forty years earlier, the first had betrayed the second, who must now hold his own against a young magistrate intent upon having him tried for murder.Was their meeting an improbable encounter, or an impossible coincidence?",
  short_summary: "One morning, high in the Dolomite mountains",
  publication_year: "2021"
)

# USERLIBRARIES /
user_library_01 = UserLibrary.create!(
  user: user_02,
  book: book_01
)
user_library_02 = UserLibrary.create!(
  user: user_03,
  book: book_02
)
user_library_03 = UserLibrary.create!(
  user: user_04,
  book: book_03
)


# REVIEWS /------------------------------------------------------------------------------

readbook_01 = ReadBook.create!(
  book: book_02,
  user: user_03,
)

readbook_02 = ReadBook.create!(
  book: book_03,
  user: user_04,
)

readbook_03 = ReadBook.create!(
  book: book_01,
  user: user_02,
)

review_01 = Review.create!(
  read_book: readbook_01,
  content: 'Some books are almost impossible to review. If a book is bad, how easily can we dwell on its flaws! But if the book is good, how do you give any recommendation that is equal the book? Unless you are an author of equal worth to the one whose work you review, what powers of prose and observation are you likely to have to fitly adorn the work?'
)

review_02 = Review.create!(
  read_book: readbook_02,
  content: 'This book?
Precious.'
)

review_03 = Review.create!(
  read_book: readbook_03,
  content: 'JUST AMAZING! FUN AND BEAUTIFUL ADVENTURE!
I HAD TO READ THE END AGAIN BECAUSE OF MY LOVE
how they made three films out of this impresses me!'
)
