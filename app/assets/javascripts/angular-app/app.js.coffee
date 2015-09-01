#@AdminEmployeesCtrl = ($scope) ->
  #$scope.employees = gon.employees
  #$scope.company = gon.company
#
  #console.log($scope.employees)
  #console.log($scope.company)
#
  #
#@AdminShiftsCtrl = ($scope) ->
  #$scope.shifts = gon.shifts
#
  #console.log($scope.shifts)
  #console.log(gon.employee)
  #
  #
#@AdminTimesheetsCtrl = ($scope) ->
  #$scope.shifts = gon.shifts
  #
  #console.log("AdminTimesheetsCtrl id running....")
  #
  #values = $scope.shifts
#
  #log = []
  #angular.forEach values, ((value, key) ->
    #@push key + ': ' + value
    #return
  #), log
  #
  #
  #
  
  
  
  

app = angular.module('admin', [
  'ngResource'
  'ngRoute'
])
# Some APIs expect a PUT request in the format URL/object/ID
# Here we are creating an 'update' method
app.factory 'Timesheet', [
  '$resource'
  ($resource) ->
    $resource('/timesheets/:id', {id:'@id'}, {update: {method: 'PUT'}})
]
app.factory 'TimesheetList', [
  '$resource'
  ($resource) ->
    $resource('/timesheets', {id:'@id'})
]
app.factory 'Shift', [
  '$resource'
  ($resource) ->
    $resource('/admin/shifts/:id', {id:'@id'}, {update: {method: 'PUT'}})
]
# In our controller we get the ID from the URL using ngRoute and $routeParams
# We pass in $routeParams and our Notes factory along with $scope
app.controller 'AdminTimesheetsCtrl', [
  '$scope'
  'Timesheet'
  ($scope, Timesheet) ->
    # First get a note object from the factory
    $scope.timesheet = Timesheet.get()
    $scope.shifts = gon.shifts
    console.log($scope.timesheet)
    console.log($scope.shifts)
    #$id = timesheet.id
     #Now call update passing in the ID first then the object you are updating
    #Timesheets.update { id: $id }, timesheet
    # This will PUT /notes/ID with the note object in the request payload
    return
]
app.controller 'AdminEmployeesCtrl', [
  '$scope'
  ($scope) ->
    $scope.employees = gon.employees
 #
    console.log($scope.employees)
   #
    return
]

