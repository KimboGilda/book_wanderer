import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="book-carousel"
export default class extends Controller {
  static targets = ["carousel"];

  connect() {
    console.log("Book carousel controller connected");
  }

  fetchRandomBooks(event) {
    event.preventDefault();

    fetch("/random_books", {
      headers: {
        Accept: "application/json"
      }
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.books_html) {
          // Insert the new books into the carousel
          this.carouselTarget.innerHTML = data.books_html;
        } else {
          console.error("Failed to fetch random books.");
        }
      })
      .catch((error) => {
        console.error("Error fetching random books:", error);
      });
  }
}
