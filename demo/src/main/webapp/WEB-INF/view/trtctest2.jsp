<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>用戶2</title>
</head>
<body>
	测试2
	
	<!-- 音视频 -->
	<!--
        本地视频流
        muted:
            本地视频流的video必须置为静音（muted)，否则会出现啸叫/回声等问题
            Mac / iPhone / iPad 需要用js设置muted属性
        autoplay：必须为激活状态
        playsinline：保证在ios safari中不全屏播放
     -->
	<button onclick="quit();">退出</button>
	本地
	<video style="width:200px; height:200px;" id="localVideo" muted
		autoplay playsinline></video>
	<!-- 远端视频流 -->
	<br /> 远端
	<video style="width:200px; height:200px;" id="remoteVideo" autoplay
		playsinline></video>

	<!-- 纯音频 -->
	<!-- 本地音频流 / 这种场景下，localaudio 其实没有播放的必要了，可以用来调试 -->
	<!--<audio id="localAudioMedia" muted autoplay></audio>-->
	<!-- 远端音频流 -->
	<!-- <audio id="remoteAudioMedia" autoplay ></audio> -->
	<script
		src="http://www.qiaohserver.cn/YokerWechat/public/js/jquery.min.js"
		type="text/javascript" charset="utf-8"></script>
   <!--<script src="https://sqimg.qq.com/expert_qq/webrtc/2.5.2/WebRTCAPI.min.js" >-->
   <script src="https://sqimg.qq.com/expert_qq/webrtc/2.5/WebRTCAPI.min.js"></script>
	<script type="text/javascript">
	 
	
	
	WebRTCAPI.fn.detectRTC({
	        screenshare : false
	    }, function(info){
	    if( !info.support ) {
	        alert('不支持WebRTC')
	    }
	});
	 //获取系统定义的错误码
		var errorCodeMap = WebRTCAPI.fn.getErrorCode();
		
		
		//错误处理
		function errorHandler(error){
		console.log("錯誤碼:"+error.errorCode);
		    if( error.errorCode >= 70000){
		        alert('账号系统错误');
		        console.error('账号系统错误',error.errorMsg)
		    }
		    else if( error.errorCode === errorCodeMap.START_RTC_FAILED){
		        console.log(error.errorMsg)
		        alert("推流失敗")
		    }   
		}
		
		
	var RTC = new WebRTCAPI({
		    "userId": '${config.userid}',
		    "userSig": '${config.userSig}',
		    "sdkAppId":  1400117238,
		    "accountType": 32541

		},function(){
		    //初始化完成后调用进房接口
		    RTC.createRoom({
		        roomid : '${config.roomid}',
		        privateMapKey: '${config.enterkey}',
		        role : "user",   //画面设定的配置集名 （见控制台 - 画面设定 )
		    },function(){  //進入房間成功
		        console.log("進入房間成功")
		        
		    });
		  		    
		},function(error){
		    console.error(error)
		});
	     
	    
	   
     
        //本地流 新增	   
	   RTC.on( 'onLocalStreamAdd' , function( data ){
        if( data && data.stream){
            var stream = data.stream
            document.querySelector("#localVideo").srcObject = stream
        }
     });
		//远端流 新增/更新
		RTC.on( 'onRemoteStreamUpdate' , function( data ){
        if( data && data.stream){
            var stream = data.stream
            console.log( data.userId + 'enter this room with unique videoId '+ data.videoId  )
            document.querySelector("#remoteVideo").srcObject = stream
            alert("有人進來了");
        }else{
            console.log( 'somebody enter this room without stream' )
        }
     });
	    
		            	
		
		//监听错误事件通知
		RTC.onErrorNotify(function(error){
		    errorHandler(error);
		})
	    
	    
		//退出房間
		function quit(){      
          var RTC = new WebRTCAPI({
			    "userId": '${config.userid}',
		        "userSig": '${config.userSig}',
		        "sdkAppId":  1400117238,
		        "accountType": 32541,
			}, function(data){
			    RTC.quit(  function(){
			       alert("退出成功");
			    } , function(){
			        alert("退出失敗");
			    } );
			}, function(data){
			    console.log("初始化失敗");
			});
	  }
	
</script>
</body>
</html>