import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox-select-parent"
export default class extends Controller {
  static targets = ["parent", "child"]
  connect() {
    // set all to false on page refresh
    console.log("test baru-1")
    this.childTargets.map(x => x.checked = false)
    this.parentTarget.checked = false
    console.log("test baru-2")

  }

  toggleChildren() {
    console.log("tetsing toggle childeren")
    if (this.parentTarget.checked) {
      console.log("parent check");
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
    console.log("tetsing toggle childeren")

    if (this.childTargets.map(x => x.checked).includes(false)) {
      this.parentTarget.checked = false
    } else {
      this.parentTarget.checked = true
    }
  }
}