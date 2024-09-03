class Bookstore < ApplicationRecord
  # Associations
  has_many :bookstore_books, dependent: :destroy
  has_many :books, through: :bookstore_books

  # Validations
  validates :name, :address, presence: true
end
