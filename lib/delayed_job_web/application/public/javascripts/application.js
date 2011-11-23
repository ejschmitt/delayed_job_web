$(function() {
  $('ul li').hover(function() {
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
})
