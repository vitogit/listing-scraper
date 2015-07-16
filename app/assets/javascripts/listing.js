
  // 
  // $('.ckeditor').ckeditor({
  // });



$(document).on('page:change', function () {
    $('.datatable').DataTable({
      "order": [[ 8, "desc" ]],
      "pageLength": 50
    });
  });
