package aoa
{	
  import flash.desktop.*;
  import flash.display.*;
  import flash.geom.*;
  import flash.system.*;
  import flash.text.*;
  import flash.utils.*;
  
  import mx.containers.*;
  import mx.controls.*;
  import mx.core.*;
  import mx.effects.*;
  import mx.effects.easing.*;
  import mx.effects.effectClasses.*;
  import mx.events.*; 
	 
  public class AoAObj extends UIComponent
  {  	    
    include "Constants.as";
    
    [Bindable] // tmp
    public static var ID:int = 0;    
    public static var creations:Array = new Array(); // all
    
    public var idx:int = 0;    
    public var scrollId:int;     
    public var rect:Rectangle;                            
    public var birth:uint;    
         
    protected var fader:Fade; 
    //protected var mover:Move;
    
    protected var lastAlpha: Number;

    //protected var scrolling: Boolean;
    public var elevatoring: Boolean;
    protected var type:int;

    //[Bindable] // tmp
    public var app:Application;
    
    public function AoAObj() 
    { 
      super();                     
      this.idx = ID;
      ID++;
      this.alpha = 1; 
      lastAlpha = 1; 
      fader = new Fade();
      creations.push(this);
    }    
        
    protected function init(a: Application, dur:int) : void 
    {
      this.app = a; 
      this.lastAlpha = 1;    
      this.birth = getTimer();  
    }    
    
    public function millisAlive(time:int) : int { return time - birth; }
    

    protected function onEffectComplete(evt:EffectEvent) : void 
    {   
      if (evt.effectInstance is FadeInstance) {      
        var effInst:FadeInstance = evt.effectInstance as FadeInstance;      
        if (effInst.alphaTo != 0) { // a fade-in
          if (elevatoring) {            
            var dur:int = AoA.rand(MIN_ELEVATOR_DUR, MAX_ELEVATOR_DUR)
            doMove(x, y < app.height/2 ? app.height : -rect.height, dur);
            //AoA.log("MICRO: DUR="+dur); 
          }    
          return;    
        }
        
      }
      else if (evt.effectInstance is MoveInstance) {
        //AoA.log("Move complete("+x+","+y+") :"+this);
      }
      else
        die("unexpected type: "+evt);  

       destroy();      
      
    }
    
    protected function destroy() : void
    {             
        if (app.contains(this)) { 
          app.removeChild(this);
          getFreePool().push(this);
          return;
        }                
        if (!SILENT) warn("Unable to destroy AoAObj#"+this);
    }    

    public function doFadeIn(dur:int)  : Fade  { return doFade(true, dur);  }
    
    public function doFadeOut(dur:int) : Fade 
    {
      //if (elevatoring) return null; // no fading here...
      //AoA.log("doFadeOut: "+this); 
      return doFade(false, dur); 
    }
    
    protected function doFade(isFadeIn: Boolean, dur:int) : Fade 
    {     
      fader.end();                   
    
      if (isFadeIn) {
      	fader.easingFunction = Sine.easeIn;
        fader.alphaTo = lastAlpha;
        fader.alphaFrom = 0;
      }
      else {
      	fader.easingFunction = Sine.easeOut;            
        fader.alphaTo = 0;
        lastAlpha = alpha;
        fader.alphaFrom = alpha;
        //AoA.log("doFadeOut: dur="+dur);
      }               
      fader.duration = dur;
      fader.play([this]);           
      return fader;
    }   
    
    protected function doMove(nx:int, ny:int, dur:int) : Move 
    {     
      return null;
    }  
     
    public static function getInstancesFor(app:Application, type:int) : Array {
		
      var tmp:Array = new Array();        
      var arr:Array = app.getChildren();
      for (var i:int = 0; i < arr.length; i++) {
      if ((type==ALL || type==TEXT) && arr[i] is TextAoA)           
        tmp.push(arr[i]);
      else if ((type==ALL || type==CLIP) && arr[i] is ClipAoA)
        tmp.push(arr[i]);        
      }  
      return tmp;
    }
     
    public function getInstances() : Array {
		
      return getInstancesFor(app, type);     
    }

    protected function getFreePool() : Array  {
		
      throw new Error("Abstract function: AoAObj.getFreePool()");
    }
    
    protected function identStr() : String  {
		
      throw new Error("Abstract function: AoAObj.identStr()");
    }                    
              
    protected function area() : Number { return rect.width * rect.height; }  

    public static function getFreePool(type:int) : Array {  
        if (type==TEXT) 
          return TextAoA.freePool; 
        else if (type==CLIP)
          return ClipAoA.freePool;
        die("unexpected type: "+type);
        return null;
    }
       
    public static function getIgnoreTicks(type:int) : Boolean  {
        if (type==TEXT) 
          return TextAoA.ignoreTicks; 
        else if (type==CLIP)
          return ClipAoA.ignoreTicks;
        die("unexpected type: "+type);
        throw new Error("die");
    }  
    
    public static function ignoreTicksFor(dur:int) : void  {
      TextAoA.ignoreTicksFor(dur);  ClipAoA.ignoreTicksFor(dur);
    }
    
    public static function ignoreTicks(val:Boolean) : void  {
      TextAoA.setIgnoreTicks(val); 
      ClipAoA.setIgnoreTicks(val);
    }
    
    public static function warn(msg:String) : void { AoA.warn(msg); }
    public static function log(msg:String) : void  { AoA.log(msg); }    
    public static function err(msg:String,e:Error=null)  : void  { AoA.err(msg, e); }     
    public static function die(msg:String,e:Error=null)  : void  { AoA.die(msg, e); }
    protected static function rand(a:int, b:int) : int { return AoA.rand(a,b); }
        
  }// end
  
}// end