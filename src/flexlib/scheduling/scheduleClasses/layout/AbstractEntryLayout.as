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
	import flexlib.scheduling.scheduleClasses.IScheduleEntry;
	import flexlib.scheduling.scheduleClasses.RowLocatorItem;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	
	[Event(name="update",type="flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent")]
	public class AbstractEntryLayout extends Layout implements IEntryLayout
	{
		protected var rows : Array;
		private var rowLocator : Dictionary;		
		private var _dataProvider : IList;	
		private var _xPosition : Number = 0;	
		private var _rowHeight : Number = 50;
		
		public function AbstractEntryLayout()
		{
			createLayout();
		}
		
		public function get dataProvider() : IList
		{
		    return _dataProvider;
		}
		
		public function set dataProvider( value : IList ) : void
		{
			_dataProvider = value;
			//tryToCreateLayout();
		}
				
		override public function get xPosition() : Number
		{
			var zoom : Number = totalMilliseconds / contentWidth;
			
			return _xPosition / zoom;
		}		
		
		override public function set xPosition( value : Number ) : void
		{
			if( isNaN( value )) return;
			
			var zoom : Number = totalMilliseconds / contentWidth;
			
			_xPosition = value * zoom;
		}
		
		[Bindable]
		public function get rowHeight() : Number
		{
		    return _rowHeight;
		}
		
		public function set rowHeight( value : Number ) : void
		{
			_rowHeight = value;
		}
		
		
		
		
		
		
		
		public function findLayoutItem( entry : IScheduleEntry ) : EntryLayoutItem
		{
			var rowLocatorItem : RowLocatorItem = getRowLocatorItem( entry );
			if( rowLocatorItem != null )
			{
				if( rowLocatorItem.layoutItem != null )
				{
					return rowLocatorItem.layoutItem;
				}
			}
			return null;
		}
				
		public function update() : void
		{
			calculateItems();
			dispatchEvent( new LayoutUpdateEvent( this ) );
		}
		
		
		public function createLayout() : void
		{
			rows = new Array();
			rowLocator = new Dictionary( true );
		}
				
		public function setRowLocatorItem( item : EntryLayoutItem, rowLocatorItem : RowLocatorItem ) : void
		{
			rowLocatorItem.layoutItem = item;
			rowLocator[ item.data ] = rowLocatorItem;
		}
		
		public function getRowLocatorItem( entry : IScheduleEntry ) : RowLocatorItem
		{
			return rowLocator[ entry ];
		}
		
		public function deleteRowLocatorItem( entry : IScheduleEntry ) : RowLocatorItem
		{
			return rowLocator[ entry ] = null;
		}
		
		protected function saveItemWithRow( item : EntryLayoutItem, row : Number, rowItem : Number ) : void
		{
			var rowLocatorItem : RowLocatorItem = new RowLocatorItem();
			rowLocatorItem.row = row;
			rowLocatorItem.rowItem = rowItem;
			setRowLocatorItem( item, rowLocatorItem );
		}			
			
		protected function isOffScreenLeftRight( entryStart : Number, viewPortEnd : Number ) : Boolean
 		{
  			var isOff : Boolean;
  			var isOffScreenOnLeftSide : Boolean = ( entryStart < 0 );
 			var isOffScreenOnRightSide : Boolean = ( entryStart > viewPortEnd );	 			
 			if( isOffScreenOnLeftSide || isOffScreenOnRightSide )
 			{
 				isOff = true;
 			}
 			return isOff;
 		}
		
 		protected function isTooSmall( width : Number ) : Boolean
 		{
 			var tooSmall : Boolean = ( width <= 0 );
 			if( tooSmall )
 			{
 				//optionally you could use a default width
 			}
 			return tooSmall;
 		}
 		
 		protected function updateLayouterProperties() : void
		{
			contentHeight = rows.length * rowHeight;
		}
				
		/**
		 * Potentially expensive call!
		 */		
		private function tryToCreateLayout() : void
		{
			if( dataProvider != null && startDate != null && endDate != null && !isNaN( rowHeight ) )
			{
				createLayout();
			}
		}
		
		/**
		 * find the items which are currently visible in the viewport
		 * _xPosition is an unscaled value 
		 * 
		 * TODO: If rows were ordered by x, we could optimize the search for items
		 */ 
		private function calculateItems() : void
		{
			var result : ArrayCollection = new ArrayCollection();
			var firstRow : Number = Math.floor( yPosition / rowHeight );
			var lastRow : Number = Math.ceil(( yPosition + viewportHeight ) / rowHeight );
			if( lastRow >= rows.length ) lastRow = rows.length - 1;
			
			var totalMilliseconds : Number = endDate.getTime() - startDate.getTime();
			var zoom : Number = totalMilliseconds / contentWidth;
			
			var xStart : Number = _xPosition;
			var xEnd : Number = _xPosition + viewportWidth * zoom;
			
			for( var rowIndex : Number = firstRow; rowIndex <= lastRow; rowIndex++ )
			{
				var row : Array = rows[ rowIndex ];
				for each( var item : EntryLayoutItem in row )
				{
					if( item.x < xEnd && item.x + item.width >= xStart ) 
					{
						item.zoom = zoom;
						item.row = rowIndex;
						result.addItem( item );					
					}
				}	
			}
			_items = result;
		}
		
		public function addItem( event : CollectionEvent ) : void
		{
			throw new Error( "Abstract method invoked" );
		}
		
		public function removeItem( event : CollectionEvent ) : void
		{
			throw new Error( "Abstract method invoked" );
		}		
		
		public function replaceItem( event : CollectionEvent ) : void
		{
			throw new Error( "Abstract method invoked" );
		}
		
		public function updateItem( event : CollectionEvent ) : void
		{
			throw new Error( "Abstract method invoked" );
		}
		
		public function resetItem( event : CollectionEvent ) : void
		{
			throw new Error( "Abstract method invoked" );
		}
				
		public function refreshItem( event : CollectionEvent ) : void
		{
			throw new Error( "Abstract method invoked" );
		}
		
		public function moveItem( event : CollectionEvent ) : void
		{
			throw new Error( "Abstract method invoked" );
		}		
	}
}