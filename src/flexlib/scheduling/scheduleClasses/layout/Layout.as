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
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;

	public class Layout extends EventDispatcher implements ILayout
	{
		protected var _items : IList;
		protected var _startDate : Number;
		protected var _endDate : Number;	
		private var _entryLayout : IEntryLayout;	
		private var _contentWidth : Number;
		private var _contentHeight : Number;
		private var _viewportWidth : Number;
		private var _viewportHeight : Number;
		private var _xPosition : Number = 0;
		private var _yPosition : Number = 0;		
		
		public function get entryLayout() : IEntryLayout
		{
		    return _entryLayout;
		}
		
		public function set entryLayout( value : IEntryLayout ) : void
		{
			_entryLayout = value;
		}
		
		public function get items() : IList
		{
		    return _items;
		}
				
		public function get contentWidth() : Number
		{
		    return _contentWidth;
		}
		
		public function set contentWidth( value : Number ) : void
		{
			_contentWidth = value;
		}

		public function get contentHeight() : Number
		{
		    return _contentHeight;
		}
		
		public function set contentHeight( value : Number ) : void
		{
			_contentHeight = value;
		}		
			
		public function get viewportWidth() : Number
		{
		    return _viewportWidth;
		}
		
		public function set viewportWidth( value : Number ) : void
		{
			_viewportWidth = value;
		}
		
		public function get viewportHeight() : Number
		{
		    return _viewportHeight;
		}
		
		public function set viewportHeight( value : Number ) : void
		{
			_viewportHeight = value;
		}
				
		public function get startDate() : Date
		{
			return new Date( _startDate );
		}
		
		public function set startDate( value : Date ) : void
		{
			_startDate = value.getTime();
		}
		
		public function get endDate() : Date
		{
			return new Date( _endDate );
		}
		
		public function set endDate( value : Date ) : void
		{
			_endDate = value.getTime();
		}
		
		public function get totalMilliseconds() : Number
		{
			return _endDate - _startDate;
		}		
		
		[Bindable]
		public function get xPosition() : Number
		{
			return _xPosition;
		}
		
		public function set xPosition( value : Number ) : void
		{
			if( isNaN( value )) return;
			_xPosition = value;
		}
		
		public function get yPosition() : Number
		{
			return _yPosition;
		}
		
		public function set yPosition( value : Number ) : void
		{
			_yPosition = value;
		}		
	}
}