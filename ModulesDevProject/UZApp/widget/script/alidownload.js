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
		accessKeySecret: "9jUYnQkkQYWXos4bJQgDBFYqKcSSH5hfqucSKs6f3AKC",
		accessKeyId: "STS.LYtCoEq7tfeHUDZEVjdrv2wCx",
		securityToken: "CAIS8wF1q6Ft5B2yfSjIrZrBCNXxnOhV0aejV2LroVY/aP1a3bLomjz2IHBOdXRvAesavv8+mGpQ6PsflqNhS55BREXDc8x8tiaTLM9/J9ivgde8yJBZor/HcDHhJnyW9cvWZPqDP7G5U/yxalfCuzZuyL/hD1uLVECkNpv74vwOLK5gPG+CYCFBGc1dKyZ7tcYeLgGxD/u2NQPwiWeiZygB+CgE0D8kt/7gmJTMs0aP3QankdV4/dqhfsKWCOB3J4p6XtuP2+h7S7HMyiY46WIRpP0n0fMcomuX5YDBWQEPvkicUfDd98NoIBV0b6Qqqm2bLRJdO5cagAEG97jGVzys8+A/za/pFt98rUECIWxxkpUqTk1BfDVYIPkmmBRgWriPKyO7UybSzXXNHhUczxJHjzk07qUyyUFWYEYI0r7Wyeh9UBRRKYe7JAVIO9tXg4TJReAN7R1wRhLE++V+BSG+SgB6jBVMxR7NhSjyChW0ufLyIG619RRZtw=="
		};
	return downloadSts;
}
