jQuery ->
  $('#timesheets-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "scrollY": 400,
    "ordering": true,
    "order": [[ 0, "desc" ]],
    "info":     true
  $('#employees-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   false,
    "scrollY": 400,
    "ordering": true,
    "order": [[ 1, "desc" ]],
    "info":     true
    
  $('#jobs-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "scrollY": 400,
    "order": [[ 0, "desc" ]],
    "info":     true
    console.log("Jobs datatable running")
    
  $('#orders-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    #"scrollY": 400,
    #"order": [[ 1, "asc" ]],
    "info":     true
    console.log("Orders datatable running")
    
  $('#orders-datatable2').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    
    "order": [[ 8, "asc" ]],
    "info":     true

    console.log("Orders2 datatable running")
  
  $('#users-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "order": [[ 1, "asc" ]],
    "info":     true
    console.log("Users datatable running")
  $('#shifts-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "scrollY": 400,
    "order": [[ 1, "asc" ]],
    "info":     true
    console.log("Shifts datatable running")
  $('#admins-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "order": [[ 1, "asc" ]],
    "info":     true
    console.log("Admins datatable running")
  $('#emp-skills-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "order": [[ 1, "asc" ]],
    "info":     true
    console.log("EmpSkills datatable running") 
  $('#skills-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "order": [[ 1, "asc" ]],
    "info":     true
    console.log("Skills datatable running")
  $('#work-datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "order": [[ 1, "asc" ]],
    "info":     true
    console.log("Work History datatable running")
  $('.datatable').dataTable
    sPaginationType: "full_numbers",
    "paging":   true,
    "order": [[ 1, "asc" ]],
    "info":     true
    console.log("Generic datatable running")