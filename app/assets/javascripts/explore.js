////////////////////////////////////////////////
////////////////////////////////////////////////
// collection of functions to build charts/maps
// for datasets and time series
////////////////////////////////////////////////
////////////////////////////////////////////////


////////////////////////////////////////////////
// determine heights of chart based on number of answers
////////////////////////////////////////////////
function pie_chart_height(json){
  var chart_height = 501; // need the 1 for the border bottom line
  if (json.question.answers.length >= 5){
    chart_height = 425 + json.question.answers.length*21 + 1;
  }
  return chart_height;
}

function crosstab_chart_height(json){
  var chart_height = 501; // need the 1 for the border bottom line
  if (json.question.answers.length + json.broken_down_by.answers.length >= 10){
    chart_height = 330 + json.question.answers.length*26.125 + json.broken_down_by.answers.length*21 + 1;
  }
  return chart_height;
}

function time_series_chart_height(json){
  var chart_height = 501; // need the 1 for the border bottom line
  if (json.question.answers.length >= 5){
    chart_height = 425 + json.question.answers.length*21 + 1;
  }
  return chart_height;
}


////////////////////////////////////////////////
// determine which highlight button to add to chart
////////////////////////////////////////////////
function determine_highlight_button(visual_element, embed_id, visual_type){
  if (gon.embed_ids){
    if (gon.embed_ids.indexOf(embed_id) > -1){
      // already exists, delete btn
      delete_highlight_button(visual_element, embed_id, visual_type);
    }else{
      // not exist, add btn
      add_highlight_button(visual_element, embed_id, visual_type);
    }
  }
}

////////////////////////////////////////////////
// add add highlight button to chart
////////////////////////////////////////////////
function add_highlight_button(visual_element, embed_id, visual_type){
  if (gon.is_admin){
    var parent = $(visual_element).parent();

    // create link
    var link = '<a class="add-highlight btn btn-primary btn-sm" href="' + $(parent).data('add-highlight') + '" data-embed-id="' + embed_id + '" data-visual-type="' + visual_type + '" ';
    link += 'title="' + gon.add_highlight_text + '" data-placement="right"><span class="glyphicon glyphicon-star" aria-hidden="true"></span></a>';

    // add link to visual
    $(visual_element).append(link);
  }
}

////////////////////////////////////////////////
// add delete highlight button to chart
////////////////////////////////////////////////
function delete_highlight_button(visual_element, embed_id, visual_type){
  if (gon.is_admin){
    var parent = $(visual_element).parent();

    // create link
    var link = '<a class="delete-highlight btn btn-danger btn-sm" href="' + $(parent).data('delete-highlight') + '" data-embed-id="' + embed_id + '" data-visual-type="' + visual_type + '" ';
    link += 'title="' + gon.delete_highlight_text + '" data-placement="right"><span class="glyphicon glyphicon-star" aria-hidden="true"></span></a>';

    // add link to visual
    $(visual_element).append(link);
    
  }
}



////////////////////////////////////////////////
// add embed button to chart
////////////////////////////////////////////////
function add_embed_button(visual_element, embed_id){
  if (gon.embed_button_link){
    var parent = $(visual_element).parent();

    // create link
    var link = '<span class="embed-chart" data-href="' + gon.embed_button_link.replace('replace', embed_id) + '" data-embed-id="' + embed_id + '"';
    link += 'title="' + gon.embed_chart_text + '" data-placement="bottom"><img src="/assets/svg/embed.svg" alt="' + gon.embed_chart_text + '" /></span>';

    // add link to visual
    $(visual_element).append(link);
  }
}


////////////////////////////////////////////////
// build title/sub title for chart/map
// if gon.visual_link is present, turn the title into a link
////////////////////////////////////////////////
function build_visual_title(highlight_path, text){
  var t = '';
  if ($(highlight_path).data('explore-link') != undefined){
    t = '<a class="visual-title-link" target="_parent" href="' + $(highlight_path).data('explore-link') + '">' + text + '</a>';
  }else{
    t = text;
  }
  return t;
}

