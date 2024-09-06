class BookstoresController < ApplicationController
    def index
        @bookstores = Bookstore.all
        # The `geocoded` scope filters only flats with coordinates
        @markers = @bookstores.geocoded.map do |bookstore|
          {
            lat: bookstore.latitude,
            lng: bookstore.longitude
          }
        end
      end
end
