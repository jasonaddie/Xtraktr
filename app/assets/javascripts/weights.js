var datatable;

function set_is_default_change(page_load){
  if (page_load == undefined){
    page_load = false;
  }
  if ($('form.weight input[name="weight[is_default]"]:checked').attr('value') == "true"){
    // applies to all
    $('form.weight #weight_applies_to_all_input').fadeOut();

    // questions
    $('form.weight #weight_codes').fadeOut();
  }else{
    // applies to all
    if (!page_load){
      $('form.weight input#weight_applies_to_all_true').prop('checked', true);
    }
    $('form.weight #weight_applies_to_all_input').fadeIn();
  }
}

function set_applies_to_all_change(page_load){
  if (page_load == undefined){
    page_load = false;
  }
  if ($('form.weight input[name="weight[applies_to_all]"]:checked').attr('value') == "true"){
    // hide questions
    $('form.weight #weight_codes').fadeOut();
  }else{
    // show questions and make sure all questions are not selected
    if (!page_load){
      $(datatable.$('tr', {"filter": "applied"})).find('td :checkbox').each(function () {
        $(this).prop('checked', false);
      });
    }
    $('form.weight #weight_codes').fadeIn();
  }
}

$(document).ready(function(){

  if ($('form.weight').length > 0){
    /* Create an array with the values of all the checkboxes in a column */
    // take from: http://www.datatables.net/examples/plug-ins/dom_sort.html
    $.fn.dataTable.ext.order['dom-checkbox'] = function  ( settings, col )
    {
      return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {
        return $('input[type="checkbox"]', td).prop('checked') ? '1' : '0';
      });
    }


    // if this is default weight, hide applies to all (marking it yes) and hide questions
    $('form.weight input[name="weight[is_default]"]').change(function(){
      set_is_default_change();
    })

    // if the weight applies to all, hide questions
    $('form.weight input[name="weight[applies_to_all]"]').change(function(){
      set_applies_to_all_change();
    });


    // selectpicker
    $('select.selectpicker-weights').selectpicker();

    // make sure the correct fields are shown
    set_is_default_change(true);
    set_applies_to_all_change(true);


    // datatable for exclude answers page
    datatable = $('#dataset-weight-questions').DataTable({
      "dom": '<"top"fli>t<"bottom"p><"clear">',
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
    $('#dataset-weight-questions tfoot input').on('keyup click', function(){
        datatable.column($(this).closest('td').index()).search(this.value, true, false).draw();
    });


    // if data-state = all, select all questions that match the current filter
    // - if not filter -> then all questions are selected
    // else, desfelect all questions that match the current filter
    // - if not filter -> then all questions are deselected
    $('a.btn-select-all').click(function(){
      var t = $(this),
        state_all = t.attr("data-state") == "all"

      $(datatable.$("tr", {"filter": "applied"}))
        .find("td input[type='checkbox']").each(function(){
          $(this).prop("checked", state_all);
        })


      t.attr("data-state", state_all ? "none" : "all" );
      return false;
    });


    // when form submits, get all checkboxes from datatable and then submit
    // - have to do this because loading data via js and so dom does not know about all inputs
    $('form.weight').submit(function(){
      // show data loader
      $(this).find('> .data-loader').fadeIn('fast');

      // empty out what was there
      $('#hidden-table-inputs', this).empty();

      // get all inputs from table and add to form
      datatable.$('input').each(function(){
        // fix the name attribute so the values are saved
        $(this).clone().attr('name', 'weight[codes][]').appendTo('#hidden-table-inputs', this);
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
