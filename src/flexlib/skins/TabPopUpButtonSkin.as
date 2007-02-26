////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package flexlib.skins
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.GradientType;

import mx.containers.TabNavigator;
import mx.core.EdgeMetrics;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.skins.Border;
import mx.skins.halo.HaloColors;
import mx.skins.halo.PopUpIcon;
import mx.styles.IStyleClient;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;



/**
 * The skin for the PopUpMenuButton to the right of the tabs on
 * a SuperTabNavigator. Uses the base skin from the Tab.
 */
public class TabPopUpButtonSkin extends UIComponent
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
											  borderColor:uint,
											  falseFillColor0:uint,
											  falseFillColor1:uint,
											  fillColor0:uint,
											  fillColor1:uint):Object
	{
		var key:String = HaloColors.getCacheKey(themeColor, borderColor,
												falseFillColor0,
												falseFillColor1,
												fillColor0, fillColor1);
		
		if (!cache[key])
		{
			var o:Object = cache[key] = {};

			// Cross-component styles.
			HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
			
			// Tab-specific styles.
			o.borderColorDrk1 =
				ColorUtil.adjustBrightness2(borderColor, 10);
			o.falseFillColorBright1 =
				ColorUtil.adjustBrightness(falseFillColor0, 15);
			o.falseFillColorBright2 =
				ColorUtil.adjustBrightness(falseFillColor1, 15);
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
	public function TabPopUpButtonSkin()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  borderMetrics
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the borderMetrics property.
	 */
	private var _borderMetrics:EdgeMetrics = new EdgeMetrics(1, 1, 1, 1);

	/**
	 *  @private
	 */
	/*
	override public function get borderMetrics():EdgeMetrics
	{
		return _borderMetrics;
	}*/

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

		// User-defined styles.
		var backgroundAlpha:Number = getStyle("backgroundAlpha");		
		var backgroundColor:Number = getStyle("backgroundColor");
		var borderColor:uint = getStyle("borderColor");
		var cornerRadius:Number = getStyle("cornerRadius");
		var fillAlphas:Array = getStyle("fillAlphas");
		var fillColors:Array = getStyle("fillColors");
		StyleManager.getColorNames(fillColors);
		var highlightAlphas:Array = getStyle("highlightAlphas");		
		var themeColor:uint = getStyle("themeColor");
		
		// Placehold styles stub.
		var falseFillColors:Array = []; /* of Number*/ // added style prop
		falseFillColors[0] = ColorUtil.adjustBrightness2(fillColors[0], -5);
		falseFillColors[1] = ColorUtil.adjustBrightness2(fillColors[1], -5);
		
		// Derivative styles.
		var derStyles:Object = calcDerivedStyles(themeColor, borderColor,
												 falseFillColors[0],
												 falseFillColors[1],
												 fillColors[0], fillColors[1]);
		
		var drawBottomLine:Boolean =
			parent != null &&
			parent.parent != null &&
			parent.parent.parent != null &&
			parent.parent.parent is TabNavigator &&
			IStyleClient(parent.parent.parent).getStyle("borderStyle") != "none";
		
		var cornerRadius2:Number = Math.max(cornerRadius - 2, 0);
		var cr:Object = { tl: cornerRadius, tr: cornerRadius, bl: 0, br: 0 };
		var cr2:Object = { tl: cornerRadius2, tr: cornerRadius2, bl: 0, br: 0 };



		var popUpIcon:IFlexDisplayObject =
			IFlexDisplayObject(getChildByName("popUpIcon"));
        
        if (!popUpIcon)
        {
            var popUpIconClass:Class = Class(getStyle("popUpIcon"));
            popUpIcon = new popUpIconClass();
            DisplayObject(popUpIcon).name = "popUpIcon";
            addChild(DisplayObject(popUpIcon));
            DisplayObject(popUpIcon).visible = true;            
        }
        
        var arrowButtonWidth:Number = Math.max(getStyle("arrowButtonWidth"),
											   popUpIcon.width + 3 + 1);
        
		var dividerPosX:Number = w - arrowButtonWidth;
        
		var arrowColor:uint = 0x111111;    

		popUpIcon.move(w - (arrowButtonWidth + popUpIcon.width) / 2,
					   (h - popUpIcon.height) / 2);
					   
					   
					   
		graphics.clear();
		
		switch (name)
		{
			case "upSkin":
			{
   				var upFillColors:Array =
					[ falseFillColors[0], falseFillColors[1] ];
   				
				var upFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];

				// outer edge
				drawRoundRect(
					0, 0, w, h - 1, cr,
					[ derStyles.borderColorDrk1, borderColor], 1,
					verticalGradientMatrix(0, 0, w, h),
					GradientType.LINEAR, null, 
					{ x: 1, y: 1, w: w - 2, h: h - 2, r: cr2 }); 

				// tab fill
				drawRoundRect(
					1, 1, w - 2, h - 2, cr2,
					upFillColors, upFillAlphas,
					verticalGradientMatrix(0, 2, w - 2, h - 6));
			
				// tab highlight
				drawRoundRect(
					1, 1, w - 2, (h - 2) / 2, cr2,
					[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
					verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2));

				// tab bottom line
				if (drawBottomLine)
				{
					drawRoundRect(
						0, h - 1, w, 1, 0,
						borderColor, fillAlphas[1]);
				}
				
				// tab shadow	
				drawRoundRect(
					0, h - 2, w, 1, 0,
					0x000000, 0.09);
				
				// tab shadow
				drawRoundRect(
					0, h - 3, w, 1, 0,
					0x000000, 0.03);
	
				break;
			}
			case "popUpOverSkin":
			case "overSkin":
			{
				var overFillColors:Array;
				if (fillColors.length > 2)
					overFillColors = [ fillColors[2], fillColors[3] ];
				else
					overFillColors = [ fillColors[0], fillColors[1] ];

				var overFillAlphas:Array;
				if (fillAlphas.length > 2)
					overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
  				else
					overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];

				// outer edge
				
				drawRoundRect(
					0, 0, w, h - 1, cr,
					[ themeColor, derStyles.themeColDrk2 ], 1,
					verticalGradientMatrix(0, 0, w, h - 6),
					GradientType.LINEAR, null, 
					{ x: 1, y: 1, w: w - 2, h: h - 2, r: cr2 });
				
				// tab fill
				drawRoundRect(
					1, 1, w - 2, h - 2, cr2,
					[ derStyles.falseFillColorBright1,
					  derStyles.falseFillColorBright2 ], overFillAlphas,
					verticalGradientMatrix(2, 2, w - 2, h - 2));
			
				// tab highlight
				drawRoundRect(
					1, 1, w - 2, (h - 2) / 2, cr2,
					[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas,
					verticalGradientMatrix(1, 1, w - 2, (h - 2) / 2));

				// tab bottom line
				if (drawBottomLine)
				{
					drawRoundRect(
						0, h - 1, w, 1, 0,
						borderColor, fillAlphas[1]);
				}
				
				// tab shadow	
				drawRoundRect(
					0, h - 2, w, 1, 0,
					0x000000, 0.09);
				
				// tab shadow
				drawRoundRect(
					0, h - 3, w, 1, 0,
					0x000000, 0.03);
				
				break;
			}

			case "disabledSkin":
			{
   				var disFillColors:Array = [ fillColors[0], fillColors[1] ];

   				var disFillAlphas:Array =
					[ Math.max( 0, fillAlphas[0] - 0.15),
					  Math.max( 0, fillAlphas[1] - 0.15) ];
			
				// outer edge
				drawRoundRect(
					0, 0, w, h - 1, cr,
					[ derStyles.borderColorDrk1, borderColor], 0.5,
					verticalGradientMatrix(0, 0, w, h - 6));
				
				// tab fill
				drawRoundRect(
					1, 1, w - 2, h - 2, cr2,
					disFillColors, disFillAlphas,
					verticalGradientMatrix(0, 2, w - 2, h - 2));
				
				// tab bottom line
				if (drawBottomLine)
				{
					drawRoundRect(
						0, h - 1, w, 1, 0,
						borderColor, fillAlphas[1]);
				}
				
				// tab shadow	
				drawRoundRect(
					0, h - 2, w, 1, 0,
					0x000000, 0.09);
				
				// tab shadow
				drawRoundRect(
					0, h - 3, w, 1, 0,
					0x000000, 0.03);
				
				break;
			}
			case "popUpDownSkin":
			case "downSkin":
			case "selectedUpSkin":
			case "selectedDownSkin":
			case "selectedOverSkin":
			case "selectedDisabledSkin":
			{
				if (isNaN(backgroundColor))
				{
					// Walk the parent chain until we find a background color
					var p:DisplayObjectContainer = parent;
					
					while (p)
					{
						if (p is IStyleClient)
							backgroundColor = IStyleClient(p).getStyle("backgroundColor");
						
						if (!isNaN(backgroundColor))
							break;
							
						p = p.parent;
					}
					
					// Still no backgroundColor? Use white.
					if (isNaN(backgroundColor))
						backgroundColor = 0xFFFFFF;
				}
				
 				// outer edge
				drawRoundRect(
					0, 0, w, h - 1, cr,
					[ derStyles.borderColorDrk1, borderColor], 1,
					verticalGradientMatrix(0, 0, w, h - 2),
					GradientType.LINEAR, null, 
					{ x: 1, y: 1, w: w - 2, h: h - 2, r: cr2 });
			
				// tab fill color
				drawRoundRect(
					1, 1, w - 2, h - 2, cr2,
					backgroundColor, backgroundAlpha);
				
				// tab bottom line
				if (drawBottomLine)
				{
					drawRoundRect(
						1, h - 1, w - 2, 1, 0,
						backgroundColor, backgroundAlpha);
				}
				
				break;
			}
		}
		
		if (popUpIcon is PopUpIcon)
        	PopUpIcon(popUpIcon).mx_internal::arrowColor = arrowColor;
	}
	
	
}

}
