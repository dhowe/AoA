package aoa
{
	import flash.display.*;
	import flash.text.*;
	
	import mx.controls.Label;
	
	public class TextLabel extends Label
	{ 
		include "Constants.as"; 
		
		private static var ID:int = 0;
		public static const _PIPE_:String = " | ";
		
		public var idx:int;
		private var container:TextAoA;
		public var lineMetrics:TextLineMetrics;
		public var windowWidth:Number;
		
		public function TextLabel(t:TextAoA) 
		{ 
			super();         
			this.idx = ID++;    
			this.container = t;
			//this.scaleX = this.scaleY = 1;
			this.blendMode = BlendMode.ADD;
			setStyle("styleName", "primary");  
		}
		
		public function stringWidth(s:String):Number {
			lineMetrics = measureText(s);
			return lineMetrics.width;
		}
		
		override protected function measure() : void 
		{
			if (container.labelMeasured) return;
			
			super.measure()
			
			
			maxWidth = (container.app.width / 2)-50;  
			
			if (AoA.largeFlip) {          
				maxWidth = Number.MAX_VALUE;
				setStyle("fontSize", MAX_FONT_SZ);   
				lineMetrics = measureText(text);
				measuredWidth = measuredMinWidth = lineMetrics.width + 10;
				measuredHeight = measuredMinHeight = lineMetrics.height;   
				container.labelMeasured = true;
			}
			else if (isMicro()) {                            
				setStyle("fontSize", MICRO_FONT_SIZE);
				maxWidth = container.app.width-50;                            
				lineMetrics = measureText(text);
				if (!SILENT && lineMetrics.width > maxWidth)
					AoA.warn("Micro too long: "+text);
				measuredWidth = measuredMinWidth = lineMetrics.width + 10;
				measuredHeight = measuredMinHeight = lineMetrics.height;
				container.labelMeasured = true;   
			}
			else {                  
				var maxFsz:Number = MAX_FONT_SZ;           
				FOR: for (var i:int=0; i<20; i++) 
				{   
					var fontSz:int = AoA.rand(MIN_FONT_SZ, maxFsz);
					
					setStyle("fontSize", fontSz);                          
					lineMetrics = measureText(text);
					
					// Add a 5 pixel horiz. border around the text & check its width
					measuredWidth = measuredMinWidth = lineMetrics.width + (container.flipping ? 250 : 10);
					//if (isMicro()) AoA.log("Micro: trying fs="+fontSz+" vs "+maxWidth+"   for '"+text+"'");
					
					if (measuredWidth > maxWidth && maxFsz > MIN_FONT_SZ) {
						// too big for the screen, try again...                  
						//if (isMicro()) AoA.log("Micro: "+getStyle("fontSize")+" is too big for the screen, try again...");                  
						maxFsz = reduceFontSize(maxFsz);                                  
						continue;
					}
					
					// Add a 5 pixel vert. border around the text
					measuredHeight = /* container.rect.height = */ measuredMinHeight = lineMetrics.height;
					
					if (ENABLE_TEXT_WINDOWING) {   
						var labelParts:Array = text.split(_PIPE_);                   
						if (!labelParts || labelParts.length < 2) 
							AoA.die("Illegal text string (unsplittable): '"+text+"'")               
						lineMetrics = measureText(" "+labelParts[labelParts.length-2]+_PIPE_+labelParts[labelParts.length-1]);            
						windowWidth = lineMetrics.width;
					}  
					
					//AoA.log("measure()->setting FontSize="+fontSz+" for "+text); 
					
					//this.textField.antiAliasType = AntiAliasType.ADVANCED;
					
					container.labelMeasured = true;                            
					break FOR;
				}
			}
			if (!container.labelMeasured)
				AoA.die("Unable to find valid font size -> TextLabel: "+text);
			
			//trace("TextLabel.measure().done: h="+measuredHeight+" w="+measuredWidth+" font="+getStyle("font")+" fontSz="+getStyle("fontSize")+" col="+getStyle("color"));
		}
		
		private function reduceFontSize(fs:Number) : Number {            
			return isMicro() ? fs-5 : fs * (.5 + (Math.random() * .5));
		}
		
		public function isMicro() : Boolean {
			return container.isMicro;           
		}
		
		/*    
		public function getTextField() : UITextField { 
		return textField as UITextField; 
		} 
		*/    
	}
}