class UserLibrariesController < ApplicationController
  def index
    @user_libraries = UserLibrary.where(user_id: current_user.id)
    book_ids = @user_libraries.pluck(:book_id) # lists w ids
    @books = Book.where(id: book_ids) # lists w books of current user
  end

  def create
    @book = Book.find(params[:book_id])
    new_book = UserLibrary.create!(
      book_id: params[:book_id],
      user_id: current_user.id
    )
    new_book.save
    @availability = false
    redirect_to book_path(@book), notice: 'Book added to your library.'
  end

  def destroy
    @user_library = UserLibrary.find_by(book_id: params[:book_id], user_id: current_user.id)

    if @user_library
      @user_library.destroy
      redirect_to books_path, notice: 'Book removed from your library.'
    else
      redirect_to books_path, alert: 'Book not found in your library.'
    end

  end
end
