class ReviewsController < ApplicationController
    before_action :set_book, :set_read_book
  
    def create
      # Create a review associated with the current read_book
      @review = @read_book.reviews.new(review_params)
  
      respond_to do |format|
        if @review.save
          format.html { redirect_to @book, notice: 'Review was successfully created.' }
          format.json {
            render json: {
              review_html: render_to_string(partial: "reviews/review", locals: { review: @review }, formats: [:html])
            }, status: :created
          }
        else
          format.html { render :new }
          format.json { render json: @review.errors, status: :unprocessable_entity }
        end
      end
    end
  
    private
  
    def set_book
      @book = Book.find(params[:book_id])
    end
  
    def set_read_book
      # Ensure that a read_book entry exists for the current user and the given book
      @read_book = ReadBook.find_or_create_by(user: current_user, book: @book)
    end
  
    def review_params
      params.require(:review).permit(:content)
    end
  end
  