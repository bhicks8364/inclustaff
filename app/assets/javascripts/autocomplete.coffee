jQuery ->
    console.log(gon.skills)
    $('[data-behavior="autocomplete"]').atwho(
        at: "@",
        'data': "/admins.json"
      )
    $('[data-behavior="skill-autocomplete"]').atwho(
        at: "",
        'data': "/skills.json",
        displayTpl: "<li>${name}</li>",
      )