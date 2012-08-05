$(function () {
    $("#root-folder")
        .bind("before.jstree", function (e, data) {
            $("#alog").append(data.func + "<br />");
        })
        .jstree({ 
            // List of active plugins
            "plugins" : ["themes", "json", "ui", "dnd", "search",
                "hotkeys", "contextmenu", "helpers"],

            "json" : { 
            
                "ajax" : {
                    // the URL to fetch the data
                    // folders.js?id=n&opr=get_children&fs=n
                    
                    "url" : "/folders.json",
                    
                    // the `data` function is executed in the instance's scope
                    // the parameter is the node being loaded 
                    // (may be -1, 0, or undefined when loading the root nodes)
                    "data" : function (n) { 
                        // the result is fed to the AJAX request `data` option
                        return { 
                            "opr" : "get_children", 
                            "id" : n.attr ? n.attr("id").replace("node-","") : 1,
                            "fs" : $("#root-folder").data("filespace")
                        }; 
                    }
                }
            }
        })
        .bind("create_node.jstree", function(e, data) {
	    var parent = $(data.rslt.parent);
	    var child = $(data.rslt.obj);
            var parent_id = parent.attr("id").replace("node-", "");
            var url = "/folders.json"; // Rails URL
	    var settings = {
		dataType: 'json',
		success: function(node_data, textStatus, jqXHR) {
		    id = "node-" + node_data["id"];
		    child.attr("id", id);
		},
		error: function(jqXHR, textStatus, errorThown) {
		    // Do rollback if create fails.
		    alert("Create failure");
		},
		type: 'POST',
		accepts: 'json',
		data: {
		    operation: 'create_node',
		    folder: {
			parent_id: parent_id
		    }
		}
	    };
            $.ajax(url, settings);
        })
        .bind("dblclick.jstree", function(e, data) {

            // 'this' is the root div
	    var inst_id = $(this).data().jstree_instance_id;
	    var inst = $.jstree._reference(inst_id);
                
	    var li_node = $(e.target.parentNode);
            var folder_id = li_node.attr("id").replace("node-","");
            var action = "/folders/" + folder_id + "/documents"; // Rails URL

	    var path = inst.get_path();

	    var path_string = "<span id=\"leader\">Files for Folder:</span>";
	    $.each(path, function(index, value) {
		path_string += "/" + value;
            });

	    $("#trail").html(path_string);

            $("#fileupload").attr("action", action);
            
            $("#fileupload > table > tbody.files").empty();
            
            // This function is copied from the uploader initialization
            // function in _uploader.html.erb.  Very un-dry.  This is the
            // only direct tie-in with the uploader.
             $.getJSON($('#fileupload').prop('action'), function (files) {
                  var fu = $('#fileupload').data('fileupload'), 
                    template;
                  fu._adjustMaxNumberOfFiles(-files.length);
                  template = fu._renderDownload(files)
                    .appendTo($('#fileupload .files'));
                  // Force reflow:
                  fu._reflow = fu._transition && template.length &&
                    template[0].offsetWidth;
                  template.addClass('in');
                  $('#loading').remove();
                });
        })
        .bind("rename_node.jstree", function (e, data) {
            var obj_id = data.rslt.obj.attr("id").replace("node-", "");
            var url = "/folders/" + obj_id + ".json"; // Rails URL
	    var settings = {
		dataType: 'json',
		success: function(data, textStatus, jqXHR) {
		    // alert("Rename success");
		},
		error: function(jqXHR, textStatus, errorThown) {
		    alert("Rename failure");
		},
		type: 'POST',
		accepts: 'json',
		data: {
		    _method: 'PUT',
		    operation: "rename_node",
		    folder: {
			name: data.rslt.title
		    }
		}
	    };
	    $.ajax(url, settings);
        })
        .bind("delete_node.jstree", function (e, data) {
	    // The obj node has already been detached from the JsTree.

	    alert("delete_node");
	    var obj = data.rslt.obj;
	    var parent = data.rslt.parent;
	    var prev = data.rslt.prev;

	    var system = obj.data().system;
//	    e.stopPropagation();

	    // Create a JSON description of the node to pass to
	    // create_node.

        })
        .bind("move_node.jstree", function (e, data) {
	    var new_instance = data.inst;
	    var old_instance = data.rslt.old_instance;
	    var old_filespace = old_instance.get_container().data("filespace");
	    var new_filespace = new_instance.get_container().data("filespace");
	    var old_parent = data.rslt.old_parent;
	    var new_parent = data.rslt.parent;
	    var is_multi = data.rslt.is_multi;
	    var child = data.rslt.obj;
            var child_id = child.attr("id").replace("node-", "");
            var url = "/folders/" + child_id + ".json"; // Rails URL

	    var old_parent_id;
	    var new_parent_id;

	    if (old_parent === -1) {
		old_parent_id = "-1";
            } else {
		old_parent_id = old_parent.attr("id").replace("node-", "");
            }
	    if (new_parent === -1) {
		new_parent_id = "-1";
            } else {
		new_parent_id = new_parent.attr("id").replace("node-", "");
            }

	    var settings = {
		dataType: 'json',
		success: function(data, textStatus, jqXHR) {
		    // alert("Move success");
		},
		error: function(jqXHR, textStatus, errorThown) {
		    alert("Move failure");
		},
		type: 'POST',
		accepts: 'json',
		data: {
		    _method: 'PUT',
		    operation: 'move_node',
		    mover: {
			old_filespace: old_filespace,
			new_filespace: new_filespace,
			old_parent: old_parent_id,
			new_parent: new_parent_id,
                    }
		}
	    };
	    $.ajax(url, settings);

	    
        })
        .bind("copy_node.jstree", function (e, data) {
            alert("Copy node");
        });
});    


