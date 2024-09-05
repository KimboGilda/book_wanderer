class BooksController < ApplicationController
  def index
    if params[:query].present?
      @books = Book.search_by_title_author_and_genre(params[:query])
    else
      @books = Book.all
    end
  end

  def show
    @book = Book.find(params[:id])


    @availability = !UserLibrary.exists?(book_id: params[:id], user_id: current_user.id)

    # Find users who have read the current book
    # pluck is a built in ruby method that shows as more than one value - it's like distinct in SQL
    user_ids = ReadBook.where(book_id: @book.id).pluck(:user_id)
    
    # Find other books that these users have read (NOT includnig the current book)
    @other_books = Book.joins(:read_books)
                       .where(read_books: { user_id: user_ids })
                       .where.not(id: @book.id)
                       .distinct

    @usernames = User.where(id: user_ids) 

  end

  
end
