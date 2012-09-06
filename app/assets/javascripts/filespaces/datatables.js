$(function() {
    // This code is executed once on page load.  We need to initialize
    // every DataTable on the page.
    $(".file-table").each(function(index, element) {

        var filespace = $(this).data().filespace; // unused
        var root_folder = $(this).data().root;
        var current_folder = $(this).data().current; // unused
        var json_url = $(this).data().jsonUrl + ".json"

        $(this).dataTable({
            "bJQueryUI": true,
            "bProcessing": true,
            "bServerSide": true,
            "sAjaxSource": json_url,
            "bAutoWidth": false,
            "bDeferRender": true,
            "sDom": '<"H"T<"clear">lfr>t<"F"ip>',
            "sPaginationType": "full_numbers",
            "aoColumns": [ 
                /* Id */ {"bVisible": true, "bSearchable": false},
                /* Name */ null,
                /* Uploaded At */  {"bSearchable": false},
                /* Size */ {"bSearchable": false, "bVisible": true},
                /* Content Type */ {"bSearchable": true},
                /* Checksum */ {"bSearchable": false, "bVisible": false}
            ],
            "fnDrawCallback": function(oSettings) {
                // $(".dataTable").width("80%");
            },
            "oTableTools": {
                "sRowSelect": "multi",
                "aButtons": [
                    "select_all",
                    "select_none",
                    {
                        "sExtends":    "text",
                        "sButtonText": "Cut",
                        "fnClick": function(nButton, oConfig) {
                            var selected  = this.fnGetSelected(), ft, oTable;
                            if (selected.length > 0) {
                                var ft = $(selected[0]).closest(".file-table"),
                                    oTable = ft.DataTable(),
                                    folder_id = ft.data("current");
                                $(selected).each(function(index, element) {
                                     var url, id, settings;
                                     
                                     // Make an XHR request to Rails server to
                                     // delete the file.  URL is DELETE HTTP
                                     // verb for the path:
                                     // /folders/:folder_id/documents/:id
                                     id = $($("td", this)[0]).text();
                                     
                                     // Rails URL.
                                     url = "/folders/" + folder_id +
                                        "/documents/" + id;
                                    
                                     settings = {
                                         dataType: 'json',
                                         success: function() {
                                             oTable.fnDeleteRow(element);
                                         },
                                         error: function() {
                                             alert("cut row failure");
                                         },
                                         type: 'POST',
                                         accepts: {json: 'application/json'},
                                         data: {
                                             _method: 'delete'
                                         }
                                     }; 
                                    $.ajax(url, settings);
                                    
                               });
                            }
                            // this.fnSelectNone();
                            // fnDeleteRow()
                            // debugger;
                            // alert("Cutting " + selected.length + " rows");
                        }
                    },
                    {
                        "sExtends":    "text",
                        "sButtonText": "Process",
                        "fnClick": function(nButton, oConfig) {
                            var oTable = this.s.dt.oInstance;
                            
                            oTable.fnProcessingIndicator();
                            
                        }
                    },
                    {
                        "sExtends":    "text",
                        "sButtonText": "Copy",
                        "fnClick": function(nButton, oConfig) {
                            /* var selected  = this.fnGetSelected(),
                                oTable = this.s.dt.oInstance, ids = [];
                            
                            // 'selected' is an array of DOM <tr> elements.
                            $(selected).each(function() {
                                var id = $("td:nth-child(1)", this);
                                ids.push(id.text());
                            });
                            
                            
                            oTable.data("copiedRows", ids); */
                        }
                    },
                    {
                        "sExtends":    "text",
                        "sButtonText": "Paste",
                        "fnClick": function(nButton, oConfig) {
                            var oTable = this.s.dt.oInstance, ids = [],
                                selected  = this.fnGetSelected(),
                                target_fs, target_folder;
                            
                            // 'selected' is an array of DOM <tr> elements.
                            $(selected).each(function() {
                                var id = $("td:nth-child(1)", this);
                                ids.push(id.text());
                            });
                            
                            // 'ids' is an array of strings representing
                            // integers:  ["3", "240", "88"] for example.
                            // fs_id is the target filespace
                            // ... is the target folder
                            
                            target_fs = oTable.data("filespace");
                            target_folder = oTable.data("current");
                        
                            
                            console.log("Pasting ids: " + ids + " to " +
                                target_fs + );
                            
                            this.fnSelectNone();
                        
                        }
                    }
                ]
            }
        });
    });
});