// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready(function() {
    
    $( ".active-jobs" ).draggable({
        addClasses: false
    });
    
    $( "#sortable" ).sortable({
      revert: true
    });
    $( "#draggable" ).draggable({
      connectToSortable: "#sortable",
      helper: "clone",
      revert: "invalid"
    });
    $( "ul, li" ).disableSelection();

  
  
    
    $('#employees').dataTable( {
        
        "paging":   true,
        "ordering": true,
        "info":     true,
        "jQueryUI": true,
        
    } );
    
} );