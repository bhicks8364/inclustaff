// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require refile
//= require jquery-ui
//= require jquery-ui/datepicker
//= require jquery.atwho
//= require dataTables/jquery.dataTables
//= require bootstrap-sprockets
//= require cocoon


//= require timesheets
//= require shifts
//= require startshift
//= require jobs
//= require company_jobs
//= require timeclock
//= require emp_jobs
//= require autocomplete
//= require datatables
//= require forms
//= require invoices
//= require at_mentions
//= require comments
//= require messages
//= require practice
//= require orders
//= require employees

//= require chartkick

//= require charts
//= require popovers
//= require tooltips
//= require underscore
//= require gmaps/google

//= require pending_approval

$(document).ready(function(){
  $('.img-zoom').hover(function() {
    $(this).addClass('transition');
  }, function() {
    $(this).removeClass('transition');
  });

  $('.img-zoom-big').hover(function() {
    $(this).addClass('transition');
  }, function() {
    $(this).removeClass('transition');
  });
});
