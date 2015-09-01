// console.log(gon.emp_code);
// var enteredCode = prompt("Please enter your employee code.");
// var msg = (enteredCode === gon.emp_code) ? "Access Granted":"Access Denied";
// alert(msg);

var nameApp = angular.module('nameApp', []);
      nameApp.controller('NameCtrl', function ($scope){
        $scope.names = ['Larry', 'Curly', 'Moe'];

        $scope.addName = function() {
          $scope.names.push($scope.enteredName);
          $scope.enteredName = '';
        };
      });