jQuery ->
  $('[data-behavior="autocomplete_users"]').atwho(
    at: "@",
    'data': "/users.json"
  )
  $('[data-behavior="autocomplete_skills"]').atwho(
    at: "#",
    'data': "/skills.json"
  )
  $('[data-behavior="autocomplete_order_notes"]').atwho(
    at: "#",
    'data': "admin/skills.json"
  )