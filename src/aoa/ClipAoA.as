package aoa
{
  import flash.display.*;
  import flash.events.*;
  import flash.filters.*;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.utils.*;
  
  import mx.containers.*;
  import mx.controls.*;
  import mx.core.*;
  import mx.effects.*;
  import mx.effects.effectClasses.*;
  import mx.events.*;  

  public class ClipAoA extends AoAObj
  {                
    private static const DBUG_1:Boolean = false;

    public static var colClips:Array; 
    public static var ignoreTicks: Boolean = false;     
    public static var freePool:Array = new Array();        
    private static var shadow:DropShadowFilter;
      
    private var isDestroyed:Boolean;      
    private var hasVideoProperties:Boolean;
    private var checkIdx:int = 0;      // tmp  
    
    private var video:AoAVideoPlayer;
    private var label:Label;
  
    public function ClipAoA()
    {
      super();           
      this.type = CLIP;  
      this.isDestroyed = false;
      this.blendMode = BlendMode.ADD;
      addEventListener(EffectEvent.EFFECT_END, onEffectComplete);                  
    }
        
    public function stopVideo() : void { if (video && video.playing) video.stop();  }
        
    override protected function init(a:Application, dur:int) : void {
      super.init(a, dur);
      if (dbg1()) log("ClipAoa#"+idx+".init()"); 
      a.addChildAt(this, 0);
      doFadeIn(dur); 
      if (dbg1()) log("ClipAoa#"+idx+".init().done");  
    }
      
    override protected function createChildren() : void  
    {  

      if (dbg1()) log("ClipAoa#"+idx+".createChildren()"); 
      super.createChildren(); 
      if (!rect) 
          rect = new Rectangle();           
      if (!video) {
          video = new AoAVideoPlayer();
          video.addEventListener(VideoEvent.REWIND, onRewind);
          addChild(video);                                          
      }
      if (AoA.showClipNames && !label) {
		  
        label = new Label();
        shadow = new DropShadowFilter();
        setStyle("font", "myriad"); 
        setStyle("fontSize", 10); 
        shadow.angle = 5; shadow.alpha = 1;
        shadow.blurX = 1; shadow.blurY = 1;
        shadow.color=0x000000; shadow.distance = 1;                 
        label.filters = [shadow];
        addChild(label);
      } 
      if (!AoA.showClipNames && label) {
        removeChild(label);
        label  = null;
      } 
      
      if (isDestroyed) return;
	  
      video.alpha = lastAlpha = 1;            
      randomClip(AoAModeManager.colorMode);                                   
      randomSize(MIN_CLIP_W+((MAX_CLIP_W-MIN_CLIP_W)/2),MAX_CLIP_W);       
      if (!randomPos()) {         
        isDestroyed = true;        
        destroy();
      }                                                                                                   
    }
              
    override protected function measure() : void  { 
      if (dbg1()) log("ClipAoa#"+idx+".measure()")
      super.measure();    
      measuredWidth = measuredMinWidth = video.width;             
      measuredHeight = measuredMinHeight = video.height;                
    }
    
    override protected function updateDisplayList(w:Number, h:Number) : void {       
      if (dbg1()) log("ClipAoa#"+idx+".updateDisplayList()")             
      super.updateDisplayList(w,h);
      if (SHOW_CLIP_BORDERS) drawBorder();          
    }        
    
    private function drawBorder() : void {
        graphics.lineStyle(5, 0xff0000, 1);
        graphics.drawRoundRect(0,0, width, height,5);
    }
    
    override protected function identStr() : String  { return video.source;  }         
    override protected function getFreePool() : Array { return freePool; }
    override public function toString() : String {
        return  "["+idx+ ": " + super.toString()+"]" ; 
    }
   
    public function randomClip(color:String) : void
      {
        if (dbg1()) log("ClipAoa#"+idx+".randomClip()");
                  
        var idx:int = (Math.random() *  Assets.clips.length);   
        if (color == ALL_COLORS) {             
          for (var j:int = 0; j < MAX_CLIPS_PER*2; j++) {  // while-true
            var src:String = Assets.clips[idx];
            if (!inUse(src)) break;
            //log("Skipping onscreen clip: "+src);
            idx = (Math.random() * Assets.clips.length);   
          } 
          setVideoSource(src);              
        }
        else {                 
          for (var i:int = 0; i < colClips.length; i++) {
            idx = (Math.random() * colClips.length);  
            if (setVideoSource(colClips[idx], /* VERIFY_CLIP_COLOR_TAGS */false)) 
              break;  // found one
            warn("Missing video clip for '"+color+"' : "+ colClips[idx]);  
          }              
              //log("ClipAoa#"+idx+".randomClip returned: "+video.source);
        }                    
      }
      
      public function setVideoSource(src:String, verify:Boolean=false) : Boolean
      {
        if (!verify || AoA.exists(src)) {
          video.source = src;
          //AoA.log("setting src: "+src);
          var idx:int = src.lastIndexOf("/");
          src = src.substr(idx+1);
          if (label) label.text = src;           
          return true;
        }          
        die("Missing video clip: "+src);
        return false;
      }     
      
      public function randomSize(min:int, max:int=MAX_CLIP_W) : void
      {           
        var W:int = rand(min, max);
        video.width = rect.width = W;
        video.height = rect.height = (W * (2/3));
        if (label) { label.width=W; label.height = 20; }
        if (dbg1()) log("ClipAoa#"+idx+".randomSize() w="+W);         
      }
      
      public function dbg1() : Boolean { return (DBUG_1&&idx==checkIdx); }
      
      public function randomPos(marginX:int=0) : Boolean
      { 
        var appWidth:Number = app.width - CLIP_BORDER_SZ;
        var maxOuterLoops:int = 10, maxInnerLoops:int = 5;
        OUTER:  for (var k:int = 0; k < maxOuterLoops; k++)  
        {
          INNER:  for (var j:int = 0; j < maxInnerLoops; j++)
          {
            y = rect.y = rand(5, (app.height-20) - rect.height);
            x = rect.x = rand(CLIP_BORDER_SZ, appWidth - rect.width); 
            var instances:Array = getInstances();
            for (var i:int = 0; i < instances.length; i++) 
            {
               if (instances[i] === this)             
                 continue;
                
               var clip:ClipAoA = instances[i];
               if (rect.intersects(clip.rect)) {
                 var oa:Number = overlapArea(clip);
                 //log("Intersects="+oa+" overLap="+overlapArea(clip));
                 if (oa > MAX_CLIP_OVERLAP_PER)  
                   continue INNER;
               }                        
            } 
            return true;   
          }
          randomSize(MIN_CLIP_W, rect.width); // try smaller
        }
        if (!SILENT) warn("Unable to find pos for ClipAoa#"+idx+" -- giving up!");
        AoA.removeOldest(CLIP, DEFAULT_FADE_TIME); // free some space...
        return false;
      }
      
      override protected function destroy() : void
      {  
        stopVideo();
        super.destroy();  
      }
      
      private function overlapArea(c2: ClipAoA) : Number {
          var r2:Rectangle = c2.rect;                      
          var overlap:Rectangle = rect.intersection(r2); 
          var test:Number = Math.min(area(), c2.area());   
          //log("Min Rect Area= "+test);
          if (test == 0)
            die("invalid area for min of this.area="+area()+" & clip.area="+c2.area());        
          var res:Number = AoA.area(overlap) / test;
          //trace(idx+"/"+c2.idx+"="+area(overlap)+"/"+test+"="+res);
          return res;           
      }
        
      private function onRewind(event:VideoEvent) : void { 
         video.play();
          //log(this+" completed");
          //doFadeOut(1000); 
      }  
      
      private function inUse(clipName:String) : Boolean
      {
//AoA.log("clip="+clipName);        
          if (clipName.indexOf("water5.flv")>-1) return false; // hack!
          if (clipName.indexOf("water6.flv")>-1) return false; // hack!
          
          var instances:Array = getInstances();
          for (var k:int = 0; k < instances.length; k++) {
             if (instances[k].video.source == clipName)
               return true;
          }
          return false;
      }              
      
      // ============================== STATICS =============================

      public static function create(a:Application, dur:int, num:int=1) : void {     
          for (var i:int=0; i<num; i++)                
            setTimeout(createOne, i*500, a, dur);        
      }
      
      private static function createOne(a:Application, dur:int) : void {
          var c:ClipAoA;
          if (freePool.length>0) {  
            c = freePool.pop();   
            c.isDestroyed = false;       
            if(DBUG_CREATES) {
             trace("================================================================");
             log("Re-using clip object #"+c.idx); 
            }            
            c.init(a, dur);
            c.createChildren();
          }
          else {
            if(DBUG_CREATES){
               trace("================================================================");
               log("Creating clip object #"+ID);
            }    
            c = new ClipAoA();  
            c.init(a, dur);           
          }               
   
     }
      
     public static function setIgnoreTicks(b:Boolean) : void  { ignoreTicks = b; }            
     public static function ignoreTicksFor(dur:int) : void  {
       setIgnoreTicks(true);  setTimeout(setIgnoreTicks, dur, false);
     }

  }// end class      

}// end package