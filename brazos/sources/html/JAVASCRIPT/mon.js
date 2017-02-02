
var TransferPlot_init = false;
var TransferPlot_select = new Array();
var TransferPlot_layer = new Array();
var TransferPlotIndex = 0;

var SubscriptionPlot_init = false;
var SubscriptionPlot_select = new Array();
var SubscriptionPlot_layer = new Array();
var SubscriptionPlotIndex = 0;

var JobPlot_init = false;
var JobPlotMode_select = new Array();
var JobPlotSpan_select = new Array();
var JobPlot_layer = new Array();
var JobPlotModeIndex = 1;
var JobPlotSpanIndex = 0;

var UserJobsPlotData_init = false;
var UserJobsPlotData_select = new Array();
var UserJobsPlotData_element = new Array();
var UserJobsPlotDataIndex = 1;

var TransferData_init = false;
var TransferDataMode_select = new Array();
var TransferDataSpan_select = new Array();
var TransferData_layer = new Array();
var TransferDataModeIndex = 0;
var TransferDataSpanIndex = 1;

var DiskUsageData_init = false;
var DiskUsageData_select = new Array();
var DiskUsageData_indicator = new Array();
var DiskUsageData_element = new Array();
var DiskUsageData_visible = new Array();

var SqueueData_init = false;
var SqueueDataSort_select = new Array();
var SqueueData_sort = new Array();
var SqueueData_select = new Array();
var SqueueData_visible = new Array();
var SqueueData_indicator = new Array();
var SqueueData_element = new Array();
var SqueueDataSortIndex = 0;

var QStatData_init = false;
var QStatDataSort_select = new Array();
var QStatData_sort = new Array();
var QStatData_select = new Array();
var QStatData_visible = new Array();
var QStatData_indicator = new Array();
var QStatData_element = new Array();
var QStatDataSortIndex = 0;

var CondorQData_init = false;
var CondorQDataSort_select = new Array();
var CondorQData_sort = new Array();
var CondorQData_select = new Array();
var CondorQData_visible = new Array();
var CondorQData_indicator = new Array();
var CondorQData_element = new Array();
var CondorQDataSortIndex = 0;

var SAMPlotOverlay_init = false;
var SAMPlotOverlay_layer = null;
var SAMPlotOverlay_timer = null;

var TopUpMap_layer = null;
var TopUpMap_timer = null;
var TopUpMap_object = new Object();

function GetObject(name) {
	if (document.getElementById) {
		if (!(this.obj = document.getElementById(name))) return false;
		this.style = document.getElementById(name).style; return true; }
	return false; }

