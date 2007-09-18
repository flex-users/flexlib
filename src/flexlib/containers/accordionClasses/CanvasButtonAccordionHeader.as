////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package flexlib.containers.accordionClasses
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import mx.containers.Accordion;
import mx.controls.Button;
import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.mx_internal;
import mx.styles.CSSStyleDeclaration;
import mx.styles.ISimpleStyleClient;
import mx.styles.StyleManager;
import flexlib.controls.CanvasButton;
import mx.skins.halo.AccordionHeaderSkin;

use namespace mx_internal;

[AccessibilityClass(implementation="mx.accessibility.AccordionHeaderAccImpl")]

/**
 * The <code>CanvasButtonAccordionHeader</code> class allows you to easily use a <code>CanvasButton</code> control as the header
 * renderer of an <code>Accordion</code>.
 * 
 * This class is a copy of the AccordionHeader class, but instead of subclassing <code>Button</code>, it subclasses
 * <code>CanvasButton</code>.
 *
 * @see flexlib.controls.CanvasButton
 * @see mx.containers.Accordion
 */
public class CanvasButtonAccordionHeader extends CanvasButton implements IDataRenderer
{
	
	//--------------------------------------------------------------------------
	//
	//  Class mixins
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Placeholder for mixin by AccordionHeaderAccImpl.
	 */
	mx_internal static var createAccessibilityImplementation:Function;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function CanvasButtonAccordionHeader()
	{
		super();

		// Since we play games with allowing selected to be set without
		// toggle being set, we need to clear the default toggleChanged
		// flag here otherwise the initially selected header isn't
		// drawn in a selected state.
		toggleChanged = false;
		mouseFocusEnabled = false;
		tabEnabled = false;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var focusObj:DisplayObject;

	/**
	 *  @private
	 */
	private var focusSkin:IFlexDisplayObject;

	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  data
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the _data property.
	 */
	private var _data:Object;

	/**
	 *  Stores a reference to the content associated with the header.
	 */
	override public function get data():Object
	{
		return _data;
	}
	
	/**
	 *  @private
	 */
	override public function set data(value:Object):void
	{
		_data = value;
	}
	
	//----------------------------------
	//  selected
	//----------------------------------

	/**
	 *  @private
	 */
	override public function set selected(value:Boolean):void
	{
		_selected = value;

		invalidateDisplayList();
	}

	private static function initializeStyles():void
	{
		var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("CanvasButtonAccordionHeader");
		
		if(!selector)
		{
			selector = new CSSStyleDeclaration();
		}
		
		selector.defaultFactory = function():void
		{
			this.fontSize = 10;
			this.fontWeight = "bold";
			this.disabledSkin = mx.skins.halo.AccordionHeaderSkin;
			this.downSkin = mx.skins.halo.AccordionHeaderSkin;
			this.horizontalGap = 2;
			this.overSkin = mx.skins.halo.AccordionHeaderSkin;
			this.paddingLeft = 5;
			this.paddingRight = 5;
			this.selectedDisabledSkin = mx.skins.halo.AccordionHeaderSkin;
			this.selectedDownSkin = mx.skins.halo.AccordionHeaderSkin;
			this.selectedOverSkin = mx.skins.halo.AccordionHeaderSkin;
			this.selectedUpSkin = mx.skins.halo.AccordionHeaderSkin;
			this.skin = mx.skins.halo.AccordionHeaderSkin;
			this.textAlign = "left";
			this.upSkin = mx.skins.halo.AccordionHeaderSkin;
		}
		
		StyleManager.setStyleDeclaration("CanvasButtonAccordionHeader", selector, false);
			
	}
	
	initializeStyles();



	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function initializeAccessibility():void
	{
		if (CanvasButtonAccordionHeader.createAccessibilityImplementation != null)
			CanvasButtonAccordionHeader.createAccessibilityImplementation(this);
	}

	/**
	 *  @private
	 */
	override protected function createChildren():void
	{
		super.createChildren();
		
		// AccordionHeader has a bit of a conflict here. Our styleName points to
		// our parent Accordion, which has padding values defined. We also have
		// padding values defined on our type selector, but since class selectors
		// take precedence over type selectors, the type selector padding values
		// are ignored. Force them in here.
		var styleDecl:CSSStyleDeclaration = StyleManager.getStyleDeclaration(className);
		
		if (styleDecl)
		{
			var value:Number = styleDecl.getStyle("paddingLeft");
			if (!isNaN(value))
				setStyle("paddingLeft", value);
			value = styleDecl.getStyle("paddingRight");
			if (!isNaN(value))
				setStyle("paddingRight", value);
		}
	}
	
	/**
	 *  @private
	 */
	override public function drawFocus(isFocused:Boolean):void
	{
		// Accordion header focus is drawn inside the control.
		if (isFocused && !isEffectStarted)
		{
			if (!focusObj)
			{
				var focusClass:Class = getStyle("focusSkin");

				focusObj = new focusClass();

				var focusStyleable:ISimpleStyleClient = focusObj as ISimpleStyleClient;
				if (focusStyleable)
					focusStyleable.styleName = this;

				addChild(focusObj);

				// Call the draw method if it has one
				focusSkin = focusObj as IFlexDisplayObject;
			}

			if (focusSkin)
			{
				focusSkin.move(0, 0);
				focusSkin.setActualSize(unscaledWidth, unscaledHeight);
			}
			focusObj.visible = true;

			dispatchEvent(new Event("focusDraw"));
		}
		else if (focusObj)
		{
			focusObj.visible = false;
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Button
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override mx_internal function layoutContents(unscaledWidth:Number,
											     unscaledHeight:Number,
											     offset:Boolean):void
	{
		super.layoutContents(unscaledWidth, unscaledHeight, offset);

		// Move the focus object to front.
		// AccordionHeader needs special treatment because it doesn't
		// show focus by having the standard focus ring display outside.
		if (focusObj)
			setChildIndex(focusObj, numChildren - 1);
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers: Button
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function rollOverHandler(event:MouseEvent):void
	{
		super.rollOverHandler(event);

		// The halo design specifies that accordion headers overlap
		// by a pixel when layed out. In order for the border to be
		// completely drawn on rollover, we need to set our index
		// here to bring this header to the front.
		var accordion:Container = Container(parent);
		if (accordion.enabled)
		{
			accordion.rawChildren.setChildIndex(this,
				accordion.rawChildren.numChildren - 1);
		}
	}
}

}
