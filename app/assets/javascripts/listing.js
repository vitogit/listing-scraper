
  //
  // $('.ckeditor').ckeditor({
  // });



$(document).on('page:change', function () {
    var table = $('.datatable').DataTable({
      "order": [[ 8, "desc" ]],
      "pageLength": 50,

    });

    // $("div.negative_search").html('Negative Search:<input class="form-control input-sm" type="text" id="negative_search">');
    $('#negative_search').keyup(function(){
      if ($(this).val() == "") {
          table.search($(this).val()).draw();
      } else {
        table.search( '^(?!.*'+$(this).val()+').*$', true, false ).draw();
        $('.input-sm').val('');
      }

    })

    // show spinner on AJAX start
    $(document).ajaxStart(function(){
      $(".spinner").show();
    });

    // hide spinner on AJAX stop
    $(document).ajaxStop(function(){
      $(".spinner").hide();
    });
  });
