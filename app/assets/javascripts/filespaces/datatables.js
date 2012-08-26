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
//          "bServerSide": true,
            "sAjaxSource": json_url,
            "bDeferRender": true,
            "sDom": 'T<"clear">lfrtip',
            "oTableTools": {
            "sRowSelect": "multi",
            "aoColumns": [ 
                /* Id */ {"bVisible": false},
                /* Name */ null,
                /* Uploaded At */  {"bSearchable": false},
                /* Size */ {"bSearchable": false, "bVisible": false},
                /* Content Type */ null,
                /* Checksum */ { "bVisible":    false }
            ],
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
                                         accepts: 'json',
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
                        "sButtonText": "Copy",
                        "fnClick": function(nButton, oConfig) {
                            var selected  = this.fnGetSelected();
                            // this.fnSelectNone();
                            alert("Copying " + selected.length + " rows");
                        }
                    },
                    {
                        "sExtends":    "text",
                        "sButtonText": "Paste",
                        "fnClick": function(nButton, oConfig) {
                            var selected  = this.fnGetSelected();
                            // this.fnSelectNone();
                            alert("Pasting " + selected.length + " rows");
                        }
                    }
                ]
            }
        });
    });
});