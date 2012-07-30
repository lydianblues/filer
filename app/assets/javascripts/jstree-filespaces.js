$(function () {

	$("#root-folder")
		.bind("before.jstree", function (e, data) {
			$("#alog").append(data.func + "<br />");
		})
		.jstree({ 
			// List of active plugins
			"plugins" : ["themes", "json", "ui", "dnd", "search",
				"hotkeys", "contextmenu"],

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
			var parent_id = data.rslt.parent.attr("id").replace("node-", "");
			var action = "/folders.json"; // Rails URL
	
			$.post(action, {operation: "create_node", parent_id: parent_id},
				function(r) {
					// do a rollback if this fails
					alert("Created node with parent " + r.parent_id + 
						" with status " + r.status);
				}
			);
		})
		.bind("dblclick.jstree", function(e, data) {
			// 'this' is the root div
				
			if (data == undefined) {
			  folder_id = $(e.target.parentNode).attr("id").replace("node-","");
			} else {
			  folder_id = data.rslt.parent.attr("id").replace("node-", "");
			}
			
			folder_id = $(e.target.parentNode).attr("id").replace("node-","");
			action = "/folders/" + folder_id + "/documents"; // Rails URL
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
			alert("Renaming node");
		})
		.bind("delete_node.jstree", function (e, data) {
			alert("Delete node");
		})
		.bind("move_node.jstree", function (e, data) {
			alert("Move node");
		})
		.bind("copy_node.jstree", function (e, data) {
			alert("Copy node");
		});
});	


