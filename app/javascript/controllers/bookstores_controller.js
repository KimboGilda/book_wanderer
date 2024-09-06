import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["map"];
  connect() {
    console.log("Hello from our first Stimulus controller");
  }

  toggle_map(event) {
    if (window.getComputedStyle(this.mapTarget).opacity === "0") {
      this.mapTarget.style.opacity = "1";
      this.mapTarget.style.pointerEvents = "auto";
    } else {
      this.mapTarget.style.opacity = "0";
      this.mapTarget.style.pointerEvents = "none";
    }
  }
}
