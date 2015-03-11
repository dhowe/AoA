package aoa
{ 
	//import com.adobe.air.logging.FileTarget;
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.geom.*;
	import flash.system.System;
	import flash.text.*;
	import flash.utils.*;
	
	import mx.containers.*;
	import mx.controls.*;
	import mx.core.*;
	import mx.effects.*;
	import mx.effects.effectClasses.*;
	import mx.events.*;
	import mx.logging.*;
	import mx.logging.targets.*;
	import mx.utils.*; 
	
	public final class AoA
	{      
		include "Constants.as";
		
		public static var app:Application;
		
		public static function init(a:Application) : void {
			app = a;
			initLogging();
			Assets.load();  
		}
		
		public static var startTime:int = getTimer();
		
		[Bindable]
		public static var windowing:Boolean = ENABLE_TEXT_WINDOWING;
		
		[Bindable]
		public static var flashClips:Boolean = false;
		
		[Bindable]
		public static var flashText:Boolean = false;
		
		[Bindable]
		public static var largeFlip:Boolean = false;
		
		
		//[Bindable]
		//public static var elevator:Boolean = ENABLE_ELEVATORING;
		
		[Bindable]
		public static var stageRotated:Boolean = ROTATE_STAGE;
		/*          
		[Bindable]
		public static var fullScreen:Boolean = FULL_SCREEN;  
		*/
		[Bindable]
		public static var flipping:Boolean = ENABLE_TEXT_FLIPPING;
		
		[Bindable]
		public static var scrolling:Boolean = ENABLE_SCROLLING;
		
		[Bindable]
		public static var showInfo:Boolean = SHOW_INFO;
		
		[Bindable]
		public static var showClipNames:Boolean = SHOW_CLIP_LABELS;
		
		[Bindable]
		public static var time:Number = 0;
		
		[Bindable]
		public static var syncTime:String;
		
		[Bindable]
		public static var totMem:Number = 0;
		
		[Bindable]
		public static var maxMem:Number = 0;
		
		[Bindable]
		public static var instanceId:int = -1;
		
		[Bindable]
		public static var socketStatus:String = "na";
		/*   
		[Bindable]
		public static var showInstanceIds:Boolean = true; */
		
		[Bindable]
		public static var fps:int;
		
		private static var logger:ILogger;
		private static var logTarget:TraceTarget;
		
		//private static var fileTarget:FileTarget;  // tmp
		
		public function AoA() {
			throw new Error("attempt to instantiate abstract class: aoa.Util!");
		}  
		
		// ========================================================================
		public static function showError(e:Error, exit:Boolean=false) : void {
			var errorMessage:TextField = new TextField();
			errorMessage.autoSize = TextFieldAutoSize.LEFT;
			errorMessage.textColor = 0xFF0000;
			errorMessage.text = e.message;
			app.addChild(errorMessage);
			if (exit)
				die("", e);
			else 
				err("", e);
		}
		
		// ============================ Introspection ===============================
		
		private static function getProps(o:Object) : String {;
			return ObjectUtil.toString(ObjectUtil.getClassInfo(o));
		}
		
		public static function getClassName(o:Object) : String  { 
			return describeType(o).classInfo.@name.toString();
		}  
		
		public static function getClass(o:Object) : Class  { 
			return describeType(o).classInfo.@name;
		}  
		
		public static function getDetails(obj:Object) : void 
		{ 
			// Get the Button control's E4X XML object description.
			var classInfo:XML = describeType(obj);
			
			// List the class name.
			var ta1:String = "Class " + classInfo.@name.toString() + "\n";
			
			// List the object's variables, their values, and their types.
			for each (var v:XML in classInfo..variable) {
				ta1 += "  Variable " + v.@name + "=" + obj[v.@name] + 
					" (" + v.@type + ")\n";
			}
			
			// List accessors as properties.
			for each (var a:XML in classInfo..accessor) {
				// Do not get the property value if it is write only.
				if (a.@access == 'writeonly') {
					ta1 += "  Property " + a.@name + " (" + a.@type +")\n";
				}
				else {
					ta1 += "  Property " + a.@name + "=" + 
						obj[a.@name] +  " (" + a.@type +")\n";
				}
			} 
			
			// List the object's methods.
			for each (var m:XML in classInfo..method)
			ta1 += "  Method " + m.@name + "():" + m.@returnType + "\n";
			log("-------------------------------------------------");
			trace(ta1+"\n-------------------------------------------------");
		}  
		
		// ============================ FrameRate ===============================
		private static var fpsCounter:Number = 1;
		private static var fpsWindow:Number = 10;
		public static function updateFPS() : void
		{
			if (fpsCounter >= fpsWindow) {
				var stopTime:Number = getTimer();
				var elapsedTimeInSecs:Number = (stopTime - startTime) / 1000;
				fps = int(fpsWindow / elapsedTimeInSecs);
				startTime = stopTime;
				fpsCounter = 1;
			}
			else 
				fpsCounter++;
		}     
		
		public static function totalFPS(totalFrames:Number) : void
		{
			fps = totalFrames / (AoA.time/1000); // sec
		}    
		
		// ============================ EventHandlers ===============================
		public static function onExiting(exitingEvent:Event):void {
			
			//AoA.log("Exiting");
			
			var winClosingEvent:Event;
			for each (var win:NativeWindow in NativeApplication.nativeApplication.openedWindows) {
				
				winClosingEvent = new Event(Event.CLOSING,false,true);
				win.dispatchEvent(winClosingEvent);
				if (!winClosingEvent.isDefaultPrevented()) {
					win.close();
				} else {
					exitingEvent.preventDefault();
				}
			}      
			if (!exitingEvent.isDefaultPrevented()) {
				
				// cleanup here...
				if (!RELEASE_BUILD)
					Log.removeTarget(logTarget);
			}
		}
		
		public static function numToChar(num:int):String {
			
			if (num > 36 && num < 41) {
				var arrows:String = "LURD";
				return arrows.charAt(num - 37); // ARROW KEYS
			}
			else if (num > 47 && num < 58) {
				var strNums:String = "0123456789";
				return strNums.charAt(num - 48);
			} else if (num > 64 && num < 91) {
				var strCaps:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
				return strCaps.charAt(num - 65);
			} else if (num > 96 && num < 123) {
				var strLow:String = "abcdefghijklmnopqrstuvwxyz";
				return strLow.charAt(num - 97);
			} else {
				return num.toString();
			}
		}
		
		public static function initLogging() : void 
		{
			if (RELEASE_BUILD) return;
			logger = Log.getLogger("AoA"); // add instanceId?      
			logTarget = new TraceTarget();
			logTarget.filters=["*"];
			logTarget.level = LogEventLevel.ALL;
			logTarget.includeCategory = false;
			logTarget.includeDate = false;
			logTarget.includeTime = true;      
			logTarget.includeLevel = true;
			Log.addTarget(logTarget);
		}    
		
		public static function dumpApplicationInfo() : void 
		{         
			var serverIP:String = "127.0.0.2";
			var patch:uint = NativeApplication.nativeApplication.runtimePatchLevel;
			var rt:String ="Runtime: "+ NativeApplication.nativeApplication.runtimeVersion+"."+patch;      
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			var appId:String = appXml.ns::id[0];
			var versionStr:String = appXml.ns::version[0];
			if (versionStr.indexOf(":")>=0) {                    
				var parts:Array = versionStr.split(":");            
				instanceId = 1; // not used for now
				var vers:String = parts[0];             
				serverIP = parts[1];
				SocketListener.setServerIP(serverIP);
				log("AppId: "+ appId+" "+vers+" Id#"+instanceId+" server="+serverIP+" "+rt);
			}
			else
				warn("AppId: "+ appId+" "+versionStr+" [no server-ip tag]");     
		}    
		
		// ============================= Logging ==============================
		
		private static function getLogger() : ILogger  {
			if (logger == null) 
				initLogging();
			if (logger == null) {
				trace("Null Logger!!!"); 
				exit();
			} 
			return logger;
		} 
		
		public static function log(msg:String="") : void  { 
			if (RELEASE_BUILD) return;
			getLogger().info(msg); 
		}
		
		public static function warn(msg:String,e:Error=null) : void {
			if (RELEASE_BUILD) return;
			getLogger().warn(toMsg(msg,e)+"!!!"); 
		}
		
		public static function err(msg:String, e:Error=null) : void  {  
			if (RELEASE_BUILD) return;            
			getLogger().error(toMsg(msg,e)+"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		}  
		
		public static function die(msg:String, e:Error=null) : void  {
			if (RELEASE_BUILD) return;
			trace("KILLED----------------------------------------------------------");
			getLogger().fatal(toMsg(msg,e));   
			if (!RELEASE_BUILD) exit();                
		} 
		
		private static function toMsg(msg:String, e:Error=null) : String {
			if (e == null && msg==null) return "";
			if (e == null) return msg; // yucko
			if (msg == null) return e.message;       
			return (msg += "\n   "+e.message);
		}    
		
		public static function exists(fileName:String) : Boolean {      
			var b:Boolean= File.applicationDirectory.resolvePath(fileName).exists;
			//log("Verifying clip: "+fileName+" -> "+b);
			return b; 
		}
		
		public static function linesFromFile(filePath:String) : Array
		{
			var file:File = File.applicationDirectory.resolvePath(filePath);       
			var fstream:FileStream = new FileStream();
			try {
				fstream.open(file, FileMode.READ);
			}
			catch (e:Error) {
				die("Unable to open file: "+filePath, e);
			}       
			var fcontents:String = fstream.readUTFBytes(fstream.bytesAvailable);                            
			var lines:Array = fcontents.split("\n");
			fstream.close();
			return lines;
		}        
		
		public static function clear(dur:int) : void {
			removeAll(TEXT, dur);  removeAll(CLIP, dur);     
		} 
		
		// ========================================================================
		
		public static function exit(msg:String="") : void
		{
			log("AoA.exit("+msg+")"); 
			var exitingEvent:Event = new Event(Event.EXITING, false, true);
			NativeApplication.nativeApplication.dispatchEvent(exitingEvent);
			if (!exitingEvent.isDefaultPrevented()) 
				NativeApplication.nativeApplication.exit();   
		}
		
		public static function moveToBack(a:DisplayObjectContainer, dObj:DisplayObject):void
		{
			var index:int = a.getChildIndex(dObj);
			if (index > 0) a.setChildIndex(dObj, 0);
		}
		
		public static function moveDown(a:DisplayObjectContainer, dObj:DisplayObject):void
		{
			var index:int = a.getChildIndex(dObj);
			if (index > 0)a.setChildIndex(dObj, index - 1);
		}
		
		public static function moveToFront(a:DisplayObjectContainer, dObj:DisplayObject):void
		{
			var index:int = a.getChildIndex(dObj);
			if (index != -1 && index < (a.numChildren - 1)) a.setChildIndex(dObj, a.numChildren - 1);
		}
		
		public static function moveUp(a:DisplayObjectContainer, dObj:DisplayObject):void
		{
			var index:int = a.getChildIndex(dObj);
			if (index != -1 && index < (a.numChildren - 1)) a.setChildIndex(dObj, index + 1); 
		}
		
		public static function hardwareFullScreen(stage:Stage, w:int, h:int) : void
		{   
			stage.fullScreenSourceRect = new Rectangle(0,0,w,h);
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		public static function softwareFullScreen(stage:Stage) : void
		{   
			stage.fullScreenSourceRect = null;
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
		
		private static function arrayContains(char:String, list:Array) : Boolean {
			for(var i:int = 0; i<list.length; i++)  
				if (list[i] == char) return true; 
			return false;
		}
		
		private static const CHOMP_CHARS:Array=["\\n", "\\r", "\\t", " "];
		public static function chomp(s:String) : String   // yuck
		{
			var i:int, j:int;
			for(i = 0; i < s.length; i++) { 
				if (!arrayContains(s.charAt(i), CHOMP_CHARS)) 
					break; 
			}
			for(j = s.length-1; j >= i; j--) {
				if (!arrayContains(s.charAt(j), CHOMP_CHARS)) 
					break; 
			}
			return s.substring(i, j+1);
		}
		
		public static function onNetworkChange(event:Event) : void {
			warn("Network status change: " + event);
		}    
		
		public static function startsWith(full:String, start:String) : Boolean
		{
			return (full.indexOf(start)==0);    
		}
		
		public static function endsWith(full:String, end:String) : Boolean
		{
			return (full.indexOf(end)==full.length-end.length);     
		}   
		
		public static function area(r:Rectangle) : Number
		{
			return r.width * r.height;
		}        
		
		/* 
		public static function hardReset() : void {
		AoAObj.setIgnoreTicks(true);
		dumpObjectCounts();
		clear(3000);     
		setTimeout(AoA.deleteAll, 5000);
		//AoAObj.setIgnoreTicksFor(2000);     
		}     */
		
		public static function dumpObjectCounts(type:int=0) : void {
			log("-------------------- OBJECTS ----------------------")
			log("Total-Objs:  "+AoAObj.creations.length);
			if (type == 0 || type == TEXT) {     
				log("Live-Texts:  "+AoAObj.getInstancesFor(app,TEXT).length);           
				log("Free-Texts:  "+TextAoA.freePool.length);
			}
			if (type == 0 || type == CLIP) {
				log("Live-Clips:  "+AoAObj.getInstancesFor(app,CLIP).length);           
				log("Free-Clips:  "+ClipAoA.freePool.length);
			}
			log("---------------------------------------------------")           
		}
		
		
		public static function clearArray(a:Array) : void {
			while (a.length>0) a.pop();
			if (a.length > 0) die("AoA.clearArray failed: "+a);
		}
		
		public static function dumpFonts(includeNonEmbedded:Boolean) : void {
			trace("FONTS: ");
			var fontArray:Array = Font.enumerateFonts(includeNonEmbedded);
			for(var i:int = 0; i < fontArray.length; i++) {
				var thisFont:Font = fontArray[i];
				trace("name:    " + thisFont.fontName);  
				//trace("typeface: " + thisFont.fontStyle);      
			}
		}
		
		public static function initMemoryCounter():void {
			// The first parameter is the interval (in milliseconds). The 
			// second parameter is number of times to run (0 means infinity).
			var myTimer:Timer = new Timer(100, 0);
			myTimer.addEventListener("timer", timerHandler);
			myTimer.start();
		}
		
		public static function timerHandler(event:TimerEvent):void {
			time = getTimer();// / 1000;
			totMem = System.totalMemory/1000000;
			maxMem = Math.max(maxMem, totMem);
		}
		
		public static function dumpDisplayList(container: DisplayObjectContainer, indentString:String = "") : void
		{
			var child:DisplayObject;
			for (var i:uint=0; i < container.numChildren; i++)
			{
				child = container.getChildAt(i);
				trace(indentString, child, child.name); 
				if (child is DisplayObjectContainer)
				{
					dumpDisplayList(child as DisplayObjectContainer, indentString + "  ")
				}
			}
		}
		
		/**
		 * Returns an integer between min and max inclusive
		 * @return int between min and max inclusive
		 */
		public static function rand(min:int, max:int) : int
		{
			return (int)(Math.random()*(max-min))+min;
		}   
		
		// =============================== AoAObj ==================================
		
		public static function dumpInstances(type:int) : void
		{ 
			var instances:Array = getInstances(type);      
			if (type==TEXT) log("TEXT.instances:");
			if (type==CLIP) log("CLIP.instances:");
			trace("----------------------------------------------------------------------------------");              
			for (var i:int = 0; i < instances.length; i++)              
				trace("       "+instances[i]+"("+instances[i].x+","+instances[i].y+")"); 
			trace("----------------------------------------------------------------------------------\n");
		} 
		
		//private static var ticker:uint = 0;
		public static function onTick(type:int, min:int, max:int) : void 
		{   
			if (AoAObj.getIgnoreTicks(type)) return; // ignoring ticks...
			
			//log((type==TEXT?"TEXT":"CLIP")+".onTick()...");
			
			var instances:Array = AoAObj.getInstancesFor(app, type);
			
			if (checkAges(instances)) // create 1 if we kill 1
				create(type,  DEFAULT_FADE_TIME)
			
			if (instances.length <= min) {
				//log((type==TEXT?"TEXT":"CLIP")+".onTick() create2");
				create(type,  DEFAULT_FADE_TIME, 2);
			}        
			else if (instances.length >= max) {
				//log((type==TEXT?"TEXT":"CLIP")+".onTick() fade2");
				randomFadeOut( type, DEFAULT_FADE_TIME, 2);
			}       
			else if (Math.random() <.5) {
				//log((type==TEXT?"TEXT":"CLIP")+".onTick() create1");
				create(type,  DEFAULT_FADE_TIME);
			}        
			else { 
				//log((type==TEXT?"TEXT":"CLIP")+".onTick() fade1");
				randomFadeOut( type, DEFAULT_FADE_TIME);
			}
		}
		
		private static function checkAges(arr:Array) : AoAObj
		{
			var time:int = getTimer();       
			for (var i:int = 0; i < arr.length; i++) {
				var obj:AoAObj = (arr[i] as AoAObj);
				var age:int = time - (obj.birth);
				if (!obj.elevatoring) {
					var micro:Boolean = (obj is TextAoA && (obj as TextAoA).isMicro);
					var maxAge:int = micro ? MAX_MICRO_LIFE_SPAN : MAX_LIFE_SPAN; 
					if (age > maxAge) {
						//log("Removing eldest: " +obj+" micro="+micro);
						obj.doFadeOut(DEFAULT_FADE_TIME);
						return obj;
					}
				}
			}
			return null;
		}
		
		public static function getInstances(type:int) : Array { 
			return AoAObj.getInstancesFor(app, type);
		}
		
		private static function getOldest(type:int) : AoAObj
		{ 
			var instances:Array = getInstances(type);
			if (instances.length < 1) return null;    
			var oldest:AoAObj;   
			var maxAge:int = 0;   
			var time:int=getTimer();       
			for (var i:int = 0; i < instances.length; i++) {
				if (!instances[i]) continue;// || instances[i].elevatoring) continue;               
				if (instances[i].millisAlive(time) > maxAge) { 
					oldest = instances[i];  
					maxAge = oldest.millisAlive(time); // this was not in the if block!!!    
				} 
			}
			return oldest;
		} 
		
		public static function removeOldest(type:int, dur:int) : void
		{
			var oldest:AoAObj = getOldest(type);
			if (oldest) {
				//log("Removing oldest: "+oldest);      
				oldest.doFadeOut(dur);
			}
			else 
				err("No oldest found of type: "+type);
		}
		
		public static function removeAll(type:int, dur:int) : void
		{ 
			var instances:Array = getInstances(type);
			for (var i:int = 0; i < instances.length; i++)               
				instances[i].doFadeOut(dur);
		} 
		
		public static function randomInstance(type:int) : AoAObj {  
			var instances:Array = getInstances(type);
			var r:int = rand(0, instances.length);      
			return instances[r];   
		}
		
		public static function randomFadeIn(type:int, dur:int, num:int=1) : void  {   
			for(var i:int = 0; i < num; i++)    { 
				var obj:AoAObj  = randomInstance(type);
				if (obj) obj.doFadeIn(dur); 
			}
		}
		
		public static function randomFadeOut(type:int, dur:int, num:int=1) : void  {       
			for(var i:int = 0; i < num; i++) {                   
				var obj:AoAObj  = randomInstance(type);
				if (obj) obj.doFadeOut(dur);       
			}
		}
		
		public static function create(type:int, dur:int, num:int=1) : void { 
			if (type==TEXT) 
				TextAoA.create(app, DEFAULT_FADE_TIME, num);   
			else if (type==CLIP)  
				ClipAoA.create(app, DEFAULT_FADE_TIME, num); 
			else 
				die("unexpected type: "+type); 
		}
		
		public static function currentTimeMillis() : Number {
			return new Date().getTime();   
		}
		
		public static function deleteAll(a:Application) : void
		{ 
			// clear the object pools
			while (TextAoA.freePool.length>0)  TextAoA.freePool.pop();     
			while (ClipAoA.freePool.length>0)  ClipAoA.freePool.pop(); 
			
			while (AoAObj.creations.length>0) { 
				var obj:AoAObj = AoAObj.creations.pop();     
				obj.visible = false;
				obj.alpha = 0;
				obj = null;      
			}
			var arr:Array = a.getChildren();
			for (var i:int = 0; i < arr.length; i++) {
				if (arr[i] is AoAObj) {
					log("app removing child: "+arr[i]);
					a.removeChild(arr[i]);
				}
			} 
			AoA.dumpObjectCounts();
			setTimeout(AoA.dumpDisplayList,3000,a);
			System.gc();
			
			AoAObj.ID = 0;
		} 
		
	}// end
	
}// end pkg