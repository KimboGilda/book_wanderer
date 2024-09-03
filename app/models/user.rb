class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :read_books, dependent: :destroy
  has_many :books, through: :user_libraries, as: :owned_books
  has_many :books, through: :read_books, as: :books_read
  has_many :reviews, through: :read_books
  has_many :user_libraries, dependent: :destroy
end
