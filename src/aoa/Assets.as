package aoa
{
  import flash.filesystem.File;
  import flash.text.engine.CFFHinting;
  
  import mx.validators.EmailValidator;
  
  public class Assets
  {    	  
    include "Constants.as";
    
    [Embed(source='assets/MyriadWebPro.ttf', fontName="PRIMARY",  
      advancedAntiAliasing='true', mimeType="application/x-font-truetype")]
    private var PRIMARY:Class;                       
    
    public static function load() : void
    {
      addClipsForDir(CLIP_DIR);
      AoA.log("Loaded "+clips.length+" clips from "+CLIP_DIR);    
     
      // Load & parse the tags file
      var lines:Array = AoA.linesFromFile(ASSETS+TAGS_FILE);
      parseTagData(lines);             
      AoA.log("Loaded file'"+ASSETS+TAGS_FILE+"' ("+length()+")");         
      
      // Load & parse the colors file
      lines = AoA.linesFromFile(ASSETS+COLORS_FILE);
      parseColorData(lines);              
      AoA.log("Loaded file'"+ASSETS+COLORS_FILE+"' ("+length()+")");                                                             
    }
     
    private static var colorTableLength:int = 0;   
    private static var colorTableString:String = "";   
    private static var colorTable:Object = new Object();                    
    private static var instances:Array = new Array();
    public static var clips:Array = new Array();
    
    public static var micros:Array = ["shifting indefinites","landscape melody","chemical observer", 
      "structural coupling", "mechanical infinities", "liminal observer", "chemical melodies",
      "machinic trajectories","structural (de)coupling","(bi)directional flow","molecular language", 
      "instinctual replication","reactive spaces","(in)finite mechanism","machine potentials", 
      "chemical physics","electro chemical flow","chemical physique", "transliminal physics",
      "sympathetic vibration","machinic responders","cast light","resonant chording", "system internals",
      "chemical allegory","reciprocal (en)folding","variable containers","ongoing fragmentation",
      "pattern flow","arising in situ","infinite partings","chemical baths","pivoting connections",
      "trust conveyors","signal setting","branching instructions","inter- locking","intra- locking",
      "violet gesture","chemical allegory","haptic language","faint recollection","synthetic memories",
      "sensible receptor","contextual positions","machinic pulse","bio mimesis","navigational memory",
      "gestural physics", "coded exchange","nervous systems","reactive gestures", "gestural reaction",
      "inertial states","resistant state","reflective soundings","positional knowledge",
      "recursive loops","streams of (re)entry","machinic sensing","surrogate sensation",
      "irreverent recursions","reciprocal inaction","viral particulate","multi- valent",
      "layered in space","repressive state machine","many to many","one to one",
      "reverse engineering","meaning production","production lines", "synaesthetic relation",
      "pattern memory","time-based inscription","circular valence", "natural languages",
      "encoded action","silicate etching", "encoded entry","self generation",  "les lumieres",
      "reversible operation","reversible progress","temporal repose","positional ambivalence",       
      "gestural motion", "electrolytic reaction", "filmic proportions", "static illusion",  
      "improbable behaviors", "synthetic memory", "transdermal evasion", "material exchange",
      "encrypted reciprocal", "on off", "off on", "in out", "out in", "haptic persuasions",  
      "vestigial glyph", "system internals", "nature of exchange", "bit wise", "falling body",
      "open for closure", "bit stream", "bit mechanics", "bodies at rest", "material natures",
      "reversible allegory", "chemical physique", "inverted voicings", "coordinate systems", 
      "arrested motion", "rest & motion", "arresting (e)motion", "nervous (at)tension", 
      "well tempered", "position (ap)position", "push pull", "bodies in motion",
      "xor nor", "logical gates", "inverted evening", "pitch black", "dark particulate",
      "limited perception", "dark horizons", "window slits","site specifics", "la nuit",
      "sight specific","ink blot","architecture of association","(in) somnia",
      "(in) version","source control","due process", "feed back", "(in) determinate",
    ];
    
    public var id:int;    
    public var line:String;
    public var tags:Array = new Array();   
    public var relatedLines:Array = new Array();
    public var relatedClips:Array = new Array();
                    
    public function Assets(idx:String,line:String,tags:String="")
    {
      this.id = int(idx);
      this.line = line;
      if (tags.length > 0)
        addTags(tags);    
    }
      
    // WARN: only returns one color at present!
    public static function clipColor(clipName:String) : String {
       for (var key:String in colorTable) {               
           var arr:Array = colorTable[key];
           if (arr.indexOf(clipName)>=0)
             return key;
       }
       return null;
    }
    
        
    public static var rotates:Array = [
      "transit_transfer_6.flv","transit_transfer_10.flv","construction_1.flv","water1.flv","water3.flv","apartmant63.flv","apartmant62.flv","apartmant56.flv","apartmant59.flv","apartmant92.flv","apartmant33.flv","apartmant49.flv","apartmant28.flv","elevator14.flv","elevator18.flv","buddhist_temple_153.flv","buddhist_temple_22.flv","buddhist_temple_149.flv","buddhist_temple_167.flv","buddhist_temple_28"
    ];
     
    private static function addClipsForDir(dirName:String) : void {
       AoA.log("addClipsForDir: "+dirName);
       var dir:File = File.applicationDirectory.resolvePath(dirName);
       var files:Array = dir.getDirectoryListing();
       AoA.log("directoryListing: "+files.length +" files");      
       for each (var item:File in files) {         
         var fname:String = CLIP_DIR + item.name; 
         clips.push(fname);
       }
    }
    
    public static function length() : int {
      return instances.length;
    }
    
/*     private static function addClips(clipName:String, count:int) : void {                     
         for (var i:int = 1; i <= count; i++) {
           var fname:String = CLIP_DIR + clipName + i + ".flv"; 
           if (!AoA.exists(fname)) {
             AoA.die("Attempt to add missing clip file: "+fname);
             break;
           }
           clips.push(fname);                                            
         }      
    }  */  
               
    public function toString() : String {
      var s:String = "["+id+": " ;
      s += line+" ("+tags+")]";
      return s;
    }
    
    public function addTags(tagStr:String) : void {
      this.tags = tagStr.split(",");
    }
    
    public static function lineAt(idx:int,arr:Array=null) : Assets {
      if (!arr) arr = instances; 
      //if (idx < 0 || idx > arr.length-1)
        //AoA.die("aoa.TextLine: Illegal index: "+idx,null);      
      return arr[idx];
    }
    
    public static function dump() : void {
         for (var i:int = 0; i < instances.length; i++) {     
           if (instances[i] != null)     
              trace(instances[i]);
        }
    }
        
    public function addRelatedLines(relLineStr:String) : void {
      this.relatedLines = relLineStr.split(",");
    }
    
    public function addRelatedClips(relClipStr:String) : void {
      this.relatedClips = relClipStr.split(",");
    }
    
    public static function parseColorData(lines:Array) : void
    {
       var tmp:Array = new Array();
       for (var i:int = 0; i < lines.length; i++)
       {
           var line:String = (lines[i] as String);
           if (line.length==0 || AoA.startsWith(line,"#")) 
             continue;        
                       
           line = AoA.chomp(line);
           var result:Array = CLIP_PAT.exec(line);
           
           if (result==null)  { 
             AoA.warn("parseColorData: no-match for line='"+line+"'");
             continue;
           }
           
           if (result.length != 4) throw new Error("bad line:"+line);
             
           var type:String = result[1];
           var idx:String  = result[2];
           var data:String = result[3];
           //trace(idx+") "+type+": "+data);
           
           if (type=="relatedClips") {            // clips for a color
             if (!tmp[idx])
               AoA.die("parseColorData: missing color -> "+data,null);
             tmp[idx] += data.toLowerCase();
           }
           else if (type=="color")  {            // a new color
             if (tmp[idx]) 
               AoA.die("parseColorData: duplicate color in color file -> "+data);
             tmp[idx]= data+":";                 
           }
         }

         var parts:Array = new Array();
         for (i = 0; i < tmp.length; i++)
         { 
             if (!tmp[i]) continue;
             
             var s:String = tmp[i] as String;
             parts = s.split(":");
             if (parts.length != 2)
               AoA.die("invalid color line: "+tmp[i],null);
               
             var color:String = AoA.chomp(parts[0]);              
             var related:Array = getExistingClips(AoA.chomp(parts[1]));
             if (related.length > 4) {                 
               colorTable[color] = related;  
               //AoA.log("Color: "+color+" ->: "+related);
               colorTableString += color+", ";                            
               colorTableLength++;
             }
             else AoA.warn("No clips for color: '"+color+ "', missing "+parts[1]);
         }
         AoA.log("Colors in color table("+colorTableLength+") -> "+colorTableString);
         colorTableString = null;
        }
                
        private static function getExistingClips(toCheck:String) : Array
        {
          var tmp:Array = toCheck.split(","); 
          var result:Array = new Array();
          for (var i:int = 0; i < tmp.length; i++) {
            var fname:String = CLIP_DIR+tmp[i]+".flv";
            if (result.indexOf(fname)<0 && AoA.exists(fname))
              result.push(fname);
          }
          return result;
        }
        
        public static function getClipsForColor(col:String) : Array
        {
          return colorTable[col];
        }
        
        public static function getRandomColor() : String
        {
          //return "blue";
          var maxTries:int = 10;
          for (var i:int = 0; i < maxTries; i++) 
          {
            var count:int = 0;          
            var idx:int = AoA.rand(0, colorTableLength); 
              INNER: for (var key:String in colorTable) {
                 if (count++ == idx)  {
                    if (key != AoAModeManager.colorMode) 
                      return key;
                    AoA.log("getRandomColor: skipping current color: "+key);
                    break INNER;
                 }
             }
            }
            AoA.die("getRandomColor().illegal state, "+maxTries+" failures...");
            return ALL_COLORS; 
        }
        
        public static function parseTagData(lines:Array) : void
        {         
             var count:int = 1;
             var tmp:Array = new Array();
             for (var i:int = 0; i < lines.length; i++)
             { 
               var line:String = (lines[i] as String);
               if (line.length==0 || AoA.startsWith(line,"#")) 
                 continue;
                 
               line = AoA.chomp(line);
               var result:Array = LINE_PAT.exec(line);
               
               if (result==null) 
               { 
                 AoA.warn("no-match: '"+line+"'");
                 continue;
               }
               if (result.length != 4) 
                 throw new Error("bad line:"+line);
                 
               var type:String = result[1];
               var idx:String  = result[2];
               var data:String = result[3];
               
               if (idx == "0" || int(idx)==0) 
                 throw new Error("[ERROR] bad input line: "+line);
               
               if (type=="line")     {          // new line
                 //trace("line"+(count++)+"="+data);
                 if (data.length<1) {
                   AoA.warn("*** Skipping empty input line w'  id="+idx+" *** ");                  
                 }               
                 else
                   tmp[int(idx)] = (new Assets(idx,data));
                   //trace(idx+": "+data);
                 continue;
               }
               
               var lineAtIdx: Assets = lineAt(int(idx), tmp);
               if (!lineAtIdx) {
                  //AoA.warn("*** Skipping empty input data for id="+idx);
                  continue;
               }
                 
               if (type=="tags")    {           // add tags
                 lineAtIdx.addTags(data);
               }
                 
               else if (type=="relatedLines")  // add lines
                 lineAtIdx.addRelatedLines(data);
                                    
               else if (type=="relatedClips")  // add clips
                 lineAtIdx.addRelatedClips(data);
                 
               else 
                 throw new Error("bad header:"+line);
            }   
            for (i = 0; i < tmp.length; i++)            
              if (tmp[i]) instances.push(tmp[i]);
            //trace("[INFO] TextLines: "+TagData.length+ " -----------------------------------------");
            //TagData.dump();    
        }
  }
}