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
        $(".filespace-tree").each(function(index, element) {
            var current_folder = $(this).data().currentFolder,
            li_node = $("#node-" + current_folder);
            if (li_node.data() && li_node.data().ntype === "current") {
                $("a", li_node).trigger("click.jstree");
            };
        });
    }, 2000); // fog requires longer timeout
    
    setTimeout(function() {
        $(".fileupload-control").each(function(index, element) {
            $(this).fileupload({
                done: function(e, data) {
                    // Don't do anything for downloads.
                }
            });
        });
    }, 0);
    
    // Make a click on the file chooser button redirect the click
    // to the associated file input field of the upload form.
    $(".file-chooser").on("click",  function() {
        $(this).next().find("input").click();
    });
    
    $(".fileupload-buttonbar").buttonset();
    $(".fileupload-buttonbar button").button();
    $("#filespace-buttonbar").buttonset();
    $("button", "filespace-buttonbar").button();
    $(".filespace-action-tabset").tabs();
    $(".filespace-chooser-tabset").tabs();

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
});

