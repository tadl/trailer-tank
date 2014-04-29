$( document ).ready(function() {
  $('#search').keydown(function(event) {
        if (event.keyCode == 13) { search_by_title(); }
    });
});

function check_for_embed(record_id, title, page, state, current_user){
 var target_div = '#input_' + record_id;
 var youtube_url = $(target_div).val();
 var youtube_id = youtube_url.replace('http://www.youtube.com/watch?v=','').replace('https://www.youtube.com/watch?v=','').split(/&/)[0];
 var youtube_check = 'https://gdata.youtube.com/feeds/api/videos/'+ youtube_id +'?v=2&alt=jsonc'
 $.ajax({
        url: youtube_check,
        type: 'GET',
        dataType: "json",
        success: function(data) {
           check_n_save(data, record_id, title, youtube_id, page, state, current_user);
        },
   error: function(){
     alert("URL is NO GOOD!");
 }
     });
  
}

function check_n_save(data, record_id, title, youtube_id, page, state, current_user){
  var can_embed = data.data.accessControl.embed
  var can_embed_mobile = data.data.accessControl.syndicate
  var clean_title = title.replace("'", "%25")
  var trailer_div = '#trailer_' + record_id
  var edit_div = '#edit_' + record_id
  var trailer_code = '<a onclick="show_trailer(\''+ youtube_id +'\')">Show Trailer</a> - Uploaded By: '+ current_user +' <button onclick="delete_embed(\''+ record_id +'\',\''+ clean_title +'\',\''+ page +'\',\''+ state +'\',\''+ current_user +'\')">Delete Trailer</button>' 
  if (can_embed == 'denied' || can_embed_mobile == 'denied' ){
    alert("This video does not allow embedding and/or mobile playback. Please try another.");
      }else{
      save_url = '/main/update_trailer.json?id='+ record_id +'&yt='+ youtube_id;
      $.ajax({
        url: save_url,
        type: 'GET',
        dataType: "json",
        success: function(data) {
          if (state == 'search' || state == 'solo'){ 
            var score = data.message
            $(trailer_div).html(trailer_code);
            $(edit_div).html('');
            $('#score').html(score);
          }else{
            var score = data.message
            $('#score').html(score);
            refresh_trailers(page, state);
          }
        } 
      });
    } 
}


function delete_embed(record_id, title, page, state, current_user){
  var delete_url = '/main/delete_trailer.json?id='+ record_id 
  var search_code = '<a onclick="search_youtube(\''+ title +'\')">Search Youtube</a></br>'
  var edit_code = 'Add Youtube URL: <input id="input_'+ record_id +'" type="text"><button onclick="check_for_embed(\''+ record_id +'\',\''+ title +'\',\''+ page +'\',\''+ state +'\',\''+ current_user +'\')">Submit</button>'
  var cant_find_code = '<button onclick="mark_cant_find(\''+ record_id +'\', \''+ page +'\', \''+ state +'\')">Mark As Not Found</button>'
  var trailer_div = '#trailer_' + record_id
  var edit_div = '#edit_' + record_id
  var not_found_div = '#not_found_' + record_id
  $.ajax({
    url: delete_url,
    type: 'GET',
    dataType: "json",
    success: function(data) {
    $(edit_div).html(search_code + edit_code);
    $(not_found_div).html(cant_find_code);  
    $(trailer_div).html('');
    } 
  });  
}

function mark_cant_find(record_id, page, state){
  var not_found_div = '#not_found_' + record_id
  cant_find_url = '/main/mark_cant_find?id='+ record_id
  $.ajax({
    url: cant_find_url,
    type: 'GET',
    dataType: "json",
    success: function(data) {
      if (state == 'search'){
        $(not_found_div).html('Marked as Not Found');
      } else {
        refresh_trailers(page, state);
      }
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

function add_by_record(){
 var id = $('#add_by').val();
  if (id){
    var url = '/main/add_record?id=' + id
    window.open(url,"_self")
     }else{
    alert("enter a record id!");  
     }     
}

function confirm_add(id){
  var url = '/main/manual_add?id=' + id
  window.open(url,"_self")
}


function search_youtube(title){
  var clean_title = title.replace("%25","'").replace("&","%26")
 var url ='http://www.youtube.com/results?search_query=' + clean_title +' trailer';
 window.open(url);
}

function show_trailer(youtube_id){
 var url ='http://www.youtube.com/watch?v=' + youtube_id;
 window.open(url);
}

function refresh_trailers(page, state){
  if (state == 'queue'){
  url = "/main/queue.js?page=" + page
  }else{
  url = "/main/cant_find.js?page=" + page
  }
  $.ajax({
  type: "GET",
  url: url,
  success: function(data){}
}); 
}

function change_role(role, email, id){
  var url = '/main/change_role.json?role='+ role +'&email='+ email
  var edit_role_div = '#edit_role_' + id
  $.ajax({
  type: "GET",
  url: url,
  success: function(data){
    if (data['message'] == 'done'){
      $(edit_role_div).html("");
    }else{
      $(edit_role_div).append("error");
    }
  }
}); 

}

