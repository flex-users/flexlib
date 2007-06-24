/*

Copyright (c) 2006. Adobe Systems Incorporated.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of Adobe Systems Incorporated nor the names of its
    contributors may be used to endorse or promote products derived from this
    software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

@ignore
*/package flexlib.scheduling
{
	import flexlib.scheduling.timelineClasses.TimelineLayout;
	import flexlib.scheduling.timelineClasses.TimelineViewer;
	
	import flash.events.Event;
	
	import mx.collections.IList;
	import mx.core.IFactory;
	import mx.core.ScrollControlBase;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	import mx.events.ScrollEventDirection;
	
	/**
	 * 
	 * Timeline is an independent control that renders and let users interact 
	 * with a customizable timeframe. Developers can use this component in combinations 
	 * other components, i.e. to add a timeline to a ScheduleViewer component. See 
	 * flexlib.scheduling.ScheduleViewer for more details. 
	 * <p>
	 * You can style the layout of the timeline frame and customize and style 
	 * each item of the timeline. By default, one item of Timeline would be a Label 
	 * displaying a date. 
	 * </p>
	 * <p>
	 * The rendering of the item can be customized via the itemRenderer property. The itemRenderer has to 
	 * implement flexlib.scheduling.timelineClasses.ITimelineEntryRenderer. 
	 * Via Timeline's timeRanges property you can pass more information to the renderers 
	 * on specific time ranges. By default a format string as used in mx.formatters.DateFormatter 
	 * is passed to the renderer depending on what time range is currently displayed. i.e. by default 
	 * a format string of "L:NNAA" is passed to the renderer when Timeline currently 
	 * only dispays a time range of one minute. 
	 * You can customize this with passing your own timeRanges collection. timeRanges 
	 * must contain items that adhere to the flexlib.scheduling.timelineClasses.ITimeDescriptor 
	 * interface. See flexlib.scheduling.timelineClasses.TimeRangeDescriptorUtil class 
	 * for more details and utilities on customizations of time ranges. 
	 * </p>
	 * Timeline supports zooming via the zoom and contentWidth property.
	 * <p>
	 * Currently, only horizontal timelines are supported. 
	 * </p>
	 * <!--<a href="examples/TimelineLabSample.html">See the example SWF</a>-->
	 * @see #itemRenderer
	 * @see flexlib.scheduling.timelineClasses.ITimelineEntryRenderer
	 * @see #timeRanges
	 * @see flexlib.scheduling.timelineClasses.ITimeDescriptor
	 * @see flexlib.scheduling.timelineClasses.TimeRangeDescriptorUtil
	 * @see flexlib.scheduling.ScheduleViewer
	 * @see flexlib.scheduling.util.DateUtil
	 * 
	 */
	public class Timeline extends ScrollControlBase
	{
		private var timelineLayout : TimelineLayout;
		private var timelineViewer : TimelineViewer;
		private var content : UIComponent;
		private var contentWidthOffset : Number;
		
		private var _timeRanges : IList;
		private var _minimumTimeRangeWidth : Number;
		private var _zoom : Number;
		
		public function Timeline() 
		{
			horizontalScrollPolicy = ScrollPolicy.AUTO;
			verticalScrollPolicy = ScrollPolicy.OFF;
			contentWidthOffset = 0;
			createTimelineLayout();			
		}
		
		/**
		 * @private
		 */		
		override protected function createChildren() : void
		{
			super.createChildren();
			
			addEventListener( ScrollEvent.SCROLL, onScroll );			
			
			content = new UIComponent();
			addChild( content );
			content.mask = maskShape;				
			
			initializeCompileTimeViewLayers();
			
			content.addChild( timelineViewer );
		}

		/**
		 * @private
		 */		
		override protected function measure():void
		{
			super.measure();
			
			measuredHeight = 20;
			measuredMinHeight = 20;
			
			if( horizontalScrollPolicy != ScrollPolicy.OFF && horizontalScrollBar )
			{
				measuredHeight += horizontalScrollBar.minHeight;
				measuredMinHeight += horizontalScrollBar.minHeight;
			}
		}

		/**
		 * @private
		 */		
		override protected function commitProperties() : void
		{
			if( isNaN( contentWidth ) && width != 0 ) contentWidth = width;
		}
		
		/**
		 * @private
		 */		
		override protected function updateDisplayList( 
			unscaledWidth : Number, 
			unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth , unscaledHeight );
			
			timelineLayout.viewportWidth = unscaledWidth;
			timelineLayout.viewportHeight = unscaledHeight;
			timelineLayout.update();
			
			setScrollBarProperties( 
				timelineLayout.contentWidth + contentWidthOffset, unscaledWidth, 
				timelineLayout.contentHeight, unscaledHeight );	
		}
		
		[Bindable]
		public function get timeRanges() : IList
		{
			return _timeRanges;
		}
		
		public function set timeRanges( value : IList ) : void
		{
			_timeRanges = value;
			timelineLayout.timeRanges = _timeRanges;
			invalidateDisplayList();
		}
		
		[Bindable]
		public function get minimumTimeRangeWidth() : Number
		{
			return _minimumTimeRangeWidth;
		}
		
		public function set minimumTimeRangeWidth( value : Number ) : void
		{
			_minimumTimeRangeWidth = value;
			timelineLayout.minimumTimeRangeWidth = _minimumTimeRangeWidth;
			invalidateDisplayList();
		}		
				
		[Bindable]
		public function get startDate() : Date
		{
			return timelineLayout.startDate;
		}		
		
		public function set startDate( value : Date ) : void
		{
			timelineLayout.startDate = value;
			invalidateDisplayList();
		}
		
		[Bindable]
		public function get endDate() : Date
		{
			return timelineLayout.endDate;
		}
		
		public function set endDate( value : Date ) : void
		{
			timelineLayout.endDate = value;
			invalidateDisplayList();
		}
		
		[Bindable]
		public function get itemRenderer() : IFactory 
		{
			return timelineViewer.itemRenderer;
		}
		
		public function set itemRenderer( value : IFactory ) : void
		{
			if( value != null && value != timelineViewer.itemRenderer )
			{
				timelineViewer.itemRenderer = value;	
			}
		}		
		
		//Navigation--------------------------		
		
		[Bindable]
		public function get zoom() : Number
		{
			return _zoom;
		}
		
		public function set zoom( value : Number ) : void
		{
			_zoom = value;
			var adjustedValue : Number = value / 100 * Math.sqrt( width );
			contentWidth = Math.pow( adjustedValue, 2 );
		}
		
		[Bindable]
		public function get contentWidth() : Number 
		{
			return timelineLayout.contentWidth;
		}
		
		public function set contentWidth( value : Number ) : void
		{
			horizontalScrollPosition *= value / timelineLayout.contentWidth;
			if( isNaN( horizontalScrollPosition )) horizontalScrollPosition = 0;						
			
			timelineLayout.contentWidth = value;	
			invalidateDisplayList();
		}
		
		[Bindable(event="xPositionChanged")]
		public function get xPosition() : Number
		{
			return timelineLayout.xPosition;
		}
		
		public function set xPosition( value : Number ) : void
		{
			horizontalScrollPosition = value;
			setXPosition( value );
			var overlap : Number = timelineLayout.contentWidth - timelineLayout.viewportWidth;
			if( overlap < value )
			{
				contentWidthOffset = value - overlap;
				invalidateDisplayList();		
			}	
		}
	
		[Bindable(event="currentDateChanged")]
		public function get currentDate() : Date
		{
			return timelineLayout.currentDate;
		}
		
		public function set currentDate( value : Date ) : void
		{
			timelineLayout.currentDate = value;
		}
				
		private function initializeCompileTimeViewLayers() : void
		{
			timelineViewer = new TimelineViewer();
			timelineLayout.addEventListener( "update", timelineViewer.update );
		}	
		
		private function createTimelineLayout() : void
		{
			if( timelineLayout == null )
			{
				timelineLayout = new TimelineLayout();
				timelineLayout.addEventListener( "propertyChange", onTimelineLayoutChange );
			}
		}
		
		private function onTimelineLayoutChange( event : PropertyChangeEvent ) : void
		{			
			if( event.property == "xPosition" )
			{
				dispatchEvent( new Event( "xPositionChanged" ) );
			}
			else if( event.property == "currentDate" )
			{
				dispatchEvent( new Event( "currentDateChanged" ) );
			}
		}
		
		private function onCurrentDateChanged( event : Event ) : void
		{
			dispatchEvent( new Event( "onCurrentDateChanged" ) );
		}
		
		private function setHorizontalScrollPosition( value : Number ) : void
		{
			if( value > maxHorizontalScrollPosition ) value = maxHorizontalScrollPosition;
			
			var event : ScrollEvent = new ScrollEvent( ScrollEvent.SCROLL );
			event.direction = ScrollEventDirection.HORIZONTAL;
			event.position = value;
			event.delta = horizontalScrollPosition - value;
			event.detail = ScrollEventDetail.THUMB_POSITION;
			horizontalScrollPosition = value;
			dispatchEvent( event );
		}
		
		private function onScroll( event : ScrollEvent ) : void
		{
			var position : Number = event.position;
			if( event.direction == ScrollEventDirection.HORIZONTAL )
			{
				xPosition = position;
			}
		}
		
		private function setXPosition( position : Number ) : void
		{
			timelineLayout.xPosition = position;
			timelineLayout.update();
		}
	}
}