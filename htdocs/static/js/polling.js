$(document).ready(function(){

var job_id = $("span#job_id").text();

$.ajaxPollSettings.interval = 1000;
$.ajaxPoll({
    url: "/api/job/"+job_id+"/polling",
    type: "GET",
    dataType: "json",
    successCondition: function (data) {
        $("div#job_log pre").html(data.log);
        return data.success != null;
    },
    success: function (data) {
        console.log(data);
        for (var i in data.uploads) {
            $("div#uploads").append('<img src="/static/upload/' + data.uploads[i].path + '" />');
        }
        $.jGrowl('success!');
    }
});

});
