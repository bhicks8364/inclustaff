jQuery ->
    $('#adjustment_adj_type_bonus').click ->
        $('.bs-example-modal-lg').modal('toggle')
    $('#adjustment_adj_type_vacation').click ->
        $('#VacationAdj').toggleClass('hide-this')