////////////////////////////////////////////////
// build highmap
////////////////////////////////////////////////
function build_highmap(shape_question_code, json_map_set){
  // create a div tag for this map
  // if gon.highlight_id exist, add it to the jquery selector path
  var selector_path = '#container-map';
  var highlight_path = '.highlight-data[data-id="' + gon.highlight_id + '"] ';
  if (gon.highlight_id){
    selector_path = highlight_path + selector_path;
  }
  var map_id = 'map-' + ($('#container-map .map').length+1);
  $(selector_path).append('<div id="' + map_id + '" class="map"></div>');

  $(selector_path + ' #' + map_id).highcharts('Map', {
      chart:{
        events: {
          load: function () {
            if (this.options.chart.forExport) {
                Highcharts.each(this.series, function (series) {
                  // only show data labels for shapes that have data
                  if (series.name != 'baseLayer'){
                    series.update({
                      dataLabels: {
                        enabled: true,
                        color: 'white',
                        formatter: function () {
                          return this.point.properties.display_name + '<br/>' + Highcharts.numberFormat(this.point.count, 0) + '   (' + this.point.value + '%)';
                        }
                      }
                    }, false);
                  }
              });
              this.redraw();
            }
          }
        }          
      },
      title: {
          text: build_visual_title(highlight_path, json_map_set.title.html),
          useHTML: true,
          style: {'text-align': 'center', 'font-size': '16px', 'color': '#888'}
      },
      subtitle: {
          text: json_map_set.subtitle.html,
          useHTML: true,
          style: {'text-align': 'center', 'margin-top': '-15px'}
      },

      mapNavigation: {
          enabled: true,
          buttonOptions: {
              verticalAlign: 'top'
          }
      },
      colorAxis: {
        min: 0,
        max: 100, 
        minColor: '#d2f1f9',
        maxColor: '#0086a5',
        labels: {
            formatter: function () {
              return this.value + '%';
            },
        },
      },
      loading: {
        labelStyle: {
          color: 'white',
          fontSize: '20px'
        },
        style: {
          backgroundColor: '#000'
        }
      },
      series : [{
          // create base layer for N/A
          // will be overriden with next data series if data exists
          data : Highcharts.geojson(highmap_shapes[shape_question_code], 'map'),
          name: 'baseLayer',
          color: '#eeeeee',
          showInLegend: false,
          tooltip: {
              headerFormat: '',
              pointFormat: '<b>{point.properties.name_en}:</b> ' + gon.na
              // using name_en in case shape has no data and therefore no display_name
          },
          borderColor: '#f6f6f6',
          borderWidth: 2,
          states: {
              hover: {
                  color: '#0086a5',
                  borderColor: '#3c4352',
                  borderWidth: 2
              }
          }
        },
        {
          // shape layer with data
          data : json_map_set.data,
          name: 'dataLayer',
          mapData: highmap_shapes[shape_question_code],
          joinBy: ['name_en', 'shape_name'],
          allAreas: false, // if shape does not have value, do not show it so base layer above will show
          tooltip: {
              headerFormat: '',
              pointFormat: '<b>{point.display_name}:</b> {point.count:,.0f} ({point.value}%)'    
          },
          borderColor: '#f6f6f6',
          borderWidth: 2,
          states: {
            hover: {
              color: '#0086a5',
              borderColor: '#3c4352',
              borderWidth: 2
            }
          },
          dataLabels: {
            enabled: true,
            color: 'white',
            formatter: function () {
              return Highcharts.numberFormat(this.point.count, 0) + '   (' + this.point.value + '%)';
            }
          }
      }],
      exporting: {
        sourceWidth: 1280,
        sourceHeight: 720,
        filename: json_map_set.title.text,
        chartOptions:{
          title: {
            text: json_map_set.title.text
          },
          subtitle: {
            text: json_map_set.subtitle.text
          }
        },
        buttons: {
          contextButton: {
            menuItems: [
              {
                text: gon.highcharts_png,
                onclick: function () {
                    this.exportChart({type: 'image/png'});
                }
              }, 
              {
                text: gon.highcharts_jpg,
                onclick: function () {
                    this.exportChart({type: 'image/jpeg'});
                }
              }, 
              {
                text: gon.highcharts_pdf,
                onclick: function () {
                    this.exportChart({type: 'application/pdf'});
                }
              }, 
              {
                text: gon.highcharts_svg,
                onclick: function () {
                    this.exportChart({type: 'image/svg+xml'});
                }
              }
            ]
          }
        }
      }          
  });

  // now add button to add as highlight
  determine_highlight_button($(selector_path + ' #' + map_id), json_map_set.embed_id, gon.visual_types.map);  

  // add embed chart button
  add_embed_button($(selector_path + ' #' + map_id), json_map_set.embed_id);
}





