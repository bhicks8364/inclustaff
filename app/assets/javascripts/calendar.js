$(document).ready(function() {

    // page is now ready, initialize the calendar...

    $('#calendar').fullCalendar({
        eventSources: [

            // your event source
            {
                url: '/admin/shifts.json', // use the `url` property
                color: 'yellow',    // an option!
                textColor: 'black'  // an option!
            }
    
            // any other sources...

        ]
        
        

        
        // put your options and callbacks here
    })


});