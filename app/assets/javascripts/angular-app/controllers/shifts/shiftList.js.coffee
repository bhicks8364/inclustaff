@ShiftsCtrl = ($scope) ->
  $scope.shifts = gon.shifts

  console.log($scope.shifts)
  console.log(gon.employee)
  $scope.employee = gon.employee

  console.log($scope.shifts)
  console.log($scope.employee)