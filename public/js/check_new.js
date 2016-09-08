// var check_new, like_notice, render_new, reply_notice;

// render_new = function(data, theme_id) {
//   var delete_url, render_url;
//   console.log('rendering...');
//   render_url = '/entries/render_new/';
//   delete_url = '/users/delete_notice?theme_id=' + theme_id;
//   $('#entry_notice').css('display', 'block');
//   $('#entry_notice_count').text(data.entry.length);
//   $.each(data.entry, function() {
//     return $.post(render_url + this.entry_id + '?theme_id=' + theme_id);
//   });
//   $.post(delete_url);
//   $('#entry_notice').css('display', 'none');
//   return $('#entry_notice_count').text(0);
// };

// reply_notice = function(reply, theme_id) {
//   var read_reply_url;
//   read_reply_url = '/users/read_reply_notice?theme_id=' + theme_id;
//   $('#reply_notice').css('display', 'block');
//   $('#reply_notice_count').text(reply.length);
//   $.each(reply, function() {
//     return new PNotify({
//       title: "返信されました No." + this.id,
//       text: "あなたの投稿に返信されました",
//       icon: "glyphicon glyphicon-share-alt"
//     });
//   });
//   return $.post(read_reply_url);
// };

// like_notice = function(like, theme_id) {
//   var read_like_url;
//   read_like_url = '/users/read_like_notice?theme_id=' + theme_id;
//   $.each(like, function() {
//     return new PNotify({
//       title: "賛同されました No." + this.id,
//       text: "あなたの投稿に賛同されました",
//       icon: "glyphicon glyphicon-thumbs-up"
//     });
//   });
//   return $.post(read_like_url);
// };

// check_new = function() {
//   var theme_id, url;
//   theme_id = location.href.match(".+/(.+?)$")[1];
//   if((theme_id.search( /^[0-9]+$/ ))==0){
//     console.log(theme_id)
//     url = '/themes/check_new/' + theme_id;
//     return setTimeout(((function(_this) {
//       return function() {
//         console.log('checking...');
//         $.get(url, function(data) {
//           console.log(data);
//           if (data.entry.length > 0) {
//             render_new(data, theme_id);
//           }
//           if (data.reply.length > 0) {
//             reply_notice(data.reply, theme_id);
//           }
//           if (data.like.length > 0) {
//             return like_notice(data.like, theme_id);
//           }
//         });
//         return check_new();
//       };
//     })(this)), 10000);
//   }
// };

// $(document).on('ready page:load', function() {
//   return check_new();
// });
