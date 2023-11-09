import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["parent", "child"];

  connect() {
    console.log("print input")

    // // Initialize the state of child checkboxes based on parent checkboxes
    // this.childTargets.forEach(child => {
    //   const parentId = child.dataset.parentId;
    //   child.checked = this.parentTargets[parentId].checked;
    // });
    console.log("print input")

  }

  toggleChildren(event) {
    const parentId = event.target.dataset.parentId;
    const isChecked = event.target.checked;

    // Check/uncheck child checkboxes associated with the clicked parent
    this.childTargets.forEach(child => {
      if (child.dataset.parentId === parentId) {
        child.checked = isChecked;
      }
    });
  }

  toggleParent(event) {
    const parentId = event.target.dataset.parentId;

    // Check the parent checkbox if all child checkboxes are checked
    this.parentTargets[parentId].checked = this.childTargets
      .filter(child => child.dataset.parentId === parentId)
      .every(child => child.checked);
  }
}
