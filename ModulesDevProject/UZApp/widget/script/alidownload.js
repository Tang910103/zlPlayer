var downloader = false;
var downloadSts = false;
var downloadSts_new = false;
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
    refreshSts_new();
	downloader.prepareDownload(downloadSts);
    downloader.prepareDownload(downloadSts_new);
	
	downloader.setRefreshStsCallback(function() {
		downloader.setSts(downloadSts);
	});
}
//浏览器输入地址：http://shenji.zlketang.com/app/video/sts可以获取最新的sts参数
//vid是固定测试视频id，只需要更换其他参数即可
function refreshSts() {
    downloadSts = {
        vid : '1347d8e2fad74413983227f16133b501',//视频播放id
    accessKeySecret: "64VJTuhNNPde4TbZBtMBxiZR1LDKgGpsSCSBKvUtmfnB",
    accessKeyId: "STS.Mp6jCvNsVmeoUQjRjXHHGPSfu",
    securityToken: "CAIS8wF1q6Ft5B2yfSjIrLODIfnCo6x32qeEV3fbtmoNRMdrv5bNlzz2IHBOdXRvAesavv8+mGpQ6PsflqNhS55BREXDc8x8tknOH7t/J9ivgde8yJBZor/HcDHhJnyW9cvWZPqDP7G5U/yxalfCuzZuyL/hD1uLVECkNpv74vwOLK5gPG+CYCFBGc1dKyZ7tcYeLgGxD/u2NQPwiWeiZygB+CgE0D8kt/7gmJTMs0aP3QankdV4/dqhfsKWCOB3J4p6XtuP2+h7S7HMyiY46WIRpP0n0fMcomuX5YDBWQEPvkicUfDd98NoIBV0b6Qqqm2bLRJdO5cagAFt7tDyLgViauURUXi0zhc0aJU533J+UhSrI7fNL+Z7FOaITqiQZtz0wxKuCoceCp3Xf8pyhyN1ccSZvvkfpWbhiqJPXnubzUIPCuHj67ZvF1R5R3I1kqtSCdJDlEayU+I9podKDJ8Dgiko6MxEXUW3kElEnqzsf3efgaw45Y7I3w=="
    };
	return downloadSts;
}

function refreshSts_new() {
    downloadSts_new = {
        vid : 'dcddb2bbb6e9475f8ec50ca2094e9364',//视频播放id
    accessKeySecret: "64VJTuhNNPde4TbZBtMBxiZR1LDKgGpsSCSBKvUtmfnB",
    accessKeyId: "STS.Mp6jCvNsVmeoUQjRjXHHGPSfu",
    securityToken: "CAIS8wF1q6Ft5B2yfSjIrLODIfnCo6x32qeEV3fbtmoNRMdrv5bNlzz2IHBOdXRvAesavv8+mGpQ6PsflqNhS55BREXDc8x8tknOH7t/J9ivgde8yJBZor/HcDHhJnyW9cvWZPqDP7G5U/yxalfCuzZuyL/hD1uLVECkNpv74vwOLK5gPG+CYCFBGc1dKyZ7tcYeLgGxD/u2NQPwiWeiZygB+CgE0D8kt/7gmJTMs0aP3QankdV4/dqhfsKWCOB3J4p6XtuP2+h7S7HMyiY46WIRpP0n0fMcomuX5YDBWQEPvkicUfDd98NoIBV0b6Qqqm2bLRJdO5cagAFt7tDyLgViauURUXi0zhc0aJU533J+UhSrI7fNL+Z7FOaITqiQZtz0wxKuCoceCp3Xf8pyhyN1ccSZvvkfpWbhiqJPXnubzUIPCuHj67ZvF1R5R3I1kqtSCdJDlEayU+I9podKDJ8Dgiko6MxEXUW3kElEnqzsf3efgaw45Y7I3w=="
    };
    return downloadSts_new;
}