////////////////////////////////////////////////
// build crosstab chart
////////////////////////////////////////////////
function build_crosstab_chart(question_text, broken_down_by_code, broken_down_by_text, json_chart, chart_height){
  if (chart_height == undefined){
    chart_height = 501; // need the 1 for the border bottom line
  }

  // create a div tag for this chart
  // if gon.highlight_id exist, add it to the jquery selector path
  var selector_path = '#container-chart';
  var highlight_path = '.highlight-data[data-id="' + gon.highlight_id + '"] ';
  if (gon.highlight_id){
    selector_path = highlight_path + selector_path;
  }
  var chart_id = 'chart-' + ($('#container-chart .chart').length+1);
  $(selector_path).append('<div id="' + chart_id + '" class="chart" style="height: ' + chart_height + 'px;"></div>');

  // create chart
  $(selector_path + ' #' + chart_id).highcharts({
    chart: {
        type: 'bar'
    },
    title: {
        text: build_visual_title(highlight_path, json_chart.title.html),
        useHTML: true,
        style: {'text-align': 'center', 'font-size': '16px', 'color': '#888'}
    },
    subtitle: {
        text: json_chart.subtitle.html,
        useHTML: true,
        style: {'text-align': 'center', 'margin-top': '-15px'}
    },
    xAxis: {
        categories: json_chart.labels,
        title: {
            text: '<span class="code-highlight">' + question_text + '</span>',
            useHTML: true,
            style: { "fontSize": "14px", "fontWeight": "bold" }
        },
    },
    yAxis: {
        min: 0,
        title: {
            text: gon.percent
        }
    },
    legend: {
        title: {
          text: '<span class="code-highlight">' + broken_down_by_code + '</span> - ',
          useHTML: true,
          style: { "color": "#333333", "fontSize": "14px", "fontWeight": "bold" }
        },
        layout: 'vertical',
        reversed: true,
        symbolHeight: 14,
        itemMarginBottom: 5,
        itemStyle: { "color": "#333333", "cursor": "pointer", "fontSize": "14px" }
    },
    tooltip: {
        pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y:,.0f}</b> ({point.percentage:.2f}%)<br/>',
        //shared: true,
        backgroundColor: 'rgba(255, 255, 255, 0.95)',
        followPointer: true
    },
    plotOptions: {
        bar: {
            stacking: 'percent'
        }
    },
    series: json_chart.data.reverse(),
    exporting: {
      sourceWidth: 1280,
      sourceHeight: 720,
      filename: json_chart.title.text,
      chartOptions:{
        title: {
          text: json_chart.title.text
        },
        subtitle: {
          text: json_chart.subtitle.text
        }
      },
      buttons: {
        contextButton: {
          menuItems: [
            {
              text: gon.highcharts_png,
              onclick: function () {
                  this.exportChart({type: 'image/png'});
              }
            }, 
            {
              text: gon.highcharts_jpg,
              onclick: function () {
                  this.exportChart({type: 'image/jpeg'});
              }
            }, 
            {
              text: gon.highcharts_pdf,
              onclick: function () {
                  this.exportChart({type: 'application/pdf'});
              }
            }, 
            {
              text: gon.highcharts_svg,
              onclick: function () {
                  this.exportChart({type: 'image/svg+xml'});
              }
            }
          ]
        }
      }
    }
  });    

  // now add button to add as highlight
  determine_highlight_button($(selector_path + ' #' + chart_id), json_chart.embed_id, gon.visual_types.crosstab_chart);  

  // add embed chart button
  add_embed_button($(selector_path + ' #' + chart_id), json_chart.embed_id);
}





