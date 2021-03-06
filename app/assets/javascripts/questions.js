/*global  $, gon*/
var datatable;
$(document).ready(function (){

  // datatable
  datatable = $("#dataset-questions").dataTable({
    "dom": '<"top"fli>t<"bottom"p><"clear">',
    "data": gon.datatable_json,
    "columns": [
      {"data":"view"},
      {"data":"code"},
      {"data":"text", "width":"25%"},
      {"data":"is_weight"},
      {"data":"has_answers"},
      {"data":"exclude"},
      {"data":"download"},
      {"data":"mappable"},
      {"data":"action"}
    ],
    "columnDefs": [
      { orderable: false, targets: [0, -1] }
    ],
    "sorting": [],
    // "order": [[1, "asc"]],
    "language": {
      "url": gon.datatable_i18n_url,
      "searchPlaceholder": gon.datatable_search
    },
    "pagingType": "full_numbers",
    "orderClasses": false
  });

  // when text of answer changes in default language, update the other languages default text table cell
  $("form.question .tab-content .tab-pane:first table#dataset-answers tbody").on("change", "tr td:first-of-type input", function (){
    var text = $(this).val();
    var row_index = $(this).closest("tbody").children("tr").index($(this).closest("tr"));

    // for the other languages, update the "default text" table cell at row_index
    for (var i=1; i < $("form.question .tab-content .tab-pane").length; i++){
      $($($("form.question .tab-content .tab-pane")[i]).find("table#dataset-answers tbody tr")[row_index]).find("td:last-of-type").html(text);
    }
  });


  // when a new answer is added, add row for each of the other languages
  $("form.question .tab-content .tab-pane:first table#dataset-answers").on("cocoon:after-insert", function (e, insertedItem) {
    var content = $(insertedItem).find("td:last");
    var default_locale = $("form.question .tab-content .tab-pane:first").data("locale");
    var row = "<tr><td>";
    row += $(content).find(".new-answer-input").html();
    row += "</td><td>";
    row += $(content).find(".new-answer-default-text").html();
    row += "</td></tr>";

    // add this new row to all languages
    for (var i=1; i < $("form.question .tab-content .tab-pane").length; i++){
      var tab_pane = $("form.question .tab-content .tab-pane")[i];
      var new_locale = $(tab_pane).data("locale");

      $(tab_pane).find("table#dataset-answers tbody")
        .append(row.replace(new RegExp("_" + default_locale, "g"), "_" + new_locale).replace(new RegExp('\\[' + default_locale + '\\]', 'g'), '[' + new_locale + ']'));

    }

    // now delete the content placeholder so form submital is not effected
    $("form.question .tab-content .tab-pane:first table#dataset-answers tbody tr:last td:last").remove();
  });

  // remove the row in all other tables too
  $("table#dataset-answers").on("cocoon:before-remove", function (e, to_delete) {
    // get index of this row so know which rows in other tables to delete
    var row_index = $(".tab-content .tab-pane:first table#dataset-answers tbody").children("tr").index(to_delete);

    for (var i=1; i < $(".tab-content .tab-pane").length; i++){
      // delete the row
      var row = $($(".tab-content .tab-pane")[i]).find("table#dataset-answers tbody tr")[row_index];
      if (row != undefined){
        $(row).remove();
      }
    }
  });

  // when a missing value is added as an answer
  // trigger, the add answer button and then add the value that was selected
  $("form.question .tab-content .tab-pane:first table#dataset-answers select#missing_answers").on("change", function () {
    // add an answer
    $(this).parent().closest("tfoot").find("a.add_fields").trigger("click");

    // add the value
    $($("form.question .tab-content .tab-pane:first table#dataset-answers tbody tr:last td")[1]).find("input").val($(this).val());

    // remove value from the list
    $(this).parent().find("option[value='" + $(this).val() + "']").remove();
    $(this).parent().val("");
  });
});
