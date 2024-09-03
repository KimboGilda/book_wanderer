class Book < ApplicationRecord
  # Associations
  has_many :read_books, dependent: :destroy
  has_many :users, through: :read_books, source: :user, as: :user_read_books
  has_many :user_libraries, dependent: :destroy
  has_many :users, through: :user_libraries, source: :user, as: :user_owned_books
  has_many :reviews, through: :read_books
  has_many :bookstore_books, dependent: :destroy
  has_many :bookstores, through: :bookstore_books

  # Validations
  validates :title, :author, presence: true
end
