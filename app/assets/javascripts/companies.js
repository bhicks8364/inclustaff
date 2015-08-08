// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// // # You can use CoffeeScript in this file: http://coffeescript.org/
// $(document).ready(function() {
//     $('#companies-table').dataTable( {
        
//         "paging":   true,
//         "ordering": true,
//         "info":     true,
//         "jQueryUI": true,
        
//     } );
    
// } );

function clearNotice(){
  $(".notice").animate({opacity:'0'}, 1500);
}
// Note that if your using rails 4 with turbolinks, you'll need to call it from a ready function:

$(document).ready(ready);
$(document).on('page:load', ready);

var ready = function() {    
   setTimeout(clearNotice, 1000);  //Flash fade
};