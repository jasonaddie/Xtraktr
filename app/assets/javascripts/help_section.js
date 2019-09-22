$(function() {
  // load the selectpicker libraries for an assignment row
  function load_assignment_row(this_row){
    console.log('-- load row')
    console.log($(this_row).find('select.selectpicker-help-page-assignment-http-method'))
    $(this_row).find('select.selectpicker-help-page-assignment-http-method').select2({width:'element'});
  }

  // when adding help page assignments - add selectpicker
  $('table#help-page-assignments tbody').on('cocoon:before-insert', function(e, insertedItem) {
    console.log('inserting new row')
    load_assignment_row(insertedItem);
  });

  // process all reports when page loads
  if ($('table#help-page-assignments tbody tr').length > 0){
    $('table#help-page-assignments tbody tr').each(function(){
      console.log('initialize assignment row')
      load_assignment_row(this);
    });
  }


  $('form select.selectpicker-help-section-parent-id').select2({width:'element', allowClear:true});

  $('form select.selectpicker-help-page-help-section-id').select2({width:'element', allowClear:true});


});
