console.log(gon.admins)
jQuery ->
  # $('.myatwho').atwho(
  #   at: "@",
  #   displayTpl: "<li> ${name} </li>",
  #   insertTpl: ":${name}:",
  #   'data': "/company_admins.json"
  # )
  $('.myatwho').atwho(
    at: '@'
    data: '/company_admins.json').atwho(
    at: '#'
    displayTpl: '<li>${name}  <small>${content}</small></li>'
    data: '/company_admins.json').atwho
    at: ':'
    dispayTpl: '<li> ${name} </li>'
    insertTpl: '${name}'
    data: '/admins.json'