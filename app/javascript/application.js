// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"
import "chartkick/chart.js"

//= require jquery3
//= require jquery_ujs
//= require_tree .
//= require turbolinks
//= require jquery
//= require datatables


setTimeout(function() {
  $('.toast').fadeOut('slow');
}, 5000);
