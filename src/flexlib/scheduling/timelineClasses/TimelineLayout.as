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
*/package flexlib.scheduling.timelineClasses
{	
	import flexlib.scheduling.scheduleClasses.layout.ILayoutProvider;
	import flexlib.scheduling.scheduleClasses.layout.Layout;
	import flexlib.scheduling.util.DateUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	[Event ("update")]
	
	/**
	 * @private
	 */
	public class TimelineLayout extends Layout implements ILayoutProvider
	{
		public var timeRanges : IList;
		public var minimumTimeRangeWidth : Number = 80;
		[Bindable]
		public var currentDate : Date;
		
		private var _contentWidth : Number;
		
		public function TimelineLayout() 
		{
			timeRanges = TimeRangeDescriptorUtil.getDefaultTimeRangeDescriptor();
		}
		
		[Bindable]
		override public function get contentWidth() : Number 
		{
			return _contentWidth;
		}
		
		override public function set contentWidth( value : Number ) : void
		{
			xPosition *= ( value / _contentWidth );
			_contentWidth = value;
		}

		public function update() : void
		{
			calculateItems(); 
			dispatchEvent( new Event("update") );
		}
		
		private function calculateItems() : void
		{
			var totalMilliseconds : Number = _endDate - _startDate;
			var entry : ITimeDescriptor = getTimeDescriptor( contentWidth, totalMilliseconds );	
			var millisecondsPerColumn : Number = entry.date.getTime();
			//var numberOfItems : Number = Math.floor( totalMilliseconds / millisecondsPerColumn ) + 1;
			var numberOfItems : Number = totalMilliseconds / millisecondsPerColumn;
			var columnWidth : Number = contentWidth / numberOfItems;			
			if( columnWidth < minimumTimeRangeWidth ) columnWidth = minimumTimeRangeWidth;
			
			_items = new ArrayCollection();
			var firstIndex : Number = Math.floor( xPosition / columnWidth );
			var lastIndex : Number = Math.ceil( ( xPosition + viewportWidth ) / columnWidth );
			for( var i : Number = firstIndex; i <= lastIndex; i++ )
			{
				var item : TimelineLayoutItem = new TimelineLayoutItem();
				
				item.width = columnWidth;
				item.height = viewportHeight;
				item.x = i * columnWidth;
            item.y = 0;
            
				currentDate = new Date( i * millisecondsPerColumn + _startDate );
				
				var data : ITimeDescriptor = new SimpleTimeDescriptor();
				data.description = entry.description;
				data.date = currentDate;				
				item.data = data;
				
				_items.addItem( item );
			}
		}
		
		/**
		 * try to find the smallest unit, which is wider than the minimumTimeRangeWidth
		 */
		private function getTimeDescriptor( totalWidth : Number, totalMilliseconds : Number ) : ITimeDescriptor
		{
			var length : Number = timeRanges.length;
			for( var i : Number = 0; i < length; i++ )
			{
				var entry : ITimeDescriptor = ITimeDescriptor( timeRanges.getItemAt( i ) );
				var step : Number = entry.date.getTime();
				var width : Number = step / totalMilliseconds * totalWidth;
				if( width >= minimumTimeRangeWidth )
				{
					return entry;
				}
			}
			return ITimeDescriptor( timeRanges.getItemAt( length - 1 ) );
		}
	}
}