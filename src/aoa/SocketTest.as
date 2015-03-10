package aoa
{
  import air.net.*;
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  
   public class SocketTest extends Sprite
  {
    private var socket:XMLSocket; // <-- Now a member variable!

    public function SocketTest()
    {
      socket = new XMLSocket();

      socket.addEventListener(DataEvent.DATA, onDataX);
      socket.addEventListener(Event.CONNECT, onEvent);
      socket.addEventListener(Event.CLOSE, onEvent);
      socket.addEventListener(NetStatusEvent.NET_STATUS, onEvent);
      socket.addEventListener(IOErrorEvent.IO_ERROR, onEvent);
      
      socket.connect("127.0.0.1", 8081);

    }
    
    private function onEvent(event:Event):void {
      AoA.log("onEvent:"+event);
    }

    private function onDataX(event:DataEvent):void {
      AoA.log("onData");
      var xmlData:XML = new XML(event.data);
      trace(xmlData.cmd.toString());
    }
  }
}