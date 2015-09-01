#nameApp = angular.module('nameApp', [])
#nameApp.controller 'NameCtrl', ($scope) ->
  #$scope.names = [
    #'Larry'
    #'Curly'
    #'Moe'
  #]
#
  #$scope.addName = ->
    #$scope.names.push $scope.enteredName
    #$scope.enteredName = ''
    #return
#
  #return







#console.log(gon.current_shift)



#app = angular.module('clock', [
  #'ngResource'
  #'ngRoute'
#])

#app.factory 'Timesheet', [
  #'$resource'
  #($resource) ->
    #$resource('/timesheets/:id', {id:'@id'}, {update: {method: 'PUT'}})
#]
#app.controller 'ClockCtrl', [
  #'$scope'
  #'Timesheet'
  #($scope, Timesheet) ->
    #$scope.timesheet = Timesheet.get()
    #$scope.shifts = gon.shifts
    #console.log($scope.timesheet)
    #console.log($scope.shifts)

    #return
#]
