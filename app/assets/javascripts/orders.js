// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready(function() {
    $('#orders').dataTable( {
        
        "paging":   true,
        "ordering": true,
        "info":     true,
        "jQueryUI": true,
        
    } );
    
//     $('#myTabs a').click(function (e) {
//         e.preventDefault()
//     $(this).tab('show')
// })
    
    
} );
