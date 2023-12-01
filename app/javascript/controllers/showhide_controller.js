import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="showhide"
export default class extends Controller {
  static targets = ["input", "output"]
  static values = { showIf: String } //PASSTHRU

  connect() {
    this.toggle()
  }

  toggle() {
    const inputValue = this.inputTarget.value;
    const showIfValues = ['CNAME']; // Array of values to match against
  
    if (showIfValues.includes(inputValue)) {
      this.outputTarget.hidden = false;
    } else {
      this.outputTarget.hidden = true;
      this.outputTarget.value = "";
    }
  }
  
}