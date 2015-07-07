$('.ckeditor').ckeditor({
});



$(document).ready(function(){
  $('.datatable').DataTable({
    "order": [[ 3, "desc" ]],
    "pageLength": 50
  });
});