function MonitorInitialize() {

	TransferPlot_init = ( function() { var i;
		TransferPlot_select[0] = new GetObject('transfer_plot_select_hour');
		TransferPlot_select[1] = new GetObject('transfer_plot_select_day');
		TransferPlot_select[2] = new GetObject('transfer_plot_select_week');
		TransferPlot_layer[0] = new GetObject('transfer_plot_hour');
		TransferPlot_layer[1] = new GetObject('transfer_plot_day');
		TransferPlot_layer[2] = new GetObject('transfer_plot_week');
		for (i=0;i<=2;i++) { if (!TransferPlot_select[i].obj || !TransferPlot_layer[i].obj) return; }
		return true; } )();

	SubscriptionPlot_init = ( function() { var i;
		SubscriptionPlot_select[0] = new GetObject('subscription_plot_select_hour');
		SubscriptionPlot_select[1] = new GetObject('subscription_plot_select_day');
		SubscriptionPlot_select[2] = new GetObject('subscription_plot_select_week');
		SubscriptionPlot_layer[0] = new GetObject('subscription_plot_hour');
		SubscriptionPlot_layer[1] = new GetObject('subscription_plot_day');
		SubscriptionPlot_layer[2] = new GetObject('subscription_plot_week');
		for (i=0;i<=2;i++) { if (!SubscriptionPlot_select[i].obj || !SubscriptionPlot_layer[i].obj) return; }
		return true; } )();

	JobPlot_init = ( function() { var i;
		JobPlotMode_select[0] = new GetObject('job_plot_mode_select_runtime');
		JobPlotMode_select[1] = new GetObject('job_plot_mode_select_termination');
		JobPlotSpan_select[0] = new GetObject('job_plot_span_select_hour');
		JobPlotSpan_select[1] = new GetObject('job_plot_span_select_day');
		JobPlotSpan_select[2] = new GetObject('job_plot_span_select_week');
		JobPlot_layer[0] = new GetObject('job_plot_runtime_hour');
		JobPlot_layer[1] = new GetObject('job_plot_runtime_day');
		JobPlot_layer[2] = new GetObject('job_plot_runtime_week');
		JobPlot_layer[3] = new GetObject('job_plot_termination_hour');
		JobPlot_layer[4] = new GetObject('job_plot_termination_day');
		JobPlot_layer[5] = new GetObject('job_plot_termination_week');
		for (i=0;i<=1;i++) { if (!JobPlotMode_select[i].obj) return; }
		for (i=0;i<=2;i++) { if (!JobPlotSpan_select[i].obj) return; }
		for (i=0;i<=5;i++) { if (!JobPlot_layer[i].obj) return; }
		return true; } )();

	UserJobsPlotData_init = ( function() { var i;
		UserJobsPlotData_select[0] = new GetObject('user_jobs_plot_data_select_hour');
		UserJobsPlotData_select[1] = new GetObject('user_jobs_plot_data_select_day');
		UserJobsPlotData_select[2] = new GetObject('user_jobs_plot_data_select_week');
		for (i=0;i<=2;i++) { UserJobsPlotData_element[i] = new GetObject('user_jobs_plot_data_element_'+i);
			 if (!UserJobsPlotData_select[i].obj || !UserJobsPlotData_element[i].obj) return; }
		return true; } )();

	TransferData_init = ( function() { var i;
		TransferDataMode_select[0] = new GetObject('transfer_data_mode_select_prod');
		TransferDataMode_select[1] = new GetObject('transfer_data_mode_select_load');
		TransferDataSpan_select[0] = new GetObject('transfer_data_span_select_hour');
		TransferDataSpan_select[1] = new GetObject('transfer_data_span_select_day');
		TransferDataSpan_select[2] = new GetObject('transfer_data_span_select_week');
		TransferDataSpan_select[3] = new GetObject('transfer_data_span_select_month');
		TransferData_layer[0] = new GetObject('transfer_data_prod_hour');
		TransferData_layer[1] = new GetObject('transfer_data_prod_day');
		TransferData_layer[2] = new GetObject('transfer_data_prod_week');
		TransferData_layer[3] = new GetObject('transfer_data_prod_month');
		TransferData_layer[4] = new GetObject('transfer_data_load_hour');
		TransferData_layer[5] = new GetObject('transfer_data_load_day');
		TransferData_layer[6] = new GetObject('transfer_data_load_week');
		TransferData_layer[7] = new GetObject('transfer_data_load_month');
		for (i=0;i<=1;i++) { if (!TransferDataMode_select[i].obj) return; }
		for (i=0;i<=3;i++) { if (!TransferDataSpan_select[i].obj) return; }
		for (i=0;i<=7;i++) { if (!TransferData_layer[i].obj) return; }
		return true; } )();

	DiskUsageData_init = ( function() { var i;
		for (i=0;i<=4;i++) { var j;
			DiskUsageData_indicator[i] = new Array(); DiskUsageData_element[i] = new Array(); DiskUsageData_visible[i] = false;
			if (!( DiskUsageData_select[i] = new GetObject('disk_usage_data_select_'+i)).obj) return;
			if (!( DiskUsageData_indicator[i][0] = new GetObject('disk_usage_data_indicator_'+i+'_0')).obj) return;
			if (!( DiskUsageData_indicator[i][1] = new GetObject('disk_usage_data_indicator_'+i+'_1')).obj) return;
			for (j=0;true;j++) { var element = new GetObject('disk_usage_data_element_'+i+'_'+j);
				if (!element.obj) break; DiskUsageData_element[i][j] = element; }}
		return true; } )();

	SqueueData_init = ( function() { var j;
		SqueueDataSort_select[0] = new GetObject('squeue_data_sort_select_user');
		SqueueDataSort_select[1] = new GetObject('squeue_data_sort_select_queue');
		SqueueDataSort_select[2] = new GetObject('squeue_data_sort_select_status');
		for (i=0;i<=2;i++) { if (!SqueueDataSort_select[i].obj) return;
			if (!( SqueueData_sort[i] = new GetObject('squeue_data_sort_'+i)).obj) return;
			SqueueData_select[i] = new Array(); SqueueData_visible[i] = new Array();
			SqueueData_indicator[i] = new Array(); SqueueData_element[i] = new Array();
			for (j=0;true;j++) { var k; var element_j = new GetObject('squeue_data_select_'+i+'_'+j);
				if (!element_j.obj) break; SqueueData_select[i][j] = element_j; SqueueData_visible[i][j] = false;
				SqueueData_indicator[i][j] = new Array(); SqueueData_element[i][j] = new Array();
				if (!( SqueueData_indicator[i][j][0] = new GetObject('squeue_data_indicator_'+i+'_'+j+'_0')).obj) return;
				if (!( SqueueData_indicator[i][j][1] = new GetObject('squeue_data_indicator_'+i+'_'+j+'_1')).obj) return;
				for (k=0;true;k++) { var element_k = new GetObject('squeue_data_element_'+i+'_'+j+'_'+k);
					if (!element_k.obj) break; SqueueData_element[i][j][k] = element_k; }}}
		return true; } )();

	QStatData_init = ( function() { var j;
		QStatDataSort_select[0] = new GetObject('qstat_data_sort_select_user');
		QStatDataSort_select[1] = new GetObject('qstat_data_sort_select_queue');
		QStatDataSort_select[2] = new GetObject('qstat_data_sort_select_status');
		for (i=0;i<=2;i++) { if (!QStatDataSort_select[i].obj) return;
			if (!( QStatData_sort[i] = new GetObject('qstat_data_sort_'+i)).obj) return;
			QStatData_select[i] = new Array(); QStatData_visible[i] = new Array();
			QStatData_indicator[i] = new Array(); QStatData_element[i] = new Array();
			for (j=0;true;j++) { var k; var element_j = new GetObject('qstat_data_select_'+i+'_'+j);
				if (!element_j.obj) break; QStatData_select[i][j] = element_j; QStatData_visible[i][j] = false;
				QStatData_indicator[i][j] = new Array(); QStatData_element[i][j] = new Array();
				if (!( QStatData_indicator[i][j][0] = new GetObject('qstat_data_indicator_'+i+'_'+j+'_0')).obj) return;
				if (!( QStatData_indicator[i][j][1] = new GetObject('qstat_data_indicator_'+i+'_'+j+'_1')).obj) return;
				for (k=0;true;k++) { var element_k = new GetObject('qstat_data_element_'+i+'_'+j+'_'+k);
					if (!element_k.obj) break; QStatData_element[i][j][k] = element_k; }}}
		return true; } )();

	CondorQData_init = ( function() { var j;
		CondorQDataSort_select[0] = new GetObject('condorq_data_sort_select_user');
		CondorQDataSort_select[1] = new GetObject('condorq_data_sort_select_queue');
		CondorQDataSort_select[2] = new GetObject('condorq_data_sort_select_status');
		for (i=0;i<=2;i++) { if (!CondorQDataSort_select[i].obj) return;
			if (!( CondorQData_sort[i] = new GetObject('condorq_data_sort_'+i)).obj) return;
			CondorQData_select[i] = new Array(); CondorQData_visible[i] = new Array();
			CondorQData_indicator[i] = new Array(); CondorQData_element[i] = new Array();
			for (j=0;true;j++) { var k; var element_j = new GetObject('condorq_data_select_'+i+'_'+j);
				if (!element_j.obj) break; CondorQData_select[i][j] = element_j; CondorQData_visible[i][j] = false;
				CondorQData_indicator[i][j] = new Array(); CondorQData_element[i][j] = new Array();
				if (!( CondorQData_indicator[i][j][0] = new GetObject('condorq_data_indicator_'+i+'_'+j+'_0')).obj) return;
				if (!( CondorQData_indicator[i][j][1] = new GetObject('condorq_data_indicator_'+i+'_'+j+'_1')).obj) return;
				for (k=0;true;k++) { var element_k = new GetObject('condorq_data_element_'+i+'_'+j+'_'+k);
					if (!element_k.obj) break; CondorQData_element[i][j][k] = element_k; }}}
		return true; } )();

	SAMPlotOverlay_init = ( function() {
		if (( SAMPlotOverlay_layer = jQuery('#sam_plot_overlay')).length == 0) return;
		return true; } )();

	}

