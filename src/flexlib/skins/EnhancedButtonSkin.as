/*
Copyright (c) 2007 FlexLib Contributors.  See:
    http://code.google.com/p/flexlib/wiki/ProjectContributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
package flexlib.skins
{

import flash.display.GradientType;

import mx.controls.Button;
import mx.core.UIComponent;
import mx.skins.Border;
import mx.skins.halo.HaloColors;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;
import mx.utils.GraphicsUtil;

/**
 * This is the enhanced version of the Halo ButtonSkin that has been customized to support four numeric
 * values in the corner, a more configurable border, and also a large number of colors in the gradient
 * (limited by 15 in ProgrammaticSkin.drawRoundRect), individually specified for up, over, etc states..
 * 
 * <p>
 * <ul>
 *  <li>
 * 		corner-radii: An array of four numeric values indicating the four corner radii [TL, TR, BR, BL] 
 * 	</li>
 * 	<li>
 *		fill-colors: An array of colors to use for the fill state gradient (of arbitrary number)
 *	</li>
 * 	<li>
 * 		selected-fill-colors: An array of colors to use for the fill gradient of the selected state.
 * 	</li>
 * 	<li>	
 * 		over-fill-colors: An array of colors to use for the fill gradient of the over state.	 
 * 	</li>
 * 	<li>
 * 		disabled-fill-colors: An array of colors to use for the fill gradient of the disabled state.
 *	</li>
 *  <li>
 *    down-fill-colors: An array of colors to use for the fill gradient of the down state.
 *  </li>
 * </ul>
 * 
 * <ul>
 * 	<li>	
 *		fill-color-ratios: An array of values from 0 to 255 that indicate the position of the colors in the selection gradient. 
 * 		Must match the cardinality of the fill-colors, or else a default will be used.
 *	</li>
 * 	<li>
 * 		selected-fill-color-ratios:  An array of values from 0 to 255 that indicate the position of the colors in the selection gradient.
 *                	    Must match the cardinality of the fill-colors, or else a default will be used.
 * 	</li>
 * 	<li>
 *		over-fill-color-ratios:  An array of values from 0 to 255 that indicate the position of the colors in the over gradient.
 *                	    Must match the cardinality of the fill-colors, or else a default will be used.
 * 	</li>
 * 	<li>
 *		disabled-fill-color-ratios:  An array of values from 0 to 255 that indicate the position of the colors in the disabled gradient.
 *                	    Must match the cardinality of the fill-colors, or else a default will be used.
 *	</li>
 *  <li>
 *    down-fill-color-ratios: An array of values from 0 to 255 that indicate the position of the colors in the down gradient.
 * 											Must match the cardinality of the fill-colors, or else a default will be used.
 *  </li>
 * </ul>
 * 
 * <ul>
 * 	<li>
 * 		border-colors: An array of color values for the border in the up state. (defaults to border-color).
 * 	</li>
 * 	<li>	
 * 		over-border-colors: An array of color values for the border in the up state. (defaults to theme-color derived)
 *	</li>
 * 	<li>
 * 		selected-border-colors: An array of values indicating the color of the selected border. (defaults to over-border-colors)
 *	</li>
 * </ul>
 * 
 * <ul>
 * 	<li>
 *		border-thickness: The thickness of the border.
 *	</li>
 * 	<li>
 * 		border-alpha: The alpha value of the border.
 * 	</li>
 * 	<li>
 * 		disabled-border-alpha (defaults to 50% of border-alpha).
 * 	</li>
 * </ul> 
 * </p>
 * 
 * @author Daniel Wabyick
 */
