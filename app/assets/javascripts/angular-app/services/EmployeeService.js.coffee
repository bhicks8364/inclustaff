#angular.module('app.employeeApp')
  #.factory('EmployeeService', [
    #'Restangular', 'Shift',
    #(Restangular, Shift)->
#
      #model = 'shifts'
      #Restangular.setBaseUrl("/")
#
      #Restangular.extendModel(model, (obj)->
        #angular.extend(obj, Shift)
      #)
#
      #list: ()     -> Restangular.all(model).getList()
  #])