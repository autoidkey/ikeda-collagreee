// 要素ら

var $document = $(document);
var $hitarea = $('.window');
var $eventname = $('#eventname');
var $x = $('#x');
var $y = $('#y');

var doc_details = {

0 : { body:'アニメの好きな人・そうでもない人いると思いますが、アニメの魅力について議論してみましょう！ 例えば、どういうアニメが好きだ、こういうアニメが嫌いだ、アニメを普段見ないから魅力が良く分からないなど自分にとってのアニメについて意見を投稿してみてください。' },
1 : { body:'アニメを見るとき大体の人が録画して見ているとおもいますが アニメを見るときタイミングはいつですか？自分は朝ですね テンションが上がります' },
2 : { body:'面白いだけでなくアニメの魅力はメッセージが込められていることをだと思います。だから大人になっても見ていて面白いのだと思います。' },
3 : { body:'ポジティブなアニメを見ると、元気で前向きになれるので、好きです。特に自分自身が困難に直面するとき、力になります。' },
4 : { body:'アニメにはいろいろなジャンルがあると思いますがどのジャンルが好みですか？自分は4コマ系アニメが好きです.話が複雑だと内容を来週までに忘れてしまうからです' },
5 : { body:'アニメだと、現実ではあり得ないような世界も表現できるので、そこが魅力かなーと。 例えば、未来や過去を舞台にしていたり、魔法が使える世界だったり。 実写で出来なくもないですが、無理やり実写化した結果、残念なことになった作品は数知れず・・・ですからね' },
6 : { body:'自分は一気に見たい派なので、時間はまちまちです。リアルタイムで放送してるのを追うときは、次の日の夜が多いですね' },
7 : { body:'いろいろな教訓とかありますね.パン食べて走ると人にぶつかるとか.ちょっと違いますねw' },
8 : { body:'アニメから学ぶことが多いです' },
9 : { body:'キャラクターが頑張ってる姿を見てキャラクターになりきって見てしまうときが有ります' },
10 : { body:'自分はどっちかというとに、話が連続している方が好きです。 銃器が出てくるハードボイルド系とか、ロボット物とか。 逆に萌え寄りすぎると若干敬遠してしまうところがありますね。' },
11 : { body:'萌えにより過ぎだったりAV系の中身が全くないのは嫌いです' },
12 : { body:'進撃の巨人、コードギアスなどのSFやアクション系が好きです。見ていて楽しいです。主人公がカッコよくて主人公に憧れます！' },
13 : { body:'SF系の主人公はかっこいいので憧れます.しかしSF系は戦争などの暗いテーマが多いのであまり好きではありません' }

}


var link_details = ["2","23","17","3","4","7","24","19","6","12","5","10","9","14"]

var FirstX = 0;
var FirstY = 0;
var Flag = 0;

// タッチイベントが利用可能かの判別

var supportTouch = 'ontouchend' in document;

// イベント名

var EVENTNAME_TOUCHSTART = supportTouch ? 'touchstart' : 'mousedown';
var EVENTNAME_TOUCHMOVE = supportTouch ? 'touchmove' : 'mousemove';
var EVENTNAME_TOUCHEND = supportTouch ? 'touchend' : 'mouseup';

// 表示をアップデートする関数群

var updateXY = function(event) {
  // jQueryのイベントはオリジナルのイベントをラップしたもの。
  // changedTouchesが欲しいので、オリジナルのイベントオブジェクトを取得
  var original = event.originalEvent;
  var x, y;
  if(original.changedTouches) {
    x = original.changedTouches[0].pageX;
    y = original.changedTouches[0].pageY;
  } else {
    x = event.pageX;
    y = event.pageY;
  }
  $x.text(x);
  $y.text(y);

  if(Flag == 0){
    FirsrX = x
    FirstY = y
    
    Flag = 1
  } else if (Flag == 2){
    Flag = 0
    if (FirsrX == x && FirstY == y) {
      var id = event.target.id.slice(11)-1;
      var url = "http://collagree.com/themes/2#entry-"+link_details[id];
      window.open().location.href = url;
      console.log("aaaaaaaaaa")
    };
  }

};

var updateEventname = function(eventname) {
  $eventname.text(eventname);
};

// イベント設定
var handleStart = function(event) {
  updateEventname(EVENTNAME_TOUCHSTART);
  updateXY(event);
  x = event.x;
  y = event.y;
  bindMoveAndEnd();
};

var handleMove = function(event) {
  event.preventDefault(); // タッチによる画面スクロールを止める
  updateEventname(EVENTNAME_TOUCHMOVE);
  updateXY(event);
};

var handleEnd = function(event) {
  Flag = 2
  updateEventname(EVENTNAME_TOUCHEND);
  updateXY(event);
  console.log(doc_details[event.target.id.slice(11)+1])
  //var url = "http://collagree.com/themes/2"+"#entry-24"
  //location.href = url;
  unbindMoveAndEnd();
};

var bindMoveAndEnd = function() {
  $document.on(EVENTNAME_TOUCHMOVE, handleMove);
  $document.on(EVENTNAME_TOUCHEND, handleEnd);
};

var unbindMoveAndEnd = function() {
  $document.off(EVENTNAME_TOUCHMOVE, handleMove);
  $document.off(EVENTNAME_TOUCHEND, handleEnd);
};

$hitarea.on(EVENTNAME_TOUCHSTART, handleStart);
