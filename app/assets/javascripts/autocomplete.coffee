jQuery ->
    console.log('autocomplete')
    $('[data-behavior="autocomplete"]').atwho(
        at: "@",
        'data': "/admins.json"
      )