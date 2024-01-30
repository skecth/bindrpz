import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["parent", "child"];

  connect() {
    // set all to false on page refresh
    this.childTargets.map(x => x.checked = false)
    this.parentTarget.checked = false
    console.log("ini checkbox all.")
  }

  toggleChildren() {
    if (this.parentTarget.checked) {
      this.childTargets.forEach(child => {
        child.checked = true;
      });
    } else {
      this.childTargets.forEach(child => {
        child.checked = false;
      });
    }
  }
  
  toggleParent() {
    if (this.childTargets.some(child => !child.checked)) {
      this.parentTarget.checked = false;
    } else {
      this.parentTarget.checked = true;
    }
  }
  
}
