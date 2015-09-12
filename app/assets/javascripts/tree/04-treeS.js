  function treeSJSON() {
    $( "#dialog" ).dialog({
      autoOpen: false,
      minWidth: 800,
      minHeight:400,
      modal: true,
      buttons: {
        OK: function() {
          $( this ).dialog( "close" );
        }
      }
    });
    

    $( "#opener" ).click(function() {
      $( "#dialog" ).dialog( "open" );
    });


  $(document).on('click','.hub_btn',function(d){
    hub_id = $(this).html();
    console.log(hub_id);

  });


  function show_dialog(message){
    $( "#dialog" ).html(message);
    $( "#dialog" ).dialog( "open" );
  }

  var $format = function(fmt, a)
  {
      var rep_fn = undefined;
      
      if (typeof a == "object") {
          rep_fn = function(m, k) { return a[ k ]; }
      }
      else {
          var args = arguments;
          rep_fn = function(m, k) { return args[ parseInt(k)+1 ]; }
      }
      
      return fmt.replace( /\{(\w+)\}/g, rep_fn);
  }

// 存在チェック
if (String.prototype.format == undefined) {
    /**
     * フォーマット関数
     */
    String.prototype.format = function(arg)
    {
        // 置換ファンク
        var rep_fn = undefined;
        
        // オブジェクトの場合
        if (typeof arg == "object") {
            rep_fn = function(m, k) { return arg[k]; }
        }
        // 複数引数だった場合
        else {
            var args = arguments;
            rep_fn = function(m, k) { return args[ parseInt(k) ]; }
        }
        
        return this.replace( /\{(\w+)\}/g, rep_fn );
    }
}

var w = window.innerWidth;
var h = window.innerHeight;

var keyc = true, keys = true, keyt = true, keyr = true, keyx = true, keyd = true, keyl = true, keym = true, keyh = true, key1 = true, key2 = true, key3 = true, key0 = true

var focus_node = null, highlight_node = null;

var text_center = true;
var outline = false;

var min_score = 0;
var max_score = 1;

var color = d3.scale.linear()
  .domain([min_score, (min_score+max_score)/2, max_score])
  .range(["lime", "yellow", "red"]);


// 10種類の色を返す関数を使う
var color10 = d3.scale.category10();
var initial_opacity = 0.8;

var highlight_color = "#0088FD";
var highlight_trans = 0.5;
  
var size = d3.scale.pow().exponent(1)
  .domain([1,100])
  .range([8,24]);
    
var force = d3.layout.force()
  .distance(60)
  .charge(
          function(d){

            if (d.node_type == 0 || d.node_type == 1){
              return -300;
            }else{
              return -30;
            }

          }
        )
  .gravity(0.1)
  .size([w,h]);

var default_node_color = "#ccc";
//var default_node_color = "rgb(3,190,100)";
var default_link_color = "#ccc";
var nominal_base_node_size = 30;
var nominal_text_size = 10;
var max_text_size = 10;
var nominal_stroke = 1.0;
var max_stroke = 4.5;
var max_base_node_size = 36;
var min_zoom = 0.5;
var max_zoom = 7;
var svg = d3.select("#tree-container").append("svg")

var zoom = d3.behavior.zoom().scaleExtent([min_zoom,max_zoom])
var g = svg.append("g");
svg.style("cursor","move");


// d3.json("graph.json", function(error, graph) {



var graph = {
  "graph": [],
  "links": [

{ source:0, target:1,distance:3.235349297255 },
{ source:0, target:2,distance:2.255758702789 },
{ source:0, target:3,distance:2.273960837261 },
{ source:0, target:4,distance:2.251369114675 },
{ source:0, target:5,distance:2.0649277925927},
{ source:1, target:6,distance:1.235349297255 },
{ source:1, target:7,distance:1.255758702789 },
{ source:1, target:8,distance:1.273960837261 },
{ source:1, target:9,distance:1.251369114675 },
{ source:2, target:10,distance:1.0649277925927 },
{ source:2, target:11,distance:1.235349297255 },
{ source:2, target:12,distance:1.255758702789 },
{ source:3, target:13,distance:1.273960837261 },
{ source:3, target:14,distance:1.251369114675 },
{ source:3, target:15,distance:1.0649277925927 },
{ source:4, target:16,distance:1.0649277925927 },
{ source:4, target:17,distance:1.0649277925927 },
{ source:4, target:18,distance:1.0649277925927 },
{ source:4, target:19,distance:1.0649277925927 },
{ source:4, target:20,distance:1.0649277925927 },
{ source:5, target:21,distance:1.0649277925927 },
{ source:5, target:22,distance:1.0649277925927 },

    ],

  "nodes": [


{ id:0, label:"アニメの魅力",node_type:0,node_size:60 },
{ id:1, label:"面白さ",node_type:1,node_size:40 },
{ id:2, label:"独特の世界観",node_type:2,node_size:45 },
{ id:3, label:"ジャンル",node_type:3,node_size:35 },
{ id:4, label:"好きなアニメ",node_type:4,node_size:40 },
{ id:5, label:"見る方法",node_type:5,node_size:50 },
{ id:6, label:"すっきりする",node_type:1,node_size:20 },
{ id:7, label:"見ていて時間を潰せる",node_type:1,node_size:25 },
{ id:8, label:"主人公のカッコよさ",node_type:1,node_size:25 },
{ id:9, label:"ストーリー",node_type:1,node_size:20 },
{ id:10, label:"ガンダム系",node_type:2,node_size:25 },
{ id:11, label:"進撃の巨人",node_type:2,node_size:25 },
{ id:12, label:"未来",node_type:2,node_size:20 },
{ id:13, label:"SF系",node_type:3,node_size:30 },
{ id:14, label:"エロ",node_type:3,node_size:20 },
{ id:15, label:"ギャグ",node_type:3,node_size:30 },
{ id:16, label:"コードギアス",node_type:4,node_size:20 },
{ id:17, label:"銀魂",node_type:4,node_size:20 },
{ id:18, label:"ワンピース",node_type:4,node_size:40 },
{ id:19, label:"時かけ",node_type:4,node_size:20 },
{ id:20, label:"HUNTER*HUNTAR",node_type:4,node_size:30 },
{ id:21, label:"YouTude",node_type:5,node_size:30 },
{ id:22, label:"寝落ち",node_type:5,node_size:30 }



    ],
  "directed": false,
  "multigraph": false
}


var doc_details = {


0 : { body:'名古屋を取り巻く庄内川と矢田川、そして国道302号線に自転車専用道路(仮名・ケッタウェイ)を整備して、市民の健康状態の向上と、自転車で移動した方が快適な街づくりを行うべきだと思います。またこのサイクリングロードを作ることによって名古屋市と隣接している自治体との交流が加速すると考えられます。' },
1 : { body:'なるほど、サイクリングロード整備によって自転車に快適なまちを作る、ということですね。現在は名古屋市の自転車道はどのくらい整備されているのでしょう。「この辺にあるな～」と思いだされた方、教えてください。' },
2 : { body:'守山区志段味に一応サイクリングロードが存在しますが、行政の広報は極めて消極的ですね。' },
3 : { body:'コメントを入れると賛成でもなく反対でもないのだがどうしても判定されてしまうが、賛成でもなく反対でもない場合はどうしたらいいのでしょうかね？' },
4 : { body:'コメントありがとうございます。投稿欄の下に左右に調節できるスライダーがあります。記述の後にスライダーを調節して投稿のボタンを押すと、賛成反対が反映されると思います。お試しください。' },
5 : { body:'志段味というと、庄内川沿いですね。森林公園も近いですし、いい所のようですね。実際にサイクリングをする人は少ないのでしょうか。それとも知る人ぞ知る穴場ですか？' },
6 : { body:'志段味のサイクリングロードは交通軸として機能していません。なぜ機能していないか？といえば、利用する絶対数が少ない上、身の丈にあっていないからです。もっと利用しやすいエリアを重点的に整備すべきだと思います。主に都心との放射状の道と、それを取り巻く環状線を重点的に。名古屋の道は歩道も車道もとても自転車で走りにくいと思いますので。' },
7 : { body:'名古屋周辺でいうと、桜通り、御用水跡街園とか、春日井市のふれあい緑道が走りやすい部類に入ると思います。残念ながら伏見通の自転車道は走りにくいです。ママチャリの速度域か、スポーツタイプの速度域かで大きく変わりますが、将来的なことを考慮するとクロスバイクで走る速度域で整備することが妥当ではないか？と考えます。' },
8 : { body:'なるほど、楽しみのための自転車道ではなく、通勤などの利便性をある程度考慮して、コース設計をすべきということですね。国内／海外で似たような事例はあるのでしょうか。' },
9 : { body:'ファシリテーターです。都合があって離脱しますが、夜またのぞきに来ます。自転車道の議論を続けてください。他の「都市と自然の調和」のご意見も、お待ちしています。ありがとうございました。' },
10 : { body:'自転車だけに注目をするのではなく、まずは何故に自転車なのかに注目すべきです。海外の場合では、park and rideという仕組みで自転車が移動手段として注目されています。しかし、日本の場合は、自転車、自動車両方が存在するなかでの通勤通学に使うようなことになるので、極めて難しい問題が山積となるように感じます。自転車という事を考える場合に、都心での交通規制に関して同時に検討する必要性を感じます。ドイツなどでは、平日月曜日から金曜日の昼までは都心に交通規制が課せられ、車両の侵入が規制される事は特に有名ですね。' },
11 : { body:'水辺の利用について、何かアイデアのある方はいらっしゃいますか。私は長らく東京近郊に住んでいますが、名古屋は川や池がうまい具合に市内にあるので、なんだかのんびりするのによさそうだなあと思います。また、水辺の困ったところでもご意見あれば、お願いします。' },
12 : { body:'水辺の利用について過日、教育委員会及び環境局職員と雑談程度に話をしました。その中で、水辺というだけでなく生物多様性と郷土愛にちいて子供たちに後世へ繋げるための教育という部分で市長部局の垣根を取り払った形で何か協同できる教育施策を考えられないか？とう話をしました。自然愛護と動物愛護、情操教育とういう部分で後世につなげるものがあれば、環境立国、教育立国としての名古屋が実現できるのではないか？そう思うのですがいかがでしょうか？' },
13 : { body:'確かにそうですね、自転車を移動手段として有効に使うためには、道路だけでなく交通規制、乗り換え場所や駐車場といった視点も同時に考慮して設計する必要があるということですね。行政も局内・局間で連携していただけると実現に近づくのかもしれません。' },
14 : { body:'なるほど、郷土の自然をこどもたちの学習に組み込んでゆくということですね。名古屋圏でも他の地域でも、このような事例をご存知の方はいらっしゃいますか。' },
15 : { body:'そういえば名古屋城外堀にはヒメホタルが生息しているそうですね、とてもめずらしいです。ホタルの保護活動にこどもたちが関与できるといいと思います。' },
16 : { body:'そろそろ、このセッションを終了します。まとめると・健康増進と移動の利便性を兼ね備えた自転車道を整備する案・現状のサイクリングロードは利用量や速度を考えたつくりになっていない・自転車道だけでなく、交通規制や駐車場といった複合的な制度設計が必要ということでよろしいでしょうか。' },
17 : { body:'そろそろ、このセッションを終了します。他にご意見はありますか。' },
18 : { body:'ファシリテーターはいったん退室します。ご意見ありがとうございました。' },
19 : { body:'堀川の導水事業は成功だと思います。北区においても庄内用水緑道、水の回廊モデル事業等が進められてきました。（過去形）木曽川水系連絡導水路事業を進め、豊かな水をお堀と堀川に注ぎ込んでいただきたい。それがひいては伊勢湾の東沿岸部に対しても良い影響を与えると思うのですが。' },
20 : { body:'自転車道の整備は賛成です。なぜ自転車道なのか。自転車が利用できるスロープ、道路の平坦さは、車椅子や足の不自由なお年寄りが歩く上でも有意義です。勿論、そこを利用する自転車乗りのマナーも重要ですが、バリアフリーな散歩道としても自転車道は有意義だと思います。' },
21 : { body:'こんばんは。ファシリテーターです。昨日から、「快適な都市環境」と「自然が調和するまち」をテーマにさまざまな意見を基に議論が開始しています。「快適な都市環境」の中で気持ちよく暮らせるまちの観点から、自転車道のあり方や意味、そして「自然が身近に感じられるまち」として名古屋市内の自然保全や活用の現状の話が挙がっています。深夜ですが、ご自由に思うことを発言してくださいね。' },
22 : { body:'快適な都市環境の形成や魅力と活力にあふれるまちづくりにとっても、自転車の役割は大きい。市が策定した「自転車利用環境基本計画」で言われている、コミュニティサイクルは、他都市の事例を見ていると行政の補助金が無いと民間単独での実現が難しいと思われる。したがって、コミュニティサイクル単体ではなく、有料駐輪場と一体になった運営の仕組みを考えることが必要ではないか。たとえば有料駐輪場の収容台数が500台とすれば、その内50台をコミュニティサイクルの置き場として再整備し、有料駐輪場とコミュニティサイクルを指定管理者に一体で管理運営させることはできないか。' },
23 : { body:'戦後から車社会に比較的に合った道路整備がされ、名古屋の１００メータ道路などは有名になりました！最近では、広い道路がまっすぐに車で走れない様な車線が沢山あります。事故防止のためなのでしょうが、車線が変わる事に、端を発した事故もふえています。まだまだリスクの洗い出しが不足しているように思うのですが、どうでしょうか？' },
24 : { body:'自転車は近接地域間移動に使うためのtoolとしては有効だと考えますが、行政の貸し出すコミュニティーサイクルという思考第一ではなく、マイサイクルとして近接地域間の移動手段として多く利用してもらえるような基盤整備を第一に考えるということはどうでしょうか？極端に日本人的な思考だと、何か事を起こすのには、行政の支援（補助金など）が必要と考えがちですが、まずは自分でできることは自分でという思考で意見提示をしなければ、名古屋市予算がいくらあっても足りなくなるんじゃないですかね？' },
25 : { body:'初投稿します。都市計画などに関して勉強不足なのですが、テーマに興味があり皆さんの意見を読んでいます。基本的な質問なのですが、コミニティサイクル は、レンタサイクルの都市版と言う理解でよいでしょうか。名古屋では見たことがなく(知らないだけかも知れませんが)、環境面等で広がっている施策でしょうか。' },
26 : { body:'レンタルサイクル都市版というカテゴリーに入るのかどうかはその考え方によるものだと思います。名古屋でも、試験的にコミュ二ティーサイクルを始めています。（名チャリ）名古屋の場合コミュニティーサイクルは、その趣旨があまり明確ではないように感じます。環境保全の場合、放置自転車問題、都心渋滞問題などあらゆる面での問題を解消しようとするけど、自転車中心に考えた事で新たな問題を引き起こしている様に感じています。' },
27 : { body:'K. Samamtha . A さま、ありがとうございます。確かに名ちゃりありましたね。名駅ー栄辺りに。いつの間にか見なくなりました。何のための施策、行動なのか、目的なのか、そして市民や名古屋にとってのメリットやデメリットを考えないといけないですね。少し他の都市のコミニティイサイクル事情を見てみます。ありがとうございました。' },
28 : { body:'昔放置自転車が社会問題になり駐輪場をせっせと造り、さらに自転車を私的な乗物から都市内における公共交通の一翼と位置付けて、安全・快適に走ることができる道と共同利用を進めるコミュニティサイクルの推進と時代とともに進展してきました。この３つの施策をうまく融合させることが大切だと思っています。それと行政だけに頼れる時代ではないので、行政は民間が進出しやすい環境を作ることが大切だと思っています。' },
29 : { body:'20日20時より約2時間、ファシリテーターがお邪魔します。このスレッドでは「名古屋の自然環境と緑地」について、皆様のご意見を募集します。自転車の話題・そのほか新しいご意見も引き続きお待ちしております。' },
30 : { body:'ヨッシーさん、みなさま、コミュニティーサイクルの議論ありがとうございます。確かに何のためにコミュニティーサイクルをするのか、利用者が合意できる目的が必要ですね。趣旨に賛同できれば、ご指摘のように行政に頼りきりでなくても民間企業や住民共助で円滑な運用ができるように思います。コミュニティーサイクルについて、民間でできることは、具体的に何かありますか。' },
31 : { body:'ファシリテーターです。道路の設計が以前に比べ変わってきたということですね。今後は必ずしも車が増える社会にならないとも言われているようですが、ドライバーから見ると、道路がどうなっていたら快適でしょうか。ご意見のある方はお願いします。また他の道路利用者の視点もお待ちしています。' },
32 : { body:'返信が遅れて申し訳ございません。僕の自転車道構想＝ケッタウェイ構想は将来のことを見越した上で成り立ってます。今は自転車が中心でしょうが、近未来に次世代型モビリティーが走行することも視野に入れて考えているのです。歩道には歩行者やシニアカーやベビーカー。自転車道には自転車並びにセグウェイなどが走行する。車道は車。この形が理想ではないか？と考えます。' },


}


var connected_hub = {}
graph.links.forEach(function(l){
  if(l.target in connected_hub){
    var list = connected_hub[l.target];
    list.push(l.source);
    connected_hub[l.target] = list;

  }else{
    var list = [];
    list.push(l.source);
    connected_hub[l.target] = list;

  }
});


    console.log(connected_hub[100]);

var linkedByIndex = {};
    graph.links.forEach(function(d) {
    linkedByIndex[d.source + "," + d.target] = true;
    });

    function isConnected(a, b) {
        return linkedByIndex[a.index + "," + b.index] || linkedByIndex[b.index + "," + a.index] || a.index == b.index;
    }

    function hasConnections(a) {
        for (var property in linkedByIndex) {
                s = property.split(",");
                if ((s[0] == a.index || s[1] == a.index) && linkedByIndex[property])                    return true;
        }
    return false;
    }
    
  force
    .nodes(graph.nodes)
    .links(graph.links)
    // .distance(10)
    .linkStrength(function(d){if(d.distance){return d.distance;}else{return 1.0;}})
    .start();

  var link = g.selectAll(".link")
    .data(graph.links)
    .enter().append("line")
    .attr("class", "link")
    .attr("class", "link")
    // .style("distance",1000)
    .style("stroke-width",nominal_stroke)
    .style("stroke", function(d) { 
    if (isNumber(d.score) && d.score>=0) return color(d.score);
    else return default_link_color; 

    })


  var node = g.selectAll(".node")
    .data(graph.nodes)
    .enter().append("g")
    .attr("class", "node")
    
    .call(force.drag)

    
    node.on("dblclick.zoom", function(d) { d3.event.stopPropagation();
    var dcx = (window.innerWidth/2-d.x*zoom.scale());
    var dcy = (window.innerHeight/2-d.y*zoom.scale());
    zoom.translate([dcx,dcy]);
     g.attr("transform", "translate("+ dcx + "," + dcy  + ")scale(" + zoom.scale() + ")");
     
     
    });
    


    
    var tocolor = "fill";
    var towhite = "stroke";
    if (outline) {
        tocolor = "stroke"
        towhite = "fill"
    }
        
    
    
  var circle = node.append("path")
    .attr("d", d3.svg.symbol()
        .size(function(d) { 

          var d_size;

          if (d.node_type == 0){
            d_size = 35;
          }else if(d.node_type == 1){
            d_size = 35;
          }else if(d.node_type == 2){
            d_size = d.node_size;
          }
          return Math.PI*Math.pow(d_size,2);

         })
        .type(function(d) { return d.type; }))
    .style(tocolor, function(d) { 
    // if (isNumber(d.score) && d.score>=0) return color(d.score);
    // else return default_node_color; 
    return color10(d.node_type);
    })
    // .attr("r", function(d){ 
    //             if (d.node_type == 0){
    //               return 3005;
    //             }else if(d.node_type == 1){
    //               return 35;
    //             }else if(d.node_type == 2){
    //               return d.node_size;
    //             }
    // })
    .style("stroke-width", nominal_stroke)
    .attr({
          opacity: initial_opacity,
            })
    .style(towhite, "white");
    
                
  var text = g.selectAll(".text")
    .data(graph.nodes)
    .enter().append("text")
    .attr({
                      "text-anchor":"middle",
                      "dy": ".35em",
                      "fill":"white"
                         })
    .style("font-size", nominal_text_size + "px")

    if (text_center)
     text.text(function(d) { return d.label; })
    .style("text-anchor", "middle");
    else 
    text.attr("dx", function(d) {return (node_size||nominal_base_node_size);})
    .text(function(d) { return '\u2002'+d.id; });


    var drag_check_x = 0.0;
    var drag_check_y = 0.0;


    node.on("mouseover", function(d) {
      // set_highlight(d);
      set_focus(d)
      if (highlight_node === null) set_highlight(d)

    })
  .on("mousedown", function(d) { d3.event.stopPropagation();
      focus_node = d;
      set_focus(d)
      if (highlight_node === null) set_highlight(d)

      drag_check_x = d.x;
      drag_check_y = d.y;

  }   ).on("click", function(d) {
      if(drag_check_x != d.x || drag_check_y != d.y){
          return 0;
      }
      if(d.node_type == 2){
        var s = "";
        console.log(d.id);
        var len = connected_hub[d.id].length;
        var index = 0;
        connected_hub[d.id].forEach(function(_id){
          s += graph.nodes[_id].label;
          if (index < len-1) s+= ",";
          index+=1;
        });
        var msg = "("+len.toString()+"人)" + s;
        var html_part = '<div class="hub_btn">{0}</div>'.format(d.id);
        var msg_body = doc_details[d.id + 1].body;
        show_dialog(msg+html_part+msg_body);


      }


  }   ).on("mouseout", function(d) {
          exit_highlight();

  }   );

        d3.select(window).on("mouseup",  
              function() {
              if (focus_node!==null)
              {
                  focus_node = null;
                  if (highlight_trans<1)
                  {

                        circle.style("opacity", initial_opacity);
                      text.style("opacity", 1);
                      link.style("opacity", 1);
                    // alert("a");

                    }
              }
          
          if (highlight_node === null) exit_highlight();
        });

function exit_highlight()
{
        highlight_node = null;
    if (focus_node===null)
    {
        svg.style("cursor","move");
        if (highlight_color!="white")
    {
      circle.style(towhite, "white");
      text.style("font-weight", "normal");
      link.style("stroke", function(o) {return (isNumber(o.score) && o.score>=0)?color(o.score):default_link_color});
 }
            
    }
}

function set_focus(d)
{   
if (highlight_trans<1)  {
    circle.style("opacity", function(o) {
                return isConnected(d, o) ? 1 : highlight_trans;
            });

            text.style("opacity", function(o) {
                return isConnected(d, o) ? 1 : highlight_trans;
            });
            
            link.style("opacity", function(o) {
                return o.source.index == d.index || o.target.index == d.index ? 1 : highlight_trans;
            });     
    }
}


function set_highlight(d)
{
    svg.style("cursor","pointer");
    if (focus_node!==null) d = focus_node;
    highlight_node = d;

    if (highlight_color!="white")
    {
          circle.style(towhite, function(o) {
                return isConnected(d, o) ? highlight_color : "white";});
            text.style("font-weight", function(o) {
                return isConnected(d, o) ? "bold" : "normal";});
            link.style("stroke", function(o) {
              return o.source.index == d.index || o.target.index == d.index ? highlight_color : ((isNumber(o.score) && o.score>=0)?color(o.score):default_link_color);

            });
    }
}
    
    
  zoom.on("zoom", function() {
  
    var stroke = nominal_stroke;
    if (nominal_stroke*zoom.scale()>max_stroke) stroke = max_stroke/zoom.scale();
    link.style("stroke-width",stroke);
    circle.style("stroke-width",stroke);
       
    var base_radius = nominal_base_node_size;
    if (nominal_base_node_size*zoom.scale()>max_base_node_size) base_radius = max_base_node_size/zoom.scale();
        circle.attr("d", d3.svg.symbol()
        .size(function(d) { return Math.PI*Math.pow(d.node_size*base_radius/nominal_base_node_size||base_radius,2); })
        .type(function(d) { return d.type; }))
        
    //circle.attr("r", function(d) { return (size(d.size)*base_radius/nominal_base_node_size||base_radius); })
    if (!text_center) text.attr("dx", function(d) { return (d.node_size*base_radius/nominal_base_node_size||base_radius); });
    
    var text_size = nominal_text_size;
    if (nominal_text_size*zoom.scale()>max_text_size) text_size = max_text_size/zoom.scale();
    text.style("font-size",text_size + "px");

    g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
    });
     
  svg.call(zoom);     
    
  resize();
  //window.focus();
  d3.select(window).on("resize", resize).on("keydown", keydown);
      
  force.on("tick", function() {
    
    node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
    text.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
  
    link.attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });
        
    node.attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; });
    });
  
  function resize() {
    var width = window.innerWidth, height = window.innerHeight ;
    svg.attr("width", width).attr("height", height);
    
    force.size([force.size()[0]+(width-w)/zoom.scale(),force.size()[1]+(height-h)/zoom.scale()]).resume();
    w = width;
    h = height;
    }
    
    function keydown() {
    if (d3.event.keyCode==32) {  force.stop();}
    else if (d3.event.keyCode>=48 && d3.event.keyCode<=90 && !d3.event.ctrlKey && !d3.event.altKey && !d3.event.metaKey)
    {
  switch (String.fromCharCode(d3.event.keyCode)) {
    case "C": keyc = !keyc; break;
    case "S": keys = !keys; break;
    case "T": keyt = !keyt; break;
    case "R": keyr = !keyr; break;
    case "X": keyx = !keyx; break;
    case "D": keyd = !keyd; break;
    case "L": keyl = !keyl; break;
    case "M": keym = !keym; break;
    case "H": keyh = !keyh; break;
    case "1": key1 = !key1; break;
    case "2": key2 = !key2; break;
    case "3": key3 = !key3; break;
    case "0": key0 = !key0; break;
  }
    
  link.style("display", function(d) {
                var flag  = vis_by_type(d.source.type)&&vis_by_type(d.target.type)&&vis_by_node_score(d.source.score)&&vis_by_node_score(d.target.score)&&vis_by_link_score(d.score);
                linkedByIndex[d.source.index + "," + d.target.index] = flag;
              return flag?"inline":"none";});
  node.style("display", function(d) {
                return (key0||hasConnections(d))&&vis_by_type(d.type)&&vis_by_node_score(d.score)?"inline":"none";});
  text.style("display", function(d) {
                return (key0||hasConnections(d))&&vis_by_type(d.type)&&vis_by_node_score(d.score)?"inline":"none";});
                
                if (highlight_node !== null)
                {
                    if ((key0||hasConnections(highlight_node))&&vis_by_type(highlight_node.type)&&vis_by_node_score(highlight_node.score)) { 
                    if (focus_node!==null) set_focus(focus_node);
                    set_highlight(highlight_node);
                    }
                    else {exit_highlight();}
                }

  }
  }
 
// });

  function vis_by_type(type)
  {
      switch (type) {
        case "circle": return keyc;
        case "square": return keys;
        case "triangle-up": return keyt;
        case "diamond": return keyr;
        case "cross": return keyx;
        case "triangle-down": return keyd;
        default: return true;
  }
  }
  function vis_by_node_score(score)
  {
      if (isNumber(score))
      {
      if (score>=0.666) return keyh;
      else if (score>=0.333) return keym;
      else if (score>=0) return keyl;
      }
      return true;
  }

  function vis_by_link_score(score)
  {
      if (isNumber(score))
      {
      if (score>=0.666) return key3;
      else if (score>=0.333) return key2;
      else if (score>=0) return key1;
  }
      return true;
  }

  function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  }   
}