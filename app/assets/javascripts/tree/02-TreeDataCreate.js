

//ツリーに使用するデータを生成する。
function createTreeData(dataAll, title, youyakuData, claster, classes) {


    // 要約に使用する
    var segmenter
    $(function(){
        segmenter = new TinySegmenter();// インスタンス生成
    })

    //------------------------------------------------
    var linkNode = makeLink(dataAll)
    var entryNP = makeNP(dataAll)
    var ClassArray = makeClass(linkNode)
    var newEntryNum = makeNewEntryNum(dataAll)
    // console.log(newEntryNum)
    var treeData = {
      "dataID": 0,
      "name" : title,
      "childSize" : 18,
      "np" : 0,
      "color": 0,
      "children": childArray(0,0),
      "agreement":false,
      "body": title,
      "user_id": "",
      "newEntry":false,
    }


    return treeData
    //------------------------------------------------

    function make_classter_children(treedata, cla){

    }

    //子供の要素を返す関数
    function serchChild(id) {
        var childArray=[]
        for (var i = 0; i < linkNode.length; i++){
            if(id == linkNode[i]["source"]){
                childArray.push(linkNode[i]["target"])
            }
        }
        return childArray
    }

    //idから何番目の配列にあるかを探す
    function serchDataArray (id) {
        for (var i = 0; i < dataAll.length; i++) {
            if (id == dataAll[i]["id"]) {
                return dataAll[i];
            }
        }
    }

    //すべてのリンク関係を生成
    function makeLink(dataAll) {
        var link = []
        for (var i = 0 ; i < dataAll.length; i++){
            if (dataAll[i]['parent_id'] != null){
                link.push({ source : dataAll[i]['parent_id'] , target : dataAll[i]['id'] });
            }else {
                link.push({ source : 0 , target : dataAll[i]["id"] });
            }
        }
        return link
    }

    function makeClass(link) {
        // 前までのランダムでクラスターを作るやつ
        // var array = []
        // var sep = 5
        // for (var i = 0 ; i < link.length; i++){
        //     if (link[i]['source'] == 0){
        //         var rand = Math.floor( Math.random() * sep + 1) ;
        //         array.push({ cla : rand , id : link[i]['target'] });
        //     }
        // }
        // return 

        console.log(claster)
        return claster

    }

    function serchColor(id){
        for (var i = 0 ; i < ClassArray.length; i++){
            if (ClassArray[i]['id'] == id){
                return ClassArray[i]['cla']
            }
        }
        return 9
    }


    //ここでrubyからのjsonデータをd3.jsが木構造に直すことができる形に直す
    function childArray(ParentId, ParentColor){
      var array = [];
      var child = serchChild(ParentId);

      for(var i = 0 ; i < child.length ; i++){
        var childId = child[i];
        //渡す色を選択する
        var color = ParentColor


        if(ParentColor == 0){
            color = serchDataArray(childId)["claster"]
        }

        var child2 = serchChild(childId);
        //入れる名前を決める
         // var nameText = serchDataArray(childId)["body"].substr(0,20)
         // var nameText = youyaku(serchDataArray(childId)["body"])
        // console.log(serchDataArray(childId)["body"])
        bodyText = serchDataArray(childId)["id"]
        // console.log(bodyText)
        var nameText = ""
        if (serchDataArray(childId)["title"] != null){
            nameText = serchDataArray(childId)["title"]
        }else {
            nameText = youyaku2(serchDataArray(childId)["id"])
        }

        //子供の要素があるかを見て会ったらその子供を入れる
        if (child2.length == 0){
            array.push({"name":String(color)+nameText,"childSize":childSize(childId),"np":entryNP[childId] ,"class" : color ,"body":serchDataArray(childId)["body"],"dataID":serchDataArray(childId)["id"],"agreement":serchDataArray(childId)["agreement"] ,"user_id": serchDataArray(childId)["user_id"], "newEntry":serchNewEntry(childId) })
        }else{
            array.push({"name":String(color)+nameText,"childSize":childSize(childId),"np":entryNP[childId] ,"class" : color ,"body":serchDataArray(childId)["body"],"dataID":serchDataArray(childId)["id"],"agreement":serchDataArray(childId)["agreement"] ,"user_id": serchDataArray(childId)["user_id"], "newEntry":serchNewEntry(childId),children : childArray(childId , color)})
        }
    
      }
      return array
    }

    function makeNP(dataAll){
        var arrayNP = []
        for(var i = 0 ; i < dataAll.length ; i++){
            id = dataAll[i].id
            arrayNP[id] = dataAll[i].np
        }
        return arrayNP
    }

    //jsで実装したよくわからない要約
    function youyaku(text){
        var newText 
        if(text.length >10){
            // console.log("----前----"+text)
            newText = doAction(text)
            // console.log(newText+newText.length )
            while (newText.length < 3 || newText.length>text.length+1){
                newText = doAction(text)
                console.log(newText)
            }
        }else {
            if (text.length>20){
                text = text.substr(20)
            }
            return text
        }
        if (newText.length>20){
                newText = newText.substr(20)
            }
        return newText
    }

    //投稿時間が新しい５つの記事idを出す
    function makeNewEntryNum(dataAll){
        if (dataAll.length < 1){
            return [];
        }
        //exam :array = [1,2,3,5,6]最新の記事５個のidを入れる
        array = []
        array.push({time: dataAll[0]["created_at"], id: dataAll[0]["id"]});

        for(var i = 1 ; i < dataAll.length ; i++){
            var flag = 0
            for(var t = 0 ; t < array.length ; t++){
                if(dataAll[i]["created_at"] >= array[t]["time"] && flag == 0){
                    array.splice( t , 0 , {time:dataAll[i]["created_at"],id:dataAll[i]["id"]} ) ;
                    flag = 1
                    if(array.length > 4){
                        array.pop()
                    }
                    break;
                }
            }
            if (flag == 0 && array.length < 6){
                array.splice( array.length , 0 , {time:dataAll[i]["created_at"],id:dataAll[i]["id"]} ) ;
            }
        }
        rArray = []
        for(var i = 0 ; i < array.length ; i++){
            rArray.push(array[i]["id"])
        }

        return rArray
    }

    //idを入れて新しい記事ならtrue,違うならfalaseを返す
    function serchNewEntry(id){
        for(var i = 0 ; i < newEntryNum.length ; i++){
            if(id == newEntryNum[i]){
                return true;
            }
        }
        return false;
    }

    //pythonを使用した要約
    function youyaku2(id){
        // console.log(id)
        for (var i = 0; i < youyakuData.length; i++){
            if (youyakuData[i]["id"] == id){
                // console.log(youyakuData[i]["text"])
                // console.log(serchDataArray(childId)["body"])
                // console.log(youyakuData[i]["text"])
                if(youyakuData[i]["text"].length < 20){
                    return youyakuData[i]["text"];
                }else{
                    return youyakuData[i]["text"].substr(0, 20);
                }
            }
        }


        // console.log("ようやくなし")
        return serchDataArray(id)["body"].substr(0, 20)

        // console.log("mis")
        // console.log(id)
    }


    //実行
    function doAction(wkIn){
        var segs = segmenter.segment(wkIn);  // 単語の配列が返る
        var dict=makeDic(wkIn)
        var wkbest=doShuffle(dict); 
        for(var i=0;i<=10;i++){
        wkOut=doShuffle(dict).replace(/\n/g,"");    
            if(Math.abs(40-wkOut.length)<Math.abs(40-wkbest.length)){
                wkbest=wkOut
            }
        }

        return wkOut
    }
    //文章をシャッフル
    function doShuffle(wkDic){
        var wkNowWord=""
        var wkStr=""
        wkNowWord=wkDic["_BOS_"][Math.floor( Math.random() * wkDic["_BOS_"].length )];
        wkStr+=wkNowWord;
        while(wkNowWord != "_EOS_"){
            wkNowWord=wkDic[wkNowWord][Math.floor( Math.random() * wkDic[wkNowWord].length )];
            wkStr+=wkNowWord;
        }
        wkStr=wkStr.replace(/_EOS_$/,"。")
        return wkStr;
    }
    //辞書に追加
    function makeDic(wkStr){
        wkStr=nonoise(wkStr);
        var wkLines= wkStr.split("。");
        var wkDict=new Object();
        for(var i =0;i<=wkLines.length-1;i++){
            var wkWords=segmenter.segment(wkLines[i]);
            if(! wkDict["_BOS_"] ){wkDict["_BOS_"]=new Array();}
            if(wkWords[0]){wkDict["_BOS_"].push(wkWords[0])};//文頭

            for(var w=0;w<=wkWords.length-1;w++){
                var wkNowWord=wkWords[w];//今の単語
                var wkNextWord=wkWords[w+1];//次の単語
                if(wkNextWord==undefined){//文末
                    wkNextWord="_EOS_"
                }
                if(! wkDict[wkNowWord] ){
                    wkDict[wkNowWord]=new Array();
                }
                wkDict[wkNowWord].push(wkNextWord);
                if(wkNowWord=="、"){//「、」は文頭として使える。
                    wkDict["_BOS_"].push(wkNextWord);
                }
            }

        }
        return wkDict;
    }

    function childSize(id){
        var childCount = 1;
        var childArray = serchChild(id);
        if(childArray.length!=0){
            for(var i = 0;i<childArray.length;i++){
                childCount = childCount + childSize(childArray[i])
            }
        }else {
            return 1 ;
        }
        return childCount;
    }

    function sRate(id,rate,p){
        var rateSum = 0;
        var childArray = serchChild(id);
        var len = childArray.length;
        if(len==0 && p==1){
            return rate;
        }else if(len==0 && p==0){
            return 0;
        }
        for(var i = 0; i<childArray.length; i++){
            childP = serchDataArray(childArray[i])["np"]
            if(childP>50){
                rateSum = rateSum + sRate(childArray[i],rate/len,p)
            }else{
                if(p==0){
                    rateSum = rateSum + sRate(childArray[i],rate/len,1)
                }else{
                    rateSum = rateSum + sRate(childArray[i],rate/len,0)
                }
            }
        }
        return rateSum

    }



    //ノイズ除去
    function nonoise(wkStr){
        wkStr=wkStr.replace(/\n/g,"。");
        wkStr=wkStr.replace(/[\?\!？！]/g,"。");
        wkStr=wkStr.replace(/[-|｜:：・]/g,"。");
        wkStr=wkStr.replace(/[「」（）\(\)\[\]【】]/g," ");
        return wkStr;
    }

}