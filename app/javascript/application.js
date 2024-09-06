// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "@popperjs/core";
import "bootstrap";
import BookstoresController from "./controllers/bookstores_controller.js";
Stimulus.register("nearby-bookstores", BookstoresController);
import BookCarouselController from "./controllers/book_carousel_controller.js";
Stimulus.register("book-carousel", BookCarouselController);
import { Turbo } from "@hotwired/turbo-rails";
Turbo.start();
