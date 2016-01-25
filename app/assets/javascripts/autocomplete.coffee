jQuery ->
   $('#autocomplete').atwho(
     at: "#",
     displayTpl: "<li> ${name} </li>",
     insertTpl: "${name}",
     'data': "/skills.json"
   )