function tree_data_change(dataAll,classes){
	var change_array = dataAll
	var class_array = []
	var len = max_id(dataAll);
	var datalen = dataAll.length
	for (var i = 0; i < classes.length; i++){
		var push_array = new Object();;
		push_array["id"] = len+i+1;
		push_array["title"] = classes[i].title;
		push_array["body"] = classes[i].title;
		push_array["parent_id"] = null;
		push_array["created_at"] = classes[i]["created_at"];
		push_array["agreement"] = false;
		push_array["claster"] = classes[i]["claster_id"];
		change_array.push(push_array);
		class_array[classes[i]["claster_id"]] = len+i+1;
	}


	for (var i = 0; i < datalen; i++){
		if(change_array[i]["parent_id"]==null){
			change_array[i]["parent_id"] = class_array[change_array[i]["claster"]];
		}
	}

	return change_array;

	function serchclasses(cla){
        for (var i = 0; i < classes.length; i++){
            if(classes[i]["claster_id"] == cla){
                return true
            }
        }
        return false
    }

    function claster_name_serch(cla){
        for (var i = 0; i < classes.length; i++){
            if(classes[i]["claster_id"] == cla){
                return classes[i]["title"]
            }
        }
    }

    function max_id(array){
    	var id = 1;
    	for (var i = 0; i < array.length; i++){
    		if(id < array[i]["id"]){
    			id = array[i]["id"];
    		}

    	}
    	return id;
    }
}

