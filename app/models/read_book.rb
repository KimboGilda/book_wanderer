class ReadBook < ApplicationRecord
  
  belongs_to :user
  belongs_to :book
  has_many :reviews, dependent: :destroy
end
