<%@ page language="java" contentType="text/html; charset=UTF-8"
 pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>index </title>
</head>
<body>
 
 <p>用户:${userid}的界面</p>
 <button onclick="send()">拨号给:</button><input id="text" type="text" />
 
 <br>状态:<div id="message"></div>
 <div id="reject"></div>
</body>
 <script src="http://www.qiaohserver.cn/YokerWechat/public/js/jquery.min.js" type="text/javascript" charset="utf-8"></script>
<script>
	
//js中格式化日期，调用的时候直接：new Date().format("yyyy-MM-dd hh:mm:ss")
	Date.prototype.format = function(fmt) {
	     var o = {
	        "M+" : this.getMonth()+1,                 //月份 
	        "d+" : this.getDate(),                    //日 
	        "h+" : this.getHours(),                   //小时 
	        "m+" : this.getMinutes(),                 //分 
	        "s+" : this.getSeconds(),                 //秒 
	        "q+" : Math.floor((this.getMonth()+3)/3), //季度
	        "S"  : this.getMilliseconds()             //毫秒 
	   	}; 
	    if(/(y+)/.test(fmt)) {
	            fmt=fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length)); 
	    }
	    for(var k in o) {
	       if(new RegExp("("+ k +")").test(fmt)){
	            fmt = fmt.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length)));
	         }
	     }
	    return fmt; 
	}    
	
//获取路由参数
function GetUrlParam(paraName) {
		var url = document.location.toString();
		var arrObj = url.split("?");

		if (arrObj.length > 1) {
			var arrPara = arrObj[1].split("&");
			var arr;

			for (var i = 0; i < arrPara.length; i++) {
				arr = arrPara[i].split("=");

				if (arr != null && arr[0] == paraName) {
					return arr[1];
				}
			}
			return "";
		} else {
			return "";
		}
	}
    
//重新连接websocket
	function reconnect(url) {

	    if(lockReconnect) return;

	    lockReconnect = true;

	    //没连接上会一直重连，设置延迟避免请求过多

	    setTimeout(function () {

	        console.info("尝试重连..." + new Date().format("yyyy-MM-dd hh:mm:ss"));

	        createWebSocket(url);

	        lockReconnect = false;

	    }, 5000);

	}
	//创建websocket
	function createWebSocket(url) {
	    try {

	        websocket = new WebSocket(url);


	    } catch (e) {
	        reconnect(url);
	    }
	}
	
    var userId = GetUrlParam("userid"); //获取当前用户id
    var websocket = null;   //websocket 实例
    var lockReconnect = false;//避免重复连接
    
	//心跳检测,每30s心跳一次
	var heartCheck = {
	    timeout: 30000,
	    timeoutObj: null,
	    serverTimeoutObj: null,
	    reset: function(){
	        clearTimeout(this.timeoutObj);
	        clearTimeout(this.serverTimeoutObj);
	        return this;
	    },
	    start: function(){
	        var self = this;
	        this.timeoutObj = setTimeout(function(){
	            //这里发送一个心跳，后端收到后，返回一个心跳消息，
	            //onmessage拿到返回的心跳然后重置setTimeOut就说明连接正常
	            var check = "{" + " \"from\":\"" + userId + "\"," + " \"time\":\""+new Date().format("yyyy-MM-dd hh:mm:ss")+"\","
				+ " \"type\":\"heartCheck"+"\""+"}";
				console.log(check);
	            websocket.send(check);
	            console.info("客户端发送心跳：" + new Date().format("yyyy-MM-dd hh:mm:ss"));
	            self.serverTimeoutObj = setTimeout(function(){//如果超过一定时间还没重置，说明后端主动断开了
	                websocket.close();//如果onclose会执行reconnect，我们执行ws.close()就行了.如果直接执行reconnect 会触发onclose导致重连两次
	            }, self.timeout)
	        }, this.timeout)
	    }
	}
	
	
	//判断当前浏览器是否支持
	WebSocket
	if ('WebSocket' in window) {
		websocket = new WebSocket("ws://localhost:8080/demo/websocket/"+userId);
	} else {
		alert('Not support websocket')
	}
	//连接发生错误的回调方法 
	websocket.onerror = function() {
		setMessageInnerHTML("error");
	};
	//连接成功建立的回调方法 
	websocket.onopen = function(event) {
		setMessageInnerHTML("与服务器建立连接");
	}
	//接收到消息的回调方法
	websocket.onmessage = function() {
 	  var response = JSON.parse(event.data);  //json化后台获取的数据
       
		//如果获取到消息，心跳检测重置
	       if(response.type=="heartCheck"){
		   heartCheck.reset().start();
		   console.log("服务端心跳:"+response.msg);
	       }

		   if(response.type == "invite"){  //通话邀请
			     document.getElementById('reject').innerHTML ="<button onclick="+'"'+"reject("+"'"+response.from+"'" + ","+ "'"+response.roomId+"'"+")"+'"'+" >拒绝接听</button>"  + '<br/>';
			     setMessageInnerHTML(response.msg);
			     setMessageInnerHTML(response.index);

			}

			if(response.type== "reject"){  //拒绝通话
			   setMessageInnerHTML(response.msg);
			   websocket.close();
			}
			//setMessageInnerHTML(event.data);
	
		
	}
	//连接关闭的回调方法 
	websocket.onclose = function() {
		setMessageInnerHTML("close");
	}
	//监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。 
	window.onbeforeunload = function() {
		websocket.close();
	}
	//将消息显示在网页上
	function setMessageInnerHTML(innerHTML) {
		document.getElementById('message').innerHTML += innerHTML + '<br/>';
	}
	
	//拒绝通话
	function reject(to, roomId){
	        var type ="reject";
	    	var post = "{" + " \"from\":\"" + userId + "\"," + " \"to\":\""+to+"\","
				+ " \"roomId\":\""+roomId+"\"," +" \"type\":\"" + type+"\","+ "  }";
			console.log(post);
				websocket.send(post);
	} 
	//关闭连接 
	function closeWebSocket() {
		websocket.close();
	//发送消息 到websocket
	function send() {
	 var to = document.getElementById('text').value;  //被通话者
	 var time = new Date().getTime().toString();	
		$.ajax({
          url: "https://www.zhuyoulife.com:8448/liaoxueChat/app/createTrtcRoom/"+userId+"/"+time.substring(time.length-4),
          type : 'json',
          method : 'GET',
          success:function(data){   
             console.log(data);   
               var type = "invite";
				var post = "{" + " \"from\":\"" + userId + "\"," + " \"to\":\""+to+"\","
				+ " \"roomId\":\""+data.roomId+"\"," +" \"type\":\"" + type+"\","+ " \"key\":\""+data.privateMapKey+"\"" + " }";
				websocket.send(post);
				console.log(post);
				var newWindow=window.open();
					setTimeout(function(){
					newWindow.location="https://www.qiaohserver.cn/liaoxueChat/app/createRoom?userId="+data.userId+"&roomId="+data.roomId+"&userSig="+data.userSig+"&key="+data.privateMapKey;
					}, 500);
							
           }

      });
		
	}
	
	
	
	
</script>
</html>
