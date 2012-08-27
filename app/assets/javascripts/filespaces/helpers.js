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
        fnCallback, bStandingRedraw) {

        if ( typeof sNewSource != 'undefined' && sNewSource != null ) {
            oSettings.sAjaxSource = sNewSource;
        }
        this.oApi._fnProcessingDisplay(oSettings, true);
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
                that.oApi._fnGetObjectDataFn(oSettings.sAjaxDataProp)(json) : json;
            
            for (var i=0 ; i<aData.length ; i++) {
                that.oApi._fnAddData( oSettings, aData[i]);
            }
            
            oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
            
            if (typeof bStandingRedraw != 'undefined'
                && bStandingRedraw === true) {
                oSettings._iDisplayStart = iStart;
                that.fnDraw(false);
            } else {
              that.fnDraw();
            }
            
            that.oApi._fnProcessingDisplay(oSettings, false);
            
            /* Callback user function - for event handlers etc */
            if ( typeof fnCallback == 'function' && fnCallback != null ) {
                fnCallback( oSettings );
            }
        }, oSettings );
        console.log("reloading datatables via ajax");
    }
    
    jQuery.fn.dataTableExt.oApi.fnProcessingIndicator =
        function(oSettings, onoff) {
            if (typeof(onoff) == 'undefined') {
                onoff=true;
            }
            this.oApi._fnProcessingDisplay(oSettings, onoff);
        };
});


