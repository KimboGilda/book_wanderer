import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl"; // Import Mapbox

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array
  };

  connect() {
    const markers = JSON.parse(this.element.dataset.mapMarkersValue); // Manually parse the data attribute
    console.log(markers);
    console.log("map controller OK");
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10",
      zoom: 12,
      center: [23.733991, 37.981981] // Adjust center based on markers
    });

    this.#addMarkersToMap();
    this.#fitMapToMarkers();
    this.#addFocusButton(); // Add the focus button
  }

  // Function to add markers to the map
  #addMarkersToMap() {
    this.markersValue.forEach((marker, index) => {
      console.log(`Adding marker ${index + 1}:`, marker);

      // Create a custom marker element
      const el = document.createElement("div");
      el.className = "custom-marker";
      el.innerHTML =
        '<i class="fa-solid fa-book" aria-hidden="true" tabindex="-1"></i>';

      // Create the popup with the name and address
      const popup = new mapboxgl.Popup({ offset: 25 }).setHTML(`
        <h3>${marker.name}</h3>
        <p>${marker.address}</p>
        <p style="color: ${marker.availability ? "green" : "red"};">
        ${marker.availability ? "Available" : "Unavailable"}
        </p>
      `);

      // Add the marker and bind the popup to it
      new mapboxgl.Marker(el)
        .setLngLat([marker.lng, marker.lat])
        .setPopup(popup) // Attach the popup to the marker
        .addTo(this.map);
    });
  }

  // Function to refocus the map on all markers
  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();

    // Extend the bounds to include all markers
    this.markersValue.forEach((marker) => {
      bounds.extend([marker.lng, marker.lat]);
    });

    // Fit the map to the markers' bounds
    this.map.fitBounds(bounds, {
      padding: 70,
      maxZoom: 15,
      duration: 1000 // Smooth transition
    });
  }

  // Function to add a custom button to the map for focusing/overviewing
  #addFocusButton() {
    // Create the button element
    const button = document.createElement("button");
    button.innerHTML = "Focus"; // Initial button text
    button.className = "focus-button"; // Add custom class for styling

    let isOverview = false;

    // toggles between focus and overview
    button.onclick = () => {
      if (!isOverview) {
        // Focus on a specific area
        this.map.flyTo({
          center: [23.7351, 37.987],
          zoom: 14,
          speed: 1.5,
          curve: 1
        });

        // Change the button text to "Overview"
        button.innerHTML = "Overview";
      } else {
        this.#fitMapToMarkers();
        button.innerHTML = "Focus";
      }

      // Toggle the state
      isOverview = !isOverview;
    };

    // Create a custom control to add the button to the map container
    const container = document.querySelector(".map-container");
    const buttonContainer = document.createElement("div");
    buttonContainer.className = "focus-button-container";
    buttonContainer.appendChild(button);

    // Append the button to the map container
    container.appendChild(buttonContainer);
  }
}
