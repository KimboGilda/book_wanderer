
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {

  hover() {
    this.element.classList.remove('fa-regular');
    this.element.classList.add('fa-solid');
  }

  unhover() {
    this.element.classList.remove('fa-solid');
    this.element.classList.add('fa-regular');
  }
}



















// document.addEventListener("DOMContentLoaded", function() {
//   const iconLinks = document.querySelectorAll('.icon-wrapper');

//   iconLinks.forEach(link => {
//     const icon = link.querySelector('.icon');

//     link.addEventListener('mouseover', () => {
//       icon.classList.remove('fa-regular');
//       icon.classList.add('fa-solid');
//     });

//     link.addEventListener('mouseout', () => {
//       icon.classList.remove('fa-solid');
//       icon.classList.add('fa-regular');
//     });
//   });
// });
