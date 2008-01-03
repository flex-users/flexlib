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
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;

	[IconFile("DragScrollingCanvas.png")]
	
	/**
	 * <code>DragScrollingCanvas</code> is a Canvas component that allows the user to drag
	 * the contents instead of or in addition to using the scrollbars. There is only one
	 * additional property, childrenDoDrag, which is a Boolean indicating whether or not
	 * a mouse down event on a child component will trigger the dragging.
	 */
	public class DragScrollingCanvas extends Canvas
	{
		
		/**
	     *  @private
	     *  Horizontal location where the user pressed the mouse button
	     *  on the canvas to start dragging.
	     */
	    private var regX:Number;
	    
	    /**
	     *  @private
	     *  Vertical location where the user pressed the mouse button
	     *  on the canvas to start dragging.
	     */
	    private var regY:Number;
	    
	    /**
	     *  @private
	     *  Horizontal scroll position when the user pressed the mouse
	     *  button on the canvas to start dragging.
	     */
	    private var regHScrollPosition:Number;
	    
	    /**
	     *  @private
	     *  Vertical scroll position when the user pressed the mouse
	     *  button on the canvas to start dragging.
	     */
	    private var regVScrollPosition:Number;
	    
	    /**
	     *  @private
	     *  Private boolean to indicate whether mouse events on the child 
	     *  components should trigger dragging.
	     */
	    private var _childrenDoDrag:Boolean = true;
	    
	    /**
	     *  Boolean to indicate whether the mouse events on the child components
	     *  should trigger the dragging. If true, any mouse down events will trigger
	     *  dragging, even if these events happen on a child, like a Button. If set to
	     *  false then only mouse down events directly on the canvas will trigger
	     *  dragging.
	     *
	     *  @default true
	     */
	    public function get childrenDoDrag():Boolean {
	    	return this._childrenDoDrag;
	    }
	    
	    /**
	     *  @private
	     */
	    public function set childrenDoDrag(value:Boolean):void {
	    	this._childrenDoDrag = value;
	    }
	    
		/**
     	*  @private
     	*  Create child objects.
     	*  All we do differently here is we add the mouse down listener.
     	*/
		override protected function createChildren():void {
			super.createChildren();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			
		}
		
		/**
	     * @private
	     * Private Array of children that should NOT trigger dragging
	     */
	    private var _undraggableChildren:Array=null;
	    
	    /**
	     * Array of child components that will not trigger the dragging. Only applicable if <code>childrenDoDrag</code>
	     * is true.
	     */
	    public function get undraggableChildren():Array {
	    	return _undraggableChildren;
	    }
	    
	    /**
	     * @public
	     */
	    public function set undraggableChildren(value:Array):void {
	    	_undraggableChildren = value;
	    }
	    
	    /**
	     * @private
	     */
	    private var _undraggableClasses:Array=null;
	    
	    /**
	     * Array of Classes that will not trigger the dragging. Only applicable if <code>childrenDoDrag</code>
	     * is true.
	     */
	    public function get undraggableClasses():Array {
	    	return _undraggableClasses;
	    }
	    
	    /**
	     * @public
	     */
	    public function set undraggableClasses(value:Array):void {
	    	_undraggableClasses = value;
	    }
		
		/**
		 * @private
		 * Our dragging handler. This is similar to the function found in the Panel 
		 * component, except we need to store the horizontalScrollPosition and the 
		 * verticalScrollPosition so we can update them correctly while we're dragging.
		 */
		protected function startDragging(event:MouseEvent):void
	    {
	    	
	    	// If the mouse event was from one of the scrollbars then we don't want
	    	// to allow dragging. This means we can allow the use of the scrollbars
	    	// and still do the dragging stuff.
	        if(event.target.parent == this.verticalScrollBar ||
	         	event.target.parent == this.horizontalScrollBar) {
	         		return;
	        }
	        
			if(_undraggableChildren != null)
			{
				for each(var child:* in _undraggableChildren)
				{
					if(event.target == child)
						return;
				}
			}
			
			if(_undraggableClasses != null)
			{
				for each(var testClass:Class in _undraggableClasses)
				{
					if(event.target is testClass)
						return;
				}
			}
	        
	        // If childrenDoDrag is set to true then we always do dragging on a mouse 
	        // down event, we don't care what was clicked on. If childrenDoDrag is false 
	        // then we only want to drag if we have been clicked directly.
	        if(_childrenDoDrag || event.target == this) {
	        	
	        	regX = event.stageX;
		        regY = event.stageY;
		        
		        regHScrollPosition = this.horizontalScrollPosition;
		        regVScrollPosition = this.verticalScrollPosition;
		        
		        systemManager.addEventListener(
		            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
		
		        systemManager.addEventListener(
		            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
		
		        systemManager.stage.addEventListener(
		            Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
	        }
	    }
	    
	    
	    /**
	     *  @private
	     * 
	     *  This function is basically the same as a function in the source code
	     *  for Panel, except instead of moving the component, we simply update the
	     *  verticalScrollPosition and horizontalScrollPosition values.
	     */
	    private function systemManager_mouseMoveHandler(event:MouseEvent):void
	    {
	    	// during a drag, only the Panel should get mouse move events
	    	// (e.g., prevent objects 'beneath' it from getting them -- see bug 187569)
	    	// we don't check the target since this is on the systemManager and the target
	    	// changes a lot -- but this listener only exists during a drag.
	    	event.stopImmediatePropagation();
	    	
	    	this.verticalScrollPosition = regVScrollPosition - (event.stageY - regY);
	    	this.horizontalScrollPosition = regHScrollPosition - (event.stageX - regX);
	    }
	
	    /**
	     *  @private
	     * 
	     *  This function is taken straight out of the source code for Panel.
	     */
	    private function systemManager_mouseUpHandler(event:MouseEvent):void
	    {
	        if (!isNaN(regX))
	            stopDragging();
	    }
	
	    /**
	     *  @private
	     * 
	     *  This function is taken straight out of the source code for Panel.
	     */
	    private function stage_mouseLeaveHandler(event:Event):void
	    {
	        if (!isNaN(regX))
	            stopDragging();
	    }
	    
	    /**
	     *  @private 
	     * 
	     *  This function is taken straight out of the source code for Panel.
	     */
	    protected function stopDragging():void
	    {
	        systemManager.removeEventListener(
	            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
	
	        systemManager.removeEventListener(
	            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
	
	        systemManager.stage.removeEventListener(
	            Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
	
	        regX = NaN;
	        regY = NaN;
	    }
	}
}