////////////////////////////////////////////////
// build pie chart
////////////////////////////////////////////////
function build_pie_chart(json_chart, chart_height){
  if (chart_height == undefined){
    chart_height = 501; // need the 1 for the border bottom line
  }

  // create a div tag for this chart
  // if gon.highlight_id exist, add it to the jquery selector path
  var selector_path = '#container-chart';
  var highlight_path = '.highlight-data[data-id="' + gon.highlight_id + '"] ';
  if (gon.highlight_id){
    selector_path = highlight_path + selector_path;
  }
  var chart_id = 'chart-' + ($('#container-chart .chart').length+1);
  $(selector_path).append('<div id="' + chart_id + '" class="chart" style="height: ' + chart_height + 'px;"></div>');

  // create chart
  $(selector_path + ' #' + chart_id).highcharts({
    chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false
    },
    title: {
        text: build_visual_title(highlight_path, json_chart.title.html),
        useHTML: true,
        style: {}
    },
    subtitle: {
        text: json_chart.subtitle.html,
        useHTML: true,
        style: {'text-align': 'center', 'margin-top': '-15px'}
    },
    tooltip: {
        formatter: function () {
          return '<b>' + this.key + ':</b> ' + Highcharts.numberFormat(this.point.options.count,0) + ' (' + this.y + '%)';
        }
    },
    plotOptions: {
        pie: {
            cursor: 'pointer',
            dataLabels: {
                enabled: false
            },
            showInLegend: true,          
        }
    },
    legend: {
        align: 'center',
        layout: 'vertical',
        symbolHeight: 14,
        symbolWidth: 14,
        itemMarginBottom: 5,
        itemStyle: { "cursor": "pointer", 'font-family':"'sourcesans_pro_l', 'sans-serif'", 'font-size': '12px', 'color': '#3C4352', 'fontWeight': 'normal' },
        symbolRadius: 100
    },
    series: [{
        type: 'pie',
        data: json_chart.data
    }],
    exporting: {
      sourceWidth: 1280,
      sourceHeight: 720,
      filename: json_chart.title.text,
      chartOptions:{
        title: {
          text: json_chart.title.text
        },
        subtitle: {
          text: json_chart.subtitle.text
        }
      },
      buttons: {
        contextButton: {
          symbol: 'url(/assets/svg/download.svg)',
          menuItems: [
            {
              text: gon.highcharts_png,
              onclick: function () {
                  this.exportChart({type: 'image/png'});
              }
            }, 
            {
              text: gon.highcharts_jpg,
              onclick: function () {
                  this.exportChart({type: 'image/jpeg'});
              }
            }, 
            {
              text: gon.highcharts_pdf,
              onclick: function () {
                  this.exportChart({type: 'application/pdf'});
              }
            }, 
            {
              text: gon.highcharts_svg,
              onclick: function () {
                  this.exportChart({type: 'image/svg+xml'});
              }
            }
          ]
        }
      }
    },
    navigation: {
          buttonOptions: {
              theme: {
                  'stroke-width': 0,
                  r: 0,
                  states: {
                      hover: {
                          fill: '#fff',
                          stroke: '#eaeaea',
                          'stroke-width': 1                            
                      },
                      select: {                          
                          fill: '#fff',
                          stroke: '#eaeaea',
                          'stroke-width': 1
                      }
                  }
              }
          }
      }

  });

  // now add button to add as highlight
  determine_highlight_button($(selector_path + ' #' + chart_id), json_chart.embed_id, gon.visual_types.pie_chart);  

  // add embed chart button
  add_embed_button($(selector_path + ' #' + chart_id), json_chart.embed_id);
}


