
$(function() {
  // add anchor links to each header on the page
  anchors.add('.support-col-left h2, .support-col-left h3, .support-col-left h4, .support-col-left h5, .support-col-left h6');

  // pull all of the headers out of the content and build a table of contents with it
  var $headers = $('.support-col-left h2')
  var $in_guide = $('.support-col-right .in-this-guide')
  var $ul = $('.support-col-right ul')
    console.log($headers)
  if ($headers.length > 0){
    $headers.each(function(){
      $ul.append('<li><a href="#' + $(this).attr('id') + '">' + $(this).text() + '</a></li>')
    })
  }else{
    console.log('no headers')
    $in_guide.addClass('no-content')
  }


});
