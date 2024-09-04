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
  end

  
end
