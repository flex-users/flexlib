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

package flexlib.controls
{
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.core.EdgeMetrics;
	import mx.core.IContainer;
	import mx.core.IFlexDisplayObject;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponentDescriptor;
	import mx.core.mx_internal;
	
	use namespace mx_internal;

	/**
	 * A Button control that allows you to add any UI components to the Button via MXML.
	 * 
	 * <p>The CanvasButton is an extension of Button that lets you set the contents of the Button
	 * to any UI components, as opposed to only a single icon and label like the normal Button control
	 * allows.</p>
	 * 
	 * <p>
	 * Example usage:
	 * <pre>
	 * &lt;flexlib:CanvasButton width="150" &gt;
	 *		&lt;mx:VBox height="100%" width="100%" verticalGap="0"&gt;
	 * 			&lt;mx:Label text="This is a" width="100%" textAlign="left" /&gt;
	 * 			&lt;mx:Label text="crazy" textAlign="center" fontSize="20" fontStyle="italic" fontWeight="bold" width="100%" /&gt;
	 * 			&lt;mx:Label text="button!" width="100%" textAlign="right" /&gt;
	 *		&lt;/mx:VBox&gt;
	 * &lt;/flexlib:CanvasButton&gt;
	 * </pre>
	 * </p>
	 * 
	 * @see mx.controls.Button
	 */
	public class CanvasButton extends Button implements IContainer
	{
		/**
		 * @private 
		 * 
		 * The internal canvas that's going to hold all the child components.
		 */
		private var canvas:Canvas;
		
		public function CanvasButton():void {
			super();
		}
		
		private var _childrenCreated:Boolean = false;
		
		override protected function createChildren():void {
			super.createChildren();
			
			//create our canvas and add it to the display list
			canvas = new Canvas();
			canvas.verticalScrollPolicy = _verticalScrollPolicy;
			canvas.horizontalScrollPolicy = _horizontalScrollPolicy;
			canvas.mouseChildren = super.mouseChildren;
			canvas.buttonMode = super.buttonMode;
			super.addChild(canvas);
			
			canvas.initializeRepeaterArrays(this);
			
			//if child components have been specified in MXML then we need 
			//to add them all now
			createComponents();
			
			//mouseChildren = true;
			
			_childrenCreated = true;	
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			//make sure our wrapper canvas is the right size
			canvas.setActualSize(unscaledWidth, unscaledHeight);
		}
		
		override protected function measure():void {
			super.measure();
			
			// we're using the canvas size as our measured height and width, instead of
			// the normal button measure sizes, which measures the icon and textfield for the label.
			// For this component we'll ignore the textfield and icon.
			measuredHeight = canvas.getExplicitOrMeasuredHeight();
			measuredWidth = canvas.getExplicitOrMeasuredWidth();
		}
    	
    	/**
    	 * @private
    	 */
    	override mx_internal function layoutContents(unscaledWidth:Number,
                                        unscaledHeight:Number,
                                        offset:Boolean):void
        {
        	super.layoutContents(unscaledWidth, unscaledHeight, offset);
        	
        	//gotta make sure the canvas is above the skin
        	setChildIndex(canvas, numChildren - 1);
        }
    	
    	
		
		/**
		 * @private
		 * 
		 * Array to hold the UIComponentDescriptor objects that get set since this component implements IContainer.
		 * These will get added the our wrapper canvas once it gets created.
		 */
		private var _childDescriptors:Array;
		
		/**
		 * Since this class implements IContainer, when it is created it's parent container will set
		 * the childDescriptors property with UIComponentDescriptor objects. These are used to create 
		 * the child components that are set in MXML.
		 */
		
		public function set childDescriptors(value:Array):void {
			_childDescriptors = value;
		}
		
		mx_internal function setDocumentDescriptor(desc:UIComponentDescriptor):void {
			
			if (_documentDescriptor && _documentDescriptor.properties.childDescriptors) {
            	if (desc.properties.childDescriptors) {
                	throw new Error("Multiple sets of visual children have been specified for this component (base component definition and derived component definition).");
				}
			} else {
				_documentDescriptor = desc;
				_documentDescriptor.document = this;
			}
                   
            if(desc.properties.childDescriptors) {
				this.childDescriptors = desc.properties.childDescriptors; 
			}
		}
		
		/**
		 * @private
		 * 
		 * Calls createComponentFromDescriptor() on the canvas component and passes all the UIComponentDescriptor objects
		 * that have been set.
		 */
		private function createComponents():void {
			for each(var desc:UIComponentDescriptor in _childDescriptors) {
				canvas.createComponentFromDescriptor(desc, true);
			}
		}
		
		private var _horizontalScrollPolicy:String = ScrollPolicy.AUTO;
	    
		public function get horizontalScrollPolicy():String
	    {
	        return _horizontalScrollPolicy;
	    }
	
	    /**
	     *  @private
	     */
	    public function set horizontalScrollPolicy(value:String):void
	    {
	        _horizontalScrollPolicy = value;
	        
	        if(canvas)
	        	canvas.horizontalScrollPolicy = value;
	    }
	    
	    private var _verticalScrollPolicy:String = ScrollPolicy.AUTO;
	    
	    public function get verticalScrollPolicy():String
	    {
	        return _verticalScrollPolicy;
	    }
	
	    /**
	     *  @private
	     */
	    public function set verticalScrollPolicy(value:String):void
	    {
	        _verticalScrollPolicy = value;
	        
	        if(canvas)
	        	canvas.verticalScrollPolicy = value;
	    }
		public override function get buttonMode():Boolean{
			return super.buttonMode;
		}
		public override function set buttonMode(value:Boolean):void{
			super.buttonMode = value;
			if(canvas) canvas.buttonMode = value;
		}
		public override function get mouseChildren():Boolean{
			return super.mouseChildren;
		}
		public override function set mouseChildren(enable:Boolean):void{
			super.mouseChildren = enable;
			if(canvas) canvas.mouseChildren = enable;
		}
 		//+HAS - Stubs for Flex 3 Beta 3
		protected var _creatingContentPane:Boolean;
		public function get creatingContentPane():Boolean{
			return this._creatingContentPane
		}
		public function set creatingContentPane(value:Boolean):void{
			this._creatingContentPane = value;
		}
		protected var _defaultButton:IFlexDisplayObject;
		public function get defaultButton():IFlexDisplayObject{
			return this._defaultButton;
		}
		public function set defaultButton(value:IFlexDisplayObject):void{
			this._defaultButton = value;
		}
		protected var _horizontalScrollPosition:Number;
		public function get horizontalScrollPosition():Number{
			return this._horizontalScrollPosition;
		}
		public function set horizontalScrollPosition(value:Number):void{
			this._horizontalScrollPosition = value;
		}
		protected var _verticalScrollPosition:Number;
		public function get verticalScrollPosition():Number{
			return this._verticalScrollPosition;
		}
		public function set verticalScrollPosition(value:Number):void{
			this._verticalScrollPosition = value;
		}
		protected var _viewMetrics:EdgeMetrics;
		public function get viewMetrics():EdgeMetrics{
			return this._viewMetrics;
		}
		public function set viewMetrics(value:EdgeMetrics):void{
			this._viewMetrics = value;
		}
	}
}