$(function() {

    // Create a new plugin for DataTables to dynamically change Ajax Source.
    $.fn.dataTableExt.oApi.fnNewAjax = function(oSettings, sNewSource) {
        if (typeof sNewSource != 'undefined' && sNewSource != null ) {
            oSettings.sAjaxSource = sNewSource;
        }
        console.log("changed ajax source for datatables to " + sNewSource);
        this.fnDraw();
   }

  // Create a new plugin for DataTables to reload the table on demand.
  // See http://datatables.net/plug-ins/api#fnReloadAjax.
  $.fn.dataTableExt.oApi.fnReloadAjax = function(oSettings, sNewSource,
    fnCallback, bStandingRedraw)
  {
      if ( typeof sNewSource != 'undefined' && sNewSource != null )
      {
          oSettings.sAjaxSource = sNewSource;
      }
      this.oApi._fnProcessingDisplay( oSettings, true );
      var that = this;
      var iStart = oSettings._iDisplayStart;
      var aData = [];
    
      this.oApi._fnServerParams( oSettings, aData );
        
      oSettings.fnServerData.call( oSettings.oInstance, oSettings.sAjaxSource,
          aData, function(json) {
          /* Clear the old information from the table */
          that.oApi._fnClearTable( oSettings );
            
          /* Got the data - add it to the table */
          var aData =  (oSettings.sAjaxDataProp !== "") ?
              that.oApi._fnGetObjectDataFn( oSettings.sAjaxDataProp )( json ) : json;
            
          for ( var i=0 ; i<aData.length ; i++ )
          {
              that.oApi._fnAddData( oSettings, aData[i] );
          }
            
          oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
            
          if ( typeof bStandingRedraw != 'undefined' && bStandingRedraw === true )
          {
              oSettings._iDisplayStart = iStart;
              that.fnDraw( false );
          }
          else
          {
              that.fnDraw();
          }
            
          that.oApi._fnProcessingDisplay( oSettings, false );
            
          /* Callback user function - for event handlers etc */
          if ( typeof fnCallback == 'function' && fnCallback != null )
          {
              fnCallback( oSettings );
          }
      }, oSettings );
      console.log("reloading datatables via ajax");

  }
});

$(function () {
    $(".filespace-tree").each(function() {
        $(this).jstree({ 
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
                        var filespace = this.get_container().data()['filespace'];
                        // the result is fed to the AJAX request `data` option
                        return { 
                            "opr" : "get_children", 
                            "id" : n.attr ? n.attr("id").replace("node-","") : 1,
                            "fs" : filespace
                        }; 
                    }
                }
            }
        })
        .bind("create_node.jstree", function(e, data) {
            var parent = $(data.rslt.parent),
              child = $(data.rslt.obj),
              parent_id = parent.attr("id").replace("node-", ""),
              url = "/folders.json", // Rails URL
              settings = {
                  dataType: 'json',
                  success: function(node_data, textStatus, jqXHR) {
                      var id = "node-" + node_data["id"];
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
              }; // end of list of vars
            $.ajax(url, settings);
        })
        .bind("dblclick.jstree click.jstree", function(e, data) {
            console.log("jstree handling (dbl-)click event");
            // 'this' is the root div of a JsTree.
            // debugger;
            var inst_id = $(this).data().jstree_instance_id,
                inst = $.jstree._reference(inst_id),
                li_node = $(e.target.parentNode),
                folder_id = li_node.attr("id").replace("node-",""),
                upload_action = "/folders/" + folder_id + "/uploads", // Rails URL
                filespace = inst.get_container().data().filespace,
                file_upload_form = $("#fileupload-form-" + filespace),
                filespace_panel = $("#filespace-" + filespace)
                oTable = $("#file-table-" + filespace).dataTable(),
                file_action =
                    "/folders/" + folder_id + "/documents.json", // Rails URL
                path = inst.get_path(li_node),
                path_string = "<span id=\"leader\">Active Folder:</span>";

            $.each(path, function(index, value) {
                path_string += "/" + value;
            });

            $(".trail", filespace_panel).html(path_string);
            file_upload_form.attr("action", upload_action);
            $("table > tbody.files", file_upload_form).empty();
                
            // This function is derived from the uploader initialization
            // function in _uploader.html.erb.  This is the only direct
            // tie-in with the uploader.
            $.getJSON(upload_action, function (files) {
                var fu = file_upload_form.data('fileupload'), 
                    template;
                fu._adjustMaxNumberOfFiles(-files.length);
                template = fu._renderDownload(files)
                    .appendTo('.files', file_upload_form);
                // Force reflow:
                fu._reflow = fu._transition && template.length &&
                    template[0].offsetWidth;
                template.addClass('in');
                $('#loading').remove();
            });

            // Install a new URL into DataTables.
            oTable.fnNewAjax(file_action); 
            oTable.fnReloadAjax();
            console.log("upload_action: " + upload_action);
            console.log("file_action: " + file_action);
        })
        .bind("rename_node.jstree", function (e, data) {
            var obj_id = data.rslt.obj.attr("id").replace("node-", ""),
                url = "/folders/" + obj_id + ".json", // Rails URL
                settings = {
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
            var obj = data.rslt.obj,
                parent = data.rslt.parent,
                prev = data.rslt.prev,
                system = obj.data().system;
        
            // Create a JSON description of the node to pass to
            // create_node.

        })
        .bind("send_node.jstree", function(e, data) {
            alert("send_node");
        })
        .bind("move_node.jstree", function (e, data) {
            var new_instance = data.inst,
                old_instance = data.rslt.old_instance,
                old_filespace = old_instance.get_container().data("filespace"),
                new_filespace = new_instance.get_container().data("filespace"),
                old_parent = data.rslt.old_parent,
                new_parent = data.rslt.parent,
                is_multi = data.rslt.is_multi,
                child = data.rslt.obj,
                child_id = child.attr("id").replace("node-", ""),
                url = "/folders/" + child_id + ".json", // Rails URL
                old_parent_id,
                new_parent_id,
                settings;
                      
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

            settings = {
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
});

// Set up each filespace so that when first viewed (by clicking
// its tab, perhaps), it looks as if the user had clicked the 
// "Current" node in the JsTree.  This causes the trail, the file
// viewer URL, and the upload URL to all be initialized for the
// "Current" folder.  Note that we have to wait for the JsTree to
// be initialized by fetching the JSON from the server and populating
// the tree.  Note that "div.filespace-tree" is statically loaded,
// so it is always present.  A more sophisticated approach would be
// to call ourself recursively (with a short timeout) if the li_node
// is missing.
$(function() {
    setTimeout(function() {
        $(".filespace-tree").each(function() {
            var current_folder = $(this).data().currentFolder,
            li_node = $("#node-" + current_folder);
            if (li_node.data().ntype === "current") {
                $("a", li_node).trigger("click.jstree");
            };
        });
    }, 1000);
});

            


