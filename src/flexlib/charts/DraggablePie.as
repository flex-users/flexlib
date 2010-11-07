/*
Copyright (c) 2010 FlexLib Contributors.  See:
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
package flexlib.charts
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import flexlib.charts.utils.GeomUtils;
    
    import mx.collections.ArrayCollection;
    import mx.collections.ICollectionView;
    import mx.core.IToolTip;
    import mx.core.UIComponent;
    import mx.formatters.NumberBaseRoundType;
    import mx.formatters.NumberFormatter;
    import mx.managers.ToolTipManager;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.StyleManager;
    
    /**
     * Dispatched when the data changes according to the .
     * <code>liveDragging</code> property.
     *
     * @eventType flash.events.Event.CHANGE
     */
    [Event(name="change", type="flash.events.Event")]
    
    /**
     * Defines the color to use for the lines on the pie chart
     * 
     * @default 0x333333
     */ 
    [Style(name="lineColor", type="uint", inherit="no")]
    
    /**
     * Defines the color to use for the lines on the pie chart when the chart is disabled
     * 
     * @default 0xAAAAAA
     */ 
    [Style(name="disabledLineColor", type="uint", inherit="no")]
    
    /**
     * Defines the alpha to use for the pie chart when the chart is disabled
     * 
     * @default 0.5
     */ 
    [Style(name="disabledAlpha", type="Number", inherit="no")]
    
    /**
     * The DraggablePie is used to allow users of your application to drag around the pie slices in a pie chart.
     * <br/><br/>
     * The chart allows you to set a data provider that implements the ICollectionView interface.<br/>
     * It provides styles for its own "tooltips" as well as the typical font styles and disabled styles.
     * <br/><br/>
     * The chart is useable from MXML or from AS3.
     */ 
    public class DraggablePie extends UIComponent
    {
        private static var classConstructed:Boolean = constructStyle();
        
        private var _sum:Number;
        private var _dataProviderChanged:Boolean;
        private var _dataProvider:ICollectionView;
        
        private var _numDecimals:Number;
        private var _sensitivityAngle:Number;
        
        /**
         * An ordered array of the angles of all edges in the pie chart
         */ 
        protected var angles:Array;
        
        /** index of the angle for the tooltip*/
        private var _tooltipAngle:Number;
        
        /** index of the dragging angle */
        private var _selectedAngle:Number;
        
        private var _hoverTip:IToolTip;
        private var _nextTip:IToolTip;
        private var _prevTip:IToolTip;
        
        private var _tooltipAngleChanged:Boolean;
        private var _selectedAngleChanged:Boolean;
        
        private var _percentRadius:Number;
        
        private var _liveDragging:Boolean;
        
        private var _labelField:String = "label";
        private var _dataField:String = "data";
        private var _colorField:String = "color";
        
        private var _tooltipTextFunction:Function;
        /**
         * @inheritDoc
         */ 
        public function DraggablePie()
        {
            super();
            _liveDragging = true;
            _numDecimals = 2;
            _percentRadius = 100;
            _sensitivityAngle = 5/GeomUtils.DEG_TO_RAD;
            
            mouseChildren = false;
            
            //0 degress is 6 o'clock
            addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
            addEventListener(MouseEvent.MOUSE_MOVE,mouseHoverHandler);
            addEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
            addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
        }
        
        private static function constructStyle():Boolean
        {
            var style:CSSStyleDeclaration = StyleManager.getStyleDeclaration("DraggablePie");
            if(style)
            {
                if(style.getStyle("disabledAlpha") == undefined)
                {
                    style.setStyle("disabledAlpha", .5);
                }
                
                if(style.getStyle("disabledLineColor") == undefined)
                {
                    style.setStyle("disabledLineColor",0xAAAAAA);
                }
                
                if(style.getStyle("lineColor") == undefined)
                {
                    style.setStyle("lineColor",0x333333);
                }
            }
            else
            {
                style = new CSSStyleDeclaration();
                style.defaultFactory = function():void
                {
                    this.disabledAlpha = .5;
                    this.disabledLineColor = 0xAAAAAA;
                    this.lineColor = 0x333333;
                };
            }
            StyleManager.setStyleDeclaration("DraggablePie",style,true);
            return true;
        }
        
        /**
         * @inheritDoc
         */ 
        public override function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);
            
            if( styleProp == "lineColor" ||
                styleProp == "disabledLineColor" ||
                styleProp == "disabledAlpha")
            {
                invalidateDisplayList();
            }
        }
        
        /**
         * @inheritDoc
         */ 
        protected override function commitProperties():void
        {
            super.commitProperties();
            
            if(_dataProviderChanged)
            {
                _dataProviderChanged = false;
                
                var series:Object;
                var fractions:Array = new Array();
                
                _sum = 0;
                for each(series in _dataProvider)
                {
                    _sum += series[_dataField];
                }
                
                for each(series in _dataProvider)
                {
                    fractions.push(series[_dataField]/_sum);
                }
                
                angles = new Array();
                var prevAngle:Number = 0;
                for each(var fraction:Number in fractions)
                {
                    var angle:Number = prevAngle + fraction * (360/GeomUtils.DEG_TO_RAD);
                    prevAngle = angle;
                    angles.push(angle);
                }
                invalidateDisplayList();
            }
        }
        
        private function updateDataProvider():void
        {
            var fractions:Array = new Array();
            for (var j:int = 0; j < angles.length; j++)
            {
                var angle:Number = angles[j];
                var prevAngle:Number = GeomUtils.getNextSmallestAngle(angle,angles);
                //calculate this angles fraction of the circle
                var fraction:Number = Math.abs(angle - prevAngle)/(360/GeomUtils.DEG_TO_RAD);
                
                //push all fractions back by one so it matches the dataProvider array
                if(j == 0)
                {
                    fractions[angles.length - 1] = fraction
                }
                else
                {
                    fractions[j - 1] = fraction;
                }
            }
            
            for (var i:int = 0; i < fractions.length; i++)
            {
                var series:Object = _dataProvider[i];
                series[_dataField] = fractions[i] * _sum;
            }
            
            if(_liveDragging)
            {
                dispatchChangeEvent();
            }
        }
        
        private function mouseDownHandler(e:MouseEvent):void
        {
            if(angles == null || enabled == false)
            {
                return;
            }
            
            var mouseAngle:Number = GeomUtils.calcAngle(center,new Point(e.localX,e.localY));
            for (var i:int = 0; i < angles.length; i++)
            {
                var angle:Number = angles[i];
                //if the angle is near zero
                if(Math.abs(360/GeomUtils.DEG_TO_RAD - angle) < _sensitivityAngle ||
                    Math.abs(angle) < _sensitivityAngle)
                {
                    //check to see if the mouse angle is near zero
                    if(Math.abs(360/GeomUtils.DEG_TO_RAD - mouseAngle) < _sensitivityAngle ||
                        Math.abs(mouseAngle) < _sensitivityAngle)
                    {
                        if(_selectedAngle != i)
                        {
                            _selectedAngleChanged = true;
                            _selectedAngle = i;
                            invalidateDisplayList();
                        }
                        return;
                    }
                }
                else if(Math.abs(angle - mouseAngle) < _sensitivityAngle)
                {
                    if(_selectedAngle != i)
                    {
                        _selectedAngleChanged = true;
                        _selectedAngle = i;
                        invalidateDisplayList();
                    }
                    return;
                }
            }
        }
        
        private function mouseHoverHandler(e:MouseEvent):void
        {
            if(angles == null || enabled == false)
            {
                return;
            }
            
            var localPoint:Point = new Point(mouseX,mouseY);
            var mouseAngle:Number = GeomUtils.calcAngle(center,localPoint);
            
            for (var i:int = 0; i < angles.length; i++)
            {
                var angle:Number = angles[i];
                //if the angle is near zero
                if(Math.abs(360/GeomUtils.DEG_TO_RAD - angle) < _sensitivityAngle ||
                    Math.abs(angle) < _sensitivityAngle)
                {
                    //check to see if the mouse angle is near zero
                    if(Math.abs(360/GeomUtils.DEG_TO_RAD - mouseAngle) < _sensitivityAngle ||
                        Math.abs(mouseAngle) < _sensitivityAngle)
                    {
                        showCursor();
                        if(stage)
                        {
                            stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
                            stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
                        }
                        return;
                    }
                }
                else if(Math.abs(angle - mouseAngle) < _sensitivityAngle)
                {
                    showCursor();
                    if(stage)
                    {
                        stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
                        stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
                    }
                    return;
                }
            }
            
            hideCursor();
            
            if(e.buttonDown)
            {
                if(isNaN(_tooltipAngle) == false)
                {
                    _tooltipAngleChanged = true;
                    _tooltipAngle = NaN;
                    invalidateDisplayList();
                }
            }
            else
            {
                var calculatedTooltipAngle:Number;
                for (var c:int = 0; c < angles.length; c++)
                {
                    if(c == angles.length - 1)
                    {
                        if(GeomUtils.angleBetween(mouseAngle,angles[c],angles[0]))
                        {
                            calculatedTooltipAngle = c;
                            break;
                        }
                    }
                    else
                    {
                        if(GeomUtils.angleBetween(mouseAngle,angles[c],angles[c + 1]))
                        {
                            calculatedTooltipAngle = c;
                            break;
                        }
                    }
                }
                
                if(_tooltipAngle != calculatedTooltipAngle)
                {
                    _tooltipAngleChanged = true;
                    _tooltipAngle = calculatedTooltipAngle;
                    invalidateDisplayList();
                }
            }
        }
        
        private function mouseMoveHandler(e:MouseEvent):void
        {
            if(e.buttonDown == false || 
                isNaN(_selectedAngle) || 
                angles == null ||
                enabled == false)
            {
                return;
            }
            
            if(stage.mouseX < 0 || stage.mouseX > stage.stageWidth ||
                stage.mouseY < 0 || stage.mouseY > stage.stageHeight)
            {
                dispatchChangeEvent();
                if(isNaN(_selectedAngle) == false)
                {
                    _selectedAngle = NaN;
                    _selectedAngleChanged = true;
                }
                
                if(stage)
                {
                    stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
                    stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
                }
                invalidateDisplayList();
                return;
            }
            
            var localPoint:Point = new Point(mouseX,mouseY);
            var mouseAngle:Number = GeomUtils.calcAngle(center,localPoint);
            var nextAngle:Number;
            var prevAngle:Number;
            
            if(_selectedAngle == angles.length - 1)
            {
                nextAngle = 360/GeomUtils.DEG_TO_RAD + angles[0];
                prevAngle = angles[_selectedAngle - 1];
            }
            else if(_selectedAngle == 0)
            {
                prevAngle = angles[angles.length - 1];
                nextAngle = angles[_selectedAngle + 1];
            }
            else
            {
                prevAngle = angles[_selectedAngle - 1];
                nextAngle = angles[_selectedAngle + 1];
            }
            
            if(GeomUtils.angleBetween(mouseAngle,prevAngle,nextAngle))
            {
                angles[_selectedAngle] = mouseAngle;
                updateDataProvider();
            }
            invalidateDisplayList();
        }
        
        private function mouseUpHandler(e:MouseEvent):void
        {
            dispatchChangeEvent();
            
            if(isNaN(_selectedAngle) == false)
            {
                _selectedAngleChanged = true;
                _selectedAngle = NaN;
            }
            
            if(stage)
            {
                stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
                stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
            }
            invalidateDisplayList();
        }
        
        private function mouseOutHandler(e:MouseEvent):void
        {
            if(isNaN(_tooltipAngle) == false)
            {
                _tooltipAngleChanged = true;
                _tooltipAngle = NaN;
            }
            invalidateDisplayList();
        }
        
        private function dispatchChangeEvent():void
        {
            if(isNaN(_selectedAngle) == false)
            {
                dispatchEvent(new Event(Event.CHANGE));
            }
        }
        
        /**
         * @inheritDoc
         */ 
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            graphics.clear();
            super.updateDisplayList(unscaledWidth,unscaledHeight);
            
            if(angles == null)
                return;
            
            //Draw pie
            var series:Object;
            var pieAlpha:Number = enabled ? alpha : getStyle("disabledAlpha");
            var lineColor:uint = enabled ? getStyle("lineColor") : getStyle("disabledLineColor");
            
            if(angles.length == 1)
            {
                series = _dataProvider[0];
                graphics.lineStyle(pieAlpha, lineColor);
                graphics.beginFill(series[_colorField], pieAlpha);
                graphics.drawCircle(center.x,center.y,radius);  
                graphics.endFill();
            }
            else
            {
                for(var i:int = 0; i < angles.length; i++)
                {
                    series = _dataProvider[i];
                    var endIndex:int = i + 1;
                    if(endIndex >= angles.length)
                        endIndex = 0;
                    
                    graphics.lineStyle(pieAlpha, lineColor);
                    graphics.beginFill(series[_colorField], pieAlpha);
                    graphics.moveTo(center.x,center.y);
                    GeomUtils.drawArc(graphics,center, radius,angles[i],angles[endIndex]);
                    graphics.lineTo(center.x, center.y);     
                    graphics.endFill();   
                }
            }
            
            //Draw tooltips
            destroyToolTip("prev");
            destroyToolTip("next");
            if(isNaN(_selectedAngle))
            {
                
                if (isNaN(_tooltipAngle))
                {
                    destroyToolTip("hover");
                }
                
                if(isNaN(_tooltipAngle) == false && _tooltipAngleChanged)
                {
                    destroyToolTip("hover");
                    _tooltipAngleChanged = false;
                    _hoverTip = createTooltip(_dataProvider[_tooltipAngle]);
                }
            }
            else
            {
                destroyToolTip("hover");
                
                _selectedAngleChanged = false;
                if(_selectedAngle == 0)
                {
                    _prevTip = createTooltip(_dataProvider[angles.length - 1]);
                }
                else
                {
                    _prevTip = createTooltip(_dataProvider[_selectedAngle - 1]);
                }
                
                _nextTip = createTooltip(_dataProvider[_selectedAngle]);
            }
        }
        
        private function destroyToolTip(type:String):void
        {
            switch(type.toLowerCase())
            {
            case "prev":
                if(_prevTip)
                {
                    ToolTipManager.destroyToolTip(_prevTip)
                    _prevTip = null;
                }
                break;
            
            case "next":
                if(_nextTip)
                {
                    ToolTipManager.destroyToolTip(_nextTip)
                    _nextTip = null;
                }
                break;
            
            case "hover":
                if(_hoverTip)
                {
                    ToolTipManager.destroyToolTip(_hoverTip)
                    _hoverTip = null;
                }
                break;
            }
        }
        
        /**
         * This method creates a tooltip blurb for the series specified.
         * 
         * @param series:Object The data object to make the tooltip for.
         * @return ITooltip The tooltip which was created.
         */ 
        protected function createTooltip(series:Object):IToolTip
        {
            var angleIndex:int = 0;
            for (var i:int = 0; i < _dataProvider.length; i++)
            {
                if(_dataProvider[i] == series)
                {
                    angleIndex = i;
                    break;
                }
            }
            var angle:Number = angles[angleIndex];
            var ttNextAngle:Number = GeomUtils.getNextLargestAngle(angle, angles);
            var ttPoint:Point = GeomUtils.calcPoint(center,(ttNextAngle - angle)/2 + angle,radius/2);
            
            var tooltip:IToolTip = ToolTipManager.createToolTip(getTooltipTextForSeries(series),0,0,null,this);
            
            var origin:Point = localToGlobal(new Point(0,0));
            if(tooltip is UIComponent)
                UIComponent(tooltip).validateNow();
            tooltip.x = origin.x + ttPoint.x - tooltip.width/2;
            tooltip.y = origin.y + ttPoint.y - tooltip.height/2;
            return tooltip;
        }
        
        /**
         * This function returns a string to be displayed by a tooltip for a particular data object.
         * 
         * @param series:Object The object to create the tooltip text for 
         */ 
        protected function getTooltipTextForSeries(series:Object):String
        {
            if(_tooltipTextFunction != null)
            {
                return _tooltipTextFunction(series);
            }
            
            var formatter:NumberFormatter = new NumberFormatter();
            formatter.precision = _numDecimals;
            formatter.rounding = NumberBaseRoundType.NEAREST;
            
            return series[_labelField] + "\n" + 
                formatter.format((series[_dataField]/_sum) * 100) +"%";
        }
        
        /**
         * This function shows a finger cursor when the user is hovering over an edge.
         */ 
        protected function showCursor():void
        {
            this.useHandCursor = true;
            this.buttonMode = true;
        }
        
        /**
         * This function hides the finger cursor when the user is hovering over an edge.
         */ 
        protected function hideCursor():void
        {
            this.useHandCursor = false;
            this.buttonMode = false;
        }
        
        private function get radius():Number { return (Math.min(width,height)/2) * (_percentRadius/100) };
        private function get center():Point { return new Point(width/2,height/2); }
        
        /**
         * The percent radius is used to figure out how large the radius should be.
         * <br/><br/>
         *  
         * The value 100% uses the the minimum of the width or the height divided by 2
         * 
         * @default 100
         */ 
        [Bindable]
        public function get percentRadius():Number { return _percentRadius; }
        public function set percentRadius(value:Number):void 
        { 
            _percentRadius = value; 
            invalidateDisplayList();
        }
        
        /**
         * Determines whether or not to dispatch change events as the mouse moves or just when the
         * mouse is released
         * 
         * @default true
         */ 
        [Bindable]
        public function get liveDragging():Boolean { return _liveDragging; }
        public function set liveDragging(value:Boolean):void { _liveDragging = value; }
        
        /**
         * The dataProvider is used to control what data the chart will draw.  Each object in it represents a pie slice.
         * <br/><br/>
         * It is internally casted to type ICollectionView.  
         * If you pass an Array it will be convered to an ArrayCollection.
         * If you pass an Object it is converted to an ArrayCollection with the object as the first element
         */ 
        [Bindable]
        public function get dataProvider():Object { return _dataProvider; }
        public function set dataProvider(value:Object):void
        {
            _dataProviderChanged = true;
            _sum = NaN;
            if(value is ICollectionView)
            {
                _dataProvider = value as ICollectionView;
            }
            else if(value is Array)
            {
                _dataProvider = new ArrayCollection(value as Array);
            }
            else if(value != null)
            {
                _dataProvider = new ArrayCollection([value]);
            }
            else
            {
                _dataProvider = null;
                angles = null;
                _selectedAngle = NaN;  
            }
            invalidateProperties();
        }
        
        /**
         * Number of decimals to show in tooltip
         * 
         * @default 2
         */ 
        [Bindable]
        public function get numDecimals():Number { return _numDecimals; }
        public function set numDecimals(value:Number):void
        {
            _numDecimals = value;
            invalidateDisplayList();
        }
        
        /** 
         * Used to determine how much leeway to give when clicking on a line or not.
         * The angle is expressed in radians.
         * 
         * @default 5 Degrees 
         */ 
        [Bindable]
        public function get sensitivityAngle():Number { return _sensitivityAngle; }
        public function set sensitivityAngle(value:Number):void { _sensitivityAngle = value; }
        
        /**
         * Used to determine which field on the objects in the data provider is the field that contains the data.
         * 
         * @default "data"
         */ 
        [Bindable]
        public function get dataField():String { return _dataField; }
        public function set dataField(value:String):void { _dataField = value; }
        
        /**
         * Used to determine which field on the objects in the data provider is the field that contains the label
         * to be used on the tooltips.
         * 
         * @default "label"
         */
        [Bindable]
        public function get labelField():String { return _labelField; }
        public function set labelField(value:String):void { _labelField = value; }
        
        /**
         * Used to determine which field on the objects in the data provider is the field that contains the color
         * to be used when drawing the pie slice.
         * 
         * @default "color"
         */
        [Bindable]
        public function get colorField():String { return _colorField; }
        public function set colorField(value:String):void { _colorField = value; }
        
        /**
         * Used to replace tooltip text without sub-classing the object.  Function must be of signature
         * <br/><br/>
         * function(series:Object):String
         * <br/><br/>
         * This function will override the numDecimals property.
         * 
         * @default null
         */
        [Bindable]
        public function get tooltipTextFunction():Function { return _tooltipTextFunction; }
        public function set tooltipTextFunction(value:Function):void { _tooltipTextFunction = value; }
    }
}