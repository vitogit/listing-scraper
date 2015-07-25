
  //
  // $('.ckeditor').ckeditor({
  // });



$(document).on('page:change', function () {
    var table = $('.datatable').DataTable({
      "order": [[ 8, "desc" ]],
      "pageLength": 50

    });

    // show spinner on AJAX start
    $(document).ajaxStart(function(){
      $(".spinner").show();
    });

    // hide spinner on AJAX stop
    $(document).ajaxStop(function(){
      $(".spinner").hide();
    });
  });
