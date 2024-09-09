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
    @availability = 'library'
    redirect_to book_path(@book), notice: 'Book added to your library.'
  end

  def destroy

    @book = Book.find(params[:id])

    @user_library = UserLibrary.find_by(book_id: params[:id], user_id: current_user.id)
    @user_library.destroy

    @availability = 'available'
    redirect_to user_libraries_path, notice: 'Book removed from your library.'
  end
end
