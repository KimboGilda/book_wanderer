class BooksController < ApplicationController

  def index
    if params[:query].present?
      @books = Book.search_by_title_author_and_genre(params[:query])
    else
      @books = Book.all
    end
  end
end
