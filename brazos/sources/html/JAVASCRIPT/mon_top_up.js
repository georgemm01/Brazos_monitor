
TopUp.fast_mode = 1;

TopUp.libs = "core";

TopUp.images_path = "IMAGES/top_up/";

TopUp.players_path = "SWF/top_up/";

TopUp.addPresets({
	"#transfer_plot_anchor a": {
		group: "transfer_plot",
		layout: "quicklook",
		effect: "transform",
		resizable: 0,
		shaded: 1,
		overlayClose: 1,
		type: "image",
		title: "Plot {current} of {total}: {alt}",
		},
	"#subscription_plot_anchor a": {
		group: "subscription_plot",
		layout: "quicklook",
		effect: "transform",
		resizable: 0,
		shaded: 1,
		overlayClose: 1,
		type: "image",
		title: "Plot {current} of {total}: {alt}",
		},
	"#job_plot_anchor a": {
		group: "job_plot",
		layout: "quicklook",
		effect: "transform",
		resizable: 0,
		shaded: 1,
		overlayClose: 1,
		type: "image",
		title: "Plot {current} of {total}: {alt}",
		},
	"#sam_plot_anchor a": {
		group: "sam_plot",
		layout: "quicklook",
		effect: "transform",
		resizable: 0,
		shaded: 1,
		overlayClose: 1,
		type: "image",
		title: "Plot {current} of {total}: {alt}",
		ondisplay: TopUpMapInit,
		onclose: TopUpMapTidy,
		},
	});

