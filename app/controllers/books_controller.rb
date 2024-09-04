class BooksController < ApplicationController
  def index
    # @book = Book.find(params[:id])
    # if UserLibrary.exists?(book_id: params[:id], user_id: current_user.id) || ReadBook.exists?(book_id: params[:id], user_id: current_user.id)
    #   @availability = false
    # else
    #   @availability = true
    # end
    if params[:query].present?
      @books = Book.search_by_title_author_and_genre(params[:query])
    else
      @books = Book.all
    end
  end

  def show
    @book = Book.find(params[:id])
    if UserLibrary.exists?(book_id: params[:id], user_id: current_user.id) || ReadBook.exists?(book_id: params[:id], user_id: current_user.id)
      @availability = false
    else
      @availability = true
    end
  end
end
