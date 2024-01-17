import $ from 'jquery';
import DataTable from 'datatables.net';
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {    
    // const id = this.element.dataset.id;
    document.addEventListener('turbo:load', function() {
      const table = $('#details_feed');
      const id = table.data('id'); 
      // Check if DataTable is not initialized
      if (!$.fn.DataTable.isDataTable('#details_feed')) {
        // Initialize DataTable
        table.DataTable({
          language: {
            search: "",
            searchPlaceholder: "Search Domain",
            info: "",
            infoFiltered: "",
            infoEmpty: "",
            zeroRecords: "No blacklist found",
          },
          ajax: {
            url: `/feeds/${id}.json`,
            dataSrc: '',
          },
          columns: [
            { data: 'data' },
          ],          
        });
    
        // Log the ajax response
        table.on('xhr.dt', function (e, settings, json, xhr) {
          console.log(json);
        });
      }
    });
    
    document.addEventListener('turbo:before-render', function() {
      const table = $('#details_feed').DataTable();
      // Check if DataTable is initialized
      if ($.fn.DataTable.isDataTable('#details_feed')) {
        // Destroy the DataTable instance
        table.destroy();
      }
    });
  }
}
