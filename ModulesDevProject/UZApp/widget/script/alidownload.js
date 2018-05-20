var alivod = {
	downloader:false,
	init: function (downloader) {		
		alivod.downloader = downloader;
		if (!alivod.downloader) {
			return;
		}
		var secretImagePath = $api.isAndroid?'widget://android.dat':'widget://ios.dat';
		var downloadDir = api.fsDir;
		alivod.downloader.initDownloader({
			 downloadDir:downloadDir,
			 maxNums:2,
			 secretImagePath:secretImagePath
		},function(ret){
			console.log('Raw:'+JSON.stringify(ret));
			if (!ret || !ret.event || !ret.mediaInfos || ret.mediaInfos.length == 0) {
				console.log('some wrong=======================');
				return;
			}
			var mediaInfos = ret.mediaInfos;
			for (var i = 0; i < mediaInfos.length;i++) {
				var mediaInfo = mediaInfos[i];
				if (!mediaInfo) {
					continue;
				}
				console.log('mediaInfo Raw:'+JSON.stringify(mediaInfo));
				var vid = mediaInfo.vid;
				if (!vid || vid == '') {
					continue;
				}
				console.log('event:'+ret.event+';media:'+JSON.stringify(mediaInfo));
				switch(ret.event) {
				case 'error':
					if (ret.code && ret.code == 4002) {//sts过期，重新获取下载信息
						setTimeout(function() {
							alivod.prepareDownload(vid);
						},(i+1)*2*1000);
					}
					break;
				case 'prepared':
					alert('准备成功，VID:'+vid);
					$api.setStorage(vid,mediaInfo);
					break;
				case 'stop':
					alert('停止成功，VID:'+vid);
					break;
				case 'progress':
					break;
				case 'completion':
					$api.setStorage(vid,mediaInfo);
					alert('下载完成，VID:'+vid);
					break;
				case 'start':
					break;
				}
			}
		});
		//alivod.removeDownload({vid:'1347d8e2fad74413983227f16133b501','quality':6,
		//"duration":2524,"size":45532284,"format":"m3u8",
		//savePath:api.fsDir+'/'+'1347d8e2fad74413983227f16133b501_m3u8_6.mp4'});
		alivod.timer.start();
	},
	prepareDownload:function(vid) {
		if (!alivod.downloader) {
			return;
		}
		alivod.timer.checkRefreshSts(function(sts) {
			var params = {
				vid : vid,
				accessKeySecret: sts.accessKeySecret,
				accessKeyId: sts.accessKeyId,
				securityToken: sts.securityToken
			};
			console.log('====================prepareDownload================');
			alivod.downloader.prepareDownload(params);
		});
	},
	stopDownload:function(media) {
		if (!alivod.downloader) {
			return;
		}
		var mediaInfo = media;
		alivod.downloader.stopDownload(mediaInfo);
	},
	startDownload:function(media) {
		if (!alivod.downloader) {
			return;
		}
		var mediaInfo = media;
		alivod.downloader.startDownload(mediaInfo);
	},
	removeDownload:function(media) {
		if (!alivod.downloader) {
			return;
		}
		var mediaInfo = media;
		alivod.downloader.removeDownload(mediaInfo);
	}
};
	
alivod.timer = {//只有课程才有
	timerId:false,
	sts:false,
	lastStsTimestamp:false,
	start:function() {
		if (alivod.timer.timerId) {
			return;
		}
		alivod.timer.timerId = setInterval(function() {//定时存储播放进去
			alivod.timer.checkRefreshSts();//启动sts检查
		},10*1000);
	},
	getTimestamp:function() {
		var timestamp =Date.parse(new Date());
		return parseInt(timestamp/1000);
	},
	setSts:function(sts) {
		console.log('setsts:'+JSON.stringify(sts));
		if (sts && typeof(sts) == 'object') {
			alivod.timer.sts = sts;
			//alivod.timer.sts.expire = 70;
			alivod.timer.lastStsTimestamp = alivod.timer.getTimestamp();
		}
	},
	checkRefreshSts:function(callback) {
		if (!alivod.timer.sts) {
			//当sts没有初始值，无需更新
			//当的确发送callback，通常play，强制启动获取刷新sts防止误判
			callback && alivod.timer.refreshStsModel(callback);
			return;
		}
		var diffTime = alivod.timer.getTimestamp() - alivod.timer.lastStsTimestamp;
		//console.log('diffTime:'+diffTime+';expire:'+(alivod.timer.sts.expire - 60));
		//预留60s,已经过期
		if (diffTime > (alivod.timer.sts.expire - 60)) {
			alivod.timer.refreshStsModel(callback);
			return;
		}
		callback && callback(alivod.timer.sts);
	},
	refreshStsModel: function (callback) {
		console.log('=================refreshStsModel===================');
		$api.get(
			'http://shenji.zlketang.com/app/video/sts?timestamp='+alivod.timer.getTimestamp(),
			function (json) {
				json = JSON.parse(json);
				if (json && json.data) {
					alivod.timer.setSts(json.data);
					callback && callback(json.data);
					console.log('STS Token:'+JSON.stringify(json.data));
				} else {//重新去获取sts
					setTimeout(function() {//重新检查更新sts
						alivod.timer.checkRefreshSts(callback);
					},2*1000);
				}
			});
	}
}
