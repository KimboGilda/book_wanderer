class Review < ApplicationRecord
  
  belongs_to :read_book
  # Validations
  validates :content, presence: true
end
