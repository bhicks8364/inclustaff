jQuery ->
   $('#autocomplete').atwho(
     at: "#",
     displayTpl: "<li> ${name} </li>",
     insertTpl: "${name}",
     'data': "/skills.json"
   )
   $("[data-behavior='autocomplete_skills']").atwho(
     at: "#",
     displayTpl: "<li> ${name} </li>",
     insertTpl: "${name}",
     'data': "/skills.json"
   )