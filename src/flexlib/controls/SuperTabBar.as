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

package flexlib.controls {
	
	import flexlib.containers.SuperTabNavigator;
	import flexlib.controls.tabBarClasses.SuperTab;
	import flexlib.events.TabReorderEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.IList;
	import mx.containers.Canvas;
	import mx.containers.ViewStack;
	import mx.controls.Button;
	import mx.controls.TabBar;
	import mx.core.ClassFactory;
	import mx.core.DragSource;
	import mx.core.IFlexDisplayObject;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.managers.DragManager;

	
	/**
	 * Fired when a tab is dropped onto this SuperTabBar, which re-orders the tabs and updates the
	 * list of tabs.
	 */
	[Event(name="tabsReordered", type="flexlib.events.TabReorderEvent")]
	
	[IconFile("SuperTabBar.png")]
	
	/**
	 *  The SuperTabBar control extends the TabBar control and adds drag and drop functionality
	 *  and closable tabs. 
	 *  <p>The SuperTabBar is used by the SuperTabNavigator component, or it can be used on its
	 *  own to independentaly control a ViewStack. SuperTabBar does not control scrolling of tabs.
	 *  Scrolling of tabs in the SuperTabNavigator is done by wrapping the SuperTabBar in a scrollable
	 *  canvas component.</p>
	 *
	 *  @mxml
	 *
	 *  <p>The <code>&lt;flexlib:SuperTabBar&gt;</code> tag inherits all of the tag attributes
	 *  of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;flexlib:SuperTabBar
	 *    <b>Properties</b>
	 *    closePolicy="SuperTab.CLOSE_ROLLOVER|SuperTab.CLOSE_ALWAYS|SuperTab.CLOSE_SELECTED|SuperTab.CLOSE_NEVER"
	 *    dragEnabled="true"
	 *    dropEnabled="true"
	 * 
	 *    <b>Events</b>
	 *    tabsReorderEvent="<i>No default</i>"
	 *    &gt;
	 *    ...
	 *       <i>child tags</i>
	 *    ...
	 *  &lt;/flexlib:SuperTabBar&gt;
	 *  </pre>
	 *
	 *  @see flexlib.containers.SuperTabNavigator
	 * 	@see mx.controls.TabBar
	 */
	public class SuperTabBar extends TabBar{
		
		use namespace mx_internal;
		
		/**
		 * Event that is dispatched when the tabs are re-ordered in the SuperTabBar.
		 */
		public static const TABS_REORDERED:String = "tabsReordered";
		
		/**
		 * @private
		 */
		private var _dragEnabled:Boolean = true;
		
		/**
		 * Boolean indicating if this SuperTabBar allows its tabs to be dragged.
		 * <p>If both dragEnabled and dropEnabled are true then the 
		 * SuperTabBar allows tabs to be reordered with drag and drop.</p>
		 */
		public function get dragEnabled():Boolean {
			return _dragEnabled;
		}
		
		/**
		 * @private
		 */
		public function set dragEnabled(value:Boolean):void {
			this._dragEnabled = value;
			
			var n:int = numChildren;
		    for (var i:int = 0; i < n; i++)
		    {
		    	var child:SuperTab = SuperTab(getChildAt(i));
		    	
		    	if(value) {
		    		addDragListeners(child);
		    	}
		    	else {
		    		removeDragListeners(child);
		    	}
		    }
		}
		
		/**
		 * @private
		 */
		private var _dropEnabled:Boolean = true;
		
		/**
		 * Boolean indicating if this SuperTabBar allows its tabs to be dropped onto it.
		 * <p>If both dragEnabled and dropEnabled are true then the 
		 * SuperTabBar allows tabs to be reordered with drag and drop.</p>
		 */
		public function get dropEnabled():Boolean {
			return _dropEnabled;
		}
		
		/**
		 * @private
		 */
		public function set dropEnabled(value:Boolean):void {
			this._dropEnabled = value;
			
			var n:int = numChildren;
		    for (var i:int = 0; i < n; i++)
		    {
		    	var child:SuperTab = SuperTab(getChildAt(i));
		    	
		    	if(value) {
		    		addDropListeners(child);
		    	}
		    	else {
		    		removeDropListeners(child);
		    	}
		    }
		}
		
		/**
		 * @private
		 */
		private var _closePolicy:String = SuperTab.CLOSE_ROLLOVER;
		
		/**
		 * The policy for when to show the close button for each tab.
		 * <p>This is a proxy property that sets each SuperTab's closePolicy setting to
		 * whatever is set here.</p>
		 * @see flexlib.controls.tabClasses.SuperTab
		 */
		public function get closePolicy():String {
			return _closePolicy;
		}
		
		/**
		 * @private
		 */
		public function set closePolicy(value:String):void {
			this._closePolicy = value;
			this.invalidateDisplayList();
			
			var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var child:SuperTab = SuperTab(getChildAt(i));
				child.closePolicy = value;
	        }
		}
		
		public function setClosePolicyForTab(index:int, value:String):void {
			if(this.numChildren >= index + 1) {
				(getChildAt(index) as SuperTab).closePolicy = value;
			}
		}
		
		public function getClosePolicyForTab(index:int):String {
			return (getChildAt(index) as SuperTab).closePolicy;
		}
		
		/**
		 * Constructor
		 */
		public function SuperTabBar(){
			super();
			
			// we make sure that when we make new tabs they will be SuperTabs
			navItemFactory = new ClassFactory(SuperTab);
		}
		
		/**
		 * @private
		 */
		override protected function createNavItem(
										label:String,
										icon:Class = null):IFlexDisplayObject{
											
			var tab:SuperTab = super.createNavItem(label,icon) as SuperTab;
			
			tab.closePolicy = this.closePolicy;
			
			if(dragEnabled) {
				addDragListeners(tab);
			}
			
			if(dropEnabled) {
				addDropListeners(tab);
			}
			
			// We need to listen for the close event fired from each tab.
			tab.addEventListener(SuperTab.CLOSE_TAB_EVENT, onCloseTabClicked, false, 0, true);
			
			return tab;
		}
		
		/**
		 * @private
		 */
		private function addDragListeners(tab:SuperTab):void {
			tab.addEventListener(MouseEvent.MOUSE_DOWN, tryDrag, false, 0, true);
			tab.addEventListener(MouseEvent.MOUSE_UP, removeDrag, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function removeDragListeners(tab:SuperTab):void {
			tab.removeEventListener(MouseEvent.MOUSE_DOWN, tryDrag);
			tab.removeEventListener(MouseEvent.MOUSE_UP, removeDrag);
		}
		
		/**
		 * @private
		 */
		private function addDropListeners(tab:SuperTab):void {
			tab.addEventListener(DragEvent.DRAG_ENTER, tabDragEnter, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_OVER, tabDragOver, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_DROP, tabDragDrop, false, 0, true);
			tab.addEventListener(DragEvent.DRAG_EXIT, tabDragExit, false, 0, true);	
		}
		
		/**
		 * @private
		 */
		private function removeDropListeners(tab:SuperTab):void {
			tab.removeEventListener(DragEvent.DRAG_ENTER, tabDragEnter);
			tab.removeEventListener(DragEvent.DRAG_OVER, tabDragOver);
			tab.removeEventListener(DragEvent.DRAG_DROP, tabDragDrop);
			tab.removeEventListener(DragEvent.DRAG_EXIT, tabDragExit);	
		}
		
		/**
		 * @private
		 */
		private function tryDrag(e:MouseEvent):void{
			e.target.addEventListener(MouseEvent.MOUSE_MOVE, doDrag);
		}
		
		/**
		 * @private
		 */
		private function removeDrag(e:MouseEvent):void{
			e.target.removeEventListener(MouseEvent.MOUSE_MOVE,doDrag);
		}
		
		/**
		 * @private
		 * 
		 * When a tab closes it dispatches a close event. This listener gets fired in response
		 * to that event. We remove the tab from the dataProvider. This might be as simple as removing
		 * the tab, but the dataProvider might be a ViewStack, which means we remove the entire child
		 * from the dataProvider (which removes it from the ViewStack).
		 */
		public function onCloseTabClicked(event:Event):void{
			var index:int = getChildIndex(DisplayObject(event.currentTarget));
			if(dataProvider is IList){
				dataProvider.removeItemAt(index);
			}
			else if(dataProvider is ViewStack){
				dataProvider.removeChildAt(index);
			}
		}
		
		/**
		 * @private
		 */
		private function doDrag(event:MouseEvent):void{
			if(event.target is IUIComponent && (IUIComponent(event.target) is SuperTab || (IUIComponent(event.target).parent is SuperTab && !(IUIComponent(event.target) is Button)))) {
				
				var tab:SuperTab;
				
				if(IUIComponent(event.target) is SuperTab) {
					tab = IUIComponent(event.target) as SuperTab;
				}
				
				if(IUIComponent(event.target).parent is SuperTab) {
					tab = IUIComponent(event.target).parent as SuperTab;
				}
				
				var ds:DragSource = new DragSource();
				ds.addData(event.currentTarget,'tabDrag');
				
				if(dataProvider is IList) {
					ds.addData(event.currentTarget,'listDP');	
				}
				
				if(dataProvider is ViewStack) {
					ds.addData(event.currentTarget,'stackDP');	
				}
				
				var bmapData:BitmapData = new BitmapData(tab.width, tab.height, true, 0x00000000);
				bmapData.draw(tab);
				var dragProxy:Bitmap = new Bitmap(bmapData); 
				
				var obj:UIComponent = new UIComponent();
				obj.addChild(dragProxy);
				
				event.target.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
				
				DragManager.doDrag(IUIComponent(event.target),ds,event,obj);	
			}					
		}
		
		/**
		 * @private
		 */
		private function tabDragEnter(event:DragEvent):void{
			
			if(event.dragSource.hasFormat('tabDrag') && event.draggedItem != event.dragInitiator){
				if(this.dataProvider is ViewStack) {
					if(event.dragSource.hasFormat("stackDP")) {
						DragManager.acceptDragDrop(IUIComponent(event.target));
					}	
				}
				else if(this.dataProvider is IList) {
					if(event.dragSource.hasFormat("listDP")) {
						DragManager.acceptDragDrop(IUIComponent(event.target));
					}
				}

			}
		}
		
		/**
		 * @private
		 */
		private function tabDragOver(event:DragEvent):void{
			// We should accept tabs dragged onto other tabs, but not a tab dragged onto itself
			if(event.dragSource.hasFormat('tabDrag') && event.dragInitiator != event.currentTarget){
				
				var dropTab:SuperTab = (event.currentTarget as SuperTab);
				var dropIndex:Number = this.getChildIndex(dropTab);
				
				// gap is going to be the indicatorOffset that will be used to place the indicator
				var gap:Number = 0;
				
				// We need to figure out if we're on the left half or right half of the
				// tab. This boolean tells us this so we know where to draw the indicator
				var left:Boolean = event.localX < dropTab.width/2;
				
				if((left && dropIndex > 0) 
					|| (dropIndex < this.numChildren - 1) ) {
					gap = this.getStyle("horizontalGap")/2;
				}
				
				gap = left ? -gap : dropTab.width + gap;
				
				dropTab.showIndicatorAt(gap);
				
				DragManager.showFeedback(DragManager.LINK);
			}
		}
		
		/**
		 * @private
		 */
		private function tabDragExit(event:DragEvent):void{
			var dropTab:SuperTab = (event.currentTarget as SuperTab);
			// turn off showing the indicator icon
			dropTab.showIndicator = false;
		}
		
		/**
		 * @private
		 */
		private function tabDragDrop(event:DragEvent):void{
			if(event.dragSource.hasFormat('tabDrag') && event.draggedItem != event.dragInitiator){
			
				var dropTab:SuperTab = (event.currentTarget as SuperTab);
				var dragTab:SuperTab = (event.dragInitiator as SuperTab);
				
				var left:Boolean = event.localX < dropTab.width/2;
				
				//var parentNavigator:SuperTabNavigator;
				var parentBar:SuperTabBar;
				
				// Since we allow mouseChildren to enabled the close button we might
				// get drag and drop events fired from the children components (ie the label
				// or icon). So we need to find the SuperTab object, SuperTabBar, and the 
				// SuperTabNavigator object from wherever we might be down the chain of children.
				var object:* = event.dragInitiator;
				while(object && object.parent) {
					object = object.parent;
					
					if(object is SuperTab) {
						dragTab = object;
					}
					else if(object is SuperTabBar) {
						parentBar = object;
						break;
					}
					/*
					else if(object is SuperTabNavigator) {
						parentNavigator = object as SuperTabNavigator;
						break;
					}*/
				}
				
				// We've done the drop so no need to show the indicator anymore	
				dropTab.showIndicator = false;
				
				var oldIndex:Number = parentBar.getChildIndex(dragTab);
				
				var newIndex:Number = this.getChildIndex(dropTab);
				if(!left) {
					newIndex += 1;
				}
				
				this.dispatchEvent(new TabReorderEvent(SuperTabBar.TABS_REORDERED, false, false, parentBar, oldIndex, newIndex));
			}	
			
		}
		
		public function resetTabs():void {
			this.resetNavItems();
		}
		
	}
}