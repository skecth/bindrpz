import { Controller } from "@hotwired/stimulus";
import DataTable from "datatables.net";

export default class extends Controller {
  connect() {
    console.log("hello data");
    document.addEventListener("turbo:load", function () {
      if (!DataTable.isDataTable('#dttb')) {
        let table = new DataTable('#dttb', {
          // "iDisplayLength": 10, //limit how many entries
          "bPaginate": false, //hide the entries
          "aaSorting": [1, 'asc'],
          language: {
            searchPlaceholder: "Search By"
          },
        });
      }else{
        let newTable=new DataTable('#dttb');
        newTable.destroy();
      }
    });
  }
}
