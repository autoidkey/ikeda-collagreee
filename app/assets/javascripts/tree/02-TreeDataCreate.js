//ツリーに使用するデータを生成する。
function createTreeData(dataAll,title) {
    var linkNode = makeLink(dataAll)
    var treeData = {
          "name" : title,
          "children": childArray(0)
    }
    return treeData

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
        // var nameText = serchDataArray(childId)["body"].substr(0,10)
        var nameText = doAction(serchDataArray(childId)["body"])
        if (serchDataArray(childId)["title"] != null){
          nameText = serchDataArray(childId)["title"]
        }
        
        //子供の要素があるかを見て会ったらその子供を入れる
        if (child2.length == 0){
          array.push({"name":nameText,"size" : 30000})
        }else{
          array.push({"name":nameText,"children" : childArray(childId)})
        }
      }
      return array
    }
}