// Load order for javascript:

// jquery
// jquery_ujs
// application
// jquery-ui-<version>.custom (first JS loaded by demo/show)
// jstree
// dataTables
// TableTools
// demo
// jstree-filespaces
// templ
// load-image
// canvas-to-blob
// fileupload (3 times)

// Part of the solution to the FOUC problem.
$('html').hide();

$(function() {
    $("#filespace-buttonbar").buttonset();
    $("button", "filespace-buttonbar").button();
    $(".filespace-action-tabset").tabs();
    $(".filespace-chooser-tabset").tabs({
        // Set things up so that a tab select event will also act like
        // a double-click on the "current" folder of the JsTree.
         select: function(event, ui) {
             var current_folder = $(ui.panel).data().currentFolder,    
                anchor_node  = $("a", $("#node-" + current_folder));
             // anchor_node.trigger("click.jstree");
         }
    });

    $(".filespace-action-tabset").bind('tabsselect', function(event, ui) {

        var data =  $(ui.panel).closest(".filespace-panel").data(),
          filespace = data.filespace,
          root_folder = data.rootFolder,
          oTable = $("#file-table-" + filespace).dataTable();

        if (ui.index == 0) {
            // The URL to use is already set in the DataTables configuration
            // data.  We are not changing it here.
            oTable.fnReloadAjax();
        }
    });
    
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
            "aButtons": [
                "select_all",
                    "select_none",
                    {
                        "sExtends":    "text",
                        "sButtonText": "Cut",
                        "fnClick": function(nButton, oConfig) {
                            var selected  = this.fnGetSelected();
                            // this.fnSelectNone();
                            alert("Cutting " + selected.length + " rows");
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
     $('html').show(); // the other half of the FOUC solution
});
