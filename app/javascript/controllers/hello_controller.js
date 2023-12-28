import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("hello toast ");
    // hide the toast after 3 seconds
    setTimeout(function() {
      $('.toast').toast('hide');
    }, 3000);
    
  }
}
