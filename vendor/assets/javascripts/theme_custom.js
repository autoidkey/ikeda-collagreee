// 議論ツリー移動ボタンよう
// グローバル変数
var syncerTimeout = null ;
// 一連の処理
$( function(){
  // スクロールイベントの設定
  $( window ).scroll( function()
  {
    // 1秒ごとに処理
    if( syncerTimeout == null )
    {
      // セットタイムアウトを設定
      syncerTimeout = setTimeout( function(){

        // 対象のエレメント
        var element = $( '#page-top' ) ;
        // 現在、表示されているか？
        var visible = element.is( ':visible' ) ;
        // 最上部から現在位置までの距離を取得して、変数[now]に格納
        var now = $( window ).scrollTop() ;
        // 最下部から現在位置までの距離を計算して、変数[under]に格納
        var under = $( 'body' ).height() - ( now + $(window).height() ) ;
        // 最上部から現在位置までの距離(now)が1500以上かつ
        // 最下部から現在位置までの距離(under)が200px以上かつ…
        if( now > 2000 )
        {
          // 非表示状態だったら
          if( !visible )
          {
            // [#page-top]をゆっくりフェードインする
            element.fadeIn( 'slow' ) ;
          }
        }
        // 1500px以下かつ
        // 表示状態だったら
        else if( visible )
        {
          // [#page-top]をゆっくりフェードアウトする
          element.fadeOut( 'slow' ) ;
        }
        // フラグを削除
        syncerTimeout = null ;
      } , 1000 ) ;
    }
  } ) ;

  // クリックイベントを設定する
  $( '#move-page-top' ).click(
      function()
      {
        // スムーズにスクロールする
        $( 'html,body' ).animate( {scrollTop:0} , 'slow' ) ;
        $("#tree-nav-btn").parents('li').addClass("active");
        $("#discussion-nav-btn").parents('li').removeClass("active");
      }
  ) ;

  // 記事を追加で表示する
  $('[id^=entry-child-count]')
  // マウスポインターが画像に乗った時の動作
  .mouseover(function(e) {
      $(this).css('opacity','0.5');
      // $(this).css('background','#e1e8ed');
      $(this).css('cursor','pointer');
  })
  // マウスポインターが画像から外れた時の動作
  .mouseout(function(e) {
    $(this).css('opacity','1');
      // $(this).css('background','white');
      $(this).css('cursor','default');
  });

  $('[id^=entry-child-count]').click(function(){
    $('#entry-child-count'+$(this).attr('entry-id')).remove();
    $('#entry-top-hidden'+$(this).attr('entry-id')).unbind();
    $(this).css('opacity','1');
    $(this).css('cursor','default');
    $('#entry-show-'+$(this).attr('entry-id')).append("<div class='text-center'><img alt='Icon loading' src='/icon-loading.gif' /></div>");

    // 言語の取得
    var lang = 'ja';
    var match = location.search.match(/locale=(.*?)(&|$)/);
    if(match) {
        lang = decodeURIComponent(match[1]);
    }


    // アクションを実行する
    $.ajax({
        url: "/themes/insert_entry/"+$(this).attr('theme-id')+"?locale="+lang,
        type: "GET",
        data: {
                entry: $(this).attr('entry-id')
                },
        success: function(data) {
          $("#entry-show-"+data.match(/\d+/)[0]).html(data);
          slider.set();
          modal.set();
        },
        error: function(data) {
        }
    });

  });

  $('[id^=child-entry-hidden]').hide();
  // 記事を追加で表示する


  // ユーザアイコンを表示
  $('#panel-users-show').on('inview', function(e) {
    $('#panel-users-show').append("<div class='text-center'><img alt='Icon loading' src='/icon-loading.gif' /></div>");
     //ブラウザの表示域に表示されたときに実行する処理Edit

    // 言語の取得
    var lang = 'ja';
    var match = location.search.match(/locale=(.*?)(&|$)/);
    if(match) {
        lang = decodeURIComponent(match[1]);
    }


    $.ajax({
        url: "/themes/insert_users/"+$(this).attr('theme-id')+"?locale="+lang,
        type: "GET",
        data: {
          entry: 2
                },
        success: function(data) {
          $("#panel-users-show").replaceWith(data);
        },
        error: function(data) {
          alert("errror");
        }
    });
    $(this).off(e);
  });
  // ユーザアイコンを表示

  //　ページの移動のロード画面表示
  $('.tab-click').click(function(e) {
    var h = $(window).height();
    $('#wrap').css('display','none');
    $('#loader-bg ,#loader').height(h).css('display','block');
  });
  $('.pege-load-click').click(function(e) {
    var h = $(window).height();
    $('#wrap').css('display','none');
    $('#loader-bg ,#loader').height(h).css('display','block');
  });
  //　ページの移動のロード画面表示

});

// $(window).bind("beforeunload", function() {

//   var user = <%= raw current_user.id.to_json %>;
//   var theme = <%= raw @theme.id.to_json %>;

//   $.ajax({
//     url: "tree/change_session_year",
//     type: "POST",
//     data: {user_id : user,
//       theme: theme,
//       flag: true,
//     },
//     dataType: "html",
//     success: function(data) {
//     },
//     error: function(data) {
//       console.log(data);
//     }
//   });
// });


// #で始まるアンカーをクリックした場合に処理
 $('a[href^=#entry]').click(function() {
    // スクロールの速度
    var speed = 500; // ミリ秒
    // アンカーの値取得
    var href= $(this).attr("href");
    // 移動先を取得
    var target = $(href == "#" || href == "" ? 'html' : href);
    // 移動先を数値で取得
    var position = target.offset().top - 30;
    // スムーススクロール
    $('body,html').animate({scrollTop:position}, speed, 'swing');
    return false;
 });

 // formの文字制限を促進させるjs
 // $('textarea').bind('keydown keyup keypress change',function(){
 //    var thisValueLength = $(this).val().length;
 //    // $('.count').html(thisValueLength);
 //    if(thisValueLength > 200 && thisValueLength < 351 ){
 //      $(this).attr('id', 'form-change-color-green');
 //    }else if(thisValueLength > 350){
 //      $(this).attr('id', 'form-change-color-red');
 //    }else{
 //      $(this).attr('id', 'entry_body');
 //    }
 //  });
