/**
 * GaugeSkin
 * 
 * All of the Gauge skins are combined into a single class. For the Gauge
 * component, this makes sense because there is very little to the skins.
 * If the component were more complex it might be worthwhile having multiple
 * classes.
 */ 
package components.gauge.skins
{
	import flash.display.Graphics;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	
	import mx.skins.Border;
	import mx.styles.IStyleManager2;
	import mx.utils.ColorUtil;

	public class GaugeSkin extends Border
	{
		public function GaugeSkin()
		{
			super();
		}
		
		/**
		 * updateDisplayList
		 * 
		 * This method is where the skin is actually drawn. Note that its colors, etc.
		 * are taken from the styles set on its parent - the Gauge component itself.
		 * Any style that has not been set is given a default value.
		 *
		 */
		override protected function updateDisplayList( w:Number, h:Number ) : void
		{
			var bgColor:Number = getStyle("backgroundColor");
			bgColor = 0xFFFFFF;
			var bgAlpha:Number = getStyle("backgroundAlpha");
			bgAlpha = .85;
			var borderColor:Number = getStyle("borderColor");
			borderColor = 0x606060;
			var borderAlpha:Number = getStyle("borderAlpha");
			borderAlpha = 1;
			var borderSize:Number = getStyle("borderThickness");
			borderSize = 1;
			var needleColor:Number = getStyle("needleColor");
			needleColor = 0x000000;
			var needleThickness:Number = getStyle("needleThickness");
			needleThickness = 3;
			var needleAlpha:Number = getStyle("needleAlpha");
			needleAlpha = 1;
			var coverColor:Number = getStyle("coverColor");
			coverColor = 0x606060;
			var coverAlpha:Number = getStyle("coverAlpha");
			coverAlpha = 1;
			var coverDropShadowEnabled:Boolean = getStyle("coverDropShadowEnabled");
			//if( isNaN(coverDropShadowEnabled) || !IStyleManager2.isValidStyleValue(coverDropShadowEnabled) ) coverDropShadowEnabled = true;
			
			var g:Graphics = graphics;
			
			g.clear();
			
			// the name property determines which skin is being drawn.
			
			switch( name )
			{
				case "frameSkin":
					g.lineStyle( borderSize, borderColor, borderAlpha );
					g.beginFill( bgColor, bgAlpha );
					//g.drawEllipse(x,y,w,h);
					g.endFill();
					// filters = [ new BevelFilter(4,225,ColorUtil.adjustBrightness2(bgColor,50),1,
										// ColorUtil.adjustBrightness2(bgColor,-50),1) ];
					break;
				case "needleSkin":
					g.lineStyle( needleThickness, needleColor, needleAlpha );
					g.beginFill( bgColor, bgAlpha );
					g.moveTo(0,h);
					g.lineTo(w,h);
					g.lineTo(w,0);
					g.lineTo(0,h);
					g.endFill();
					// filters = [ new BevelFilter(4,225,ColorUtil.adjustBrightness2(bgColor,50),1,
										// ColorUtil.adjustBrightness2(bgColor,-50),1) ];
					break;
				case "coverSkin":
					g.lineStyle( needleThickness, coverColor, coverAlpha );
					g.beginFill( coverColor, coverAlpha );
					g.moveTo(0,h);
					g.lineTo(w,h);
					g.lineTo(w,0);
					g.lineTo(0,h);
					g.endFill();
					// filters = [ new BevelFilter(4,225,ColorUtil.adjustBrightness2(bgColor,50),1,
										// ColorUtil.adjustBrightness2(bgColor,-50),1) ];
					if (coverDropShadowEnabled) filters = [new DropShadowFilter()];
					break;
			}
		}
		
	}
}