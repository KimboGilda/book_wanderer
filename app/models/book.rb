class Book < ApplicationRecord
  # Associations
  has_many :read_books, dependent: :destroy
  has_many :users, through: :read_books, source: :user, as: :user_read_books
  has_many :user_libraries, dependent: :destroy
  has_many :users, through: :user_libraries, source: :user, as: :user_owned_books
  has_many :reviews, through: :read_books
  has_many :bookstore_books, dependent: :destroy
  has_many :bookstores, through: :bookstore_books
  has_many :recommendations, dependent: :destroy
  has_many :recommended_users, through: :recommendations, source: :user


  validates :title, :author, :genre, presence: true
  include PgSearch::Model

  pg_search_scope :search_by_title_author_and_genre,
  against: [ :title, :author, :genre, :summary ],
  using: {
    tsearch: { prefix: true }
  }
end
