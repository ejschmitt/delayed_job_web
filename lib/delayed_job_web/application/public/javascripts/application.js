$(function() {
  $('ul li.job').hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  })

  $('a.backtrace').click(function (e) {
    e.preventDefault();
    if($(this).prev('div.backtrace:visible').length > 0) {
      $(this).next('div.backtrace').show();
      $(this).prev('div.backtrace').hide();
    } else {
      $(this).next('div.backtrace').hide();
      $(this).prev('div.backtrace').show();
    }
  });

  $('a[rel=poll]').click(function() {
    var href = $(this).attr('href')
    $(this).parent().text('Starting...')
    $("#main").addClass('polling')

    setInterval(function() {
      $.ajax({dataType: 'text', type: 'get', url: href, success: function(data) {
        $('#main').html(data)
        $('#main .time').relatizeDate()
      }})
    }, poll_interval * 1000)

    return false
  })
})
