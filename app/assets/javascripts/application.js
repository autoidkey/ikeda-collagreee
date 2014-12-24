// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require d3
//= require turbolinks
//= require_tree .
//= require bootstrap-sprockets
//= require jquery-ui/slider
//= require jquery.autopager-1.0.0
//= require jquery.leanModal.min

// jquery.leanModal
$(function() {
  $( 'a[rel*=leanModal]').leanModal({
    top: 50,                     // #modal-windowの縦位置
    overlay : 0.7,               // #modal-windowの背面の透明度
    closeButton: ".modal_close"  // #modal-windowを閉じるボタンのdivのclass
  });
});
