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

  def seasons_recomendation
    # Create text body for request
    @text = "Please provide two arrays:
      Array 1: Titles — this array should contain 10 famous or classic book titles that are influenced by the current season.
      Array 2: Authors — this array should contain only the last names of the authors of the books from the first array. Respond like **Array 1: Titles**.....**Array 2: Authors** and all titles and last names should be in English."

      # Call AI to generate recommendations
      @random_rec = generate_book_recommendations(@text)

      if @random_rec
        books_array = @random_rec.split("\n").map { |book| book.gsub(/(^\d+\.\s*|-)*/, '') }
        text = books_array.join("\n")
        titles, authors = split_array_text(text)
      else
        @results = "No recommendations available."
        return []
      end

        # Initialize carousel array
      @books_for_carousel = []

        # Combine titles and authors into pairs
      books_and_authors = titles.zip(authors)

        # Process each title-author pair
      books_and_authors.each do |title, author|
        search_results = get_books(title, author)

          # Find the earliest book (considering missing publication dates)
        earliest_book = search_results.min_by do |book|
          published_date = book['volumeInfo'].dig('publishedDate')
          published_year = published_date&.split('-')&.first.to_i || Float::INFINITY
        end

        next if earliest_book.nil? # Skip if no valid book is found

          # Extract book information
        book_title = earliest_book['volumeInfo']['title'] || title
        book_author = earliest_book['volumeInfo']['authors']&.join(', ') || author
        first_summary = earliest_book['volumeInfo']['description']
        genre = earliest_book['volumeInfo']['categories']&.join(', ') || Faker::Book.genre
        if first_summary.nil? || first_summary.length < 50
          first_summary =  generate_book_description(title, author, genre)
        end
        summary = first_summary.truncate(500, separator: ' ', omission: '...')
        publication_year = earliest_book['volumeInfo'].dig('publishedDate')&.split('-')&.first

        cover_image_url = earliest_book['volumeInfo']['imageLinks']&.dig('thumbnail')
        if cover_image_url

            # Create only if not already exists
          unless Book.exists?(title: book_title, author: book_author)
            book = Book.create!(
              title: book_title,
              author: book_author,
              publication_year: publication_year,
              summary: summary,
              short_summary: summary,
              genre: genre,
              cover_image_url: cover_image_url
            )
              # Add to the carousel array

            @books_for_carousel << book
          else
            book = Book.find_by(title: book_title, author: book_author)
            @books_for_carousel << book
          end
        end
      end
    # Return the array of book objects
    @books_for_carousel
  end


end
