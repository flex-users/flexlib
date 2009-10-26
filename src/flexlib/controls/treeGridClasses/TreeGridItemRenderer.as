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

package flexlib.controls.treeGridClasses
{

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import flexlib.controls.TreeGrid;

import mx.controls.Image;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.IToolTip;
import mx.core.SpriteAsset;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.events.FlexEvent;
import mx.events.ToolTipEvent;
import mx.events.TreeEvent;
import mx.managers.ILayoutManagerClient;
import mx.styles.IStyleClient;

[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 * 
 */
public class TreeGridItemRenderer extends UIComponent 
								  implements IDataRenderer, 
								  			 IDropInListItemRenderer, 
											 ILayoutManagerClient,
							  				 IListItemRenderer
{
	//----------------------------------
	//  disclosureIcon
    //----------------------------------

	/**
	 *  The internal IFlexDisplayObject that displays the disclosure icon
	 *  in this renderer.
	 */
	protected var disclosureIcon:IFlexDisplayObject;
	
    //----------------------------------
	//  icon
    //----------------------------------

	/**
	 *  The internal IFlexDisplayObject that displays the icon in this renderer.
	 */
	protected var icon:IFlexDisplayObject;
	
    //----------------------------------
	//  label
    //----------------------------------

	/**
	 *  The internal UITextField that displays the text in this renderer.
	 */
	protected var label:UITextField;
	
	
	/**
	 *  The internal shape that displays the trunks in this renderer.
	 */
	protected var trunk:Sprite;
	
	
	private var listOwner : TreeGrid;
	
	
	/**
     *  Constructor.
     */
	public function TreeGridItemRenderer()
	{
		super();
	}
	
	/**
	 *  @private
	 */
	override protected function createChildren():void
	{
        super.createChildren();

		if (!label)
		{
			label = new UITextField();
			label.styleName = this;
			addChild(label);
		}
		
		addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler);
	}
	
	/**
	 *  @private
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();

		if (icon)
		{
			removeChild(DisplayObject(icon));
			icon = null;
		}

		if (disclosureIcon)
		{
			disclosureIcon.removeEventListener(MouseEvent.MOUSE_DOWN, 
			      							   disclosureMouseDownHandler);
			removeChild(DisplayObject(disclosureIcon));
			disclosureIcon = null;
		}
		
		if(trunk)
		{
			trunk.graphics.clear();
			removeChild(DisplayObject(trunk));
			trunk = null;
		}

		if ( _data )
		{
			listOwner = TreeGrid( _listData.owner );

			if (_listData.disclosureIcon)
			{
				var disclosureIconClass:Class = _listData.disclosureIcon;
				var disclosureInstance:* = new disclosureIconClass();
				
				// If not already an interactive object, then we'll wrap 
				// in one so we can dispatch mouse events.
				if (!(disclosureInstance is InteractiveObject))
				{
					var wrapper:SpriteAsset = new SpriteAsset();
					wrapper.addChild(disclosureInstance as DisplayObject);
					disclosureIcon = wrapper as IFlexDisplayObject;
				}
				else
				{
					disclosureIcon = disclosureInstance;
				}

				addChild(disclosureIcon as DisplayObject);
				disclosureIcon.addEventListener(MouseEvent.MOUSE_DOWN,
												disclosureMouseDownHandler);
			}
			
			if(_listData.trunk != "none" )
			{
				trunk = new Sprite();
				addChild(trunk);
			}
			
			if (_listData.icon)
			{
				var iconClass:Class = _listData.icon;
				icon = new iconClass();

				addChild(DisplayObject(icon));
			}
			
			label.text = _listData.label;
			label.multiline = listOwner.variableRowHeight;
			label.wordWrap = listOwner.wordWrap;
			
			
			if (listOwner.showDataTips)
			{
				if (label.textWidth > label.width ||
					listOwner.dataTipFunction != null)
				{
					toolTip = listOwner.itemToDataTip(_data);
				}
				else
				{
					toolTip = null;
				}
			}
			else
			{
				toolTip = null;
			}
		}
		else
		{
			label.text = " ";
			toolTip = null;
		}

		invalidateDisplayList();
	}
	
	/**
	 *  @private
	 */
	override protected function measure():void
	{
		super.measure();

		var w:Number = _data ? _listData.indent : 5;
		
		w = w + 5;

		if (disclosureIcon)
			w += disclosureIcon.width;

		if (icon)
			w += icon.measuredWidth;

		// guarantee that label width isn't zero because it messes up ability to measure
		if (label.width < 4 || label.height < 4)
		{
			label.width = 4;
			label.height = 16;
		}
		
		if (isNaN(explicitWidth))
		{
			w += label.getExplicitOrMeasuredWidth();	
			measuredWidth = w;
			measuredHeight = label.getExplicitOrMeasuredHeight();
		}
		else
		{
			label.width = Math.max(explicitWidth - w, 4);
			measuredHeight = label.getExplicitOrMeasuredHeight();
			if (icon && icon.measuredHeight > measuredHeight)
				measuredHeight = icon.measuredHeight;
		}
	}

	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var startx:Number = _data ? _listData.indent : 0;
		
		//if( startx == 0 )
		startx = startx + 5;
			
		if (disclosureIcon)
		{
			disclosureIcon.x = startx;

			startx = disclosureIcon.x + disclosureIcon.width;
			
			disclosureIcon.setActualSize(disclosureIcon.width,
										 disclosureIcon.height);
			
			disclosureIcon.visible = _data ?
									 _listData.hasChildren :
									 false;
									 
			
			
		}
		
		if(trunk)
		{
			trunk.graphics.clear();
			
			trunk.graphics.lineStyle( 1, _listData.trunkColor, 0.5 );
			
			for( var i : int = 0; i < _listData.depth - 1; i++ )
			{
				var currentx : Number = 5 + i * _listData.indentationGap;
				trunk.graphics.moveTo(currentx + (disclosureIcon.width / 2), 0 - _listData.trunkOffsetTop );
				trunk.graphics.lineTo(currentx + (disclosureIcon.width / 2), this.height + _listData.trunkOffsetBottom );
			}
			
			if(disclosureIcon && disclosureIcon.visible)
			{
				//vertical item line (separated in 2 part, top of the icon and bottom of the icon)
				trunk.graphics.moveTo(startx - (disclosureIcon.width / 2), 0 - _listData.trunkOffsetTop );
				trunk.graphics.lineTo(startx - (disclosureIcon.width / 2), disclosureIcon.y );
				
				if(_listData.hasSibling)
				{
					trunk.graphics.moveTo(startx - (disclosureIcon.width / 2), disclosureIcon.y + disclosureIcon.height );
					trunk.graphics.lineTo(startx - (disclosureIcon.width / 2), this.height + _listData.trunkOffsetBottom );
				}
				
				//horizontal item line
				trunk.graphics.moveTo(startx, disclosureIcon.y + disclosureIcon.height / 2 );
				trunk.graphics.lineTo(startx + (_listData.indentationGap / 3), disclosureIcon.y + disclosureIcon.height / 2 );				
				startx = startx + (_listData.indentationGap / 3);
			}
			else
			{
				if(!disclosureIcon.visible)
				{
					var endy : Number=0;
					//vertical item line
					if(_listData.hasSibling)
					{
						endy = this.height + _listData.trunkOffsetBottom;
					}
					else
					{
						endy = disclosureIcon.y + disclosureIcon.height / 2;
					}
					trunk.graphics.moveTo(startx - (disclosureIcon.width / 2), 0 - _listData.trunkOffsetTop );
					trunk.graphics.lineTo(startx - (disclosureIcon.width / 2), endy );
					
					//horizontal item line
					trunk.graphics.moveTo(startx - (disclosureIcon.width / 2) , disclosureIcon.y + disclosureIcon.height / 2 );
					trunk.graphics.lineTo(startx + (_listData.indentationGap / 3) , disclosureIcon.y + disclosureIcon.height / 2 );					
					startx = startx + (_listData.indentationGap / 3);
				}
				else
				{
					//trunk.graphics.moveTo(startx , 0 - _listData.trunkOffsetTop );
					//trunk.graphics.lineTo(startx , this.height + _listData.trunkOffsetBottom );
				}
			}
		}
		
		
		if (icon)
		{
			icon.x = startx;
			startx = icon.x + icon.measuredWidth;
			icon.setActualSize(icon.measuredWidth, icon.measuredHeight);
		}
		
		label.x = startx;
		label.setActualSize(unscaledWidth - startx, measuredHeight);
		
		// using truncateToFit to add the 3 dots to labels if the columns are too small
		if( label.truncateToFit() )
		{
			label.toolTip = _listData.label;
		}
		
		
		
		//var verticalAlign:String = getStyle("verticalAlign");
		/*if (verticalAlign == "top")
		{
			label.y = 0;
			if (icon)
				icon.y = 0;
			if (disclosureIcon)
				disclosureIcon.y = 0;
		}
		else if (verticalAlign == "bottom")
		{
			label.y = unscaledHeight - label.height + 2; // 2 for gutter
			if (icon)
				icon.y = unscaledHeight - icon.height;
			if (disclosureIcon)
				disclosureIcon.y = unscaledHeight - disclosureIcon.height;
		}
		else
		{*/
		// TODO
		//}

		label.y = (unscaledHeight - label.height) / 2;
		if (icon)
			icon.y = (unscaledHeight - icon.height) / 2;
		if (disclosureIcon)
			disclosureIcon.y = (unscaledHeight - disclosureIcon.height) / 2;
				
				
				
				
				
		var labelColor:Number;

		if (data && parent)
		{
			if (!enabled)
				labelColor = getStyle("disabledColor");

			else if (listOwner.isItemHighlighted(listData.uid))
        		labelColor = getStyle("textRollOverColor");

			else if (listOwner.isItemSelected(listData.uid))
        		labelColor = getStyle("textSelectedColor");

			else
        		labelColor = getStyle("color");
			
			label.setColor(labelColor);
		}
	}
	
	/**
	 *  @private
	 */
	private function toolTipShowHandler(event:ToolTipEvent):void
	{
		var toolTip:IToolTip = event.toolTip;

		// Calculate global position of label.
		var pt:Point = new Point(0, 0);
		pt = label.localToGlobal(pt);
		pt = root.globalToLocal(pt);			
		
		toolTip.move(pt.x, pt.y + (height - toolTip.height) / 2);
			
		var screen:Rectangle = systemManager.screen;
		var screenRight:Number = screen.x + screen.width;
		if (toolTip.x + toolTip.width > screenRight)
			toolTip.move(screenRight - toolTip.width, toolTip.y);
	}

	/**
	 *  @private
	 */
	private function disclosureMouseDownHandler(event:Event):void
	{
		event.stopPropagation();
		
		//if (listOwner.isOpening || !listOwner.enabled)
		//	return;

		var open:Boolean = _listData.open;
		_listData.open = !open;
		
		listOwner.dispatchTreeEvent(TreeEvent.ITEM_OPENING,
		                        _listData, //listData
                                this,  	//renderer
                                event, 	//trigger
                                !open, 	//opening
    							true)   //dispatch
	}
	
	
	
	/**
     *  @private
     */
	private var invalidatePropertiesFlag:Boolean = false;
	
    /**
     *  @private
     */
	private var invalidateSizeFlag:Boolean = false;

 	//--------------------------------------------------------------------------
	//
	//  Overridden properties: UIComponent
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  nestLevel
    //----------------------------------

    /**
     *  @private
     */
	override public function set nestLevel(value:int):void
	{
		super.nestLevel = value;
	
	}
	
	/**
	 *  @private
	 */
	private var _listData:TreeGridListData;

	[Bindable("dataChange")]
	public function get listData() : BaseListData
	{
		return _listData;
	}
	
	public function set listData( value : BaseListData ) : void
	{
		if( !value )
			return;
		
		_listData = TreeGridListData( value );	
	}
	
	
	/**
     *  @private
     */
    private var _data:Object;

	[Bindable("dataChange")]
	public function get data(): Object
	{
		return _data;
	}
	
	
	public function set data( value : Object ):void
	{
		_data = value;
	
		invalidateProperties();

		dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
	}

} // end class
} // end package