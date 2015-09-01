#app = angular.module('home', []).controller 'HomeCtrl', [
  #'$scope'
  #($scope) ->
    #$scope.entries = [
      #{name: "Britt"}
      #{name: "Hanna"}
      #{name: "Hicks"}
    #]
    #$scope.addEntry = ->
      #$scope.entries.push($scope.newEntry)
      #$scope.newEntry = {}
  #]
#home = angular.module('home', ["ngResource"])
#home.controller 'HomeCtrl', 
#($scope, $resource) ->
  #Shift = $resource('/shifts.json', {shiftId:'@id'});
  #$scope.shifts = Shift.query()
  #
  #console.log($scope.shifts)
  #
    
  #$scope.addPhone = ->
    #$scope.phones.push($scope.newPhone)
    #$scope.newPhone = {}
    

#angular.module('shifts', [ 'restangular' ])
#.config (RestangularProvider) ->
  #set the base url for api calls on our RESTful services
  #newBaseUrl = ''
  #if window.location.hostname == 'localhost'
    #newBaseUrl = 'http://localhost:8080/api/rest/register'
  #else
    #deployedAt = window.location.href.substring(0, window.location.href)
    #newBaseUrl = deployedAt + '/api/rest/register'
  #RestangularProvider.setBaseUrl newBaseUrl
  #return
  
  
  
  