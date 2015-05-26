function onReady() {

    // var linkNode = [
    //         { source:0, target:1 },
    //         { source:0, target:2 },
    //         { source:0, target:3 },
    //         { source:0, target:4 },
    //         { source:0, target:5 },
    //         { source:1, target:6 },
    //         { source:2, target:7 },
    //         { source:3, target:8 },
    //         { source:3, target:9 },
    //         { source:4, target:10 },
    //         { source:4, target:11 },
    //         { source:10, target:12 },
    //         { source:11, target:13 }
    // ]

    // var nodeData = [
    //     { id:0, text:"アニメの魅力", depth:0},
    //     { id:2, text:"アニメの魅力", depth:1 },
    //     { id:3, text:"ボジティブなアニメが好き", depth:1},
    //     { id:4, text:"アニメのジャンル", depth:1 },
    //     { id:5, text:"アニメの独特の世界観", depth:1 },
    //     { id:6, text:"一気に見たい派", depth:2 },
    //     { id:7, text:"いろいろな教訓", depth:2 },
    //     { id:8, text:"学ぶ", depth:2 },
    //     { id:10, text:"ハードボイルド系、ロボット系", depth:2 },
    //     { id:11, text:"SF、アクション", depth:2 },
    //     { id:12, text:"萌え、AV系", depth:3 },
    //     { id:9, text:"頑張っている姿", depth:2 },
    //     { id:13, text:"SF系", depth:3 },
    //     { id:1, text:"アニメの見るタイミング", depth:1 },
    // ]

    // var nodeBodyText = [
    //     "アニメの魅力",
    //     "アニメを見るとき大体の人が録画して見ているとおもいますがアニメを見るときタイミングはいつですか？自分は朝ですね テンションが上がります",
    //     "面白いだけでなくアニメの魅力はメッセージが込められていることをだと思います。だから大人になっても見ていて面白いのだと思います。",
    //     "ポジティブなアニメを見ると、元気で前向きになれるので、好きです。特に自分自身が困難に直面するとき、力になります。",
    //     "アニメにはいろいろなジャンルがあると思いますがどのジャンルが好みですか？自分は4コマ系アニメが好きです。話が複雑だと内容を来週までに忘れてしまうからです",
    //     "アニメだと、現実ではあり得ないような世界も表現できるので、そこが魅力かなーと。 例えば、未来や過去を舞台にしていたり、魔法が使える世界だったり。 実写で出来なくもないですが、無理やり実写化した結果、残念なことになった作品は数知れず・・・ですからね",
    //     "自分は一気に見たい派なので、時間はまちまちです。 リアルタイムで放送してるのを追うときは、次の日の夜が多いですね",
    //     "いろいろな教訓とかありますね.パン食べて走ると人にぶつかるとかちょっと違いますねw",
    //     "アニメから学ぶことが多いです",
    //     "キャラクターが頑張ってる姿を見てキャラクターになりきって見てしまうときが有ります",
    //     "自分はどっちかというとに、話が連続している方が好きです。銃器が出てくるハードボイルド系とか、ロボット物とか。 逆に萌え寄りすぎると若干敬遠してしまうところがありますね。",
    //     "進撃の巨人、コードギアスなどのSFやアクション系が好きです。見ていて楽しいです。主人公がカッコよくて主人公に憧れます！",
    //     "萌えにより過ぎだったりAV系の中身が全くないのは嫌いです",
    //     "SF系の主人公はかっこいいので憧れます。しかしSF系は戦争などの暗いテーマが多いのであまり好きではありません",
    // ]

    var testlink = [
        { source:0, target:1 },
        { source:0, target:2 },
        { source:0, target:3 },
        { source:0, target:4 },
        { source:0, target:5 },
        { source:0, target:6 },
        { source:0, target:7 },
        { source:0, target:8 },
        { source:0, target:9 },
        { source:0, target:10 },
    ]

    var testdata = [
        { id:0, text:"aaaa", depth:0, depthCount:0 },
        { id:1, text:"aaaa", depth:1, depthCount:0 },
        { id:2, text:"aaaa", depth:1, depthCount:1 },
        { id:3, text:"aaaa", depth:1, depthCount:2 },
        { id:4, text:"aaaa", depth:1, depthCount:3 },
        { id:5, text:"aaaa", depth:1, depthCount:4 },
        { id:6, text:"aaaa", depth:1, depthCount:5 },
        { id:7, text:"aaaa", depth:1, depthCount:6 },
        { id:8, text:"aaaa", depth:1, depthCount:7 },
        { id:9, text:"aaaa", depth:1, depthCount:8 },
        { id:10, text:"aaaa", depth:1, depthCount:9 },
    ]

    var json = jsonBack();
    var dataAll = childBack()
    var linkNode = []
    var nodeData = []
    var nodeBodyText = []




    // var makeData = function() {
    //     var dataAll = childBack()
    //     for (var i = 0; i < dataAll.length ; i++){
    //         if (dataAll[i]["parent_id"] == null){
    //             linkNode.push({ source : 0 , target : dataAll[i]["id"] })
    //             nodeData.push({ id:dataAll[i]["id"], text:dataAll[i]["title"], depth:1 , body:dataAll[i]["body"]})
    //         }
    //     }
    // }


    //一番上のノードの処理
    nodeBodyText.push(titleBack());
    nodeData[0] = {id:0, text:titleBack(), depth:0 };
    // var div = $('<div class="window" id="chartWindow0">'+titleBack()+'</div>');
    // $("#chart-demo").append(div);


    //すべてのリンク関係を生成
    for (var i = 0 ; i < dataAll.length; i++){
        if (dataAll[i]['parent_id'] != null){
            linkNode.push({ source : dataAll[i]['parent_id'] , target : dataAll[i]['id'] });
        }else {
            linkNode.push({ source : 0 , target : dataAll[i]["id"] });
            nodeBodyText.push(dataAll[i]["body"]);
            nodeData.push({id:dataAll[i]["id"], text:dataAll[i]["title"], depth:1 })
        }
    }

    console.log("--------------------------")
    console.log(dataAll)
    console.log(linkNode)
    console.log(nodeData)
    console.log(nodeBodyText)


    //dataAllから指定のidのデータを取り出す
    function iSerch(id) {
        for (var i = 0 ; i < dataAll.length; i++){
            if (dataAll[i]['id'] == id){
                return dataAll[i]
            }
        }
    }

    console.log("--------------------------")
    makeNode();
    console.log("--------------------------") 
    console.log(nodeData)
    //
    function makeNode() {
        var array = [0]
        var child = serchChild(array[0])
        array.splice(0, 1)
        for (var i = 0; i<child.length; i++) {

            array.push(child[i])
        };

        while(array.length　!=　0 ){
            for (var i = 0; i　<　array.length; i++) {
                var child = serchChild(array[0])
                array.splice(0, 1)
                for (var i = 0; i<child.length; i++) {
                    var data = iSerch(child[i])
                    array.push(child[i])
                    console.log(data)

                    //データの追加
                    var p = serchParent(child[i])
                    var d = serchIdData(p)["depth"] 

                    nodeBodyText.push(data["body"]);
                    nodeData.push({id:data["id"], text:data["body"].slice(0, 6), depth:d+1 })
                };
            };
        }

    }

    //ノードの配置を設定する！
    nodeSet()

    var wSet = 12
    var pSet = 6
    //すべての子供の長さを計算
    function childWidth(){
        var dataWidthArray = []
        for (var i = 0; i < nodeData.length; i++){
            var c = serchChild(nodeData[i]["id"]).length
            if(c>1){
                var width = wSet*c +pSet * (c-1)
                dataWidthArray[i] = width
            }else {
                dataWidthArray[i]=0
            }
        }


    }




    function nodeSet(){

        //idと配列順を並び替える！
        // var tempArray = []
        //  for (var i = 0; i < nodeData.length; i++){
        //     var flag = 0
        //     for (var t = 0; t < nodeData.length; t++){
        //         if (i == nodeData[t]["id"]){
        //             tempArray[i] = nodeData[t]
        //             flag = 1
        //         }
        //         if (flag == 1){
        //             break
        //         }
        //     }
        // }
        // nodeData = tempArray

        console.log(nodeData)

        //その深さにどれだけ数があるかを探して配列に代入していく かつ　depthCountをつけていく
        var countArray = []
        for (var t = 0; t < nodeData.length; t++){
            var d = nodeData[t]["depth"]
            if (countArray[d] == null) {
                countArray[d] = 0
                nodeData[t]["depthCount"] = 0
            }else {
                countArray[d] = countArray[d] + 1
                nodeData[t]["depthCount"] = countArray[d]
            }
        }




        // depthArrayにそれぞれの深さの値を入れておく
        var depthArray = []
        var pushNum = 0
        var arrayTemp = []
        for (var i = 0; i < nodeData.length; i++){
            arrayTemp.push(i);
            if(i==nodeData.length-1){
                depthArray.push(arrayTemp);
                break;
            } 
            if(nodeData[i]["depth"]!=nodeData[i+1]["depth"]){
                depthArray.push(arrayTemp);
                arrayTemp = []
            }
        }



        //それぞれの下のノードの長さを調べる
        var dataWidthArray = []
        for (var i = 0; i < nodeData.length; i++){
            var c = serchChild(nodeData[i]["id"]).length
            if(c>1){
                console.log(c)
                var d = nodeData[i]["depth"]
                var width = c*10*Math.pow(0.9,d+1)+10*Math.pow(0.9,d+1)*0.6*c
                dataWidthArray[i] = width
            }else {
                dataWidthArray[i]=0
            }
        }


        //それぞれのノードの配置を決定する
        var dataLocateArray = []
        //それぞれの深さの今決定している長さ
        var depthLengthArray = []
        var nowDepth = 1
        for (var i = 1; i < nodeData.length; i++){
            var count = nodeData[i]["depthCount"]
            var w = 10*Math.pow(0.9,nowDepth)
            var l = (count+1)*w+w*0.8*(count)+add

            if (nowDepth!=nodeData[i]["depth"]){
                nowDepth++;
            }

            if (dataWidthArray[i]==0){
                dataLocateArray[i] = w
                depthLengthArray[i] = depthLengthArray[i]+w
                depthLengthArray[i+1] = depthLengthArray[i+1]+w
            }else {

            }
        }

        console.log(dataLocateArray)
        console.log(depthLengthArray)

        //配列の合計を求める
        var sum  = function(arr) {
        var sum = 0;
        for (var i=0,len=arr.length; i<len; ++i) {
            sum += arr[i];
        };
        return sum;
        };




        var setWindow = function(name,l,t,num,w,h){
            console.log(num)
            var id = "chartWindow"+num
            var div = $('<div class="window" id='+id+'>'+name+'</div>');
            $("#chart-demo").append(div);
            $('#chartWindow'+num).css({
              'left': l+'em',  
              'top': t+'em', 
              'width': w+'em',
              //'height': h+'em',
            }); 
        }
        
    

        var add = 0
        var deforeAdd = 0
        //それぞれのノードの配置を決定してノードを配置する
        var dataLocateArray = []
        var nowDepth = 1
        for (var i = 1; i < nodeData.length; i++){
            var count = nodeData[i]["depthCount"]
            var d = nodeData[i]["depth"] 
            if (nowDepth!=d){
                nowDepth=d
                add=0
            }
            var w = 10*Math.pow(0.9,d)
            var h = 4*Math.pow(0.9,d)
            var l = (count+1)*w+w*0.8*(count)+add

            if (dataLocateArray[i]!=null && d!=1){
                l = dataLocateArray[i]
            }


            var t = (d+1)*16
            if(dataWidthArray[i]!=0 && d==1){
                add = add+dataWidthArray[i]/2
                deforeAdd = dataWidthArray[i]/2
                l = l + deforeAdd
            }
            setWindow(nodeData[i]["text"],l,t,nodeData[i]["id"],w,h)
            dataLocateArray[i] = l

            //その子供にデータを継承する
            var c = serchChild(nodeData[i]["id"])
            if (c.length==1){
                dataLocateArray[serchDataReverse(c[0])]=l
            }else if(c.length==2){
                dataLocateArray[serchDataReverse(c[0])]=l-w
                dataLocateArray[serchDataReverse(c[1])]=l+w
            }else if(c.length==3){
                dataLocateArray[serchDataReverse(c[0])]=l-w
                dataLocateArray[serchDataReverse(c[1])]=l
                dataLocateArray[serchDataReverse(c[2])]=l+w
            }else if(c.length==4){
                dataLocateArray[serchDataReverse(c[0])]=l-w/2-w
                dataLocateArray[serchDataReverse(c[1])]=l-w/2
                dataLocateArray[serchDataReverse(c[2])]=l+w/2
                dataLocateArray[serchDataReverse(c[3])]=l+w/2+w
            }else if(c.length==5){
                dataLocateArray[serchDataReverse(c[0])]=l-w/2-w
                dataLocateArray[serchDataReverse(c[1])]=l-w
                dataLocateArray[serchDataReverse(c[2])]=l
                dataLocateArray[serchDataReverse(c[3])]=l-w/2
                dataLocateArray[serchDataReverse(c[4])]=l-w/2+w
            }
        }

         setWindow(nodeData[0]["text"],dataWidthArray[0]/2,10,0,10,4)
    }

    function setWindow(name,l,t,num,w,h){
        console.log(num)
        var id = "chartWindow"+num
        var div = $('<div class="window" id='+id+'>'+name+'</div>');
        $("#chart-demo").append(div);
        $('#chartWindow'+num).css({
          'left': l+'em',  
          'top': t+'em', 
          'width': w+'em',
          //'height': h+'em',
        }); 
    }


    function serchChild(id) {
        var childArray=[]
        for (var i = 0; i < linkNode.length; i++){
            if(id == linkNode[i]["source"]){
                childArray.push(linkNode[i]["target"])
            }
        }
        return childArray
    }

    function serchParent(id) {
        for (var i = 0; i < linkNode.length; i++){
            if(id == linkNode[i]["target"]){
                return linkNode[i]["source"]
            }
        }
    }

    //引数を含めたその子要素全員を返す
    function serchChildAll(id) {
        var childArray = [id]
        var tempArray = []

        while(childArray.length != 0){
            var children = serchChild(childArray[0])
            tempArray.push(childArray[0])
            for (var i = 0; i < children.length; i++){
                childArray.push(children[i])
            }
            childArray.splice(0, 1); 
        }
        return tempArray

    }

    //idが同じノードデータを探して返す
    function serchIdData (id) {
        for (var i = 0; i < nodeData.length; i++) {
            if (id == nodeData[i]["id"]) {
                return nodeData[i]
            }
        }
    }

    //idから何番目の配列にあるかを探す
    function serchDataReverse (id) {
        for (var i = 0; i < nodeData.length; i++) {
            if (id == nodeData[i]["id"]) {
                return i
            }
        }
    }

    




    var color = "gray";
    var scaleValue = 1.0


    var instance = jsPlumb.getInstance({
        // notice the 'curviness' argument to this Bezier curve.  the curves on this page are far smoother
        // than the curves on the first demo, which use the default curviness value.
        ConnectionOverlays: [

            [ "Arrow", { location: 0.85 } ],
        ],

        Connector: [ "Bezier", { curviness: 50 } ],
        DragOptions: { cursor: "pointer", zIndex: 2000 },
        PaintStyle: { strokeStyle: color, lineWidth: 3 },
        EndpointStyle: { radius: 10, fillStyle: color },
        HoverPaintStyle: {strokeStyle: "#ec9f2e" },
        EndpointHoverStyle: {fillStyle: "#ec9f2e" },
        Container: "chart-demo"

    });

    window.setZoom = function(zoom, instance, transformOrigin, el) {
      transformOrigin = transformOrigin || [ 0.5, 0.5 ];
      instance = instance || jsPlumb;
      el = el || instance.getContainer();
      var p = [ "webkit", "moz", "ms", "o" ],
          s = "scale(" + zoom + ")",
          oString = (transformOrigin[0] * 100) + "% " + (transformOrigin[1] * 100) + "%";

      for (var i = 0; i < p.length; i++) {
        el.style[p[i] + "Transform"] = s;
        el.style[p[i] + "TransformOrigin"] = oString;
      }

      el.style["transform"] = s;
      el.style["transformOrigin"] = oString;

      instance.setZoom(zoom);    
    };



    var basicType = {
        overlays: [
            "Arrow"
        ]
    };

    instance.registerConnectionType("basic", basicType);

    // suspend drawing and initialise.
    instance.batch(function () {
        // declare some common values:
        var arrowCommon = { foldback: 0.7, fillStyle: color, width: 14 },
        // use three-arg spec to create two different arrows with the common values:
            overlays = [
                [ "Arrow", { location: 0.7 }, arrowCommon ],
                [ "Arrow", { location: 0.3, direction: -1 }, arrowCommon ]
            ];

        // add endpoints, giving them a UUID.
        // you DO NOT NEED to use this method. You can use your library's selector method.
        // the jsPlumb demos use it so that the code can be shared between all three libraries.
        var windows = jsPlumb.getSelector(".chart-demo .window");

        for (var i = 0; i < windows.length; i++) {
            instance.addEndpoint(windows[i], {
                uuid: windows[i].getAttribute("id") + "-bottom",
                anchor: "Bottom",
                maxConnections: -1,
                isSource: true,
                isTarget: true
            });
            if(i!=0){
                instance.addEndpoint(windows[i], {
                    uuid: windows[i].getAttribute("id") + "-top",
                    anchor: "Top",
                    maxConnections: -1,
                    isSource: true,
                    isTarget: true
                });
            }
        }

        instance.bind("connection", function (connInfo, originalEvent) {
            init(connInfo.connection);
        });

        //instance.draggable(jsPlumb.getSelector(".chart-demo .window"), { grid: [20, 20] });

        // instance.connect({uuids: ["chartWindow3-bottom", "chartWindow6-top" ], overlays: overlays, detachable: true, reattach: true});
        for (var i = 0 ;i < linkNode.length ; i++ ){

                var from = "chartWindow"+linkNode[i]["source"]+"-bottom"
                var to = "chartWindow"+linkNode[i]["target"]+"-top"
                instance.connect({uuids: [from, to], editable: true});
        }
          //instance.connect({uuids: [from, to], editable: true});
        
        instance.draggable(windows);

    });


    //コネックションをクリックした時の意イベント
    instance.bind("click", function (conn, originalEvent) {
            //if (confirm("Delete connection from " + conn.sourceId + " to " + conn.targetId + "?"))
                //instance.detach(conn);
            //console.log(conn)
            //var source = conn.targetId+"-top";
            //var target = conn.sourceId+"-bottom";
            //instance.connect({uuids: [source, target], editable: true});
            instance.detach(conn);
            //conn.toggleType("basic");
            //すべてのエンドポイントを消す
            //updateXY();


    });

    jsPlumb.fire("jsPlumbDemoLoaded", instance);



    var toId = ""
    var fromId = ""
    var thisTemp
    //ノードの繋ぎ換えをするupdateXY()
    var updateConect = function(message) {
        console.log(toId)
        //結合したノードのテキストを変更する！
        document.getElementById(toId.substr(1)).innerHTML=message;
        nodeData[toId.slice(12)]["text"] = message
        console.log(thisTemp)
        //すべてのノードを消してから選択ノードを消す
        instance.deleteEveryEndpoint();
        $(fromId).remove()

        //結合ノードの大きさを大きくする
        var widthNew = $(thisTemp).css("width") 
        var size = $(thisTemp).css("font-size")
        var top = $(thisTemp).css("top")
        var left = $(thisTemp).css("left")
        size = (size.substring( 0, size.length-2)*1.2) + "px"
        widthNew = (widthNew.substring( 0, widthNew.length-2 )*1.25) + "px"
        $(toId).css({"color":"red","width":widthNew , "font-size":size , "top":top , "left" : left })


        toId = toId.slice(12)
        fromId = fromId.slice(12)

        //ノードの削除
        for (var i = 0 ;i < linkNode.length ; i++ ){
            if (linkNode[i]["target"]==fromId) {
                linkNode.splice(i, 1);
            };
        }

        //ノードの追加
        var l = linkNode.length
        for (var i = 0 ;i < l ; i++ ){
            if (linkNode[i]["source"]==fromId) {
                var t = linkNode[i]["target"]
                linkNode.push({ source:toId,target:t })
            }
         };
    

         updateLinkConect();

    };

    var updateLinkConect = function() {
        console.log("updateLinkConect")
        console.log(linkNode)

        instance.deleteEveryEndpoint();

             // suspend drawing and initialise.
        instance.batch(function () {
            // declare some common values:
            var arrowCommon = { foldback: 0.7, fillStyle: color, width: 14 },
            // use three-arg spec to create two different arrows with the common values:
                overlays = [
                    [ "Arrow", { location: 0.7 }, arrowCommon ],
                    [ "Arrow", { location: 0.3, direction: -1 }, arrowCommon ]
                ];

            // add endpoints, giving them a UUID.
            // you DO NOT NEED to use this method. You can use your library's selector method.
            // the jsPlumb demos use it so that the code can be shared between all three libraries.
            var windows = jsPlumb.getSelector(".chart-demo .window");

            for (var i = 0; i < windows.length; i++) {
                instance.addEndpoint(windows[i], {
                    uuid: windows[i].getAttribute("id") + "-bottom",
                    anchor: "Bottom",
                    maxConnections: -1,
                    isSource: true,
                    isTarget: true
                });
             
                    instance.addEndpoint(windows[i], {
                        uuid: windows[i].getAttribute("id") + "-top",
                        anchor: "Top",
                        maxConnections: -1,
                        isSource: true,
                        isTarget: true
                    });
                
            }

            instance.bind("connection", function (connInfo, originalEvent) {
                init(connInfo.connection);
            });

            //instance.draggable(jsPlumb.getSelector(".chart-demo .window"), { grid: [20, 20] });
            for (var i = 0 ;i < linkNode.length ; i++ ){
                var from = "chartWindow"+linkNode[i]["source"]+"-bottom"
                var to = "chartWindow"+linkNode[i]["target"]+"-top"
                instance.connect({uuids: [from, to], editable: true});
            }
            // instance.connect({uuids: ["chartWindow3-bottom", "chartWindow6-top" ], overlays: overlays, detachable: true, reattach: true});

            instance.draggable(windows);

        });
    }

    //　重なり判定！
    $(".window").draggable();

    $( ".window" ).droppable({
        accept : ".window" , // 受け入れる要素を指定
        drop : function(event , ui){

            // 結合ノードを消すのと結合ノードを大きくする
            toId = "#"+$(this).attr("id")
            fromId = "#"+ui.draggable.attr("id")

            console.log(fromId)
            console.log(toId)

            console.log(this)
            thisTemp = this
            
            //つなぎかえをするのかを判定
            if (serchIdData(toId.slice(12))["depth"]==1 && serchIdData(fromId.slice(12))["depth"]==1){
            }else if (serchParent(toId.slice(12)) == serchParent(fromId.slice(12))) {
            }else {
                return
            }

            var text1 = "ToText:"+serchIdData(toId.slice(12))["text"]+"<p>"+serchIdData(toId.slice(12))+"</p>"+"<hr>"
            var text2 = "FromText:"+serchIdData(fromId.slice(12))["text"]+"<p>"+serchIdData(fromId.slice(12))+"</p>"
            var bodyText = serchIdData(toId.slice(12))["text"]+ serchIdData(fromId.slice(12))["text"]
            var form = '<p>テーマ</p><input type="text" name="inputtxt" id="inputtxt" value='+bodyText+'>' 
            show_dialog( text1+text2+form , 0);

        } ,
        out : function (event , ui){
            //var dragId = ui.draggable.attr("id");
            // $(this).find(".drop" + dragId).remove();
        }

    });


    $("#click-event-big").click(function(){
        scaleValue = scaleValue - 0.1
        setZoom(scaleValue,instance)
        var w1 = $("#chart-demo").css("width")
        var h1 = $("#chart-demo").css("height")
    
        var w = Number(w1.substring(0, w1.length-2)) * 1.05
        var h = Number(h1.substring(0, h1.length-2)) * 1.05

        $("#chart-demo").css({"width":w+"px" , "height":h+"px"})

    });

    $("#click-event-small").click(function(){
        scaleValue = scaleValue + 0.1
        setZoom(scaleValue,instance);
            
        var w1 = $("#chart-demo").css("width")
        var h1 = $("#chart-demo").css("height")
    
        var w = Number(w1.substring(0, w1.length-2)) * 0.95
        var h = Number(h1.substring(0, h1.length-2)) * 0.95

        $("#chart-demo").css({"width":w+"px" , "height":h+"px"})
    });


    $( "#dialog_connect" ).dialog({
      autoOpen: false,
      minWidth: 800,
      minHeight:400,
      modal: true,
      buttons: {
        OK: function() {
          var message = $( this ).find('input').val();
          $( this ).dialog( "close" );
          console.log("message="+message);
          updateConect(message);
        },
        キャンセル: function() {
          $( this ).dialog( "close" );
        },
      }
    });

    $( "#dialog_thred" ).dialog({
      autoOpen: false,
      minWidth: 800,
      minHeight:400,
      modal: true,
      buttons: {
        OK: function() {
            //表示テキストとデータの変更を一括で行う
            var message = $( this ).find('input').val();
            document.getElementById(toId).innerHTML= message;
            serchIdData(toId.slice(11))["text"] = message

            //ラジオボタンが押されているかの処理をしていく
            var radioVal = $("input[name='radio_test']:checked").val();

            //１つのスレッドのみを強要させる
            if (radioVal == 0) {
                //結合ノードの大きさを大きくする
                console.log("bigbigbig")
                console.log(thisTemp)
                var widthNew = $(thisTemp).css("width") 
                var size = $(thisTemp).css("font-size")
                var top = $(thisTemp).css("top")
                var left = $(thisTemp).css("left")
                size = (size.substring( 0, size.length-2)*1.2) + "px"
                widthNew = (widthNew.substring( 0, widthNew.length-2 )*1.25) + "px"
                $(thisTemp).css({"color":"red","width":widthNew , "font-size":size, "top":top , "left" : left})
                updateLinkConect();

            }else if (radioVal == 1){
                //スレッド全体を拡大する
                var array = serchChildAll(toId.slice(11))
                for (var i = 0 ; i < array.length ; i++){
                    var id = "#chartWindow" + array[i];
                    console.log(id);
                    $(id).css({"border-color":"red" , "border-width":"1px"});
                }
            }
         　 $( this ).dialog( "close" );

        },
        キャンセル: function() {
          $( this ).dialog( "close" );
        },
      }
    });

    

    function show_dialog(message,num){
        if (num == 0){
            $( "#dialog_connect" ).html(message);
            $( "#dialog_connect" ).dialog( "open" );
        }else if (num == 1){
            $( "#dialog_thred" ).html(message);
            $( "#dialog_thred" ).dialog( "open" );
        }
      }




    var touchX = 0
    var touchY = 0
      /* タッチの開始時のイベント */
    $('.window').bind('mousedown', function() {
        touchX = event.pageX;   // X 座標の位置
        touchY = event.pageY;   // Y 座標の位置
    });

    /* マウスボタンを離したときのイベント */
    $('.window').bind('mouseup', function() {

        if (touchX == event.pageX && touchY == event.pageY){
            console.log(this.id)
            var touchId = this.id.slice(11)
            var text1 = "<p>タイトル:" + serchIdData(touchId)["text"] + "<p>"+"<p>"+nodeBodyText[serchDataReverse(touchId)]+"</p>"+"<hr>"
            var textForm = '<p>タイトル変更</p><input type="text" name="inputtxt" id="inputtxt" value='+ serchIdData(touchId)["text"] +'>' 
            var textButton1 = "<p>１つのスレッド強調　"+'<input type="radio" id="rd0" name="radio_test" value="0" /></p>'
            var textButton2 = "<p>スレッド全体強調　"+'<input type="radio" id="rd1" name="radio_test" value="1" /></p>'
            toId = this.id
            thisTemp = this
            show_dialog(text1+textForm+textButton1+textButton2 , 1 )

        }
    });


    $("#push").click(function(){
        console.log("aaaaaa")
        changeNode (2,4)
    })

    function changeNode (id1,id2) {
        //id2のほうが大きいとする！
        if (id1 > id2){
            var temp = id1
            id1 = id2
            id2 = temp
        }

        nodeData[id2]["id"] = nodeData[id1]["id"] + 1;  
        console.log(nodeData[id2]["id"])
        for (var i = 1 ; i < (id2 - id1) ; i++) {
            nodeData[id1+i]["id"] = nodeData[id1+1]["id"]+1;  
        }  

        //一度すべてのhtml要素を消す！
        for (var i = 1 ; i <nodeData.length ; i++) {
            var id = "#chartWindow"+i;
            $(id).remove();
        }  
        

        instance.deleteEveryEndpoint();
        nodeSet();
        updateLinkConect();

    }

    //ボタンの子要素の中心点を取る
    function centerPoint (id) {
        var array = serchChildAll(id)
        var xSum = 0
        var ySum = 0
        for (var i = 0 ; i < array.length ; i++){
            var id = "#chartWindow"+array[i]
            var x = $(id).css('width')
            var y = $(id).css('height')
            console.log(x)
            xSum = xSum + Number(x.substring(0 , x.length-2));
            ySum = ySum + Number(y.substring(0 , y.length-2));
        }
        console.log(xSum / array.length)
        console.log(ySum / array.length)
        console.log("result")
        return [xSum / array.length , ySum / array.length]

    }

    $("#pushCheck1").click(function(){
        updateLinkConect();
    });

    $("#pushCheck2").click(function(){
        nodeSet();
    });






}