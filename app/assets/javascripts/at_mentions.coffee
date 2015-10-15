jQuery ->
  $('[data-behavior="autocomplete_users"]').atwho(
    at: "@",
    'data': "/users.json"
  )
  $('[data-behavior="autocomplete_skills"]').atwho(
    at: "#",
    'data': "/skills.json"
  )