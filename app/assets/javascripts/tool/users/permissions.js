/*global main_notification */

$(document).ready(function() {
  $("#users_edit_roles #permissions input:radio").change(function(){
    var that = this;
    $.ajax({
      type: 'POST',
      url: $('#users_edit_roles #permissions').parents('form').attr('action'),
      data: 'user_id=' + $(this).attr('name') + '&role_id=' + $(this).attr('value'),
      error: function() {
        main_notification.display_message('You cannot remove the only account holder.');
        $("#"+ $(that).attr('name') +"_1").attr("checked", "checked");
      }
    });
  });

});