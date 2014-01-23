function check_for_embed(record_id){
 var target_div = '#input_' + record_id;
 var youtube_url = $(target_div).val();
 var youtube_id = youtube_url.replace('http://www.youtube.com/watch?v=','');
 var youtube_check = 'https://gdata.youtube.com/feeds/api/videos/'+ youtube_id +'?v=2&alt=jsonc'
 $.ajax({
        url: youtube_check,
        type: 'GET',
        dataType: "json",
        success: function(data) {
           check_n_save(data, record_id, youtube_id);
        },
   error: function(){
     alert("URL is NO GOOD!");
 }
     });
  
}

function check_n_save(data, record_id, youtube_id){
  var test = data.data.accessControl.embed;
  var message_div = '#error_' + record_id
  if (test == 'denied'){
    $(message_div).html("This video does not allow embedding. Please try another.");
      }else{
      save_url = '/main/leaders.json?id='+ record_id +'&yt='+ youtube_id;
      $.ajax({
        url: save_url,
        type: 'GET',
        dataType: "json",
        success: function(data) {
           alert(data);
        } 
        });
      }
}

