var downloader = false;
var downloadSts = false;
function initdonwloader (player) {
	downloader = player;
	if (!downloader) {
		return;
	}
	var secretImagePath = $api.isAndroid?'widget://android.dat':'widget://ios.dat';
	var downloadDir = 'fs://';
	console.log(api.fsDir);
	downloader.initDownloader({
		 downloadDir:downloadDir,
		 maxNums:1,
		 secretImagePath:secretImagePath
	},function(ret){
		console.log(JSON.stringify(ret));
	});
	
	refreshSts();
	downloader.prepareDownload(downloadSts);
	
	downloader.setRefreshStsCallback(function() {
		downloader.setSts(downloadSts);
	});
}
//浏览器输入地址：http://shenji.zlketang.com/app/video/sts可以获取最新的sts参数
//vid是固定测试视频id，只需要更换其他参数即可
function refreshSts() {
    downloadSts = {
        vid : '1347d8e2fad74413983227f16133b501',//视频播放id
    accessKeySecret: "H7bjq1SZRkH6MwSPhy29jTgZJuqTYqSkBghLc8ksBS9R",
    accessKeyId: "STS.HC4atLsTaXjDMpo5rT51dvjWv",
    securityToken: "CAIS8wF1q6Ft5B2yfSjIqYCBKs74notA76ivT1be0XIBOb5Ima/8lDz2IHBOdXRvAesavv8+mGpQ6PsflqNhS55BREXDc8x8tiXoMqF/J9ivgde8yJBZor/HcDHhJnyW9cvWZPqDP7G5U/yxalfCuzZuyL/hD1uLVECkNpv74vwOLK5gPG+CYCFBGc1dKyZ7tcYeLgGxD/u2NQPwiWeiZygB+CgE0D8kt/7gmJTMs0aP3QankdV4/dqhfsKWCOB3J4p6XtuP2+h7S7HMyiY46WIRpP0n0fMcomuX5YDBWQEPvkicUfDd98NoIBV0b6Qqqm2bLRJdO5cagAFMTuIPINHg1M2QMqswcJAQsirOKr3aZIWPyokBOJoCmEARvrSlEO6Lki9ZOSwRAUp8s3SUeh2XfCxArxjBmMarA4iNjeNiH/SSUdF2jED7+xeNoBGLUPDQA68ibOYlveO7FfTlzq45Mic9efsDY6KJZuu0CwRFPnLRnwq1anPEuA=="
    };
	return downloadSts;
}
