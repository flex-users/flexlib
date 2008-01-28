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
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.core.ScrollPolicy;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	
	[Style(name="buttonWidth", type="Number", inherit="no")]
	
	[Style(name="leftButtonStyleName", type="String", inherit="no")]
	[Style(name="rightButtonStyleName", type="String", inherit="no")]
	[Style(name="upButtonStyleName", type="String", inherit="no")]
	[Style(name="downButtonStyleName", type="String", inherit="no")]
	
	[IconFile("ButtonScrollingCanvas.png")]
	
	public class ButtonScrollingCanvas extends Canvas
	{
		[Embed (source="../assets/assets.swf", symbol="up_arrow")]
		private static var DEFAULT_UP_BUTTON:Class;
		
		[Embed (source="../assets/assets.swf", symbol="down_arrow")]
		private static var DEFAULT_DOWN_BUTTON:Class;
		
		[Embed (source="../assets/assets.swf", symbol="left_arrow")]
		private static var DEFAULT_LEFT_BUTTON:Class;
		
		[Embed (source="../assets/assets.swf", symbol="right_arrow")]
		private static var DEFAULT_RIGHT_BUTTON:Class;
		
		private var leftButton:Button;
		private var rightButton:Button;
		private var upButton:Button;
		private var downButton:Button;
		
		private var _explicitButtonHeight:Number;
		
		private var innerCanvas:Canvas;
		
		private var timer:Timer;
		
		public var scrollSpeed:Number = 10;
	   	public var scrollJump:Number = 10;
		
		private var _childrenCreated:Boolean = false;
		
		private var _startScrollingEvent:String = MouseEvent.MOUSE_DOWN;
		
		public function get startScrollingEvent():String {
			return this._startScrollingEvent;
		}
		
		public function set startScrollingEvent(value:String):void {
			if(_childrenCreated) {
				removeListeners(_startScrollingEvent);
				addListeners(value);
			}
			_startScrollingEvent = value;
			
		}
		
		private var _stopScrollingEvent:String = MouseEvent.MOUSE_UP;
		
		public function get stopScrollingEvent():String {
			return this._stopScrollingEvent;
		}
		
		public function set stopScrollingEvent(value:String):void {
			_stopScrollingEvent = value;
		}
		
		public static var DEFAULT_BUTTON_WIDTH:Number = 50;
		
		public function ButtonScrollingCanvas()
		{ 
			super();
		}
		
		
		/**
		 * @private
		 */
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("ButtonScrollingCanvas");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.upButtonStyleName = "upButton";
				this.downButtonStyleName = "downButton";
				this.leftButtonStyleName = "leftButton";
				this.rightButtonStyleName = "rightButton";
			}
			
			StyleManager.setStyleDeclaration("ButtonScrollingCanvas", selector, false);
			
			
			
			// Style for the left arrow for tab scrolling
			var upStyleName:String = selector.getStyle("upButtonStyleName");
			var upSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + upStyleName);
			
			if(!upSelector)
			{
				upSelector = new CSSStyleDeclaration();
			}
			
			upSelector.defaultFactory = function():void
			{
				this.icon = DEFAULT_UP_BUTTON;	
				this.fillAlphas = [1,1,1,1];
				this.cornerRadius = 0;	
			}
			
			StyleManager.setStyleDeclaration("." + upStyleName, upSelector, false);
			
			// Style for the down arrow button
			var downStyleName:String = selector.getStyle("downButtonStyleName");
			var downSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + downStyleName);
			
			if(!downSelector)
			{
				downSelector = new CSSStyleDeclaration();
			}
			
			downSelector.defaultFactory = function():void
			{
				this.icon = DEFAULT_DOWN_BUTTON;	
				this.fillAlphas = [1,1,1,1];
				this.cornerRadius = 0;	
			}
			
			StyleManager.setStyleDeclaration("." + downStyleName, downSelector, false);
			
			// Style for the left arrow button
			var leftStyleName:String = selector.getStyle("leftButtonStyleName");
			var leftSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + leftStyleName);
			
			if(!leftSelector)
			{
				leftSelector = new CSSStyleDeclaration();
			}
			
			leftSelector.defaultFactory = function():void
			{
				this.icon = DEFAULT_LEFT_BUTTON;	
				this.fillAlphas = [1,1,1,1];
				this.cornerRadius = 0;	
			}
			
			StyleManager.setStyleDeclaration("." + leftStyleName, leftSelector, false);
			
			// Style for the right arrow button
			var rightStyleName:String = selector.getStyle("rightButtonStyleName");
			var rightSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + rightStyleName);
			
			if(!rightSelector)
			{
				rightSelector = new CSSStyleDeclaration();
			}
			
			rightSelector.defaultFactory = function():void
			{
				this.icon = DEFAULT_RIGHT_BUTTON;	
				this.fillAlphas = [1,1,1,1];
				this.cornerRadius = 0;	
			}
			
			StyleManager.setStyleDeclaration("." + rightStyleName, rightSelector, false);
			
		}
		
		initializeStyles();
		
		override public function initialize():void {
			super.initialize();
			
			//initialize the default styles
			ButtonScrollingCanvas.initializeStyles();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			timer = new Timer(scrollSpeed);
			
			// We have 4 buttons for each side of the conainter
			leftButton = new Button();
			rightButton = new Button();
			upButton = new Button();
			downButton = new Button();
			
			leftButton.styleName = getStyle("leftButtonStyleName");
			rightButton.styleName = getStyle("rightButtonStyleName");
			upButton.styleName = getStyle("upButtonStyleName");
			downButton.styleName = getStyle("downButtonStyleName");
			
			// this is the main canvas component, we tell it to
			// never show the scrollbars since we're controlling them
			// on our own
			innerCanvas = new Canvas();
			innerCanvas.document = this.document;
			innerCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
			innerCanvas.verticalScrollPolicy = ScrollPolicy.OFF;
			innerCanvas.clipContent = true;
	        
	        // Since the createChild method can get called after children have 
	        // already been added to the Canvas, we have to swap any children
	        // that have already been added into the innerCanvas	
			while(this.numChildren > 0) {
				innerCanvas.addChild(this.removeChildAt(0));
			}
			
			// Add the innerCanvas and all the buttons to rawChildren
			rawChildren.addChild(innerCanvas);
			rawChildren.addChild(leftButton);
			rawChildren.addChild(rightButton);
			rawChildren.addChild(upButton);
			rawChildren.addChild(downButton);
		
			_childrenCreated = true;
				
			// and of course we listen for mouseover events on our buttons.
			// if you wanted to use mousedown instead you would change these lines
			addListeners(_startScrollingEvent);
		}
		
		private function addListeners(eventString:String):void {
			leftButton.addEventListener(eventString, startScrollingLeft, false, 0, true);
			rightButton.addEventListener(eventString, startScrollingRight, false, 0, true); 
			upButton.addEventListener(eventString, startScrollingUp, false, 0, true); 
			downButton.addEventListener(eventString, startScrollingDown, false, 0, true); 	
		}
		
		private function removeListeners(eventString:String):void {
			leftButton.removeEventListener(eventString, startScrollingLeft);
			rightButton.removeEventListener(eventString, startScrollingRight); 
			upButton.removeEventListener(eventString, startScrollingUp); 
			downButton.removeEventListener(eventString, startScrollingDown); 	
		}
		
		/**
		 * If we have already created the innerCanvas element, then we add the child to
		 * that. If not, that means we haven't called createChildren yet. So what we do
		 * is add the child to this main Canvas, and once we call createChildren we'll
		 * remove all the children and switch them over to innerCanvas.
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			if(_childrenCreated) {
				return innerCanvas.addChild(child);
			}
			else {
				return super.addChild(child);
			}
		}
		
		override public function get horizontalScrollPosition():Number {
			return innerCanvas.horizontalScrollPosition;
		}
		
		override public function set horizontalScrollPosition(value:Number):void {
			innerCanvas.horizontalScrollPosition = value;
			
			callLater(enableOrDisableButtons);
		}
		
		override public function get verticalScrollPosition():Number {
			return innerCanvas.verticalScrollPosition;
		}
		
		override public function set verticalScrollPosition(value:Number):void {
			innerCanvas.verticalScrollPosition = value;
			
			callLater(enableOrDisableButtons);
		}
		
		override public function get maxHorizontalScrollPosition():Number {
			return innerCanvas.maxHorizontalScrollPosition;
		}
		
		override public function get maxVerticalScrollPosition():Number {
			return innerCanvas.maxVerticalScrollPosition;
		}
		
		public function get buttonWidth():Number {
			var s:Number = getStyle("buttonWidth");
			if(s) return s;
			
			
			return ButtonScrollingCanvas.DEFAULT_BUTTON_WIDTH;
		}
		public function set buttonWidth(value:Number):void {
			this.setStyle("buttonWidth", value);
			invalidateDisplayList();
		}
		
		public function set explicitButtonHeight(value:Number):void {
			this._explicitButtonHeight = value;
			invalidateDisplayList();
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			innerCanvas.setActualSize(unscaledWidth, unscaledHeight);
			
			positionButtons(unscaledWidth, unscaledHeight);
			
			//when compiled against Flex 3 SDK the call to enableOrDisableButtons happens before
			//the scroll properties (horizontalScrolLPosition and maxHorizontalScrollPosittion) are set on
			//inner Canvas, so we do callLater instead. I'm not sure what changed from Flex 2-3 SDK to cause this, 
			//but hey, it seems to work using callLater, so there we go
			callLater(enableOrDisableButtons);
		}
		
		private function positionButtons(unscaledWidth:Number, unscaledHeight:Number):void {
			var buttonWidth:Number = this.buttonWidth;
			
			var buttonHeight:Number = _explicitButtonHeight ? _explicitButtonHeight : unscaledHeight; 
			
			
			leftButton.move(0, 0);
			leftButton.setActualSize(buttonWidth, buttonHeight);
			
			rightButton.move(unscaledWidth - buttonWidth, 0);
			rightButton.setActualSize(buttonWidth, buttonHeight);
			
			upButton.move(buttonWidth, 0);
			downButton.move(buttonWidth, unscaledHeight - buttonWidth);
			upButton.setActualSize(unscaledWidth - buttonWidth*2, buttonWidth);
			downButton.setActualSize(unscaledWidth - buttonWidth*2, buttonWidth);
		}
		
		
		
		
		private function startScrollingLeft(event:Event):void {
	    	if(!(event.currentTarget as Button).enabled) return;
	    	
			startScrolling(scrollLeft, event.currentTarget as Button);
	    }
	    
	    private function startScrollingRight(event:Event):void {
	    	if(!(event.currentTarget as Button).enabled) return;
	    	
			startScrolling(scrollRight, event.currentTarget as Button);
	    }
	    
	    private function startScrollingUp(event:Event):void {
	    	if(!(event.currentTarget as Button).enabled) return;
	    	
			startScrolling(scrollUp, event.currentTarget as Button);
	    }
	    
	    private function startScrollingDown(event:Event):void {
	    	if(!(event.currentTarget as Button).enabled) return;
	    	
	    	startScrolling(scrollDown, event.currentTarget as Button);
	    }
	    
	    private function startScrolling(scrollFunction:Function, button:Button):void {
	    	if(_stopScrollingEvent == MouseEvent.MOUSE_UP) {
	    		stage.addEventListener(_stopScrollingEvent, stopScrolling);
	    	}
	    	else {
	    		button.addEventListener(_stopScrollingEvent, stopScrolling);
	    	}
	    	
	    	if(timer.running) {
				timer.stop();
			}
			
			timer = new Timer(this.scrollSpeed);
			timer.addEventListener(TimerEvent.TIMER, scrollFunction);
			
			timer.start();
	    }
	    
	    private function stopScrolling(event:Event):void {
	    	if(timer.running) {
				timer.stop();
			}
	    }
	    
	    private function scrollLeft(event:TimerEvent):void {
	    	innerCanvas.horizontalScrollPosition -= scrollJump;
	    	enableOrDisableButtons();
	    }
	    
	    private function scrollRight(event:TimerEvent):void {
			innerCanvas.horizontalScrollPosition += scrollJump;
			enableOrDisableButtons();
		}
		
		private function scrollUp(event:TimerEvent):void {
	    	innerCanvas.verticalScrollPosition -= scrollJump;
	    	enableOrDisableButtons();
	    }
	    
	    private function scrollDown(event:TimerEvent):void {
			innerCanvas.verticalScrollPosition += scrollJump;
			enableOrDisableButtons();
		}
	    
	   
	    /**
	     * We check to see if the buttons should be shown. If we can't scroll in
	     * one direction then we don't show that particular button.
	     */ 
	    protected function enableOrDisableButtons():void {
	    	if(this.horizontalScrollPolicy == ScrollPolicy.OFF) {
	    		leftButton.visible = rightButton.visible = leftButton.includeInLayout = rightButton.includeInLayout = false;
	    	}
	    	else {
	    		leftButton.visible = leftButton.enabled = innerCanvas.horizontalScrollPosition > 0;
	    		rightButton.visible = rightButton.enabled = innerCanvas.horizontalScrollPosition < innerCanvas.maxHorizontalScrollPosition;
	    	}
	    	
	    	if(this.verticalScrollPolicy == ScrollPolicy.OFF) {
	    		upButton.visible = downButton.visible = upButton.includeInLayout = downButton.includeInLayout = false;
	    	}
	    	else {
	    		upButton.visible = upButton.enabled = upButton.includeInLayout = innerCanvas.verticalScrollPosition > 0;
	    		downButton.visible = downButton.enabled = downButton.includeInLayout = innerCanvas.verticalScrollPosition < innerCanvas.maxVerticalScrollPosition;
	    	}
	    	
	    	positionButtons(this.width, this.height);
	    }
	    
	    override public function getChildAt(index:int):DisplayObject {
	    	return _childrenCreated ? innerCanvas.getChildAt(index) : super.getChildAt(index);
	    }
	    
	    override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
	    	if(_childrenCreated) {
	    		return innerCanvas.addChildAt(child, index);
	    	}
	    	else {
	    		return super.addChildAt(child, index);
	    	}
	    }
	    
	    override public function getChildByName(name:String):DisplayObject {
	    	return _childrenCreated ? innerCanvas.getChildByName(name) : super.getChildByName(name);
	    }
	    
	    override public function getChildIndex(child:DisplayObject):int {
	    	return _childrenCreated ? innerCanvas.getChildIndex(child) : super.getChildIndex(child);
	    }
	    
	    override public function getChildren():Array {
	    	return _childrenCreated ? innerCanvas.getChildren() : super.getChildren();
	    }
		
	}
}