function TransferPlotSelect(i) { var j = parseInt(i); var k;
	if (!TransferPlot_init || (j<0) || (j>2)) return; TransferPlotIndex = j;
	TransferPlot_select[j].style.backgroundColor = "#3BB9FF";
	TransferPlot_layer[j].style.zIndex = 10;
	for (k=0;k<=2;k++) { if (k==j) continue;
		TransferPlot_select[k].style.backgroundColor = "#FFFFFF";
		TransferPlot_layer[k].style.zIndex = -10; }}

function SubscriptionPlotSelect(i) { var j = parseInt(i); var k;
	if (!SubscriptionPlot_init || (j<0) || (j>2)) return; SubscriptionPlotIndex = j;
	SubscriptionPlot_select[j].style.backgroundColor = "#3BB9FF";
	SubscriptionPlot_layer[j].style.zIndex = 10;
	for (k=0;k<=2;k++) { if (k==j) continue;
		SubscriptionPlot_select[k].style.backgroundColor = "#FFFFFF";
		SubscriptionPlot_layer[k].style.zIndex = -10; }}

function JobPlotModeSelect(i) { var j = parseInt(i); var k;
	if (!JobPlot_init || (j<0) || (j>1)) return; JobPlotModeIndex = j;
	JobPlotMode_select[j].style.backgroundColor = "#3BB9FF";
	for (k=0;k<=1;k++) { if (k==j) continue;
		JobPlotMode_select[k].style.backgroundColor = "#FFFFFF"; }
	JobPlotSpanSelect(JobPlotSpanIndex); }

