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
    
    var userId = GetUrlParam("userid"); //获取当前用户id
	var websocket = null;
	
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

	   var response = JSON.parse(event.data);
		if(response.type == "invite"){
		     document.getElementById('reject').innerHTML ="<button onclick="+'"'+"reject("+"'"+response.from+"'" + ","+ "'"+response.roomId+"'"+")"+'"'+" >拒绝接听</button>"  + '<br/>';
		     setMessageInnerHTML(response.msg);
		     setMessageInnerHTML(response.index);
	
		}
		
		if(response.type== "reject"){
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
	}
	//发送消息 到websocket
	function send() {
	
		$.ajax({
          url: "http://localhost:8080/demo/app/createTrtcRoom/"+userId+"/1234",
          type : 'json',
          method : 'GET',
          success:function(data){   
             console.log(data);
           
               var to = document.getElementById('text').value;  //被通话者
               var type = "invite";
				var post = "{" + " \"from\":\"" + userId + "\"," + " \"to\":\""+to+"\","
				+ " \"roomId\":\""+data.roomId+"\"," +" \"type\":\"" + type+"\","+ " \"key\":\""+data.privateMapKey+"\"" + " }"
				websocket.send(post);
				console.log(post);
				
				var newWindow=window.open();
					setTimeout(function(){
					newWindow.location="http://localhost:8080/demo/app/createRoom?userId="+data.userId+"&roomId="+data.roomId+"&userSig="+data.userSig+"&key="+data.privateMapKey;
					}, 500);
							
           }

      });
		
	}
	
</script>
</html>
