package aoa
{
  import air.net.*;
  
  import flash.events.*;
  import flash.net.*;
  import flash.utils.*;
  
  public class SocketListener
  {    
    public static const SOCKET_CHECK_INTERVAL:int = 10*1000; // 10 sec for now
    private static const CHECK_CHARS:Array = ["<","\\",">"];
          
    public static const port:int = 8081; 
    public static var host:String = "localhost";
      
    // singleton ==============================
    private static var instance:SocketListener;
    private static var lock:Object = new Object();
    
    public static function getInstance() : SocketListener {
      if (!instance) 
        instance = new SocketListener(lock);
      return instance;        
    } 
    
    // class ===================================
    private static var lastSyncMsgAt:Number = AoA.startTime;  
    private static var lastSyncMsg:Number = AoA.currentTimeMillis();
    
    private var lastMsgId:int = -1;
    private var socket:Socket;
    //private var monitor:SocketMonitor;    
    //private var useMonitor:Boolean;
    private var socketListenerId:int;
    
    public function SocketListener(o:Object)
    {
      AoA.log("creating socket listener: "+host);
      
      if (o != lock) 
        AoA.die("Attempt to directly create singleton: SocketListener");
      
      this.socket = new Socket();    
      
      /* if (useMonitor) {
        monitor = new SocketMonitor(host, port);         
        monitor.addEventListener(StatusEvent.STATUS, socketStatusChange);
        monitor.start();  
        AoA.log("SocketMonitor started...");
      } */       
      
      socket.addEventListener(Event.CONNECT, onEvent);
      socket.addEventListener(Event.CLOSE, onEvent);
      socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
      socket.addEventListener(ProgressEvent.SOCKET_DATA, onProgressEvent);
      
      AoA.log("SocketListener created for: "+host);
    }
    
    public function connect() : void 
    {
        AoA.log("SocketListener attempting to connect...");  
        try {
          socket.connect(host, port); 
          AoA.socketStatus = "trying";
        }
        catch (se:SecurityError) {
          AoA.warn("Unable to connect to socket...");
        }   
        catch (e:SecurityError) {
          AoA.warn("Unable to connect to socket: ",e);
        }        
    }

    /* private function socketStatusChange(event:StatusEvent) : void
    {
        AoA.log("SocketStatusChange: state="+monitor.available+" event="+event); 
    } */  

    private function onError(e:IOErrorEvent):void {
      AoA.warn("SocketListener: "+e.text);
      //socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityEvent);
      addNetworkListener();
    }
    
    private function onEvent(event:Event):void {
       switch(event.type) {
          case Event.CLOSE: 
            AoA.warn("Socket unexpectedly closed! ");            
            addNetworkListener();
            break;
          case Event.CONNECT: 
            AoA.log("SocketListener connected on port "+port);           
            clearInterval(socketListenerId);
            break;
          default:
            AoA.warn("Unexpected Socket Event: "+event);
        }
    }
    
    private function onSecurityEvent(event:SecurityErrorEvent) : void {      
      //AoA.log("onSecurityEvent(event="+event+")");
    } 
    
    
    private function addNetworkListener() : void {
      //AoA.log("Starting socket-checker (interval="+SOCKET_CHECK_INTERVAL+"ms)...");
      socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityEvent);
      AoA.socketStatus = "err";
      clearInterval(socketListenerId);
      socketListenerId = setInterval(connect, 30*1000); // check every 30 sec for server
    }
    
    private function onProgressEvent(event:ProgressEvent):void {      
        var msg:String = socket.readUTFBytes(socket.bytesAvailable);
        //AoA.log("Socket: "+msg);
        onData(msg);
    }    
    
    public static function elapsedSinceLastSyncMessage() : Number {
      //AoA.log(AoA.currentTimeMillis() +" - "+ lastSyncMsgAt);
      return (int)(AoA.currentTimeMillis() - lastSyncMsgAt);
    }  
    
    public static function setServerIP(serverIP:String) : void {      
      host = serverIP;
      //AoA.log("setting ip: "+host);
    }
    
    public static function getSyncTime() : Number {
      var tmp:Number = lastSyncMsg + elapsedSinceLastSyncMessage();
/*       var syncStr:String = String(tmp);
      AoA.syncTime = syncStr.substring(syncStr.length-5,syncStr.length); */
      AoA.syncTime = tmp+"";
      return tmp;
    }
    
     // check the id against the last (tmp)
    private function checkId(id:int) : void  
    {         
       //AoA.log("[INFO] Received msg id="+id+"...");
       if (lastMsgId > 0 && id != (lastMsgId+1) ) {
         AoA.warn("[WARN] Missed msg id="+(lastMsgId+1)+"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
         AoA.socketStatus = "MISS!!!";
         misses += (lastMsgId+1)+", ";
         lastMsgId = -1;
       }
       else
         lastMsgId = id;
    }   
       
    private var misses:String = "";
    private function checkCommand(fromServer:String) : String  
    {             
      if (fromServer.charAt(fromServer.length-1)=="\n")  // remove the line break
        fromServer=fromServer.substr(0,fromServer.length-1);
      else
        AoA.warn("NO ENDING LINE BREAK!!!");
      
      var openXml:String="<sync ";
      var openXmlIdx:int = fromServer.indexOf("<sync ");
      if (openXmlIdx<0) { 
        AoA.err("Invalid sync string(1): "+fromServer);
        return null;
      }
      var closeXml:String="\>";
      var closeXmlIdx:int = fromServer.lastIndexOf(closeXml);
      if (closeXmlIdx<0) {
        AoA.err("Invalid sync string(2): "+fromServer);
        return null;
      }
      
      // remove start and end tags
      fromServer = fromServer.substring(openXmlIdx+openXml.length, closeXmlIdx-1); 
      
      for (var j:int = 0; j < CHECK_CHARS.length; j++) {      
        if (fromServer.indexOf(CHECK_CHARS[j])>=0) {          
          AoA.err("Invalid sync string(badChar="+CHECK_CHARS[j]+"): "+fromServer);
          return null;
        }
      }
             
      //AoA.log("||SERVER||"+fromServer+"||\SERVER||");
            
      if (AoA.showInfo) // update the socket status
        AoA.socketStatus = (misses.length==0) ? "ok" : misses;
      
      return fromServer;
    }
    
    public function onData(fromServer:String) : void  
    {                   
      fromServer = checkCommand(fromServer);
      if (!fromServer) return;
               
      // parse out the id 
      var pre:String="id='";        
      if (fromServer.indexOf(pre) != 0)
        AoA.err("NO MATCH(Id): |||"+fromServer+"|||");
      fromServer = fromServer.substring(pre.length);
      var idIdx:int = fromServer.indexOf("'");
      if (idIdx<0) AoA.err("Invalid id string: "+fromServer);
      var id:int = parseInt(fromServer.substring(0, idIdx)); 
      fromServer = fromServer.substring(idIdx+1); // the rest  
      
      if (fromServer.charAt(0)==" ") // chop the leading space
        fromServer = fromServer.substr(1,fromServer.length); 
      
      //AoA.log("GOT ID="+id+" |||"+fromServer+"|||");
      
      checkId(id); // TMP
      
      // parse out the time
      pre ="time='";
      if (fromServer.indexOf(pre) != 0) 
         AoA.err("NO MATCH(Id): |||"+fromServer+"|||");
      fromServer = fromServer.substring(pre.length);
      var timeIdx:int = fromServer.indexOf("'");
      if (timeIdx<0) AoA.err("Invalid time string: "+fromServer);
      var time:Number = parseInt(fromServer.substring(0, timeIdx)); 
      //AoA.log("time string="+time);            
      fromServer = fromServer.substring(timeIdx+1); // the rest   
      
      if (fromServer.charAt(0)==" ") // chop the leading space
        fromServer = fromServer.substr(1,fromServer.length); 
      
      //AoA.log("GOT TIME="+time+" |||"+fromServer+"|||");
      
      if (fromServer.length==0)  {// just time 
        lastSyncMsg = time;
        lastSyncMsgAt = AoA.currentTimeMillis()
        //AoA.log("Sync="+tmp+"  ServerSync: "+serverSyncStamp +" Local="+lastSyncMsgAt);
      }
      else  {// we have a cmd with a time       
        //AoA.log("Cmd String: \""+fromServer+"\"");
        parseCommandStr(time, fromServer);                                    
      }  
      fromServer = null;                  
       //sendReply();      
    }
    
    private function parseCommandStr(serverSyncStamp:Number, cmdString:String) : void 
    {       
       //AoA.log("parseCommandStr.serverSyncStamp="+serverSyncStamp+" cmd="+cmdString+"\n");
       if (serverSyncStamp < 0) AoA.die("Invalid serverSyncStamp: "+serverSyncStamp);
       var pre:String = "cmd='"; // get cmd string
       if (cmdString.indexOf(pre) != 0) { 
         AoA.err("Bad Cmd String(1): \""+cmdString+"\"");
         return;
       }             
       cmdString = cmdString.substring(pre.length, cmdString.length);                          
       var tickIdx:int = cmdString.indexOf("' ");
       if (tickIdx<0) {
         AoA.err("Bad Cmd String(2): \""+cmdString+"\"");
         return;
       }
       var cmd:String = cmdString.substring(0,tickIdx);     
       cmdString = cmdString.substring(tickIdx+1,cmdString.length);                  
       

       pre = "start='";  // get start time
       if (cmdString.charAt(0)==" ") cmdString=cmdString.substr(1,cmdString.length);
       if (cmdString.indexOf(pre) != 0) { 
         AoA.err("Bad Start String(1): \""+cmdString+"\"");
         return;
       }
       cmdString = cmdString.substring(pre.length, cmdString.length);
       tickIdx = cmdString.indexOf("'");
       if (tickIdx<0) AoA.err("Bad Start String(2): \""+cmdString+"\""); 
       var start:String = cmdString.substring(0, tickIdx);
       cmdString = cmdString.substring(tickIdx+1,cmdString.length); 
       if (cmdString.length != 0)  {       // the rest     
         AoA.err("Bad Start String(3): extra characters(shold be 0-length) in \""+cmdString+"\"");
         return;
       }
       //AoA.log("Cmd="+cmd+" Sync="+serverSyncStamp+" Time="+start);

       //scheduleCommandEvent(cmd, parseInt(start));               
      
      var callTime:Number = getSyncTime() + parseInt(start);
       var mm:AoAModeManager = AoAModeManager.getInstance();
       mm.queueCommand(cmd, callTime);        
    }

/*     // NOT USED
    private function scheduleCommandEvent(cmd:String, startTime:Number, duration:Number=-1) : void 
    {                          
       var callTime:Number = getSyncTime() + startTime;
       if (callTime < 0) {
         AoA.err("Invalid callTime="+callTime);
         return;
       }   
       
       //AoA.nextCmdTime = callTime + "";
       var args:Array = new Array(); 
        args.push(callTime);
        switch (cmd) {
          case "reset":
           args.push(AoAModeManager.reset);           
           break;
         case "clipFlash":
           args.push(AoAModeManager.clipFlash);           
           break;
         case "clearCmds":
           // clear all timers
           break; 
         case "oneClipPer":
           args.push(AoAModeManager.oneClipPer);
           break; 
         case "oneTextPer":
           args.push(AoAModeManager.oneTextPer);
           break;
         case "brown":
           args.push(AoAModeManager.setColorMode); 
           args.push(cmd);
         case "turqoise":
           args.push(AoAModeManager.setColorMode); 
           args.push(cmd);
           break;           
         case "red":
           args.push(AoAModeManager.setColorMode); 
           args.push(cmd);
           break;          
         case "green":
           args.push(AoAModeManager.setColorMode);
           args.push(cmd);
           break;          
         default:
           AoA.err("Unexpected CMD: "+cmd);   
           return;                       
       }
       //AoA.log("new SyncFunction("+args+")\n-------------------------------------------");
       var syncFun:SyncFunction = new SyncFunction(args);   
       syncFun.run(); 
    }
    */
    
  }// end class
  
}// end pkg

