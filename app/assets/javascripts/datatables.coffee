jQuery ->
  $('#timesheets-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "ordering": true,
    "info":     true
    
  $('#jobs-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "order": [[ 0, "desc" ]],
    "info":     true
    console.log("Running")
    