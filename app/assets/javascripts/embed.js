//= require i18n
//= require i18n/translations
//= require jquery
//= require explore

var keys = [];

////////////////////////////////////////////////
// build highmap
function build_highmaps(json){
  if (json.map){
    // adjust the height/width of the map to fit its container
    $('#container-map').width($(document).width());
    $('#container-map').height($(document).height());

    // test if the filter is being used and build the chart(s) accordingly
    if (json.map.constructor === Array){
      // filters
      var map_index = 0;

      var stop_loop = false;
      for(var h=0; h<json.map.length; h++){
        if (json.broken_down_by && json.map[h].filter_results.map_sets.constructor === Array){

          for(var i=0; i<json.map[h].filter_results.map_sets.length; i++){
            // create map for filter that matches gon.broken_down_by_value and broken down by that matches gon.broken_down_by_value
            if (json.map[h].filter_answer_value == gon.filtered_by_value && json.map[i].broken_down_answer_value == gon.broken_down_by_value){          
              build_highmap(json.map[h].filter_results.shape_question_code, json.map[h].filter_results.map_sets[i]);
              stop_loop = true;
              break;
            }

            // increase the map index
            map_index += 1;        
          }

          if (stop_loop === true){
            break;
          }
        }else{

          // create map for filter that matches gon.filtered_by_value
          if (json.map[i].filter_answer_value == gon.filtered_by_value){          
            build_highmap(json.map[h].filter_results.shape_question_code, json.map[h].filter_results.map_sets);
            break;
          }

          // increase the map index
          map_index += 1;        
        }
      }

    }else{

      // no filters
      if (json.broken_down_by && json.map.map_sets.constructor === Array){

        for(var i=0; i<json.map.map_sets.length; i++){
          // create map for broken down by that matches gon.broken_down_by_value
          if (json.map[i].broken_down_answer_value == gon.broken_down_by_value){          
            build_highmap(json.map.shape_question_code, json.map.map_sets[i]);
            break;
          }
        }

      }else{
        build_highmap(json.map.shape_question_code, json.map.map_sets);
      }
    }
  }
}


////////////////////////////////////////////////
// build crosstab charts for each chart item in json
function build_crosstab_charts(json){
  if (json.chart){
    // determine chart height
    var chart_height = crosstab_chart_height(json);

    // test if the filter is being used and build the chart(s) accordingly
    if (json.chart.constructor === Array){
      // filters
      for(var i=0; i<json.chart.length; i++){
        // create chart for filter that matches gon.filtered_by_value
        if (json.chart[i].filter_answer_value == gon.filtered_by_value){          
          build_crosstab_chart(json.question.original_code, json.broken_down_by.original_code, json.broken_down_by.text, json.chart[i].filter_results, chart_height);
          break;
        }
      }

    }else{
      // no filters
      build_crosstab_chart(json.question.original_code, json.broken_down_by.original_code, json.broken_down_by.text, json.chart, chart_height);
    }
  }
} 


////////////////////////////////////////////////
// build pie chart for each chart item in json
function build_pie_charts(json){
  if (json.chart){
    // determine chart height
    var chart_height = pie_chart_height(json);

    // test if the filter is being used and build the chart(s) accordingly
    if (json.chart.constructor === Array){
      // filters
      for(var i=0; i<json.chart.length; i++){
        // create chart for filter that matches gon.filtered_by_value
        if (json.chart[i].filter_answer_value == gon.filtered_by_value){          
          build_pie_chart(json.chart[i].filter_results, chart_height);
          break;
        }
      }

    }else{
      // no filters
      build_pie_chart(json.chart, chart_height);
    }
  }
} 


////////////////////////////////////////////////
// build time series line chart for each chart item in json
function build_time_series_charts(json){
  if (json.chart){
    // determine chart height
    var chart_height = time_series_chart_height(json);

    // test if the filter is being used and build the chart(s) accordingly
    if (json.chart.constructor === Array){
      // filters
      for(var i=0; i<json.chart.length; i++){
        // create chart for filter that matches gon.filtered_by_value
        if (json.chart[i].filter_answer_value == gon.filtered_by_value){          
          build_time_series_chart(json.chart[i].filter_results, chart_height);
          break;
        }
      }

    }else{
      // no filters
      build_time_series_chart(json.chart, chart_height);
    }
  }
}

function load_highlights(highlight_data){
console.log('----------------load_highlights');
console.log(highlight_data);
  // pull out all of the keys
  $.each(highlight_data, function(k,v){ keys.push(k)});

  // build chart for each key
  var data, key;
  for(var i=0;i<keys.length;i++){
    key = keys[i];
console.log('key = ' + key);      
    data = highlight_data[key];
console.log('data');
console.log(data)
    if (data.json_data){
      gon.highlight_id = key;

      // set fitler_value and broken_down_by_value if exists
      if (data.broken_down_by_value){
        gon.broken_down_by_value = data.broken_down_by_value;
      }
      if (data.filtered_by_value){
        gon.filtered_by_value = data.filtered_by_value;
      }

    // test if time series or dataset
      if (data.json_data.time_series){
        build_time_series_charts(data.json_data);
      }else if(data.json_data.dataset){
        // test for visual type
        if (data.visual_type == 'chart'){
          if (data.json_data.analysis_type == 'comparative'){
            build_crosstab_charts(data.json_data);
          }else{
            build_pie_charts(data.json_data);
          }
        }else if (data.visual_type == 'map') {
          build_highmaps(data.json_data);
        }
      }


      if (gon.update_page_title){
        build_page_title(data.json_data);
      }
    }
  };
}

/////////////////////////////////////////
/////////////////////////////////////////
$(document).ready(function() {
  // set languaage text
  Highcharts.setOptions({
    lang: {
      contextButtonTitle: gon.highcharts_context_title
    },
  colors: ['#00adee', '#e88d42', '#9674a9', '#f3d952', '#6fa187', '#b2a440', '#d95d6a', '#737d91', '#d694e0', '#80b5bc', '#a6c449', '#1b74cc', '#4eccae']
  });

  if (gon.highlight_data){
    load_highlights(gon.highlight_data)
  }

});