public class EnhancedButtonSkin extends Border
{
	//include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var cache:Object = {}; 
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Several colors used for drawing are calculated from the base colors
	 *  of the component (themeColor, borderColor and fillColors).
	 *  Since these calculations can be a bit expensive,
	 *  we calculate once per color set and cache the results.
	 */
	private static function calcDerivedStyles(themeColor:uint,
											  fillColor0:uint,
											  fillColor1:uint):Object
	{
		var key:String = HaloColors.getCacheKey(themeColor,
												fillColor0, fillColor1);
				
		if (!cache[key])
		{
			var o:Object = cache[key] = {};
			
			// Cross-component styles.
			HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
		}
		
		return cache[key];
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function EnhancedButtonSkin()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  measuredWidth
	//----------------------------------
	
	/**
	 *  @private
	 */
	override public function get measuredWidth():Number
	{
		return UIComponent.DEFAULT_MEASURED_MIN_WIDTH;
	}
	
	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredHeight():Number
	{
		return UIComponent.DEFAULT_MEASURED_MIN_HEIGHT;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);
        
       
        // corner-radius
        var cornerRadii : Array = getStyle("cornerRadii");
    	var cornerRadius:Number = getStyle("cornerRadius");
        if ( cornerRadii == null )
        {
        	if ( isNaN( cornerRadius ) )
        	{
        		cornerRadius = 0;
        	}
        	cornerRadii = [ cornerRadius, cornerRadius, cornerRadius, cornerRadius ];
        }
		
        // fill gradient colors		
		var fillColors:Array = getStyle( "fillColors" );
		
		// tricky, code below relies on two fillColors
		if ( fillColors.length == 1 )
		{
		    fillColors.push( fillColors[0] );
		}
		
		var upFillColors:Array = fillColors;
		
		
		var selectedFillColors:Array = getStyle( "selectedFillColors" );
		if ( selectedFillColors == null )
		{
			selectedFillColors = [ fillColors[1], fillColors[1] ];
		}
		
		var overFillColors:Array = getStyle( "overFillColors" );
		if ( overFillColors == null )
		{
			overFillColors = selectedFillColors;
		}
		
		var disFillColors:Array = getStyle( "disabledFillColors" );
		if ( disFillColors == null )
		{
			disFillColors = fillColors;
		}
		
		var downFillColors:Array = getStyle( "downFillColors" );
		// not set to a default value to allow for backwards compatibility (from .2)
		if ( downFillColors != null )
		{
			var downFillColorRatios:Array = getColorRatios( "downFillColorRatios", downFillColors.length );
			var downFillAlphas:Array = getAlphas( "downFillAlphas", downFillColors.length );
		}

		var upFillColorRatios:Array = getColorRatios( "fillColorRatios", fillColors.length );
		var overFillColorRatios:Array = getColorRatios( "overFillColorRatios", overFillColors.length );
		var selectedFillColorRatios:Array = getColorRatios( "selectedFillColorRatios", selectedFillColors.length );
		var disFillColorRatios:Array = getColorRatios( "disabledFillColorRatios", disFillColors.length );
		
		var fillAlphas:Array = getAlphas( "fillAlphas", fillColors.length );
		var overFillAlphas:Array = getAlphas( "overFillAlphas", overFillColors.length );
		var selectedFillAlphas:Array = getAlphas( "selectedFillAlphas", selectedFillColors.length );
		
		var disFillAlphas:Array = [];
		for ( var i:int = 0; i < fillAlphas.length; i++ ) 
		{
			disFillAlphas[i] = Math.max( 0, fillAlphas[i] - 0.15 );
		}
		
		
		// make sure the fillAlphas is padded to the fillColors length if its too short.
		for ( i = fillAlphas.length; i < fillColors.length; i++ ) 
		{
			fillAlphas.push( fillAlphas[i-1] );
		}
	
		var upFillAlphas:Array = fillAlphas;
		
	    StyleManager.getColorNames(fillColors);
		StyleManager.getColorNames(upFillColors);
		StyleManager.getColorNames(overFillColors);
		StyleManager.getColorNames(selectedFillColors);

	    
	  var highlightAlphas:Array = getStyle("highlightAlphas");
	 
		// Border props
		var themeColor:uint = getStyle("themeColor");
		var borderThickness : uint = getStyle( "borderThickness" );
		
		var borderColors:Array = getStyle( "borderColors" );
		if ( borderColors == null )
		{
		    var borderColor : Number = getStyle("borderColor");
		    borderColors = [ borderColor, ColorUtil.adjustBrightness( borderColor, -50 ) ];
		}
		
		var overBorderColors:Array = getStyle( "overBorderColors" );
		if ( overBorderColors == null )
		{
           overBorderColors = [ themeColor, ColorUtil.adjustBrightness2( themeColor, -25 ) ]; 
		}
		
	    var selectedBorderColors:Array = getStyle( "selectedBorderColors" );
		if ( selectedBorderColors == null )
		{
		    selectedBorderColors = overBorderColors;
		}
		
		var borderAlpha : Number = getStyle( "borderAlpha" );
		if ( isNaN( borderAlpha ) )
			borderAlpha = 1;
			
		var disabledBorderAlpha : Number = getStyle( "disabledBorderAlpha" );
		if ( isNaN( disabledBorderAlpha ) )
		{
		    disabledBorderAlpha = borderAlpha / 0.5;
		}
	    	

		// Derivative styles.
		var derStyles:Object = calcDerivedStyles(themeColor, fillColors[0],
												 fillColors[1]);

		var emph:Boolean = false;
		
		if (parent is Button)
			emph = Button(parent).emphasized;
			
		var cr:Object = radiiUtil( cornerRadii, 0 );
		var cr1:Object = radiiUtil( cornerRadii, 1 );
		var cr2:Object = radiiUtil( cornerRadii, 2 );
		
		var bt:uint = borderThickness;
		var tmp:Number;
		
		graphics.clear();
												
		switch (name)
		{	
			case "selectedUpSkin":
			case "selectedOverSkin":
			{
				// button border/edge
				/*drawRoundRect(
					0, 0, w, h, cr,
					selectedBorderColors, 1,
					verticalGradientMatrix(0, 0, w , h )); 
				*/
				// button border/edge
				drawRoundRect(
					0, 0, w, h, cr,
					selectedBorderColors, borderAlpha,
					verticalGradientMatrix(0, 0, w , h ),
					GradientType.LINEAR, null, 
					{ x: bt+1, y: bt+1, w: (w - 2*bt) - 2, h: (h - 2*bt)-2, r: cr2 });
				
											
				// button fill
				drawRoundRect(
					bt, bt, w - 2 * bt, h - 2 * bt, cr1,
					selectedFillColors, selectedFillAlphas,
					verticalGradientMatrix(0, 0, w - 2 * bt, h - 2 * bt),
					GradientType.LINEAR,
					selectedFillColorRatios );
					
				// top highlight
				drawRoundRect(
					bt+1, bt+1, (w- 2*bt)-2, ( (h-2*bt)-2) / 2,
					{ tl: cr2.tl, tr:cr2.tr, bl:0, br: 0 }, 
					//{ tl: cr2, tr: cr2, bl: 0, br: 0 },
					[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
					verticalGradientMatrix(bt, bt, w - 2*bt, (h - 2*bt) / 2)); 
										  				
				break;
			}

			case "upSkin":
			{

				if (emph)
				{
					// button border/edge
					drawRoundRect(
						0, 0, w, h, cr,
						borderColors, borderAlpha,
						verticalGradientMatrix(0, 0, w , h ),
						GradientType.LINEAR, null, 
						{ x: bt+1, y: bt+1, w: (w - 2*bt) - 2, h: (h - 2*bt)-2, r: cr2 });
						//{ x: 2, y: 2, w: w - 4, h: h - 4, r: cornerRadius - 2 });
                            
					// button fill
					drawRoundRect(
						bt+1, bt+1, (w-2*bt)-2, (h-2*bt)-2, cr2,
						upFillColors, upFillAlphas,
						verticalGradientMatrix(bt, bt, w - 2 * bt, h - 2 * bt), 
						GradientType.LINEAR,
						upFillColorRatios);
										  
					// top highlight
					drawRoundRect(
						bt+1, bt+1, (w- 2*bt)-2, ( (h-2*bt)-2) / 2,
						{ tl: cr2.tl, tr:cr2.tr, bl:0, br: 0 }, 
						//{ tl: cr2, tr: cr2, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(bt, bt, w - 2*bt, (h - 2*bt) / 2)); 
				}
				else
				{
					// button border/edge
					drawRoundRect(
						0, 0, w, h, cr,
						borderColors, borderAlpha,
						verticalGradientMatrix(0, 0, w, h),
						GradientType.LINEAR, null, 
						{ x: bt, y: bt, w: w - 2*bt, h: h - 2*bt, r: cr1 }); 
						//{ x: 1, y: 1, w: w - 2, h: h - 2, r: cornerRadius - 1 }); 
						
					// button fill
					drawRoundRect(
						bt, bt, w - 2*bt, h - 2*bt, cr1,
						upFillColors, upFillAlphas,
						verticalGradientMatrix(bt, bt, w - 2*bt, h - 2*bt),
						GradientType.LINEAR,
						upFillColorRatios); 

					// top highlight
					drawRoundRect(
						bt, bt, w - 2*bt, (h-2*bt) / 2,
						{ tl: cr1.tl, tr:cr1.tr, bl:0, br: 0 }, 
						//{ tl: cr1, tr: cr1, bl: 0, br: 0 },
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
						verticalGradientMatrix(bt, bt, w - 2*bt, (h - 2*bt) / 2)); 
				}
				break;
			}
						
			case "overSkin":
			{
				// button border/edge
				drawRoundRect(
					0, 0, w, h, cr,
					overBorderColors, borderAlpha,
					verticalGradientMatrix(0, 0, w , h),
					GradientType.LINEAR, null, 
					{ x: bt, y: bt, w: w - 2*bt, h: h - 2*bt, r: cr1 }); 
					//{ x: 1, y: 1, w: w - 2, h: h - 2, r: cornerRadius - 1 }); 
											
				// button fill
				drawRoundRect(
					bt, bt, w - 2*bt, h - 2*bt, cr1,
					overFillColors, overFillAlphas,
					verticalGradientMatrix(bt, bt, w - 2*bt, h - 2*bt),
					GradientType.LINEAR,
					overFillColorRatios);  
										  
				// top highlight
				drawRoundRect(
					bt, bt, w - 2*bt, (h - 2*bt) / 2,
					{ tl: cr1.tl, tr:cr1.tr, bl:0, br: 0 }, 
					//{ tl: cr1, tr: cr1, bl: 0, br: 0 },
					[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
					verticalGradientMatrix(bt, bt, w - 2*bt, (h - 2*bt) / 2));  
				
				break;
			}
			case "downSkin":
			case "selectedDownSkin":
			{
				// button border/edge
				drawRoundRect(
					0, 0, w, h, cr,
					overBorderColors, borderAlpha,
					verticalGradientMatrix(0, 0, w , h )); 
												
				// button fill
				if ( downFillColors != null )
				{
					drawRoundRect(
						bt, bt, w - 2*bt, h - 2*bt, cr1,
						downFillColors, downFillAlphas,
						verticalGradientMatrix(bt, bt, w - 2*bt, h - 2*bt),
						GradientType.LINEAR,
						downFillColorRatios);  
				}
				else // use derived style if no custom defined (backwards compatibility from .2)
				{
					drawRoundRect(
						bt, bt, w - 2*bt, h - 2*bt, cr1,
						[ derStyles.fillColorPress1, derStyles.fillColorPress2], fillAlphas[0],
						verticalGradientMatrix(bt, bt, w - 2*bt, h - 2*bt));  
				}						  

				// top highlight
				drawRoundRect(
					bt+1, bt+1, (w-2*bt)-2, ( (h-2*bt)-2) / 2,
					//{ tl: cr2, tr: cr2, bl: 0, br: 0 },
					{ tl: cr2.tl, tr:cr2.tr, bl:0, br: 0 }, 
					[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
					verticalGradientMatrix(bt, bt, w - 2*bt, (h-2*bt) / 2));  
				
				break;
			}
			case "disabledSkin":
			case "selectedDisabledSkin":
			{
				// button border/edge
				drawRoundRect(
					0, 0, w, h, cr,
					borderColors, disabledBorderAlpha,
					verticalGradientMatrix(0, 0, w, h ),
					GradientType.LINEAR, null, 
					//{ x: 1, y: 1, w: w - 2, h: h - 2, r: cornerRadius - 1 });
					{ x: bt, y: bt, w: w - 2*bt, h: h - 2*bt, r: cr1 });
					
				// button fill
				drawRoundRect(
					bt, bt, w - 2*bt, h - 2*bt, cr1,
					disFillColors, disFillAlphas,
					verticalGradientMatrix(bt, bt, w - 2*bt, h - 2*bt),
					GradientType.LINEAR,
					disFillColorRatios);
				
				break;
			}
		}
	}
	
	/**
	 * Utility to create smaller radii for incremental shapes.
	 */ 
	private function radiiUtil( rads:Array, inset:Number ) : Object
	{
		
		var newRads : Object = {};
		
		newRads.tl = Math.max( 0, rads[0] - inset );
		newRads.tr = Math.max( 0, rads[1] - inset );
		newRads.br = Math.max( 0, rads[2] - inset );
		newRads.bl = Math.max( 0, rads[3] - inset );
		
		return newRads;
	} 
	
	/**
	 * Utility function to get color ratios that match a given number of fill colors. 
	 */ 
	private function getColorRatios( styleAttributeName:String, numColors:Number ) : Array
	{
		var ratios : Array = getStyle( styleAttributeName );
	
		if ( ratios != null && ratios.length == numColors )
		{
			return ratios;
		}
		else if ( styleAttributeName != "fillColorRatios" )
		{
			return getColorRatios( "fillColorRatios", numColors );
		}
		else
		{
			// Create an evenly spaced default [ 0, chunk*1, chunk*2 ... 255]
			var chunkSize:Number = 255/(numColors - 1);
			ratios = [];
			for ( var i:int = 0; i < numColors; i++ )
			{
				ratios[i] = Math.round( i * chunkSize );
			}
			return ratios;
		}
	}
	
	/**
	 * Utility function to get fill alphas that match a given number of fill colors.
	 */ 
	private function getAlphas( styleAttributeName:String, numColors:Number ) : Array
	{
		var alphas : Array = getStyle( styleAttributeName );
	
		if ( alphas != null && alphas.length == numColors )
		{
			return alphas;
		}
		else if ( styleAttributeName != "fillAlphas" )
		{
			return getAlphas( "fillAlphas", numColors );	
		}
		else 
		{
			// default to 50% alpha
			alphas = [];
			for ( var i:int = 0; i<numColors; i++ )
			{
				alphas.push( 0.5 );
			}
			
			return alphas;
		}
	}
	
	
}
}