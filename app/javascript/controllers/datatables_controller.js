import $ from 'jquery';
import DataTable from 'datatables.net';
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    document.addEventListener('turbo:load', function() {
      const table = $('#dttb');
      // Check if DataTable is not initialized
      if (!$.fn.DataTable.isDataTable('#dttb')) {
        // Initialize DataTable
        table.DataTable({
          language: {
            search: "",
            paging: true,
            searchPlaceholder: "Search...",
            dom: 'rfltip',
            bSort: true
          }
        });
      }
    });
    
    document.addEventListener('turbo:before-render', function() {
      const table = $('#dttb').DataTable();
      // Check if DataTable is initialized
      if ($.fn.DataTable.isDataTable('#dttb')) {
        // Destroy the DataTable instance
        table.destroy();
      }
    });
    
  }}