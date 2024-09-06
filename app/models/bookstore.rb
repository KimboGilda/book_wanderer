class Bookstore < ApplicationRecord
  # Associations
  has_many :bookstore_books, dependent: :destroy
  has_many :books, through: :bookstore_books

  # Validations
  validates :name, :address, presence: true

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
