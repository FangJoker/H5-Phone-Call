package TRTC;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import org.apache.log4j.Logger;

import com.alibaba.fastjson.JSONObject;

/**
 * @ServerEndpoint 注解是一个类层次的注解，它的功能主要是将目前的类定义成一个websocket服务器端,
 *                 注解的值将被用于监听用户连接的终端访问URL地址,客户端可以通过这个URL来连接到WebSocket服务器端
 */
@ServerEndpoint("/websocket/{userid}")
public class WebSocketTest {

	private static Logger logger = Logger.getLogger(WebSocketTest.class);

	// 静态变量，用来记录当前在线连接数。应该把它设计成线程安全的。
	private static int onlineCount = 0;

	// concurrent包的线程安全Set，用来存放每个客户端对应的MyWebSocket对象。若要实现服务端与单一客户端通信的话，可以使用Map来存放，其中Key可以为用户标识
	public static CopyOnWriteArraySet<WebSocketTest> webSocketSet = new CopyOnWriteArraySet<WebSocketTest>();
	// 若要实现服务端与指定客户端通信的话，可以使用Map来存放，其中Key可以为用户标识
	public static ConcurrentHashMap<String, Object> webSocketMap = new ConcurrentHashMap<String, Object>();

	// 与某个客户端的连接会话，需要通过它来给客户端发送数据
	private Session session;

	/**
	 * 连接建立成功调用的方法
	 * 
	 * @param session
	 *            可选的参数。session为与某个客户端的连接会话，需要通过它来给客户端发送数据
	 */
	@OnOpen
	public void onOpen(Session session, @PathParam(value = "userid") String userid) {
		this.session = session;
		webSocketSet.add(this); // 加入set中
		webSocketMap.put(userid, this); // 加入map中

		addOnlineCount(); // 在线数加1
		logger.info("有新连接加入！当前在线人数为" + getOnlineCount());
		logger.info( "userid:" + userid);
		logger.info("队列:" + JSONObject.toJSONString(webSocketMap));
	}

	/**
	 * 连接关闭调用的方法
	 */
	@OnClose
	public void onClose() {
		webSocketSet.remove(this); // 从set中删除
		subOnlineCount(); // 在线数减1
		logger.info("有一连接关闭！当前在线人数为" + getOnlineCount());
	}

	/**
	 * 收到客户端消息后调用的方法
	 * 
	 * @param message
	 *            客户端发送过来的消息
	 * @param session
	 *            可选的参数
	 */
	@OnMessage
	public void onMessage(String message) {
		logger.info("来自客户端的消息:" + message);
		JSONObject j =  JSONObject.parseObject(message);//把客户端的请求封装成json
		logger.info("请求类型"+j.get("type"));
		if(j.get("type").equals("invite")){  //类型为通话请求			 
			logger.info("来自"+j.get("from")+"的通话请求");			
			// 推送给单个客户端 发通知给被通话者
		  for (String user : webSocketMap.keySet()) {
				if (user.equals(j.get("to"))) {
					WebSocketTest item = (WebSocketTest) webSocketMap.get(j.get("to"));
					try {
						JSONObject res = new JSONObject();
						res.put("msg",j.get("from") + "向你发起通话" );
						res.put("from", j.get("from"));
						res.put("type","invite" );
						res.put("roomId", j.get("roomId"));
						res.put("url", "localhost:8080/demo/app/getInRoom/"+j.get("to")+"/"+j.get("roomId")+"/"+j.get("key"));
						String url ="<a " +"target="+'"'+"blank"+'"' +  "href="+'"'+res.get("url")+'"'+">点击进入通话</a>"; //进入通话超链接
						res.put("index", url);
						logger.info("封装:"+res.toJSONString());
						item.sendSingleMessage(item.session, j.get("from") + "向你发起通话");
						
						logger.info("通话url:"+url);
						item.sendSingleMessage(item.session, res.toJSONString());
					} catch (IOException e) {
						e.printStackTrace();
					}
				}

			}
		}
		
		if(j.get("type").equals("reject")){ //拒绝通话
			 
		 logger.info("用户"+j.get("to")+"拒绝了"+"来自"+j.get("from")+"的通话请求");			
			// 推送给单个客户端 发通知给被通话者
		  for (String user : webSocketMap.keySet()) {
				if (user.equals(j.get("to"))) {
					WebSocketTest item = (WebSocketTest) webSocketMap.get(j.get("to"));
					try {
						JSONObject res = new JSONObject();
						res.put("msg", j.get("to") + "拒绝你发起的通话" );
						res.put("type","reject" );
						item.sendSingleMessage(item.session,res.toJSONString());						
					} catch (IOException e) {
						e.printStackTrace();
					}
				}

			}
		}
		

	}

	/**
	 * 发生错误时调用
	 * 
	 * @param session
	 * @param error
	 */
	@OnError
	public void onError(Session session, Throwable error) {
		logger.info("发生错误");
		error.printStackTrace();
	}

	/**
	 * 这个方法与上面几个方法不一样。没有用注解，是根据自己需要添加的方法。
	 * 
	 * @param message
	 * @throws IOException
	 */
	public void sendMessage(String message) throws IOException {
		this.session.getBasicRemote().sendText(message);
		// this.session.getAsyncRemote().sendText(message);
	}

	// 定向发送信息
	public void sendSingleMessage(Session mySession, String message) throws IOException {
		synchronized (this) {
			try {
				if (mySession.isOpen()) {// 该session如果已被删除，则不执行发送请求，防止报错
					// this.session.getBasicRemote().sendText(message);
					mySession.getBasicRemote().sendText(message);
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
	}

	public static synchronized int getOnlineCount() {
		return onlineCount;
	}

	public static synchronized void addOnlineCount() {
		WebSocketTest.onlineCount++;
	}

	public static synchronized void subOnlineCount() {
		WebSocketTest.onlineCount--;
	}

	


}