function JobPlotSpanSelect(i) { var j = parseInt(i); var k;
	if (!JobPlot_init || (j<0) || (j>5)) return; JobPlotSpanIndex = j;
	JobPlotSpan_select[j].style.backgroundColor = "#3BB9FF";
	for (k=0;k<=2;k++) { if (k==j) continue;
		JobPlotSpan_select[k].style.backgroundColor = "#FFFFFF"; }
	j += 3*JobPlotModeIndex; JobPlot_layer[j].style.zIndex = 10;
	for (k=0;k<=5;k++) { if (k==j) continue;
		JobPlot_layer[k].style.zIndex = -10; }}

function UserJobsPlotDataSelect(i) { var j = parseInt(i); var k;
	if (!UserJobsPlotData_init || (j<0) || (j>2)) return; UserJobsPlotDataIndex = j;
	UserJobsPlotData_select[j].style.backgroundColor = "#3BB9FF";
	UserJobsPlotData_element[j].style.display = "block";
	for (k=0;k<=2;k++) { if (k==j) continue;
		UserJobsPlotData_select[k].style.backgroundColor = "#FFFFFF";
		UserJobsPlotData_element[k].style.display = "none"; }}

function TransferDataModeSelect(i) { var j = parseInt(i); var k;
	if (!TransferData_init || (j<0) || (j>1)) return; TransferDataModeIndex = j;
	TransferDataMode_select[j].style.backgroundColor = "#3BB9FF";
	for (k=0;k<=1;k++) { if (k==j) continue;
		TransferDataMode_select[k].style.backgroundColor = "#FFFFFF"; }
	TransferDataSpanSelect(TransferDataSpanIndex); }

function TransferDataSpanSelect(i) { var j = parseInt(i); var k;
	if (!TransferData_init || (j<0) || (j>7)) return; TransferDataSpanIndex = j;
	TransferDataSpan_select[j].style.backgroundColor = "#3BB9FF";
	for (k=0;k<=3;k++) { if (k==j) continue;
		TransferDataSpan_select[k].style.backgroundColor = "#FFFFFF"; }
	j += 4*TransferDataModeIndex; TransferData_layer[j].style.zIndex = 10;
	for (k=0;k<=7;k++) { if (k==j) continue;
		TransferData_layer[k].style.zIndex = -10; }}

