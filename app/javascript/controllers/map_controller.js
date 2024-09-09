import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl"; // Don't forget this!

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
  }

  #addMarkersToMap() {
    this.markersValue.forEach((marker, index) => {
      console.log(`Adding marker ${index + 1}:`, marker); // Debugging line to ensure all markers are added

      // Create a custom marker element
      const el = document.createElement("div");
      el.className = "custom-marker";
      el.innerHTML =
        '<i class="fa-solid fa-book" aria-hidden="true" tabindex="-1"></i>';

      // Create the popup with the name and address
      const popup = new mapboxgl.Popup({ offset: 25 }).setHTML(`
        <h3>${marker.name}</h3>
        <p>${marker.address}</p>
      `);

      // Add the marker and bind the popup to it
      new mapboxgl.Marker(el)
        .setLngLat([marker.lng, marker.lat])
        .setPopup(popup) // Attach the popup to the marker
        .addTo(this.map);
    });
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    this.markersValue.forEach((marker) => {
      bounds.extend([marker.lng, marker.lat]);
    });

    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 });
  }
}