////////////////////////////////////////////////
// build time series line chart
////////////////////////////////////////////////
function build_time_series_chart(json_chart, chart_height){
  if (chart_height == undefined){
    chart_height = 501; // need the 1 for the border bottom line
  }

  // create a div tag for this chart
  // if gon.highlight_id exist, add it to the jquery selector path
  var selector_path = '#container-chart';
  var highlight_path = '.highlight-data[data-id="' + gon.highlight_id + '"] ';
  if (gon.highlight_id){
    selector_path = highlight_path + selector_path;
  }
  var chart_id = 'chart-' + ($('#container-chart .chart').length+1);
  $(selector_path).append('<div id="' + chart_id + '" class="chart" style="height: ' + chart_height + 'px;"></div>');

  // create chart
  $(selector_path + ' #' + chart_id).highcharts({
    chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false
    },
    title: {
        text: build_visual_title(highlight_path, json_chart.title.html),
        useHTML: true,
        style: {'text-align': 'center', 'font-size': '16px', 'color': '#888'}
    },
    subtitle: {
        text: json_chart.subtitle.html,
        useHTML: true,
        style: {'text-align': 'center', 'margin-top': '-15px'}
    },
    xAxis: {
        categories: json_chart.datasets
    },
    yAxis: {
        title: {
            text: gon.percent
        },
        max: 100,
        min: 0,
        plotLines: [{
            value: 0,
            width: 1,
            color: '#808080'
        }]
    },
    tooltip: {
        headerFormat: '<span style="font-size: 13px; font-style: italic; font-weight: bold;">{point.key}</span><br/>',
        pointFormat: '<span style="font-weight: bold;">{series.name}</span>: {point.count:,.0f} ({point.y:.2f}%)<br/>',
    },
    legend: {
        layout: 'vertical',
        symbolHeight: 14,
        itemMarginBottom: 5,
        itemStyle: { "color": "#333333", "cursor": "pointer", "fontSize": "14px", "fontWeight": "bold" }
    },
    series: json_chart.data,
    exporting: {
      sourceWidth: 1280,
      sourceHeight: 720,
      filename: json_chart.title.text,
      chartOptions:{
        title: {
          text: json_chart.title.text
        },
        subtitle: {
          text: json_chart.subtitle.text
        }
      },
      buttons: {
        contextButton: {
          menuItems: [
            {
              text: gon.highcharts_png,
              onclick: function () {
                  this.exportChart({type: 'image/png'});
              }
            }, 
            {
              text: gon.highcharts_jpg,
              onclick: function () {
                  this.exportChart({type: 'image/jpeg'});
              }
            }, 
            {
              text: gon.highcharts_pdf,
              onclick: function () {
                  this.exportChart({type: 'application/pdf'});
              }
            }, 
            {
              text: gon.highcharts_svg,
              onclick: function () {
                  this.exportChart({type: 'image/svg+xml'});
              }
            }
          ]
        }
      }
    }
  });

  // now add button to add as highlight
  determine_highlight_button($(selector_path + ' #' + chart_id), json_chart.embed_id, gon.visual_types.line_chart);  

  // add embed chart button
  add_embed_button($(selector_path + ' #' + chart_id), json_chart.embed_id);
}


////////////////////////////////////////////////
// update the page title to include the title of the analysis
function build_page_title(json){
  // get current page title
  // first index - dataset/time series title
  // last index - app name
  var title_parts = $('title').html().split(' | ');

  if (json.results.title.text){
    $('title').html(title_parts[0] + ' | ' + json.results.title.text + ' | ' + title_parts[title_parts.length-1])
  }else{
    $('title').html(title_parts[0] + ' | ' + title_parts[title_parts.length-1])
  }
   
}


////////////////////////////////////////////////
$(document).ready(function() {

  // record a chart as a highlight
  $('#tab-chart, #tab-map').on('click', 'a.add-highlight', function(e){
    e.preventDefault();
    var link = this;

    $.ajax({
      type: "POST",
      url: $(link).attr('href'),
      data: {embed_id: $(link).data('embed-id'), visual_type: $(link).data('visual-type')},
      dataType: 'json'
    }).done(function(success){
      if (success){
        // record embed id
        gon.embed_ids.push($(link).data('embed-id'));

        // show delete button
        $(link).fadeOut(function(){
          delete_highlight_button($(link).parent(), $(link).data('embed-id'), $(link).data('visual-type'));
        });
      }else{
      }
    });

  });


  // delete a chart as a highlight
  $('#tab-chart, #tab-map').on('click', 'a.delete-highlight', function(e){
    e.preventDefault();
    var link = this;

    $.ajax({
      type: "POST",
      url: $(link).attr('href'),
      data: {embed_id: $(link).data('embed-id'), visual_type: $(link).data('visual-type')},
      dataType: 'json'
    }).done(function(success){
      if (success){
        // delete embed id
        gon.embed_ids.splice( $.inArray($(link).data('embed-id'), gon.embed_ids), 1 );
        
        // show delete button
        $(link).fadeOut(function(){
          add_highlight_button($(link).parent(), $(link).data('embed-id'), $(link).data('visual-type'));
        });
      }else{

      }
    });

  });

});