function DiskUsageDataToggle(i) { var j = parseInt(i); var k;
	if (!DiskUsageData_init || (j<0) || (j>4)) return;
	DiskUsageData_visible[j] = !DiskUsageData_visible[j];
	DiskUsageData_indicator[j][0].style.display = DiskUsageData_visible[j] ? "none" : "block";
	DiskUsageData_indicator[j][1].style.display = DiskUsageData_visible[j] ? "block" : "none";
	for (k=0;k<DiskUsageData_element[j].length;k++) {
		DiskUsageData_element[j][k].style.display = DiskUsageData_visible[j] ? "block" : "none"; }}

function DiskUsageDataToggleAll() { var i; var DiskUsageDataAll_visible = true;
	if (!DiskUsageData_init) return;
	for (i=0;i<=4;i++) { if (!DiskUsageData_visible[i]) continue;
		DiskUsageDataToggle(i); DiskUsageDataAll_visible = false; }
	if (!DiskUsageDataAll_visible) return;
	for (i=0;i<=4;i++) DiskUsageDataToggle(i); }

function SqueueDataToggle(n,m) { var i = parseInt(n); var j = parseInt(m); var k;
	if (!SqueueData_init || (i<0) || (i>2) || (j<0) || (j>(SqueueData_select[i].length-1))) return;
	SqueueData_visible[i][j] = !SqueueData_visible[i][j];
	SqueueData_indicator[i][j][0].style.display = SqueueData_visible[i][j] ? "none" : "block";
	SqueueData_indicator[i][j][1].style.display = SqueueData_visible[i][j] ? "block" : "none";
	for (k=0;k<SqueueData_element[i][j].length;k++) {
		SqueueData_element[i][j][k].style.display = SqueueData_visible[i][j] ? "block" : "none"; }}

function QStatDataToggle(n,m) { var i = parseInt(n); var j = parseInt(m); var k;
	if (!QStatData_init || (i<0) || (i>2) || (j<0) || (j>(QStatData_select[i].length-1))) return;
	QStatData_visible[i][j] = !QStatData_visible[i][j];
	QStatData_indicator[i][j][0].style.display = QStatData_visible[i][j] ? "none" : "block";
	QStatData_indicator[i][j][1].style.display = QStatData_visible[i][j] ? "block" : "none";
	for (k=0;k<QStatData_element[i][j].length;k++) {
		QStatData_element[i][j][k].style.display = QStatData_visible[i][j] ? "block" : "none"; }}

function SqueueDataToggleAll() { var i = SqueueDataSortIndex; var j; var SqueueDataAll_visible = true;
	if (!SqueueData_init) return;
	for (j=0;j<SqueueData_select[i].length;j++) { if (!SqueueData_visible[i][j]) continue;
		SqueueDataToggle(i,j); SqueueDataAll_visible = false; }
	if (!SqueueDataAll_visible) return;
	for (j=0;j<SqueueData_select[i].length;j++) SqueueDataToggle(i,j); }

function QStatDataToggleAll() { var i = QStatDataSortIndex; var j; var QStatDataAll_visible = true;
	if (!QStatData_init) return;
	for (j=0;j<QStatData_select[i].length;j++) { if (!QStatData_visible[i][j]) continue;
		QStatDataToggle(i,j); QStatDataAll_visible = false; }
	if (!QStatDataAll_visible) return;
	for (j=0;j<QStatData_select[i].length;j++) QStatDataToggle(i,j); }

function SqueueDataSortSelect(n) { var i = parseInt(n); var j;
	if (!SqueueData_init || (i<0) || (i>2)) return; SqueueDataSortIndex = i;
	SqueueDataSort_select[i].style.backgroundColor = "#3BB9FF";
	SqueueData_sort[i].style.display = "block";
	for (j=0;j<=2;j++) { if (j==i) continue;
		SqueueDataSort_select[j].style.backgroundColor = "#FFFFFF";
		SqueueData_sort[j].style.display = "none"; }}

