$(document).ready(function(){
    $('#data-upload-button').click(function() {
        $('#data-upload-button input').css("display", "none");
        $('#data-upload-message').html('<img src="/static/img/ajax-loader.gif"/>');

        $('#data-upload-file').upload('/upload', function (res) {
           $('#data-upload-button, #data-upload-file').remove();
           $('#data-upload-message').html(res.file);
        }, 'json');
    });

$('#service-add-submit').button();
$('#service-add').validate({
  errorLabelContainer: '#service-add-error',
  submitHandler: function(form) {
      $(form).loading({
          img: '/static/css/loading.gif',
          align: 'center'
      });
      $(form).ajaxSubmit({
        success: function(data) {
          console.log(data);
          $.jGrowl('success!');
        },
        error: function() {
            $.jGrowl('failed!');
        },
        complete: function(){
            $(form).loading(false);
        }
      });
  }
});

});

