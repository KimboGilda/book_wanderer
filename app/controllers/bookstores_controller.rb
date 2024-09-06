class BookstoresController < ApplicationController
    def index
        @bookstores = Bookstore.geocoded
        # The `geocoded` scope filters only flats with coordinates
        # Build the markers array
        @markers = @bookstores.map do |bookstore|
         {
          name: bookstore.name,
          address: bookstore.address, 
          lat: bookstore.latitude,
          lng: bookstore.longitude
        }
      end
    end
  end
