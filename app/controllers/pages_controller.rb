class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :random_books]

  # Home action for initial page load
  def home
    @books = Book.all

  end


  def generate_book_description(title, author, genre)
    character = Faker::Fantasy::Tolkien.character
    setting = Faker::Fantasy::Tolkien.location
    adjective = Faker::Adjective.positive
    conflict =  Faker::Fantasy::Tolkien.poem

    description = "

        In the #{genre.downcase} novel '#{title}' by #{author}, readers are introduced to #{character}, a #{adjective} individual living in #{setting}.
        As the story unfolds, #{character} faces an unexpected challenge: #{conflict}.
        This gripping tale explores themes of resilience and the human spirit, offering a thought-provoking journey that will stay with readers long after the final page is turned.

    "
    description.strip
  end

  def start_recommendation
    # Trigger the job with the current user's ID
    SeasonJobJob.perform_later
  end
  # Action for fetching random books when clicking the "Random Book" button
  def random_books
    @random_books = Book.order("RANDOM()").limit(6)

    respond_to do |format|
      format.json do
        render json: {
          books_html: render_to_string(partial: "books/book", collection: @random_books, as: :book, formats: [:html])
        }, status: :ok
      end
    end
  end

  # Action for fetching personalized recommendations when clicking the "Our Collection" button
  def our_selection
    if current_user


      @three_recommendations_pro_click = current_user.recommended_books.sample(6)

      # twenty_four_recommendations
      # @three_recommendations_pro_click = @twenty_four_recommendations.sample(6)
    else
      @three_recommendations_pro_click = []
    end

    respond_to do |format|
      format.json do
        render json: {
          books_html: render_to_string(partial: "books/book", collection: @three_recommendations_pro_click, as: :book, formats: [:html])
        }, status: :ok
      end
    end
  end

  def season
    @season_rec = seasons_recomendation

    respond_to do |format|
      format.json do
        render json: {
          books_html: render_to_string(partial: "books/book", collection: @season_rec, as: :book, formats: [:html])
        }, status: :ok
      end
    end
  end

end
end