function QStatDataSortSelect(n) { var i = parseInt(n); var j;
	if (!QStatData_init || (i<0) || (i>2)) return; QStatDataSortIndex = i;
	QStatDataSort_select[i].style.backgroundColor = "#3BB9FF";
	QStatData_sort[i].style.display = "block";
	for (j=0;j<=2;j++) { if (j==i) continue;
		QStatDataSort_select[j].style.backgroundColor = "#FFFFFF";
		QStatData_sort[j].style.display = "none"; }}

function CondorQDataToggle(n,m) { var i = parseInt(n); var j = parseInt(m); var k;
	if (!CondorQData_init || (i<0) || (i>2) || (j<0) || (j>(CondorQData_select[i].length-1))) return;
	CondorQData_visible[i][j] = !CondorQData_visible[i][j];
	CondorQData_indicator[i][j][0].style.display = CondorQData_visible[i][j] ? "none" : "block";
	CondorQData_indicator[i][j][1].style.display = CondorQData_visible[i][j] ? "block" : "none";
	for (k=0;k<CondorQData_element[i][j].length;k++) {
		CondorQData_element[i][j][k].style.display = CondorQData_visible[i][j] ? "block" : "none"; }}

function CondorQDataToggleAll() { var i = CondorQDataSortIndex; var j; var CondorQDataAll_visible = true;
	if (!CondorQData_init) return;
	for (j=0;j<CondorQData_select[i].length;j++) { if (!CondorQData_visible[i][j]) continue;
		CondorQDataToggle(i,j); CondorQDataAll_visible = false; }
	if (!CondorQDataAll_visible) return;
	for (j=0;j<CondorQData_select[i].length;j++) CondorQDataToggle(i,j); }

function CondorQDataSortSelect(n) { var i = parseInt(n); var j;
	if (!CondorQData_init || (i<0) || (i>2)) return; CondorQDataSortIndex = i;
	CondorQDataSort_select[i].style.backgroundColor = "#3BB9FF";
	CondorQData_sort[i].style.display = "block";
	for (j=0;j<=2;j++) { if (j==i) continue;
		CondorQDataSort_select[j].style.backgroundColor = "#FFFFFF";
		CondorQData_sort[j].style.display = "none"; }}

function SAMPlotOverlayShow(element,yshow,xshow,tshow) {
	if (!SAMPlotOverlay_init) return;
	element.style.backgroundColor = "#3BB9FF";
	SAMPlotOverlay_timer = setTimeout( function () {
		SAMPlotOverlay_layer.css({ top:yshow+"px", left:xshow+"px" });
		SAMPlotOverlay_layer.html(tshow);
		SAMPlotOverlay_layer.show(100); }, 400 ); }

function SAMPlotOverlayHide(element,color) {
	if (!SAMPlotOverlay_init) return;
	element.style.backgroundColor = color;
	clearTimeout(SAMPlotOverlay_timer);
	SAMPlotOverlay_timer = null;
	SAMPlotOverlay_layer.hide(100); }

