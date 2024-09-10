class ReadBooksController < ApplicationController
  def index
    @read = ReadBook.where(user_id: current_user.id)
    book_ids = @read.pluck(:book_id) # lists w ids
    @books = Book.where(id: book_ids) # lists w books of current user
  end

  def create
    @book = Book.find(params[:book_id])
    new_read_book = ReadBook.create!(
      book_id: params[:book_id],
      user_id: current_user.id
    )
    new_read_book.save
    @user_library = UserLibrary.find_by(book_id: params[:book_id], user_id: current_user.id)
    @user_library.destroy if @user_library
    RecommendationJob.perform_later(current_user.id)
    @availability = 'read'
    redirect_to book_path(@book), notice: 'Book added to your read books. Please leave a review 📖🤗'
  # user_libraries_path
  end

  def destroy

    @book = Book.find(params[:id])

    @read_books = ReadBook.find_by(book_id: params[:id], user_id: current_user.id)
    @read_books.destroy

    @availability = 'available'
    redirect_to read_books_path, notice: 'Book removed from your library.'
  end
end
