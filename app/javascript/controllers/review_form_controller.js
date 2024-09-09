import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="review-form"
export default class extends Controller {
  static targets = ["form", "reviews"];

  connect() {}

  toggle(event) {
    event.preventDefault();
    this.formTarget.classList.toggle("d-none");
  }

  submitEnd(event) {
    event.preventDefault();
    const { success, detail } = event;
    const [data, status, xhr] = detail;

    if (success) {
      this.reviewsTarget.insertAdjacentHTML("beforeend", data.review_html);
      this.hide();
      this.formTarget.reset();
    } else {
      console.error("Review submission failed:", data);
    }
  }

  hide() {
    this.formTarget.classList.add("d-none");
  }
}
