import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["map"];
  connect() {
    console.log("Hello from our first Stimulus controller");
  }

  toggle_map(event) {
    if (this.mapTarget.style.display === "none") {
      this.mapTarget.style.display = "block";
    } else {
      this.mapTarget.style.display = "none";
    }
  }
}
