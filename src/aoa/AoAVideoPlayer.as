package aoa
{
    import flash.display.*;
    import flash.geom.*;
    
    import mx.controls.VideoDisplay;
    import mx.controls.videoClasses.VideoPlayer;
  
    [Bindable] public class AoAVideoPlayer extends VideoDisplay {

    include "Constants.as"; 
       
    public var smoothing:Boolean = false;//VIDEO_SMOOTHING;
    public var deblocking:int = 0;      //DEBLOCKING_VAL;
      
    public function AoAVideoPlayer(){
      super();
    }   
      
/*     public function doRotate() : void  {   
      var m:Matrix = new Matrix();
      rotateAroundInternalPoint(m, width / 2, height / 2, 90);
      this.transform.matrix = m;
    }
    
    private function rotateAroundInternalPoint(m:Matrix, x:Number, y:Number, angleDegrees:Number):void
    {   
      var p:Point = m.transformPoint(new Point(x, y));
      rotateAroundExternalPoint(m, p.x, p.y, angleDegrees);
    }
 
    private function rotateAroundExternalPoint(m:Matrix, x:Number, y:Number, angleDegrees:Number):void
    {
      m.translate(-x, -y);
      m.rotate(angleDegrees*(Math.PI/180));
      m.translate(x, y);
    } */

    override public function addChild(child:DisplayObject):DisplayObject{
      var video:VideoPlayer = VideoPlayer(child);
      video.smoothing = smoothing;
      video.deblocking = deblocking;      
      return super.addChild(child);
    }      
  } 
}