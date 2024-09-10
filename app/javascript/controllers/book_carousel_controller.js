import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="book-carousel"
export default class extends Controller {
  static targets = ["carousel"];

  connect() {
    console.log("Book carousel controller connected");
  }

  // Fetch random books on "Random Book" button click
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
          this.carouselTarget.innerHTML = data.books_html;
        } else {
          console.error("Failed to fetch random books.");
        }
      })
      .catch((error) => {
        console.error("Error fetching random books:", error);
      });
  }

  // Fetch personalized recommendations on "Our Collection" button click
  fetchOurSelectionBooks(event) {
    event.preventDefault();

    fetch("/our_selection", {
      headers: {
        Accept: "application/json"
      }
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        if (data.books_html) {
          this.carouselTarget.innerHTML = data.books_html;
        } else {
          console.error("Failed to fetch our collection.");
        }
      })
      .catch((error) => {
        console.error("Error fetching our collection:", error);
      });
  }

  // Seasonal recommendation on "Season" btn click
  fetchSeasonBooks(event) {
    event.preventDefault();

    fetch("/season", {
      headers: {
        Accept: "application/json"
      }
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.books_html) {
          this.carouselTarget.innerHTML = data.books_html;
        } else {
          console.error("Failed to fetch season recommendation.");
        }
      })
      .catch((error) => {
        console.error("Error fetching  season recommendation:", error);
      });
  }


}
