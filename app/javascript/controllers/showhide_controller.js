import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="showhide"
export default class extends Controller {
  static targets = ["input", "output"]
  static values = { showIf: String } 

  connect() {
    this.toggle()
  }

  toggle() {
    const inputValue = this.inputTarget.value; // 'this.element' refers to the DOM element associated with the controller
    console.log(`Selected Value: ${inputValue}`);
    
    const showIfValues = ['CNAME', 'A', 'AAA']; // Array of values to match against
    
    if (showIfValues.includes(inputValue)) {
      this.outputTarget.hidden = false;
      if (inputValue === 'CNAME') {
        this.outputTarget.placeholder = "Domain";
      } else if (inputValue === 'A') {
        this.outputTarget.placeholder = "IPv4";
      } else if (inputValue === 'AAA') {
        this.outputTarget.placeholder = "IPv6";
      }
    } else {
      this.outputTarget.hidden = true;
      this.outputTarget.value = "";
      console.log("No match");
    }
  }
}
    
  // submitForm(event) {
  //   event.preventDefault(); // Prevent the default form submission

  //   // Perform actions here when the form is submitted
  //  window.alert("Submit cannot submit")

  //   // Optionally, you can access the form data
  //   // Perform actions with formData if needed
  // }
  // checkToggle(event) {
  //   console.log("checkbox click");

  //   const checkbox = event.target;
  //   const showIfValues = ['CNAME']; // Array of values to match against

  //   if (checkbox.checked) {
  //     console.log("checkbox is checked");

  //     const inputValue = this.inputTarget.value;
  //     console.log(inputValue)
  //     if (!showIfValues.includes(inputValue)) {
  //       // Show error or handle validation when the inputValue is not in showIfValues
  //       console.error("Invalid selection!"); // Log an error message
  //       // You can add logic to display an error message to the user
  //     }
  //   }
