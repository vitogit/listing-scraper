

  $('.ckeditor').ckeditor({
  });



$(document).on('page:change', function () {
    $('.datatable').DataTable({
      "order": [[ 3, "desc" ]],
      "pageLength": 50
    });
  });
