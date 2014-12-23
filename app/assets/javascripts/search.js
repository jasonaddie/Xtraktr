$(document).ready(function(){
  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });


  $('#users-datatable').dataTable({
    "dom": '<"top"f>t<"bottom"lpi><"clear">',
    "serverSide": true,
    "ajax": $('#users-datatable').data('source'),
    "order": [[2, 'desc']],
    "language": {
      "url": gon.datatable_i18n_url
    }
  });


  $('#dataset-datatable').dataTable({
    "dom": '<"top"f>t<"bottom"lpi><"clear">',
    "language": {
      "url": gon.datatable_i18n_url
    },
    "columnDefs": [
      { orderable: false, "targets": [5,7] }
    ]
  });

  $('#shapeset-datatable').dataTable({
    "dom": '<"top"f>t<"bottom"lpi><"clear">',
    "language": {
      "url": gon.datatable_i18n_url
    },
    "columnDefs": [
      { orderable: false, "targets": [5] }
    ]
  });

});
