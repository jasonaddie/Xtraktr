var datatable;
function set_is_default_change(page_load){
  if (page_load == undefined){
    page_load = false;
  }
  if ($('form.time_series_weight input[name="time_series_weight[is_default]"]:checked').attr('value') == "true"){
    // applies to all
    $('form.time_series_weight #time_series_weight_applies_to_all_input').fadeOut();

    // questions
    $('form.time_series_weight #weight_codes').fadeOut();
  }else{
    // applies to all
    if (!page_load){
      $('form.time_series_weight input#time_series_weight_applies_to_all_true').prop('checked', true);
    }
    $('form.time_series_weight #time_series_weight_applies_to_all_input').fadeIn();
  }
}

function set_applies_to_all_change(page_load){
  if (page_load == undefined){
    page_load = false;
  }
  if ($('form.time_series_weight input[name="time_series_weight[applies_to_all]"]:checked').attr('value') == "true"){
    // hide questions
    $('form.time_series_weight #weight_codes').fadeOut();
  }else{
    // show questions and make sure all questions are not selected
    if (!page_load){
      $(datatable.$('tr', {"filter": "applied"})).find('td :checkbox').each(function () {
        $(this).prop('checked', false);
      });
    }
    $('form.time_series_weight #weight_codes').fadeIn();
  }
}

$(document).ready(function(){

  if ($('form.time_series_weight').length > 0){
    /* Create an array with the values of all the checkboxes in a column */
    // take from: http://www.datatables.net/examples/plug-ins/dom_sort.html
    $.fn.dataTable.ext.order['dom-checkbox'] = function  ( settings, col )
    {
      return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {
        return $('input[type="checkbox"]', td).prop('checked') ? '1' : '0';
      });
    }


    // if this is default weight, hide applies to all (marking it yes) and hide questions
    $('form.time_series_weight input[name="time_series_weight[is_default]"]').change(function(){
      set_is_default_change();
    })

    // if the weight applies to all, hide questions
    $('form.time_series_weight input[name="time_series_weight[applies_to_all]"]').change(function(){
      set_applies_to_all_change();
    });

    // when dataset is selected for choosing weight question, show questions in that dataset
    $('select#time_series_weight_dataset_id').change(function(){
      // find the row of the dataset in the table and get the options
      var input = $('table#time-series-dataset-questions tbody tr td input[value="' + $(this).val() + '"]');
      if (input){
        var options = input.closest('tr').find('td:last-of-type select option').clone();

        // add options to question weight selection
        $('select#time_series_weight_code').empty().append(options);
        $('select#time_series_weight_code').val('');
        $('select#time_series_weight_code').selectpicker('refresh');
        $('select#time_series_weight_code').selectpicker('render');
      }
    });

    // selectpicker
    $('select.selectpicker-weights').selectpicker();
    $('select.selectpicker-assignment-dataset').selectpicker();

    // make sure the correct fields are shown
    set_is_default_change(true);
    set_applies_to_all_change(true);


    // datatable for exclude answers page
    datatable = $('#time-series-weight-questions').DataTable({
      "dom": '<"top"fli>t<"bottom"p><"clear">',
      "data": gon.datatable_json,
      // "deferRender": true,
      "columns": [
        {"data":"checkbox", "orderDataType": "dom-checkbox"},
        {"data":"code"},
        {"data":"text"},
        {"data":"other_weights"}
      ],
      "order": [[1, 'asc']],
      "language": {
        "url": gon.datatable_i18n_url,
        "searchPlaceholder": gon.datatable_search
      },
      "pagingType": "full_numbers",
      "orderClasses": false
    });

    // search boxes in footer
    $('#time-series-weight-questions tfoot input').on('keyup click', function(){
        datatable.column($(this).closest('td').index()).search(this.value, true, false).draw();
    });


    // if data-state = all, select all questions that match the current filter
    // - if not filter -> then all questions are selected
    // else, desfelect all questions that match the current filter
    // - if not filter -> then all questions are deselected
    $('a.btn-select-all').click(function(){
      if ($(this).attr('data-state') == 'all'){
        $(datatable.$('tr', {"filter": "applied"})).find('td :checkbox').each(function () {
          $(this).prop('checked', true);
        });
        $(this).attr('data-state', 'none');
      }else{
        $(datatable.$('tr', {"filter": "applied"})).find('td :checkbox').each(function () {
          $(this).prop('checked', false);
        });
        $(this).attr('data-state', 'all');
      }

      return false;
    });

    // when form submits, get all checkboxes from datatable and then submit
    // - have to do this because loading data via js and so dom does not know about all inputs
    $('form.time_series_weight').submit(function(){
      // show data loader
      $(this).find('> .data-loader').fadeIn('fast');

      // empty out what was there
      $('#hidden-table-inputs', this).empty();

      // get all inputs from table and add to form
      datatable.$('input').each(function(){
        $(this).clone().appendTo('#hidden-table-inputs', this);
      });

    });

}


  // index page
  if ($('table#weight-datatable').length > 0){
    // when applie to link is clicked populate the modal and then show it
    $('a.applies-to').click(function(e){
      e.preventDefault();
      e.stopPropagation();
      var ths = $(this);
      modal($('#questions-popup').html(),
        {
          position:'center',
          before: function(t)
          {
            t.find('.header').html(t.find('.header').data('title').replace('[weight]', ths.closest('tr').find('td:first').html()));
            t.find('.text').html(ths.closest('td').find('.applies-to-questions').html());
          }
        }
      );

    });
  }
});