function TopUpMapInit() {
	var tu_content = jQuery("#top_up .te_content"); if (tu_content.length == 0) return;
	var tu_name = ( /\/(\w+)\.png/ ).exec(tu_content.html()); if (tu_name == null) return; tu_name = tu_name[1];
	var tu_obj = TopUpMap_object[tu_name]; if (tu_obj == null) return;
	var oheight = tu_content.outerHeight(); var owidth = tu_content.outerWidth(); var scale = owidth/800;
	var top = parseInt(0.5+scale*tu_obj.top); var left = parseInt(0.5+scale*tu_obj.left);
	var ysteps = parseInt(0.5+tu_obj.ysteps); var xsteps = parseInt(0.5+tu_obj.xsteps);
	var iheight = parseInt(0.5+scale*tu_obj.iheight); var iwidth = parseInt(0.5+scale*tu_obj.iwidth);
	var theight = parseInt(0.5+tu_obj.tlines*12); var twidth = parseInt(0.5+tu_obj.twidth);
	var i,j,rh,cw,rt,ct,rc,cc,link,text; var cwa = new Array(); var html = '';
	if ((top < 0) || (left < 0) || (ysteps < 1) || (xsteps < 1) || (iheight < 4*ysteps) || (iwidth < 4*xsteps) ||
		(oheight < (iheight + top)) || (owidth < (iwidth + left))) return;
	html += '<DIV id="mon_top_up" style="z-index:2001; display:block; position:absolute; top:24px; left:5px; height:' +
		oheight+'px; width:'+owidth+'px; margin:0px; padding:0px; color:inherit; background-color:transparent;' +
		' text-align:center; overflow:visible;">\n';
	html += '\t<DIV id="mon_top_up_grid" style="z-index:2001; display:block; position:absolute;' +
		' top:'+top+'px; left:'+left+'px; height:'+iheight+'px; width:'+iwidth+'px; margin:0px; padding:0px;' +
		' color:inherit; background-color:transparent; text-align:center; overflow:visible;">\n';
	html += '\t\t<table style="z-index:2001; display:block; position:static; height:'+iheight+'px; width:'+iwidth +
		'px; margin:0px; padding:0px; border-width:0px; border-collapse:separate; border-spacing:0px;' +
		' color:inherit; background-color:transparent;">\n';
	ct = 0; for (j=0;j<xsteps;j++) { cw = parseInt(0.5+(iwidth - ct)/(xsteps-j)); ct += (cwa[j] = cw); }
	rt = 0; for (i=0;i<ysteps;i++) { rh = parseInt(0.5+(iheight - rt)/(ysteps-i));
		rc = parseInt(0.5+rt+rh/2); rc += ( rc < iheight/2 ) ? 30 : -(40 + theight);
		html += '\t\t\t<tr style="color:inherit; background-color:transparent;">\n';
		ct = 0; for (j=0;j<xsteps;j++) { cw = cwa[j]; cc = parseInt(0.5+ct+cw/2) - parseInt(0.5+twidth/2) - 5;
			link = tu_obj.link(i,j); text = tu_obj.text(i,j);
			html += '\t\t\t\t<td style="height:'+(rh-4)+'px; width:'+(cw-4)+'px; margin:0px; padding:0px;' +
				' border-width:2px; border-collapse:separate; border-style:solid; border-color:transparent;' +
				' color:inherit; background-color:transparent;'+( (link != null) && (text != null) ? ' cursor:pointer;"' +
					' onClick="javascript:window.open(\''+link+'\',\'NEW\');"' +
					' onMouseOver="javascript:TopUpMapShow(this,'+rc+','+cc+','+'\''+text+'\');"' +
					' onMouseOut="javascript:TopUpMapHide(this);"' : '"' )+'></td>\n'; ct += cw; }
		html += '\t\t\t</tr>\n'; rt += rh; } html += '\t\t</table>\n';
	html += '\t\t<DIV id="mon_top_up_text" style="z-index:2001; display:none; position:absolute; top:0px; left:0px; height:'+theight+'px;' +
		' width:'+twidth+'px; margin:0px; padding:3px; border-width:2px; border-style:solid; border-color:#000000; color:#000000;' +
		' background-color:#BBDDFF; text-align:center; white-space:nowrap; line-height:12px; font-size:10px; font-weight:500;' +
		' font-family:Geneva,Helvetica,Verdana,sans-serif; font-variant:normal; font-style:normal; overflow:hidden;">\n';
	html += '\t\t</DIV>\n'; html += '\t</DIV>\n'; html += '</DIV>\n'; tu_content.append(html);
	if (( TopUpMap_layer = jQuery('#mon_top_up_text')).length == 0) return; return true; }

function TopUpMapShow(element,yshow,xshow,tshow) {
	element.style.borderColor = "#000000";
	element.style.backgroundColor = "#3BB9FF";
	TopUpMap_timer = setTimeout( function () {
		TopUpMap_layer.css({ top:yshow+"px", left:xshow+"px" });
		TopUpMap_layer.html(tshow);
		TopUpMap_layer.show(100); }, 400 ); }

function TopUpMapHide(element) {
	element.style.borderColor = "transparent";
	element.style.backgroundColor = "transparent";
	clearTimeout(TopUpMap_timer);
	TopUpMap_timer = null;
	TopUpMap_layer.hide(100); }

function TopUpMapTidy() { return;
	TopUpMap_layer[0].remove();
	TopUpMap_layer[1].remove();
	TopUpMap_layer = [null,null]; }

