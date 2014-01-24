$( document ).ready(function() {
  $('#search').keydown(function(event) {
        if (event.keyCode == 13) { search_by_title(); }
    });
});

function check_for_embed(record_id, title){
 var target_div = '#input_' + record_id;
 var youtube_url = $(target_div).val();
 var youtube_id = youtube_url.replace('http://www.youtube.com/watch?v=','').replace('https://www.youtube.com/watch?v=','');
 var youtube_check = 'https://gdata.youtube.com/feeds/api/videos/'+ youtube_id +'?v=2&alt=jsonc'
 $.ajax({
        url: youtube_check,
        type: 'GET',
        dataType: "json",
        success: function(data) {
           check_n_save(data, record_id, youtube_id, title);
        },
   error: function(){
     alert("URL is NO GOOD!");
 }
     });
  
}

function check_n_save(data, record_id, youtube_id, title){
  var test = data.data.accessControl.embed;
  var trailer_div = '#trailer_' + record_id
  var edit_div = '#edit_' + record_id
  var delete_code = '<button onclick="delete_embed("'+ record_id +'","'+ title +'")">Delete Trailer</button>' 
  if (test == 'denied'){
    $(message_div).html("This video does not allow embedding. Please try another.");
      }else{
      save_url = '/main/update_trailer.json?id='+ record_id +'&yt='+ youtube_id;
      $.ajax({
        url: save_url,
        type: 'GET',
        dataType: "json",
        success: function(data) {
          var embed_code = data['message']; 
          $(trailer_div).html(embed_code);
          $(edit_div).html(delete_code)
        } 
        });
      }
}

function delete_embed(record_id, title){
  var save_url = '/main/delete_trailer.json?id='+ record_id 
  var search_code = '<a onclick="search_youtube("'+ title +'")">Search Youtube</a></br>'
  var edit_code = 'Add Youtube URL: <input id="input_'+ record_id +'" type="text"><button onclick="check_for_embed("'+ record_id +'","'+ title +'")">Submit</button>'
  var trailer_div = '#trailer_' + record_id
  var edit_div = '#edit_' + record_id
  $.ajax({
    url: save_url,
    type: 'GET',
    dataType: "json",
    success: function(data) {
    var embed_code = data['message']; 
    $(edit_div).html(search_code + edit_code);
    $(trailer_div).html('');
    } 
  });  
}


function search_by_title(){
 var title = $('#search').val();
 var clean_title = encodeURIComponent(title);  
  if (title){
    var url = '/main/search_by_title?title=' + clean_title
    window.open(url,"_self")
     }else{
    alert("enter a title!");  
     }     
}

function search_youtube(title){
 var clean_title = encodeURIComponent(title); 
 var url ='http://www.youtube.com/results?search_query=' + clean_title;
 window.open(url);
}
