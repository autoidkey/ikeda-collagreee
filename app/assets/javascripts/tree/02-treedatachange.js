function tree_data_change(dataAll,classes){
	var change_array = dataAll
	var class_array = []
	var len = dataAll.length;
	console.log(change_array);
	for (var i = 0; i < classes.length; i++){
		var push_array = new Object();;
		push_array["id"] = len+i+1;
		push_array["title"] = classes[i].title;
		push_array["body"] = classes[i].title;
		push_array["parent_id"] = null;
		// push_array["created_at"] = classes[i]["created_at"];
		push_array["agreement"] = false;
		push_array["claster"] = classes[i]["claster_id"];
		change_array.push(push_array);
		class_array[classes[i]["claster_id"]] = len+i+1;
		console.log("psuh")
		console.log(push_array)
	}


	for (var i = 0; i < len; i++){
		if(dataAll[i]["parent_id"]==null){
			change_array[i]["parent_id"] = class_array[dataAll[i]["claster"]];
		}
	}
	console.log(dataAll);
	console.log(change_array);

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
}

