jQuery ->

  $('.myatwho').atwho(
    at: '@'
    displayTpl: '<li>${name}  <small> ${content}</small></li>'
    data: gon.admins_display).atwho(
    at: '#'
    displayTpl: '<li>${name}  <small>${company} (${content})</small></li>'
    insertTpl: '${name}'
    data: gon.company_admins_display).atwho
    at: ':'
    dispayTpl: '<li> ${name} </li>'
    insertTpl: '${name}'
    data: gon.users