/*
import flash.utils.*;
import flash.events.*;
import aoa.*;

class SyncFunction {
  
  private var func:Function;
  //private var endFunct:Function;
  private var syncTimer:Timer;
  private var params:Array;
  private var startTime:Number;
  private var completed:Boolean;
  private var duration:int;
  //var parent:SocketListener;
      
  public function SyncFunction(args:Array) : void {
    //AoA.log("SyncFunction<init>"+args);
    //this.parent = sl;
    startTime = Number(args.shift());
    if (!startTime) 
      AoA.die("invalid start param: startTime="+startTime +" args="+ args);
    //AoA.log("SyncFunction<init> @"+startTime);      
    func = args.shift();
    if (func == null) 
      AoA.die("invalid start param: func="+func+" args="+ args);
    params = args;
  }
  
  public function run() : void {
       // twice the time til start   
    var repeats:int = (startTime / 50 ) * 2;            
    syncTimer = new Timer(50, repeats); // check every 50 ms     (why not use tick timer?)  
    var checkForSyncCmd:Function = function(te:TimerEvent) : void {        
       var now:Number = SocketListener.getSyncTime(); 
       if (!completed && now >= startTime) {                 
         //AoA.log(now+") Calling scheduled function: "+func+" w' params: "+params);
         completed = true;
         func();
         if (params.length > 0) 
         {
           AoA.log("calling func w' params: "+params);
           func(params);// deal w args & duration
           
           // quick hack for now to disable colors after 30 seconds
           setTimeout(AoAModeManager.setColorMode, 30000);
         }
         syncTimer.stop();
          AoA.nextCmd="none";
         AoAModeManager.nextCmdTime = -1;
         AoAModeManager.nextCmdTimeStr = "-1"; 
       }
       // else AoA.log("triggering event in "+(startTime-now)+"ms");
     };       
     syncTimer.addEventListener(TimerEvent.TIMER, checkForSyncCmd);
     syncTimer.start();       
  } 
}*/
