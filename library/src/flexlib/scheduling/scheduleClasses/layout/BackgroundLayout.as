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
*/
package flexlib.scheduling.scheduleClasses.layout
{
	import flexlib.scheduling.scheduleClasses.BackgroundItem;
	import flexlib.scheduling.timelineClasses.ITimeDescriptor;
	import flexlib.scheduling.timelineClasses.TimeRangeDescriptorUtil;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	[Event(name="update",type="flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent")]
	public class BackgroundLayout extends Layout implements IBackgroundLayout
	{		
		private var _minimumTimeRangeWidth : Number = 80;
		private var _backgroundItems : IList;
		private var _timeRanges : IList;			
		
		private var _contentWidth : Number;	
		
		public function BackgroundLayout()
		{
			timeRanges = TimeRangeDescriptorUtil.getDefaultTimeRangeDescriptor();
		}
				
		public function get minimumTimeRangeWidth() : Number
		{
			return _minimumTimeRangeWidth;
		}
		
		public function set minimumTimeRangeWidth( value : Number ) : void
		{
			_minimumTimeRangeWidth = value;
		}
		
		public function get backgroundItems() : IList
		{
			return _backgroundItems;
		}
		
		public function set backgroundItems( value : IList ) : void
		{
			_backgroundItems = value;
		}
		
		override public function get contentWidth() : Number
		{
			return _contentWidth;
		}
		
		override public function set contentWidth( value : Number ) : void
		{
			xPosition *= value / _contentWidth; 
			_contentWidth = value;
		}
		
		public function get timeRanges() : IList
		{
			return _timeRanges;
		}		
		
		public function set timeRanges( value : IList ) : void
		{
			_timeRanges = value;
		}
		
		public function update( event : LayoutUpdateEvent ) : void
		{
			entryLayout = IEntryLayout( event.layout );
			contentWidth = entryLayout.contentWidth;
			startDate = entryLayout.startDate;
			endDate = entryLayout.endDate;
			viewportWidth = entryLayout.viewportWidth;
			viewportHeight = entryLayout.viewportHeight;			
			xPosition = entryLayout.xPosition;
			yPosition = entryLayout.yPosition;			
			
			calculateItems();
			dispatchEvent( new LayoutUpdateEvent( this ) );
		}
		
		private function calculateItems() : void
		{
			var timeDescriptor : ITimeDescriptor = getTimeDescriptor( contentWidth, totalMilliseconds );
			var millisecondsPerColumn : Number = timeDescriptor.date.getTime();	
			var numberOfItems : Number = Math.floor( totalMilliseconds / millisecondsPerColumn ) + 1;
			var columnWidth : Number = contentWidth / numberOfItems;
			if( columnWidth < minimumTimeRangeWidth ) columnWidth = minimumTimeRangeWidth;
			
			_items = new ArrayCollection();
			var firstIndex : Number = Math.floor( xPosition / columnWidth );
			var lastIndex : Number = Math.ceil(( xPosition + viewportWidth ) / columnWidth );
			
			for( var i : Number = firstIndex; i < lastIndex; i++ )
			{
				var item : BackgroundLayoutItem = new BackgroundLayoutItem();
				
				item.width = columnWidth;
				item.height = viewportHeight;
				item.x = i * columnWidth;
				
				var currentTime : Number = ( i * columnWidth + columnWidth / 2 ) * totalMilliseconds / contentWidth;
				var colorItem : BackgroundItem = findBackgroundItem( currentTime );
				if( colorItem == null ) continue;
				item.backgroundColor = colorItem.color;
				item.toolTip = colorItem.description;
				
				var now : Number = new Date().getTime() - _startDate;
				var currentIndex : Number = Math.floor( now / columnWidth );
				if( i == currentIndex ) item.backgroundColor = 0xff0000;
	
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
		
		/**
		 * return background definition depending on time
		 */ 
		private function findBackgroundItem( relativeTime : Number ) : BackgroundItem
		{
			if( _backgroundItems == null ) return null;
			var result : BackgroundItem = null;			
			for( var i : Number = 0; i < _backgroundItems.length; i++ )
			{
				var colorItem : BackgroundItem = BackgroundItem( _backgroundItems.getItemAt( i ) );
				if( relativeTime >= colorItem.startDate.getTime() && relativeTime < colorItem.endDate.getTime() )
				{
					result = colorItem;
				}
			}			
			return result;
		}
	}
}