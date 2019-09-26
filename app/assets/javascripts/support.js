
$(function() {
  // add anchor links to each header on the page
  anchors.add('.support-col-left h2, .support-col-left h3, .support-col-left h4, .support-col-left h5, .support-col-left h6');

  // pull all of the headers out of the content and build a table of contents with it
  var $headers = $('.support-col-left h2, .support-col-left h3')
  var $in_guide = $('.support-col-right .in-this-guide')
  var $ul = $('.support-col-right ul')
  var last_header = null
  var html = ''

  if ($headers.length > 0){
    $headers.each(function(){
      if ($(this).text().trim() !== ''){
        if ($(this)[0].nodeName == 'H2' && last_header === 'H3'){
          html += '</ul>'
        }else if ($(this)[0].nodeName == 'H3' && last_header === 'H2'){
          html += '<ul>'
        }
        html += '</li>'
        html += '<li><a href="#' + $(this).attr('id') + '">' + $(this).text() + '</a>'
        last_header = $(this)[0].nodeName
      }
    })
    // close the last list item
    if (html.length > 0){
      html += '</li>'
    }
    $ul.append(html)
  }else{
    $in_guide.addClass('no-content')
  }


});
