
  // 
  // $('.ckeditor').ckeditor({
  // });



$(document).on('page:change', function () {
    $('.datatable').DataTable({
      "order": [[ 7, "desc" ]],
      "pageLength": 50
    });
  });
