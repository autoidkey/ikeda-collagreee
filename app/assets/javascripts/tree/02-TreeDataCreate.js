

//ツリーに使用するデータを生成する。
function createTreeData(dataAll,title,youyakuData) {


    // 要約に使用する
    var segmenter
    $(function(){
        segmenter = new TinySegmenter();// インスタンス生成
    })

    //------------------------------------------------
    var linkNode = makeLink(dataAll)
    var treeData = {
          "name" : title,
          "childSize" : 18,
          "children": childArray(0)
    }
    return treeData
    //------------------------------------------------

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


    //ここでrubyからのjsonデータをd3.jsが木構造に直すことができる形に直す
    function childArray(ParentId){
      var array = [];
      var child = serchChild(ParentId);

      for(var i = 0 ; i < child.length ; i++){
        childId = child[i];
        var child2 = serchChild(childId);

        //入れる名前を決める
         var nameText = serchDataArray(childId)["body"].substr(0,20)
         // var nameText = youyaku(serchDataArray(childId)["body"])
        // console.log(serchDataArray(childId)["body"])
        // var nameText = youyaku2(serchDataArray(childId)["id"])
        if (serchDataArray(childId)["title"] != null){
           nameText = serchDataArray(childId)["title"]
         }
        
        //子供の要素があるかを見て会ったらその子供を入れる
        if (child2.length == 0){
          array.push({"name":nameText,"childSize":childSize(childId),"sRate" :sRate(childId,1,1) })
        }else{
          array.push({"name":nameText,"childSize":childSize(childId),"sRate" :sRate(childId,1,1),"children" : childArray(childId)})
        }
      }
      return array
    }

    //jsで実装したよくわからない要約
    function youyaku(text){
        var newText 
        if(text.length >10){
            console.log("----前----"+text)
            newText = doAction(text)
            console.log(newText+newText.length )
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

    //pythonを使用した要約
    function youyaku2(id){
        for (var i = 0; i < youyakuData.length; i++){
            if (youyakuData[i]["id"] == id){
                console.log(youyakuData[i]["text"])
                console.log(serchDataArray(childId)["body"])
                if(youyakuData[i]["text"].length<20){
                    return youyakuData[i]["text"];
                }else{
                    return serchDataArray(childId)["body"].substr(0, 20);
                }
                
            }
        }
        console.log("mis")
        console.log(id)
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