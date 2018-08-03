package com.cn.controller;

import java.io.BufferedReader;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

import com.alibaba.fastjson.JSONObject;
import com.sun.istack.internal.logging.Logger;

import TRTC.WebRTCSigApi;

@Controller
@RequestMapping("/app")
public class AppController {

	private static Logger logger = Logger.getLogger(AppController.class);



	
	
	
	/**创建房间
	 * @param userid 用户唯一标识 roomid 房间号
	 * @return modelAndView 渲染试图层
	 * **/
	@RequestMapping(value = "/createRoom" ,method = RequestMethod.GET)
	public ModelAndView createTRTC(HttpServletRequest request) {
		//WebRTCSigApi w = new WebRTCSigApi();
	   // Map<String, String> r = w.init(roomId, userId);
        String userId  = request.getParameter("userId");
        String roomId  = request.getParameter("roomId");
        String userSig = request.getParameter("userSig");
        String key     = request.getParameter("key");
        JSONObject res = new JSONObject();		
		res.put("userId", userId);
		res.put("roomId", roomId);
		res.put("userSig", userSig);
		res.put("key", key);		
		return new ModelAndView("trtctest", "config", res);
		
	}
	
	/**进入房间
	 * @param userid 用户唯一标识 roomid 房间号
	 * @return modelAndView 渲染试图层
	 * **/
	@RequestMapping(value = "/getInRoom/{userid}/{roomid}/{key}" ,method = RequestMethod.GET)
	public ModelAndView getTRTC(@PathVariable("userid") String userId,@PathVariable("roomid") int roomId,@PathVariable("key") String key) {
		WebRTCSigApi w = new WebRTCSigApi();
	    Map<String, String> r = w.init(roomId, userId);
		JSONObject res =  JSONObject.parseObject(JSONObject.toJSONString(r));	
		res.put("userid", userId);
		res.put("roomid", roomId);
		res.put("enterkey", key);
		logger.info("进入房间:"+JSONObject.toJSONString(res));
		return new ModelAndView("trtctest2", "config", res);
		
	}
	
	/**发起通话
	 * @param userid 用户唯一标识 roomid 房间号
	 * @return modelAndView 渲染视图层
	 * **/
	@ResponseBody
	@RequestMapping(value = "/createTrtcRoom/{userid}/{roomid}" ,method = RequestMethod.GET)
	public JSONObject createRoom(@PathVariable("userid") String userId,@PathVariable("roomid") int roomId) {
		WebRTCSigApi w = new WebRTCSigApi();
	    Map<String, String> r = w.init(roomId, userId);
		JSONObject res =  JSONObject.parseObject(JSONObject.toJSONString(r));	
		res.put("userId", userId);
		res.put("roomId", roomId);
		logger.info("创建房间:"+JSONObject.toJSONString(res));		
		return res;
		
	}
	
	
	@RequestMapping(value = "/showindex")
	public ModelAndView showIndex(@RequestParam("userid") String userid){
		return new ModelAndView("index", "userid", userid);
	}
	
	
}
