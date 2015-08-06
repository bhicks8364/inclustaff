// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready(function() {
    $( "#datepicker" ).datepicker({
        dateFormat: "yy-mm-dd",
        altField: "#alternate",
        altFormat: " DD,   MM d, yy"
    });
    
    
    
    
    $('#jobs').dataTable( {
        
        "paging":   true,
        "ordering": true,
        "info":     true,
        "jQueryUI": true,
        
    } );


    $( "#accordion" ).accordion();


    

} );


// $(document).ready(function() {

//     $('#job_start_date').datepicker({
//         minDate: 0, 
//         maxDate: "+1M +10D", 
//         dateFormat: "yy-mm-dd"
        
//     });
//     $('#job_end_date').datepicker({
//         minDate: 0, 
//         maxDate: "+1M +10D", 
//         dateFormat: "yy-mm-dd"
        
//     });
    
//     $('#order_needed_by').datepicker({
//         minDate: 0, 
//         maxDate: "+1M +10D", 
//         dateFormat: "yy-mm-dd"
        
//     });
    
    
    
        
        
        
        
        
        
        

// });