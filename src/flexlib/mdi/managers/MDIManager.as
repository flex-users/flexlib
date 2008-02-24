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


package flexlib.mdi.managers
{
	import flash.display.DisplayObject;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	import flexlib.mdi.containers.MDIWindow;
	import flexlib.mdi.effects.IMDIEffectsDescriptor;
	import flexlib.mdi.effects.MDIEffectsDescriptorBase;
	import flexlib.mdi.effects.effectClasses.MDIGroupEffectItem;
	import flexlib.mdi.events.MDIManagerEvent;
	import flexlib.mdi.events.MDIWindowEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.EventPriority;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.effects.CompositeEffect;
	import mx.effects.Effect;
	import mx.effects.effectClasses.CompositeEffectInstance;
	import mx.events.EffectEvent;
	import mx.events.ResizeEvent;
	import mx.managers.PopUpManager;
	import mx.utils.ArrayUtil;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when a window is added to the manager.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_ADD
	 */
	[Event(name="windowAdd", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the minimize button is clicked.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_MINIMIZE
	 */
	[Event(name="windowMinimize", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  If the window is minimized, this event is dispatched when the titleBar is clicked. 
	 * 	If the window is maxmimized, this event is dispatched upon clicking the restore button
	 *  or double clicking the titleBar.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_RESTORE
	 */
	[Event(name="windowRestore", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the maximize button is clicked or when the window is in a
	 *  normal state (not minimized or maximized) and the titleBar is double clicked.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_MAXIMIZE
	 */
	[Event(name="windowMaximize", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the minimize button is clicked.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_CLOSE
	 */
	[Event(name="windowClose", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the window gains focus and is given topmost z-index of MDIManager's children.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_FOCUS_START
	 */
	[Event(name="windowFocusStart", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the window loses focus and no longer has topmost z-index of MDIManager's children.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_FOCUS_END
	 */
	[Event(name="windowFocusEnd", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the window begins being dragged.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_DRAG_START
	 */
	[Event(name="windowDragStart", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched while the window is being dragged.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_DRAG
	 */
	[Event(name="windowDrag", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the window stops being dragged.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_DRAG_END
	 */
	[Event(name="windowDragEnd", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when a resize handle is pressed.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_RESIZE_START
	 */
	[Event(name="windowResizeStart", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched while the mouse is down on a resize handle.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_RESIZE
	 */
	[Event(name="windowResize", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the mouse is released from a resize handle.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.WINDOW_RESIZE_END
	 */
	[Event(name="windowResizeEnd", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the windows are cascaded.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.CASCADE
	 */
	[Event(name="cascade", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 *  Dispatched when the windows are tiled.
	 *
	 *  @eventType flexlib.mdi.events.MDIManagerEvent.TILE
	 */
	[Event(name="tile", type="flexlib.mdi.events.MDIManagerEvent")]
	
	/**
	 * Class responsible for applying effects and default behaviors to MDIWindow instances such as
	 * tiling, cascading, minimizing, maximizing, etc.
	 */
	public class MDIManager extends EventDispatcher
	{
		
		private static var globalMDIManager:MDIManager;
		public static function get global():MDIManager
		{
			if(MDIManager.globalMDIManager == null)
			{
				globalMDIManager = new MDIManager(Application.application as UIComponent);
				globalMDIManager.isGlobal = true;
			}
			return MDIManager.globalMDIManager;
		}
		
		private var isGlobal:Boolean = false;
		private var windowToManagerEventMap:Dictionary;

		private var tiledWindows:ArrayCollection;
		public var tileMinimize:Boolean = true;
		public var tileMinimizeWidth:int = 200;
		public var showMinimizedTiles:Boolean = false;
		public var tilePadding:Number = 8;
		public var minTilePadding:Number = 5;
		public var enforceBoundaries:Boolean = true;
		
		public var effects:IMDIEffectsDescriptor = new MDIEffectsDescriptorBase();
		
		public static const CONTEXT_MENU_LABEL_TILE:String = "Tile";
		public static const CONTEXT_MENU_LABEL_TILE_FILL:String = "Tile + Fill";
		public static const CONTEXT_MENU_LABEL_CASCADE:String = "Cascade";
		public static const CONTEXT_MENU_LABEL_SHOW_ALL:String = "Show All Windows";
		
		/**
     	*   Contstructor()
     	*/
		public function MDIManager(container:UIComponent, effects:IMDIEffectsDescriptor = null):void
		{
			this.container = container;
			if(effects != null)
			{
				this.effects = effects;
			}
			if(tileMinimize)
			{
				tiledWindows = new ArrayCollection();
			}
			this.container.addEventListener(ResizeEvent.RESIZE, containerResizeHandler);
			
			// map of window events to corresponding manager events
			windowToManagerEventMap = new Dictionary();
			windowToManagerEventMap[MDIWindowEvent.MINIMIZE] = MDIManagerEvent.WINDOW_MINIMIZE;
			windowToManagerEventMap[MDIWindowEvent.RESTORE] = MDIManagerEvent.WINDOW_RESTORE;
			windowToManagerEventMap[MDIWindowEvent.MAXIMIZE] = MDIManagerEvent.WINDOW_MAXIMIZE;
			windowToManagerEventMap[MDIWindowEvent.CLOSE] = MDIManagerEvent.WINDOW_CLOSE;
			windowToManagerEventMap[MDIWindowEvent.FOCUS_START] = MDIManagerEvent.WINDOW_FOCUS_START;
			windowToManagerEventMap[MDIWindowEvent.FOCUS_END] = MDIManagerEvent.WINDOW_FOCUS_END;
			windowToManagerEventMap[MDIWindowEvent.DRAG_START] = MDIManagerEvent.WINDOW_DRAG_START;
			windowToManagerEventMap[MDIWindowEvent.DRAG] = MDIManagerEvent.WINDOW_DRAG;
			windowToManagerEventMap[MDIWindowEvent.DRAG_END] = MDIManagerEvent.WINDOW_DRAG_END;
			windowToManagerEventMap[MDIWindowEvent.RESIZE_START] = MDIManagerEvent.WINDOW_RESIZE_START;
			windowToManagerEventMap[MDIWindowEvent.RESIZE] = MDIManagerEvent.WINDOW_RESIZE;
			windowToManagerEventMap[MDIWindowEvent.RESIZE_END] = MDIManagerEvent.WINDOW_RESIZE_END;
			
			// these handlers execute default behaviors, these events are dispatched by this class
			addEventListener(MDIManagerEvent.WINDOW_ADD, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_MINIMIZE, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_RESTORE, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_MAXIMIZE, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_CLOSE, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
						
			addEventListener(MDIManagerEvent.WINDOW_FOCUS_START, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_FOCUS_END, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_DRAG_START, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_DRAG, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_DRAG_END, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_RESIZE_START, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_RESIZE, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.WINDOW_RESIZE_END, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			
			addEventListener(MDIManagerEvent.CASCADE, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
			addEventListener(MDIManagerEvent.TILE, executeDefaultBehavior, false, EventPriority.DEFAULT_HANDLER);
		}
		
		private var _container:UIComponent;
		public function get container():UIComponent
		{
			return _container;
		}
		public function set container(value:UIComponent):void
		{
			this._container = value;
		}
		

		/**
     	*  @private
     	*  the managed window stack
     	*/
     	[Bindable]
		public var windowList:Array = new Array();

		public function add(window:MDIWindow):void
		{
			if(windowList.indexOf(window) < 0)
			{
				window.windowManager = this;
				
				this.addListeners(window);
				
				this.windowList.push(window);
				
				this.addContextMenu(window);
				
				if(this.isGlobal)
				{
					PopUpManager.addPopUp(window,Application.application as DisplayObject);
					this.position(window);
				}
				else
				{
					// to accomodate mxml impl
					if(window.parent == null)
					{
						this.container.addChild(window);
						this.position(window);
					}
				} 		
				
				dispatchEvent(new MDIManagerEvent(MDIManagerEvent.WINDOW_ADD, window, this));
				bringToFront(window);
			}
		}
		
		/**
		 *  Positions a window on the screen 
		 *  
		 * 	<p>This is primarly used as the default space on the screen to position the window.</p>
		 * 
		 *  @param window:MDIWindow Window to position
		 */
		public function position(window:MDIWindow):void
		{	
			window.x = this.windowList.length * 30;
			window.y = this.windowList.length * 30;

			if((window.x + window.width) > container.width) window.x = 40;
			if((window.y + window.height) > container.height) window.y = 40; 	
		}
		
		public function addContextMenu(window:MDIWindow,contextMenu:ContextMenu=null):void
		{
			// add default context menu 
			if(contextMenu == null)
			{
				var defaultContextMenu:ContextMenu = new ContextMenu();
					defaultContextMenu.hideBuiltInItems();
				
				var arrangeItem:ContextMenuItem = new ContextMenuItem(CONTEXT_MENU_LABEL_TILE);
			  		arrangeItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);	
			  		defaultContextMenu.customItems.push(arrangeItem);

           	 	var arrangeFillItem:ContextMenuItem = new ContextMenuItem(CONTEXT_MENU_LABEL_TILE_FILL);
			  		arrangeFillItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);  	
			  		defaultContextMenu.customItems.push(arrangeFillItem);
                
                var cascadeItem:ContextMenuItem = new ContextMenuItem(CONTEXT_MENU_LABEL_CASCADE);
			  		cascadeItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
			  		defaultContextMenu.customItems.push(cascadeItem);
                
                var showAllItem:ContextMenuItem = new ContextMenuItem(CONTEXT_MENU_LABEL_SHOW_ALL);
			  		showAllItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
			  		defaultContextMenu.customItems.push(showAllItem);
                   	
            	this.container.contextMenu = defaultContextMenu;
			}
			else
			{	
				// add passed in context menu
				window.contextMenu = contextMenu;
			}
		}	
		
		private function menuItemSelectHandler(event:ContextMenuEvent):void
		{
			var win:MDIWindow = event.contextMenuOwner as MDIWindow;
			switch(event.target.caption)
			{	
				case(CONTEXT_MENU_LABEL_TILE):
					this.tile(false, this.tilePadding);
				break;
				
				case(CONTEXT_MENU_LABEL_TILE_FILL):
					this.tile(true, this.tilePadding);
				break;
				
				case(CONTEXT_MENU_LABEL_CASCADE):
					this.cascade();
				break;
				
				case(CONTEXT_MENU_LABEL_SHOW_ALL):
					this.showAllWindows();
				break;
			}
		}
		
		private function windowEventProxy(event:Event):void
		{
			if(event is MDIWindowEvent && !event.isDefaultPrevented())
			{
				var winEvent:MDIWindowEvent = event as MDIWindowEvent;
				var mgrEvent:MDIManagerEvent = new MDIManagerEvent(windowToManagerEventMap[winEvent.type], winEvent.window, this);
				
				switch(winEvent.type)
				{
					case MDIWindowEvent.MINIMIZE:
						
						mgrEvent.window.saveStyle();
						
						var maxTiles:int = Math.floor(this.container.width / (this.tileMinimizeWidth + this.tilePadding));
						var xPos:Number = getLeftOffsetPosition(this.tiledWindows.length, maxTiles, this.tileMinimizeWidth, this.minTilePadding);
						var yPos:Number = this.container.height - getBottomTilePosition(this.tiledWindows.length, maxTiles, mgrEvent.window.minimizeHeight, this.minTilePadding);
						var minimizePoint:Point = new Point(xPos, yPos);
						
						mgrEvent.effect = this.effects.getWindowMinimizeEffect(mgrEvent.window, this, minimizePoint);
					break;
					
					case MDIWindowEvent.RESTORE:
						mgrEvent.window.restoreStyle();
						mgrEvent.effect = this.effects.getWindowRestoreEffect(winEvent.window, this, winEvent.window.savedWindowRect);
					break;
					
					case MDIWindowEvent.MAXIMIZE:
						mgrEvent.window.restoreStyle();
						mgrEvent.effect = this.effects.getWindowMaximizeEffect(winEvent.window, this);
					break;
					
					case MDIWindowEvent.CLOSE:
						mgrEvent.effect = this.effects.getWindowCloseEffect(mgrEvent.window, this);
					break;
					
					case MDIWindowEvent.FOCUS_START:
						mgrEvent.effect = this.effects.getWindowFocusStartEffect(winEvent.window, this);
					break;
					
					case MDIWindowEvent.FOCUS_END:
						mgrEvent.effect = this.effects.getWindowFocusEndEffect(winEvent.window, this);
					break;
		
					case MDIWindowEvent.DRAG_START:
						mgrEvent.effect = this.effects.getWindowDragStartEffect(winEvent.window, this);
					break;
		
					case MDIWindowEvent.DRAG:
						mgrEvent.effect = this.effects.getWindowDragEffect(winEvent.window, this);
					break;
		
					case MDIWindowEvent.DRAG_END:
						mgrEvent.effect = this.effects.getWindowDragEndEffect(winEvent.window, this);
					break;
					
					case MDIWindowEvent.RESIZE_START:
						mgrEvent.effect = this.effects.getWindowResizeStartEffect(winEvent.window, this);
					break;
					
					case MDIWindowEvent.RESIZE:
						mgrEvent.effect = this.effects.getWindowResizeEffect(winEvent.window, this);
					break;
					
					case MDIWindowEvent.RESIZE_END:
						mgrEvent.effect = this.effects.getWindowResizeEndEffect(winEvent.window, this);
					break;
				}
				
				dispatchEvent(mgrEvent);
			}			
		}
		
		public function executeDefaultBehavior(event:Event):void
		{
			if(event is MDIManagerEvent && !event.isDefaultPrevented())
			{
				var mgrEvent:MDIManagerEvent = event as MDIManagerEvent;
				
				switch(mgrEvent.type)
				{					
					case MDIManagerEvent.WINDOW_ADD:
						// get the effect here because this doesn't pass thru windowEventProxy()
						mgrEvent.effect = this.effects.getWindowAddEffect(mgrEvent.window, this);
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.WINDOW_MINIMIZE:						
						mgrEvent.effect.addEventListener(EffectEvent.EFFECT_END, onMinimizeEffectEnd);
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.WINDOW_RESTORE:
						removeTileInstance(mgrEvent.window);
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.WINDOW_MAXIMIZE:
						removeTileInstance(mgrEvent.window);
						maximizeWindow(mgrEvent.window);
					break;
					
					case MDIManagerEvent.WINDOW_CLOSE:
						removeTileInstance(mgrEvent.window);
						mgrEvent.effect.addEventListener(EffectEvent.EFFECT_END, onCloseEffectEnd);
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.WINDOW_FOCUS_START:
						mgrEvent.window.hasFocus = true;
						mgrEvent.window.validateNow();
						container.setChildIndex(mgrEvent.window, container.numChildren - 1);
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.WINDOW_FOCUS_END:
						mgrEvent.window.hasFocus = false;
						mgrEvent.window.validateNow();
						mgrEvent.effect.play();
					break;
		
					case MDIManagerEvent.WINDOW_DRAG_START:
						mgrEvent.effect.play();
					break;
		
					case MDIManagerEvent.WINDOW_DRAG:
						mgrEvent.effect.play();
					break;
		
					case MDIManagerEvent.WINDOW_DRAG_END:
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.WINDOW_RESIZE_START:
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.WINDOW_RESIZE:
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.WINDOW_RESIZE_END:
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.CASCADE:
						// get the effect here because this doesn't pass thru windowEventProxy()
						mgrEvent.effect = this.effects.getCascadeEffect(mgrEvent.effectItems, this);
						mgrEvent.effect.play();
					break;
					
					case MDIManagerEvent.TILE:
						// get the effect here because this doesn't pass thru windowEventProxy()
						mgrEvent.effect = this.effects.getTileEffect(mgrEvent.effectItems, this);
						mgrEvent.effect.play();
					break;
				}
			}			
		}
		
		private function onMinimizeEffectEnd(event:EffectEvent):void
		{
			// if this was a composite effect (almost definitely is), we make sure a target was defined on it
			// since that is optional, we look in its first child if we don't find one
			var targetWindow:MDIWindow = event.effectInstance.target as MDIWindow;
			
			if(targetWindow == null && event.effectInstance is CompositeEffectInstance)
			{
				var compEffect:CompositeEffect = event.effectInstance.effect as CompositeEffect;
				targetWindow = Effect(compEffect.children[0]).target as MDIWindow;
			}			
			
			tiledWindows.addItem(targetWindow);
			reTileWindows();
		}
		
		private function onCloseEffectEnd(event:EffectEvent):void
		{
			remove(event.effectInstance.target as MDIWindow);
		}
				
		
		/**
		 * Handles resizing of container to reposition elements
		 * 
		 *  @param event The ResizeEvent object from event dispatch
		 * 
		 * */
		private function containerResizeHandler(event:ResizeEvent):void
		{	
			//repositions any minimized tiled windows to bottom left in their rows
			reTileWindows();
		}
		
		
		/**
		 * Gets the left placement of a tiled window
		 * 
		 *  @param tileIndex The index value of the current tile instance we're placing
		 * 
		 *  @param maxTiles The maximum number of tiles that can be placed horizontally across the container given the minimimum width of each tile
		 * 
		 *  @param minWinWidth The width of the window tile when minimized
		 * 
		 *  @param padding The padding accordance to place between minimized tile window instances
		 * 
		 * */
		private function getLeftOffsetPosition(tileIndex:int, maxTiles:int, minWinWidth:Number, padding:Number):Number
		{
			var tileModPos:int = tileIndex % maxTiles;
			if(tileModPos == 0)
				return padding;
			else
				return (tileModPos * minWinWidth) + ((tileModPos + 1) * padding);
		}
		
		
		/**
		 * Gets the bottom placement of a tiled window
		 * 
		 *  @param maxTiles The maximum number of tiles that can be placed horizontally across the container given the minimimum width of each tile
		 * 
		 *  @param minWinHeight The height of the window tile instance when minimized -- probably the height of the titleBar instance of the Panel
		 * 
		 * 	@param padding The padding accordance to place between minimized tile window instances
		 * 
		 * */
		private function getBottomTilePosition(tileIndex:int, maxTiles:int, minWindowHeight:Number, padding:Number):Number
		{
			var numRows:int = Math.floor(tileIndex / maxTiles);
			if(numRows == 0)
				return minWindowHeight + padding;
			else
				return ((numRows + 1) * minWindowHeight) + ((numRows + 1) * padding);
		}
		
		
		/**
		 * Gets the height accordance for tiled windows along bottom to be used in the maximizing of other windows -- leaves space at bottom of maximize height so tiled windows still show
		 * 
		 *  @param maxTiles The maximum number of tiles that can be placed horizontally across the container given the minimimum width of each tile
		 * 
		 *  @param minWinHeight The height of the window tile instance when minimized -- probably the height of the titleBar instance of the Panel
		 * 
		 * 	@param padding The padding accordance to place between minimized tile window instances
		 * 
		 * */
		private function getBottomOffsetHeight(maxTiles:int, minWindowHeight:Number, padding:Number):Number
		{
			var numRows:int = Math.ceil(this.tiledWindows.length / maxTiles);
			//if we have some rows get their combined heights... if not, return 0 so maximized window takes up full height of container
			if(this.tiledWindows.length != 0)
				return ((numRows) * minWindowHeight) + ((numRows + 1) * padding);
			else
				return 0;
		}
		
		/**
		 * Retiles the remaining minimized tile instances if one of them gets restored or maximized
		 * 
		 * */
		private function reTileWindows():void
		{
			var maxTiles:int = Math.floor(this.container.width / (this.tileMinimizeWidth + this.tilePadding));
			
			//we've just removed/added a row from the tiles, so we tell any maximized windows to change their height
			
			if(this.tiledWindows.length % maxTiles == 0 || (this.tiledWindows.length - 1) % maxTiles == 0)
			{
				var openWins:Array = getOpenWindowList();
				for(var winIndex:int = 0; winIndex < openWins.length; winIndex++)
				{
					if(MDIWindow(openWins[winIndex]).maximized)
						maximizeWindow(MDIWindow(openWins[winIndex]));
				}
			}
			
			for(var i:int = 0; i < tiledWindows.length; i++)
			{
				var currentWindow:MDIWindow = tiledWindows.getItemAt(i) as MDIWindow;
				var xPos:Number = getLeftOffsetPosition(i, maxTiles, this.tileMinimizeWidth, this.minTilePadding);
				var yPos:Number = this.container.height - getBottomTilePosition(i, maxTiles, currentWindow.minimizeHeight, this.minTilePadding);
				var movePoint:Point = new Point(xPos, yPos);
				this.effects.reTileMinWindowsEffect(currentWindow, this, movePoint).play();
			}	
		}
		
	
		
		/**
		 * Maximizing of Window
		 * 
		 * @param window MDIWindowinstance to maximize
		 * 
		 **/
		private function maximizeWindow(window:MDIWindow):void
		{
			var maxTiles:int = this.container.width / this.tileMinimizeWidth;
			if(showMinimizedTiles)
			{
				this.effects.getWindowMaximizeEffect(window, this, getBottomOffsetHeight(maxTiles, window.minimizeHeight, this.minTilePadding)).play();
			}
			else
			{
				this.effects.getWindowMaximizeEffect(window, this).play();
			}
		}
		

		
		/**
		 * Removes the closed window from the ArrayCollection of tiled windows
		 * 
		 *  @param event MDIWindowEvent instance containing even type and window instance that is being handled
		 * 
		 * */
		private function removeTileInstance(window:MDIWindow):void
		{
			for(var i:int = 0; i < tiledWindows.length; i++)
			{
				if(tiledWindows.getItemAt(i) == window)
				{
					this.tiledWindows.removeItemAt(i);
					reTileWindows();
				}
			}
		}


		
		public function addCenter(window:MDIWindow):void
		{
			this.add(window);
			this.center(window);
		}
		
		
		/**
		 * Brings a window to the front of the screen. 
		 * 
		 *  @param win Window to bring to front
		 * */
		public function bringToFront(window:MDIWindow):void
		{
			if(this.isGlobal)
			{
				PopUpManager.bringToFront(window as IFlexDisplayObject);
			}
			else
			{				
				for each(var win:MDIWindow in windowList)
				{
					if(win != window && win.hasFocus)
					{
						win.dispatchEvent(new MDIWindowEvent(MDIWindowEvent.FOCUS_END, win));
					}
					if(win == window && !window.hasFocus)
					{
						win.dispatchEvent(new MDIWindowEvent(MDIWindowEvent.FOCUS_START, win));
					}
				}
			}
			
		}
		
		
		/**
		 * Positions a window in the center of the available screen. 
		 * 
		 *  @param window:MDIWindow to center
		 * */
		public function center(window:MDIWindow):void
		{
			window.x = this.container.width / 2 - window.width;
			window.y = this.container.height / 2 - window.height;
		}
		
		/**
		 * Removes all windows from managed window stack; 
		 * */
		public function removeAll():void
		{	
		
			for each(var window:MDIWindow in windowList)
			{
				if(this.isGlobal)
				{
					PopUpManager.removePopUp(window as IFlexDisplayObject);
				}
				else
				{
					container.removeChild(window);
				}
				
				this.removeListeners(window);
			}
			
			this.windowList = new Array();
		}
		
		/**
		 *  @private
		 * 
		 *  Adds listeners 
		 *  @param window:MDIWindow  
		 */
		
		private function addListeners(window:MDIWindow):void
		{
			window.addEventListener(MDIWindowEvent.MINIMIZE, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.RESTORE, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.MAXIMIZE, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.CLOSE, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			
			window.addEventListener(MDIWindowEvent.FOCUS_START, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.FOCUS_END, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.DRAG_START, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.DRAG, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.DRAG_END, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.RESIZE_START, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.RESIZE, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
			window.addEventListener(MDIWindowEvent.RESIZE_END, windowEventProxy, false, EventPriority.DEFAULT_HANDLER);
		}


		/**
		 *  @private
		 * 
		 *  Removes listeners 
		 *  @param window:MDIWindow 
		 */
		private function removeListeners(window:MDIWindow):void
		{
			window.removeEventListener(MDIWindowEvent.MINIMIZE, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.RESTORE, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.MAXIMIZE, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.CLOSE, windowEventProxy);
			
			window.removeEventListener(MDIWindowEvent.FOCUS_START, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.FOCUS_END, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.DRAG_START, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.DRAG, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.DRAG_END, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.RESIZE_START, windowEventProxy);
			window.removeEventListener(MDIWindowEvent.RESIZE, windowEventProxy);	
			window.removeEventListener(MDIWindowEvent.RESIZE_END, windowEventProxy);
		}
		
		
		
		
		/**
		 *  Removes a window instance from the managed window stack 
		 *  @param window:MDIWindow Window to remove 
		 */
		public function remove(window:MDIWindow):void
		{	
			
			var index:int = ArrayUtil.getItemIndex(window, this.windowList);
			
			windowList.splice(index, 1);
			
			if(this.isGlobal)
			{
				PopUpManager.removePopUp(window as IFlexDisplayObject);
			}
			else
			{
				container.removeChild(window);
			}
			
			removeListeners(window);
			
			// set focus to newly-highest depth window
			for(var i:int = container.numChildren - 1; i > -1; i--)
			{
				var dObj:DisplayObject = container.getChildAt(i);
				if(dObj is MDIWindow)
				{
					bringToFront(MDIWindow(dObj));
					return;
				}
			}
		}				
		
		/**
		 * Pushes a window onto the managed window stack 
		 * 
		 *  @param win Window:MDIWindow to push onto managed windows stack 
		 * */
		public function manage(window:MDIWindow):void
		{	
			if(window != null)
				windowList.push(window);
		}
		
		/**
		 *  Positions a window in an absolute position 
		 * 
		 *  @param win:MDIWindow Window to position
		 * 
		 *  @param x:int The x position of the window
		 * 
		 *  @param y:int The y position of the window 
		 */
		public function absPos(window:MDIWindow,x:int,y:int):void
		{
			window.x = x;
			window.y = y;		
		}
		
		/**
		 * Gets a list of open windows for scenarios when only open windows need to be managed
		 * 
		 * @return Array
		 */
		public function getOpenWindowList():Array
		{	
			var array:Array = [];
			for(var i:int = 0; i < windowList.length; i++)
			{
				if(!MDIWindow(windowList[i]).minimized)
				{
					array.push(windowList[i]);
				}
			}
			return array;
		}
		
		/**
		 *  Tiles the window across the screen
		 *  
		 *  <p>By default, windows will be tiled to all the same size and use only the space they can accomodate.
		 *  If you set fillAvailableSpace = true, tile will use all the space available to tile the windows with
		 *  the windows being arranged by varying heights and widths. 
     	 *  </p>
		 * 
		 *  @param fillAvailableSpace:Boolean Variable to determine whether to use the fill the entire available screen
		 * 
		 */
		public function tile(fillAvailableSpace:Boolean = false,gap:Number = 0):void
		{			
			var openWinList:Array = getOpenWindowList();
				
			var numWindows:int = openWinList.length;
			
			if(numWindows == 1)
			{
				MDIWindow(openWinList[0]).maximizeRestore();
			}
			else if(numWindows > 1)
			{
				var sqrt:int = Math.round(Math.sqrt(numWindows));
				var numCols:int = Math.ceil(numWindows / sqrt);
				var numRows:int = Math.ceil(numWindows / numCols);
				var col:int = 0;
				var row:int = 0;
				var availWidth:Number = this.container.width;
				var availHeight:Number = this.container.height
				
				if(showMinimizedTiles)
					availHeight = availHeight - getBottomOffsetHeight(this.tiledWindows.length, openWinList[0].minimizeHeight, this.minTilePadding);
					
				var targetWidth:Number = availWidth / numCols - ((gap * (numCols - 1)) / numCols);
				var targetHeight:Number = availHeight / numRows - ((gap * (numRows - 1)) / numRows);
				
				var effectItems:Array = [];
					
				for(var i:int = 0; i < openWinList.length; i++)
				{
					
					var win:MDIWindow = openWinList[i];
					
					bringToFront(win)
					
					var item:MDIGroupEffectItem = new MDIGroupEffectItem(win);
					
					item.widthTo = targetWidth;
					item.heightTo = targetHeight;

					if(i % numCols == 0 && i > 0)
					{
						row++;
						col = 0;
					}
					else if(i > 0)
					{
						col++;
					}
	
					item.moveTo = new Point((col * targetWidth), (row * targetHeight)); 
			
					//pushing out by gap
					if(col > 0) 
						item.moveTo.x += gap * col;
					
					if(row > 0) 
						item.moveTo.y += gap * row;
	
					effectItems.push(item);
	
				}
				
	
				if(col < numCols && fillAvailableSpace)
				{
					var numOrphans:int = numWindows % numCols;
					var orphanWidth:Number = availWidth / numOrphans - ((gap * (numOrphans - 1)) / numOrphans);
					//var orphanWidth:Number = availWidth / numOrphans;
					var orphanCount:int = 0
					for(var j:int = numWindows - numOrphans; j < numWindows; j++)
					{
						//var orphan:MDIWindow = openWinList[j];
						var orphan:MDIGroupEffectItem = effectItems[j];
						
						orphan.widthTo = orphanWidth;
						//orphan.window.width = orphanWidth;
						
						orphan.moveTo.x = (j - (numWindows - numOrphans)) * orphanWidth;
						if(orphanCount > 0) 
							orphan.moveTo.x += gap * orphanCount;
						orphanCount++;
					}
				} 
				
				dispatchEvent(new MDIManagerEvent(MDIManagerEvent.TILE, null, this, null, effectItems));
			}
		}
		
		// set a min. width/height
		public function resize(window:MDIWindow):void
		{		
			var w:int = this.container.width * .6;
			var h:int = this.container.height * .6
			if(w > window.width)
				window.width = w;
			if(h > window.height)
				window.height=h;
		}
		
		
		
		/**
		 *  Cascades all managed windows from top left to bottom right 
		 * 
		 */	
		public function cascade():void
		{
			var effectItems:Array = [];
			
			var windows:Array = getOpenWindowList();
			var xIndex:int = 0;
			var yIndex:int = -1;
			
			for(var i:int = 0; i < windows.length; i++)
			{
				var window:MDIWindow = windows[i] as MDIWindow;
				
				bringToFront(window);
				
				var item:MDIGroupEffectItem = new MDIGroupEffectItem(window);
				item.widthFrom = window.width;
				item.widthTo = container.width * .5;
				item.heightFrom = window.height;
				item.heightTo = container.height * .5;
				
				if(yIndex * 40 + item.heightTo + 25 >= container.height)
				{
					yIndex = 0;
					xIndex++;
				}
				else
				{
					yIndex++;
				}
				
				var destX:int = xIndex * 40 + yIndex * 20;
				var destY:int = yIndex * 40;
				item.moveTo = new Point(destX, destY);
					
				effectItems.push(item);
			}
			
			dispatchEvent(new MDIManagerEvent(MDIManagerEvent.CASCADE, null, this, null, effectItems));
		}
		
		
		public function showAllWindows():void
		{
			// this prevents retiling of windows yet to be unMinimized()
			tiledWindows.removeAll();			
			
			for each(var window:MDIWindow in windowList)
			{
				if(window.minimized)
				{
					window.unMinimize();
				}
			}
		}	
	}
}