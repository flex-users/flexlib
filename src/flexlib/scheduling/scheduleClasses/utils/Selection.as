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
*/package flexlib.scheduling.scheduleClasses.utils
{
	import flash.utils.Dictionary;
	
	/**
	 * @private
	 */	
	public class Selection
	{
		public var allowMultipleSelection : Boolean = false;
		
		protected var item : Object;
		protected var items : Dictionary;
		
		public function Selection()
		{
			items = new Dictionary();
		}
		
		public function hasItem( item : Object ) : Boolean
		{
			return items[ item ];	
		}
		
		public function get selectedItem() : Object
		{
			return item;
		}
		
		public function set selectedItem( value : Object ) : void
		{
			clear();
			setItem( value );
		}
		
		public function get selectedItems() : Array
		{
			var result : Array = new Array();
			for each( var item : Object in items )
			{
				result.push( item );
			}
			return result;
		}
		
		public function set selectedItems( newItems : Array ) : void
		{
			clear();
			if( newItems == null ) return;
			
			for each( var item : Object in newItems )
			{
				items[ item ] = item;
			}
		}
		
		public function addItem( item : Object ) : void
		{
			if( allowMultipleSelection )
			{
				items[ item ] = item;			
			}
			else 
			{
				clear();
				setItem( item );
			}
		}
		
		public function removeItem( item : Object ) : void
		{
			delete items[ item ];
			this.item = null;
		}
		
		public function clear() : void
		{
			item = null;
			items = new Dictionary();		
		}
		
		public function getNumberOfSelectedItems() : Number
		{
			var size : Number = 0;
			for each( var item : Object in items )
			{
				size++;
			}
			return size;
		}		
		
		private function setItem( value : Object ) : void
		{
			item = value;
			items[ value ] = value;			
		}
	}
}