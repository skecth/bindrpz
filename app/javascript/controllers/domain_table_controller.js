import { Controller } from "@hotwired/stimulus";
import DataTable from "datatables.net";

export default class extends Controller {
  connect() {
    console.log("hello list Domain");
    document.addEventListener("turbo:load", function () {
      if (!DataTable.isDataTable('#dttb_domain')) {
        let table = new DataTable('#dttb_domain', {
          "iDisplayLength": 100,
          language: {
            searchPlaceholder: "Search"
          },
        });
      }
    });
  }
}
