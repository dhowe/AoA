package aoa
{
  import flash.display.*;
  import flash.events.*;
  import flash.filters.*;
  import flash.geom.Rectangle;
  import flash.text.*;
  import flash.utils.*;
  
  import mx.containers.*;
  import mx.core.*;
  import mx.effects.*;
  import mx.events.*;
  import mx.effects.effectClasses.*;

  public class TextAoA extends AoAObj
  {   
    public static var freePool:Array = new Array();
    private static var shadow:DropShadowFilter;
    public static var ignoreTicks: Boolean = false;
    
    public var labelMeasured:Boolean;
    public var isMicro:Boolean;

    protected var stopWindowingAtX:Number;    
    protected var windowing:Boolean;     
    protected var targetText:String;
    protected var windowingId:uint;
    public var flipping:Boolean;
    protected var label:TextLabel;
    protected var flipTimer:Timer;            
    protected var window:Shape;

    public function TextAoA() 
    {
      super();         
      this.type = TEXT;
      shadow = new DropShadowFilter();
      addEventListener(EffectEvent.EFFECT_END, onEffectComplete);                
    } 
      
    override protected function createChildren() : void  {
      //log("TextAoA#"+idx+".createChildren()");
      super.createChildren();
                  
      if (!window) { 
        window = new Shape();
        addChild(window);
      }
      if (!label) {                        
        label = new TextLabel(this);           
        //label.addEventListener(MouseEvent.CLICK, clickHandler);
        addChild(label);                    
        addShadow(); 
      }    
      label.mask = null;  
    }                                     
    
    /* private function clickHandler(event:Event):void 
    {      
       AoA.log("CLICK: "+label.text);
      var myAntiAliasSettings:CSMSettings = new CSMSettings(48, 0.8, -0.8); 
      var myAliasTable:Array = new Array(myAntiAliasSettings); 
      TextRenderer.setAdvancedAntiAliasingTable("PRIMARY", FontStyle.ITALIC, TextColorType.DARK_COLOR, myAliasTable);   
    }  */

    override protected function getFreePool() : Array { return freePool; }
    override protected function identStr() : String  { return label.text; }               
    override public function toString() : String { return  "["+idx+ ": " + label.text+"]" ; }        
    
    override protected function init(a:Application, dur:int) : void  
    {
      //log("TextAoA#"+idx+".init()");
      super.init(a, dur);
      
      this.labelMeasured = false;
      this.visible = false;
      this.isMicro = false;                                                              
      this.windowing = false;
      this.flipping = false;
      this.elevatoring = false;
      scaleX = scaleY = 1;
      
      //if (mover != null) mover.end();
      if (fader != null) fader.end();
      
      if (!rect) rect = new Rectangle();  
      isMicro = (!AoA.flashText && Math.random() < MICRO_TEXT_PROBABILITY);
      
      if (AoA.largeFlip) {
        isMicro = false;
        a.addChildAt(this, 0);
        label.text = randomMicro();                              
        scaleX = 5;
        scaleY = scaleX * 1.8;        
        flipping = true;
        lastAlpha = .3;  
      }
      else if (isMicro) {
        a.addChildAt(this, 0);
        label.text = randomMicro();                        
        lastAlpha = .6;    
      }
      else {
        a.addChild(this);
        var txt:String = targetText = randomText().line; 
        //if (AoA.windowing) 
          //windowing = (Math.random() < WINDOW_PROBABILITY);
        if (AoA.flipping)  
          flipping = (Math.random() < FLIP_PROBABILITY);
          
        if (AoA.flashText && !flipping) {
          // (AoA.flashText)  // make a smaller phrase
            txt = Math.random() <.8 ? splitPhrase(txt) : txt;         
        }
        label.text = txt;                  
      }

      doFadeIn(dur);             
    }        

    private function splitPhrase(str:String) : String
    { 
      var tmp:String = str;
      var idx:int = -1
      var len:int = str.length/2;
      str =  (Math.random()<.5) ? str = str.substring(0, len) : str = null;
      
      if (str) {  // 1st half
        idx = str.lastIndexOf("|");
        str = (idx > -1) ? str.substring(0,idx-1) : str = null;
      }
      
      if (!str) { // 2nd half
        str = tmp.substr(len+1);
        idx = str.indexOf("|");
        str = str.substring(idx+1);
      }
      //AoA.log(str+" FROM "+tmp);
      return str;
    }
    
    override protected function destroy() : void
    { 
      this.visible = false;
      if (flipping && flipTimer) {
        flipTimer.stop();
        flipTimer = null;
      }      
      if (windowing) 
        clearInterval(windowingId);      
      super.destroy();  
    }
    
    private function moveWindow() : void {
      x -= WINDOWING_SPEED/2;
      window.x += WINDOWING_SPEED;         
      if (window.x >= stopWindowingAtX) {
        clearInterval(windowingId);
        if (FADE_ON_END_WINDOWING)
          doFadeOut(DEFAULT_FADE_TIME);
      }
    }
       
    private function onFlipTick(event:TimerEvent):void  {
      //log("flip");
      if (flipping) {
        var txt:String = randomText(true).line;        
        if (!AoA.largeFlip) 
        {
          // measure the width          
          var txtWidth:Number = label.stringWidth(txt);          
          for (var k:int = 1;txtWidth > (rect.width-5) && k <= 20;k++) {
            var idx:int = txt.lastIndexOf(TextLabel._PIPE_);
            if (idx < 0) break;
            txt = txt.substr(0,idx);
            txtWidth = label.stringWidth(txt);
          }
        }
        label.text = txt;
      }
      /* if (elevatoring) {
        y += 1;
        rect.y += 1; 
      }    */   
    }

    private function onFlipDone(event:TimerEvent):void  {
      //AoA.log("FLIP-DONE: "+targetText);
      flipping = false; 
      elevatoring = false;
      label.text = targetText;           
      label.lineMetrics = measureText(targetText);      
      rect.width = label.lineMetrics.width;
      rect.height = label.lineMetrics.height;
      //AoA.log("FLIP-DONE: "+targetText);
    }
  
    override protected function measure() : void {        
      super.measure();
      //log("TextAoA#"+idx+".measure(flip="+flipping+")");     
      measuredWidth = measuredMinWidth = label.measuredWidth;            
      measuredHeight = measuredMinHeight = label.measuredHeight;    
      
      if (!visible)
      {
          if (!randomPos()) {
            //if (isMicro) log("Destroying Text#"+idx+": "+label.text);             
            destroy();
            return;
          }
          if (windowing) setupWindow();
  
          if (flipping/*  || elevatoring */) {
            //die("flipping enabled!!");
            var numFlips:int = AoA.largeFlip ? 0 : rand(MIN_FLIP_COUNT, MAX_FLIP_COUNT);
            flipTimer = new Timer(MS_PER_FLIP,  numFlips);
            flipTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onFlipDone);
            flipTimer.addEventListener(TimerEvent.TIMER, onFlipTick);
            flipTimer.start();           
          }              
        visible = true;            
      }                             
    }
          
    public static function removeMicros(dur:int) : void
    { 
      var instances:Array = AoA.getInstances(TEXT);
      for (var i:int = 0; i < instances.length; i++) {               
        var ta:TextAoA = instances[i];
        if (ta.isMicro) ta.doFadeOut(dur);
      }
    } 
          
    public static function removeLargeFlips(dur:int) : void
    { 
      var instances:Array = AoA.getInstances(TEXT);
      for (var i:int = 0; i < instances.length; i++) {               
        var ta:TextAoA = instances[i];
        if (ta.scaleX>1) ta.doFadeOut(dur);
      }
    } 
    
    public function randomPos() : Boolean
    {       
      rect.width = measuredWidth;   
      rect.height = measuredHeight; 
      
      if (AoA.largeFlip) {
        x = rect.x = 0;
        y = rect.y = 200; 
        return true;
      }    
      else if (isMicro) 
      {
        var parts:Array = label.text.split(" ");
        var word1W:Number = label.stringWidth(parts[0]);         
        x = rect.x = app.width/2 - word1W - MICRO_BEZEL_SPACING;
        TRIES: for (var t:int = 0; t < MAX_TEXTS_PER; t++) 
        {                          
          y = rect.y = rand(0, (app.height - (measuredHeight)));            
          var insts:Array = getInstances();
          for (var i:int = 0; i < insts.length; i++) {    
            var ta:TextAoA = insts[i];
            if (ta === this) continue;
            if (rect.intersects(ta.rect)) 
              continue TRIES;                                                                                              
          }      
          if (elevatoring) {
            y = rect.y = Math.random()<.5 ? -measuredHeight : app.height;
          }
          return true;
        }        
        return false;
      } 
     
                               
      
      //log("TextAoA#"+idx+".randomPos("+rect.width+","+rect.height+")");
      var k:int = 0; var j:int = 0
      for (k = 0; k < MAX_TEXTS_PER; k++) 
      {               
        OUTER: for (j = 0; j < 10; j++) 
        {                                                          
            x = rect.x = rand(30, (label.maxWidth - rect.width-20));  
            if (Math.random()<.5) x += app.width/2;          
            //log("x="+x);
            //log("label.max="+label.maxWidth+" rect.width="+rect.width+" maxX="+(label.maxWidth - rect.width));
            y = rect.y = rand(0, (app.height - (rect.height*4)));
                 
            var insts2:Array = getInstances();
            for (var z:int = 0; z < insts2.length; z++) {    
               var r:TextAoA = insts2[z];
               if (r === this) continue;
               //trace(z+"."+idx+") checking: "+r);
               if (rect.intersects(r.rect)) 
                  continue OUTER;                                                                                                   
            } 
            //trace("TextAoA#"+idx+".xpos="+x+" range=0->"+maxWidth+" app.w="+app.width+" rect="+rect);                
            return true;             
        }   
        // really want to change the font size here to something smaller               
      }      
      if (!SILENT) warn("Unable to find pos for TextAoA#"+idx+" after "+(k*j)+" tries -- giving up");
      //removeOldest(TEXT, DEFAULT_FADE_TIME); // free some space... (this doesnt help at all)
      return false;      
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void {
       //trace("TextAoA#"+idx+".updateDisplayList()");
      super.updateDisplayList(unscaledWidth, unscaledHeight);  
      var W:Number = unscaledWidth*scaleX; 
      var H:Number = unscaledHeight*scaleY;
      label.setActualSize(W, H);
      stopWindowingAtX = W - label.windowWidth;
      ///trace("unscaled: "+unscaledWidth+","+unscaledHeight);
      if (SHOW_TEXT_BORDERS) drawBorder();
      //drawSprite();  
    }     
       
  private function addShadow() : void {
    //trace("TextAoA#"+idx+".DROP_SHADOW=true");
    // properties: shadow color, alpha, amount of blur(x/y), strength, 
    // quality, and options for inner shadows and knockout effects.
    shadow.angle = 10;        
    shadow.blurX = 1;
    shadow.blurY = 1;       
    shadow.distance = 2;                 
    filters = [shadow];
  }
   
  private function drawBorder() : void {
    label.graphics.lineStyle(1, 0xffff00, 1);
    label.graphics.drawRoundRect(0,0, rect.width, rect.height,4);
  }
   
  private function randomText(allowDuplicates:Boolean=false) : Assets
  {
     var lineAsset:Assets;
      for (var k:int = 0; k < MAX_TEXTS_PER*2; k++)  
      {
           var index:int = rand(0, Assets.length()); 
           lineAsset = Assets.lineAt(index);
           if (lineAsset == null) die("Null LineAsset at idx="+index); 
           if (!allowDuplicates && inUse(lineAsset.line)) {
             //log("Skipping duplicate text: "+td.line); 
             continue;
           }
           return lineAsset;
      }            
      AoA.die("***Duplicate text onscreen: "+lineAsset.line);  
      return lineAsset;                
  } 
   
  private function randomMicro(allowDuplicates:Boolean=false) : String
  {
      var line:String;
      for (var k:int = 0; k < MAX_TEXTS_PER*2; k++)  
      {
           var index:int = rand(0, Assets.micros.length); 
           line = Assets.micros[index];
           if (!line) die("Null Micro at idx="+index);           
           if (!allowDuplicates && inUse(line)) {
             log("Skipping duplicate micro: "+line); 
             continue;
           }
           return line;
      }            
      AoA.die("***Duplicate micro onscreen: "+line);  
      return line;                
  } 
   
  private function setupWindow() : void  {        
      window.x = 0; window.y = 0; 
      window.graphics.beginFill(0xff0000);
      window.graphics.drawRect(0, 0, label.windowWidth, rect.height);
      window.graphics.endFill();     
      windowingId = setInterval(moveWindow, MS_PER_WINDOW);//label.endWindowWidth));
      label.mask=window;
  }  

  private function inUse(text:String) : Boolean
  {
        var instances:Array = getInstances();
        for (var k:int = 0; k < instances.length; k++) {
           if (instances[k].label.text == text)
             return true;
        }
        return false;
  }
    
  // ========================== STATICS ===================================
   
  public static function create(a:Application, dur:int, num:int=1) : void 
  {        
     for(var i:int=0; i < num; i++) 
       setTimeout(createOne, i*600, a, dur);
  }
   
  private static function createOne(a:Application, dur:int) : void {   
      var c:TextAoA;
      if (freePool.length>0) {
        c = freePool.pop();
        if(DBUG_CREATES) {
          trace("==========================================================");
          log("Re-using text object #"+c.idx);
        }
      }
      else {
        c = new TextAoA(); 
        if(DBUG_CREATES){
          trace("==========================================================");
          log("Creating text object #"+c.idx);
        }      
      }                               
      c.init(a, dur);                 
  }           
  public static function setIgnoreTicks(b:Boolean) : void  { ignoreTicks = b; }            
  public static function ignoreTicksFor(dur:int) : void  {
     setIgnoreTicks(true);  setTimeout(setIgnoreTicks, dur, false);
  }
    
 } // end class
    
} // end
