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
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	
	public class SimpleLayout extends AbstractEntryLayout implements IEntryLayout
	{		
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
				var rowItems : IList = IList( dataProvider.getItemAt( i ) );
				addRowItemsToRow( rowItems, i );
			}
			updateLayouterProperties();
		}		
		
		private function addRowItemsToRow( rowItems : IList, i : Number ) : void
		{
			rows[ i ] = new Array();
			var rowItemsLength : Number = 	rowItems.length;
			for ( var j : Number = 0; j < rowItemsLength; j++ )
			{
				var item : IScheduleEntry = IScheduleEntry( rowItems.getItemAt( j ) );
				
				var x : Number = item.startDate.getTime() - startDate.getTime();					
				if( isOffScreenLeftRight( x, totalMilliseconds ) ) continue;
				
				var width : Number = item.endDate.getTime() - item.startDate.getTime();
				if( isTooSmall( width ) ) continue;
				
				var layoutItem : EntryLayoutItem = new EntryLayoutItem();
				layoutItem.x = x;
				layoutItem.y = i * rowHeight;	
				layoutItem.width = width; 
				layoutItem.height = rowHeight;
				layoutItem.data = item;
				
				rows[ i ][ j ] = layoutItem;
				saveItemWithRow( layoutItem, i, j );
			}
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