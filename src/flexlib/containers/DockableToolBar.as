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

package flexlib.containers
{

import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.geom.Point;
import mx.controls.Image;
import mx.containers.TitleWindow;
import mx.containers.HBox;
import mx.core.Application;
import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.managers.PopUpManager;

import flexlib.containers.Docker;

use namespace mx_internal;

/**
 *  Dispatched when the <code>ToolBar</code> is docked.
 * 
 *  @eventType flash.events.Event
 */
[Event(name="dock", type="flash.events.Event")]

/**
 *  Dispatched when the <code>ToolBar</code> is poped up into a floating window.
 * 
 *  @eventType flash.events.Event
 */
[Event(name="float", type="flash.events.Event")]

/**
 *  Image to be used for the dragStrip icon.
 *  If not specified, the default image is used.
 */
[Style(name="dragStripIcon", type="String", inherit="no")]

/**
 *  The DockableToolBar container is used along with the Docker 
 *  container to add individual ToolBars within a Docker context.
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;flexlib:DockableToolBar&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;flexlib:DockableToolBar
 *    <b>Properties</b>
 *    draggable="true"
 *    initialPosition="top"
 *
 *    <b>Events</b>
 *    dock="<i>No default</i>"
 *    float="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *
 *  @see flexlib.containers.Docker
 *
 */

public class DockableToolBar extends FlowContainer
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function DockableToolBar()
	{
		super();
		horizontalScrollPolicy = "off";
		verticalScrollPolicy = "off";
	}

	[Embed(source="../assets/dragStripIcon.png")]
	private var dragStripIconClass:Class;

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * Flag which indicates whether this ToolBar can be dragged by user.
	 */
	public var draggable:Boolean = true;

	/**
	 * A reference to the dragStrip image used by the ToolBar
	 */
	private var dragStrip:Image;

	/**
	 * The initial location of the ToolBar. This can be either "top" or "bottom".
	 */
	public var initialPosition:String = "top";
	
	/**
	 * @private
	 * A reference to the Docker object to which this ToolBar would be Docked.
	 */
	mx_internal var docker:Docker;
	
	/**
	 * @private
	 * A reference to the PopUp Window object when the ToolBar is floating.
	 */
	protected var floatingWindow:TitleWindow;

	// False means floating Toolbar
	private var _isDocked:Boolean = true;
	
	private var estimatedWidth:Number;
	
	/**
	 *  @private
	 *  Horizontal location where the user pressed the mouse button
	 *  to start dragging
	 */
	private var regX:Number;
	
	/**
	 *  @private
	 *  Vertical location where the user pressed the mouse button
	 *  to start dragging
	 */
	private var regY:Number;

	mx_internal var rowCount:int = -1;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * Indicates whether the ToolBar is currently docked.
	 */
	public function get isDocked():Boolean
	{
		return _isDocked;
	}
    
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
 	/**
	 *  @private
	 */
	override protected function createChildren():void
	{
		super.createChildren();
		
		if (draggable)
		{
			if (!dragStrip)
			{
				dragStrip = new Image();
				var iconStyle:Object = getStyle("dragStripIcon");
				if (iconStyle)
					dragStrip.source = iconStyle
				else
					dragStrip.source = dragStripIconClass;
				
				dragStrip.toolTip = "Drag to move the Toolbar";
				addChildAt(dragStrip, 0);
			}
		
			dragStrip.addEventListener("mouseDown", mouseDownHandler);
		}
	}
    
 	/**
	 *  @private
	 */
    override public function getExplicitOrMeasuredWidth():Number
    {
    	return Math.min(systemManager.screen.width, super.getExplicitOrMeasuredWidth());
    }

	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		if (dragStrip && unscaledWidth < dragStrip.getExplicitOrMeasuredWidth())
			return;
		layoutObject.rowCount = isDocked ? (isNaN(explicitWidth) ? 1 : rowCount) : -1;
		layoutObject.modifyTargetHeight = !_isDocked;
		super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	protected function mouseDownHandler(event:MouseEvent):void
	{
	
		if (!docker)
			return;
			
		var pt:Point = (floatingWindow ? floatingWindow : this).globalToLocal(
						new Point(event.stageX, event.stageY));
		regX = pt.x;
		regY = pt.y;

		systemManager.addEventListener("mouseMove", mouseMoveHandler);
		systemManager.addEventListener("mouseUp", mouseUpHandler);
		systemManager.stage.addEventListener(
			Event.MOUSE_LEAVE, stopDragging);
		
		if (measuredWidth > 200 || !isNaN(percentWidth))
		{
			var area:int = measuredHeight * measuredWidth;
			estimatedWidth = Math.max(Math.sqrt(area) * 1.6, measuredMinWidth);
		}
		else
			estimatedWidth = measuredWidth;

		event.stopPropagation();
	}

	/**
	 *  @private
	 */
	protected function mouseUpHandler(event:MouseEvent):void
	{
		
		var prevDocked:Boolean = _isDocked;
		_isDocked = docker.dragOver(this, event, true);
		
		updateFloatingStatus(event);
		
		UIComponent(parent).invalidateDisplayList();
		
		if (floatingWindow)
		{
			var s:int = (prevDocked && !_isDocked) ? 2 : 1;
			floatingWindow.x = event.stageX - regX / s;
			floatingWindow.y = event.stageY - regY;
			floatingWindow.getTitleBar().addEventListener("mouseDown", mouseDownHandler);
			if (floatingWindow.x < -floatingWindow.width / 2)
				floatingWindow.x = -floatingWindow.width / 2;
			if (floatingWindow.x > systemManager.screen.width - floatingWindow.width / 2)
				floatingWindow.x = systemManager.screen.width - floatingWindow.width / 2;
		}
		stopDragging(event);
	}
	
	/**
	 *  @private
	 */
	protected function stopDragging(event:Event):void
	{
		docker.dragProxy.graphics.clear();
		systemManager.removeEventListener("mouseUp", mouseUpHandler);
		systemManager.removeEventListener("mouseMove", mouseMoveHandler);
		systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, stopDragging);
	}
	
	/**
	 * @private
	 * Used to update change the ToolBar state to docked or floating according to 
	 * the dragdrop position.
	 */
	protected function updateFloatingStatus(event:MouseEvent):void
	{
		if (_isDocked && floatingWindow)
		{
			var pt:Point = localToGlobal(new Point(x, y));
			floatingWindow.x = event.stageX;//pt.x;
			floatingWindow.y = pt.y;
			floatingWindow.getTitleBar().removeEventListener("mouseDown", mouseDownHandler);
			PopUpManager.removePopUp(floatingWindow);
			floatingWindow = null;
			dragStrip.visible = dragStrip.includeInLayout = true;
			dispatchEvent(new Event("dock"));
		}
		else
		if (!_isDocked && !floatingWindow)
		{
			floatingWindow = new PopUpToolBar();
			floatingWindow.title = label;
			floatingWindow.horizontalScrollPolicy = "off";
			floatingWindow.verticalScrollPolicy = "off";
			pt = localToGlobal(new Point(0, 0));
			floatingWindow.x = pt.x;
			floatingWindow.y = pt.y;
						
			floatingWindow.width = estimatedWidth;
			mx.managers.PopUpManager.addPopUp(floatingWindow, docker);

			if (parent is HBox && parent.numChildren == 1)
				parent.parent.removeChild(parent);
			parent.removeChild(this);
			
			dragStrip.visible = dragStrip.includeInLayout = false;
			floatingWindow.addChild(this);
			floatingWindow.validateNow();
			dispatchEvent(new Event("float"));
		}
	}

	/**
	 *  @private
	 */
	protected function mouseMoveHandler(event:MouseEvent):void
	{
		var overDockingArea:Boolean = docker.dragOver(this, event);
		
		var g:Graphics = docker.dragProxy.graphics;
		g.lineStyle(1, 0x000000, 0.5);
		g.beginFill(0xFFFFFF, 0.45);
		var wrapFactor:Number = (_isDocked && !overDockingArea) ? 
					measuredWidth / estimatedWidth : 1;
		var dragObject:UIComponent = UIComponent(_isDocked ? this : parent);
		g.drawRect(event.stageX - regX / wrapFactor, event.stageY - regY, 
					dragObject.width / wrapFactor, dragObject.height * wrapFactor);
		g.endFill();
	}

}

}
