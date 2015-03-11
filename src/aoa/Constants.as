    // APPLICATION CONSTANTS =========================================
        
    public static const RELEASE_BUILD: Boolean = true;
    public static const NETWORK_ENABLED:Boolean = true;
    public static const HIDE_MOUSE: Boolean = RELEASE_BUILD;
            
    public static const SHOW_INFO:Boolean = !RELEASE_BUILD;
    public static const SERVER_EFFECT_DUR:int = 45000; 
    public static const BLANK_EFFECT_DUR:int  = 10000;
    public static const MAX_TEXTS_PER:int=7, MAX_CLIPS_PER:int=10;
    
    public static const SILENT: Boolean = RELEASE_BUILD;          
    public static const SHOW_CLIP_LABELS:Boolean = false;
                   
    public static const ENABLE_ELEVATORING:Boolean = false; 
    public static const ELEVATOR_PROB:Number = .5; 
     
    public static const SHOW_TEXT: Boolean = true;
    public static const SHOW_VIDEO: Boolean = true;
        
    public static const INITIAL_TEXT_COUNT:int = 3;
    public static const INITIAL_CLIP_COUNT:int = 4;
    public static const MIN_TEXTS_PER:int=2;                
    public static const MIN_CLIPS_PER:int=3;
    
    private static const MIN_FONT_SZ:Number = 12;
    private static const MAX_FONT_SZ:Number = 127;
        
    public static const ROTATE_STAGE:Boolean = false; 
    public static const SHOW_MIDLINE:Boolean = false;
    public static const DBUG_CREATES:Boolean = false;   
    public static const ENABLE_START_ON_LOGIN: Boolean = false;

    public static const ENABLE_TICK_TIMER:Boolean = true;
      
    // IGNORE ========================================================

    public static const FADE_ON_END_WINDOWING:Boolean  = true;
    
    // MODES =========================================================
    public static const ENABLE_TEXT_FLIPPING:Boolean = true;
    public static const FLIP_PROBABILITY:Number = .5;    
    public static const MAX_FLIP_COUNT:int = 150;
    public static const MIN_FLIP_COUNT:int = 100;
    public static const MS_PER_FLIP:int = 50;              
    
    public static const ENABLE_TEXT_WINDOWING:Boolean = false; 
    public static const WINDOW_PROBABILITY:Number = .3;
    public static const WINDOWING_SPEED:Number = 3.1;
    public static const MS_PER_WINDOW:int = 20;  
    
    public static const MICRO_TEXT_PROBABILITY:Number = .2; // .2
    public static const MICRO_FONT_SIZE:int = 127;
        
    public static const ENABLE_SCROLLING: Boolean = false;      
    public static const SCROLL_SPEED:int = 3;

    public static const FULL_SCREEN: Boolean = false;
    
    // DRAWING =======================================================
    
    public static const SHOW_CLIP_BORDERS:Boolean = false;
    public static const SHOW_TEXT_BORDERS:Boolean = false;       
    
    // SCALARS =======================================================
    public static const MIN_ELEVATOR_DUR:int = 1000000;
    public static const MAX_ELEVATOR_DUR:int = 1000000;
    public static const MAX_LIFE_SPAN:int = 60000;          // 1  min
    public static const MAX_MICRO_LIFE_SPAN:int = 10000;    // 15 sec
    public static const TIMER_INTERVAL:int = 5000;          // 5  sec
    public static const DEFAULT_FADE_TIME:int = 3000;       // 3  sec    
    public static const MAX_CLIP_OVERLAP_PER:Number = .4;
    public static const TEXT:int= 1, CLIP:int= 2, ALL:int=0;  
    public static const MIN_CLIP_W:int=240, MAX_CLIP_W:int=720;          
    public static const MICRO_BEZEL_SPACING:Number = 16;
    
    // CONSTS ========================================================      
    
    public static const ASSETS:String = "assets/";
    //public static const CLIP_DIR:String = "/AoAResources/clips/ 	";
	public static const CLIP_DIR:String = "assets/clips/";
    public static const TAGS_FILE:String = "aoa-tags.txt";
    public static const COLORS_FILE:String = "aoa-colors.txt";
    public static const ALL_COLORS:String = "all";
    public static const CLIP_BORDER_SZ:int = 4;
	public static const MARGIN:int = 200;
    
    // REGEXS =========================================================
    
    public static var LINE_PAT:RegExp = /^(line|tags|relatedLines|relatedClips)([0-9][0-9]*)=(.*)$/;
    public static var CLIP_PAT:RegExp = /^(color|relatedClips)([0-9][0-9]*)=(.*)$/;

    // ================================================================
