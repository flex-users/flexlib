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
	import mx.collections.ArrayCollection;
	import mx.collections.IList;

	[Event(name="update",type="flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent")]
	public class HorizontalLinesLayout extends Layout implements IHorizontalLinesLayout
	{
		private var _rowHeight : Number;

		public function get rowHeight() : Number
		{
		    return _rowHeight;
		}

		public function set rowHeight( value : Number ) : void
		{
			_rowHeight = value;
		}

		public function update( event : LayoutUpdateEvent ) : void
		{
			entryLayout = IEntryLayout( event.layout );
			contentWidth = entryLayout.contentWidth;
			startDate = entryLayout.startDate;
			endDate = entryLayout.endDate;
			viewportWidth = entryLayout.viewportWidth;
			viewportHeight = entryLayout.viewportHeight;
			rowHeight = entryLayout.rowHeight;
			xPosition = entryLayout.xPosition;
			yPosition = entryLayout.yPosition;

			calculateItems( entryLayout );
			dispatchEvent( new LayoutUpdateEvent( this ) );
		}

		protected function calculateItems( entryLayout : IEntryLayout ) : void
		{
			var result : IList = new ArrayCollection();
			var firstRow : Number = Math.floor( yPosition / rowHeight );
			var lastRow : Number = Math.ceil(( yPosition + viewportHeight ) / rowHeight );

			for( var i : Number = firstRow; i <= lastRow; i++ )
			{
				var item : HorizontalLinesLayoutItem = new HorizontalLinesLayoutItem();

				item.x = 0;
				item.y = i * rowHeight;
				item.width = viewportWidth;

				result.addItem( item );
			}
			_items = result;
		}
	}
}