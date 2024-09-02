class Review < ApplicationRecord
  
  belongs_to :readbook
  # Validations
  validates :content, presence: true
end
