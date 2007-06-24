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
	
	import mx.events.CollectionEvent;

	public class BestFitLayout extends AbstractEntryLayout implements IEntryLayout
	{
		/**
		 * Layout the complete dataProvider so that 
		 * one millisecond equals one pixel. This is the best 
		 * precision we can ever show, since Dates have this 
		 * resolution.
		 */
		override public function createLayout() : void
		{
			super.createLayout();
			if( dataProvider == null ) return;
			createLayoutFor( 0, dataProvider.length );
		}
		
		private function createLayoutFor( startIndex : Number, endIndex : Number ) : void
		{
			var len : Number = endIndex;
			for( var i : Number = startIndex; i < len; i++ )
			{
				var item : IScheduleEntry = IScheduleEntry( dataProvider.getItemAt( i ) );
				addItemToRow( item );
			}
			updateLayouterProperties();
		}
	
		private function addItemToRow( entry : IScheduleEntry ) : void
		{
			var x : Number = entry.startDate.getTime() - startDate.getTime();
			if( isOffScreenLeftRight( x, totalMilliseconds ) ) return;
			
			var width : Number = entry.endDate.getTime() - entry.startDate.getTime();
			if( isTooSmall( width ) ) return;
			
			var layoutItem : EntryLayoutItem = new EntryLayoutItem();
			layoutItem.x = x;
			layoutItem.width = width; 
			layoutItem.height = rowHeight;
			layoutItem.data = entry;
			
			//sets y and row of the item
			insertNonOverlapping( layoutItem );
		}
				
		/**
		 * find the lowest row, which hasn't 
		 * overlapping items and add the item to it
		 */ 
		private function insertNonOverlapping( item : EntryLayoutItem ) : void
		{
			//Either find an existing row and squeeze the item into it...
			var length : Number = rows.length;
			for ( var rowIndex : Number = 0; rowIndex < length; rowIndex++ )
			{
				var row : Array = rows[ rowIndex ];
				var index : Number = findNonOverlappingPosition( row, item );
				if( index >= 0 )
				{
					item.row = rowIndex;
					item.y = rowIndex * item.height;
					row.splice( index, 0, item );
					//save item against row location for efficient access.
					saveItemWithRow( item, rowIndex, index );
					return;
				}
			}
			
			//...or create a new row and place the item in there.
			item.row = length;
			item.y = length * item.height;			
			var newRow : Array = new Array();
			newRow.push( item );
			rows.push( newRow );
			//save item against row location for efficient access.
			saveItemWithRow( item, length, 0 );
		}
		
		/**
		 * See if we can fit the item into this row
		 * return the index of the inserting point or -1 if no position could be found
		 * 
		 * TODO: If we could assume, that the dataProvider is ordererd by startTime, 
		 * we wouldn't have to search here. Instead we could simply add the items.
		 */ 
		private function findNonOverlappingPosition( row : Array, item : EntryLayoutItem ) : Number
		{
			var x : Number = item.x;
			var width : Number = item.width;

			var length : Number = row.length;
			if( length == 0 ) return 0;
			
			var i : Number = 0;
			while( i < length && x > row[ i ].x ) i++;
			
			//x was greater than all of the entries
			if( i == length )
			{
				if( x >= row[ i - 1 ].x + row[ i - 1 ].width )
				{
					return length;	
				}
				return -1;
			}
			//x is lower or equal to the current entry
			if( x < row[ i ].x && x + width <= row[ i ].x ){
				if( i == 0 ) return 0;
				if( x > row[ i - 1 ].x + row[ i - 1 ].width )
				{					
					return i;
				} 
			}
			return -1;
		}
		
		override public function addItem( event : CollectionEvent ) : void
		{
			createLayout();
		}
		
		override public function removeItem( event : CollectionEvent ) : void
		{
			createLayout();
		}		
		
		override public function replaceItem( event : CollectionEvent ) : void
		{
			createLayout();
		}
		
		override public function updateItem( event : CollectionEvent ) : void
		{
			createLayout();
		}
		
		override public function resetItem( event : CollectionEvent ) : void
		{
			createLayout();
		}
				
		override public function refreshItem( event : CollectionEvent ) : void
		{
			createLayout();
		}
		
		override public function moveItem( event : CollectionEvent ) : void
		{
			//do nothing on move. This shouldn't have an influence on the component.
		}			
	}
}