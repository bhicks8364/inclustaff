// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready(function() {
    $('#shifts').dataTable( {
        
        "paging":   true,
        "ordering": true,
        "info":     true,
        "jQueryUI": true,
        
    } );
    
} );

$(document).ready(function() {
    $('.clockpicker').clockpicker({
        placement: 'bottom',
        align: 'right',
        autoclose: true,
        // default: Date.now(),
        donetext: 'Done'
    });
    
    // $( "h3" ).hide( "slow" );

    
    
    
    
    
    
});