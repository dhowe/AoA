package aoa
{
  import flash.events.*;
  import flash.utils.*;
  
  import mx.core.*;
  
  public class AoAModeManager
  {   
    include "Constants.as";       
        
    [Bindable]
    public static var colorMode:String = ALL_COLORS;
    
    [Bindable] // tmp
    public static var nextCmd:String;
      
    [Bindable] // tmp
    public static var nextCmdTimeStr:String = "none";
       
    private static var nextCmdTime:Number = -1;    
    
    // ======================= consts =============================
    public static const BW:String = "bw";    
    public static const RED:String = "red";
    public static const BLUE:String = "blue";
    public static const GREEN:String = "green";
    public static const BROWN:String = "brown";
    public static const BLANK:String = "blank";       
    public static const NIGHT:String = "night";
    public static const YELLOW:String = "yellow";
    public static const ELEVATOR:String = "elev";
    public static const FLASH_TEXT:String = "flashText";
    public static const LARGE_FLIP:String = "largeFlip";
    public static const FLASH_CLIPS:String = "flashClips";
    public static const DEFAULTS:String = "defaults";    
       
    // ======================= members ============================
    private var mode:String = DEFAULTS;    
    private var resetTaskId:int;
    private var commandMonitor:Timer; 
    
    // ====================== singleton ===========================
    private static var instance:AoAModeManager;
    private static var lock:Object = new Object();    
    public static function getInstance() : AoAModeManager {
      if (!instance) 
        instance = new AoAModeManager(lock);
      return instance;        
    }     

    public function AoAModeManager(o:Object) {
      if (o != lock) 
        AoA.die("Attempt to directly create singleton: AoAModeManager");      
      commandMonitor = new Timer(50, 0);
      commandMonitor.addEventListener(TimerEvent.TIMER, checkForCmd);
      commandMonitor.start();
    } 
    
    public function queueCommand(cmd:String, time:Number): void {
      nextCmd = cmd;
      nextCmdTime = time;
      nextCmdTimeStr = time + "";
    }  
    
    private var checkForCmd:Function = function(te:TimerEvent) : void {        
       var now:Number = SocketListener.getSyncTime(); 
       if (nextCmd && now >= nextCmdTime) {                 
         //AoA.log(now+") Calling scheduled function: "+func+" w' params: "+params);
         var next:String = nextCmd;
         nextCmd = null;
         nextCmdTime = -1;
         nextCmdTimeStr = "none";
         AoAModeManager.getInstance().setMode(next); 
       }
    }
    
    private function clearResetTask()  : void {
      //AoA.log("AoAModeManager.clearResetTask()");
      clearInterval(resetTaskId);
    }
    
    public function setMode(mode:String) : void {      
      restoreDefaults();
      clearResetTask();  
      this.mode = mode;    
      if (!RELEASE_BUILD) 
        AoA.log("AoAModeManager.setMode("+mode+")");
      var durTilDefault:int = SERVER_EFFECT_DUR;
      switch(mode) {                
        case RED: 
          setColorMode(RED);
          break;         
        case GREEN: 
          setColorMode(GREEN);
          break;  
        case BW: 
          setColorMode(BW);
          break;
        case NIGHT: 
          setColorMode(NIGHT);
          break;
        case BROWN:
          setColorMode(BROWN);         
          break;
        case ELEVATOR:
          setColorMode(ELEVATOR);         
          break;
        case DEFAULTS: 
          durTilDefault = 50;
          break;  
        case FLASH_CLIPS: 
          setClipFlash(true);
          break;
        // -------------------------------------
        case FLASH_TEXT: 
          setTextFlash(true);  
          setTimeout(reset, durTilDefault);        
          return;     // dont call restoreDefaults
        case LARGE_FLIP:
          setLargeFlip(true);  
          setTimeout(reset, durTilDefault);        
          return;     // dont call restoreDefaults
        case BLANK:           
          AoA.clear(3000);
          AoAObj.ignoreTicksFor(BLANK_EFFECT_DUR);          
          return;    // dont call restoreDefaults      
        default: 
          AoA.die("Invalid mode: "+mode);
      }
      resetTaskId = setTimeout(restoreDefaults, durTilDefault);   
    }
    
    // ================================== MODES ================================
    public function randomColorMode() : void {  setMode(Assets.getRandomColor()); }
    public function setColorMode(col:String=ALL_COLORS)  : void {    
        
      if (col != ALL_COLORS && col != colorMode) {
        var clips:Array= Assets.getClipsForColor(col);
        if (!clips) {              
          AoA.err("No clips for custom color: "+col+" -> ignoring call!");
          return;
        }          
        ClipAoA.colClips = clips;
        AoA.removeAll(CLIP, DEFAULT_FADE_TIME);      
        AoA.log("AoAModeManager.setColorMode("+col+")");           
      }  
      colorMode = col;  
    }   
  
    public function setClipFlash(val:Boolean) : void
    {
      //AoA.log("AoAModeManager.clipFlash()");
      AoA.flashClips = val;
      AoA.clear(2000);  
      TextAoA.removeMicros(500);           
      AoAObj.ignoreTicks(val); 
    }
    
    public function setTextFlash(val:Boolean) : void
    {
      //AoA.log("AoAModeManager.textFlash()");
        AoA.flashText = val;
        //AoA.log("Mode.FlashText="+val);
        AoA.clear(2000);     
        TextAoA.removeMicros(500);        
        AoAObj.ignoreTicks(val);        
    }
    
    public function setLargeFlip(val:Boolean) : void
    {
      //AoA.log("AoAModeManager.textFlash()");
        AoA.largeFlip = val;        
        //AoA.log("Mode.FlashText="+val);
        TextAoA.setIgnoreTicks(val);                                    
        if (val) {
          TextAoA.removeMicros(1000);
          //AoA.removeAll(TEXT, 3000);     
          //TextAoA.haveGiant = false;
          AoA.create(TEXT, 1000, 1);
        }   
        else
          TextAoA.removeLargeFlips(1000);       
    }
     
/*     public function oneClipPer() : void
    {
      AoA.die("AoAModeManager.oneClipPer()... unimplemented");
    }
    
    public function oneTextPer() : void
    {
      AoA.die("AoAModeManager.oneTextPer()... unimplemented");
    } */
    
    public function reset(caller:String="") : void
    {
       //AoA.log("AoA.reset("+caller+")");
       AoA.clear(3000);
       var f:Function = function(a:Application):void 
       {       
         restoreDefaults();
         if (SHOW_TEXT)  TextAoA.create(a, 3000, INITIAL_TEXT_COUNT);   
         if (SHOW_VIDEO) ClipAoA.create(a, 3000, INITIAL_CLIP_COUNT)
         
       }; 
       //AoAObj.ignoreTicksFor(10000);
       setTimeout(f, 5000, AoA.app);      
    }
    
    public function restoreDefaults() : void
    {
        setColorMode();
        AoAObj.ignoreTicks(false);
        AoA.largeFlip  = false;
        AoA.flashClips = false;//INITIAL_CLIP_FLASHING;
        AoA.flashText  = false;//INITIAL_TEXT_FLASHING;
        AoA.flipping   = ENABLE_TEXT_FLIPPING;
        AoA.windowing  = false;//ENABLE_TEXT_WINDOWING;       
        AoA.scrolling  = false;//ENABLE_SCROLLING;    
    }
  }
  
}