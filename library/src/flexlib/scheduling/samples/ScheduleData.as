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
*/package flexlib.scheduling.samples
{
	import flexlib.scheduling.scheduleClasses.IScheduleEntry;
	import flexlib.scheduling.scheduleClasses.SimpleScheduleEntry;
	import flexlib.scheduling.scheduleClasses.ColoredScheduleEntry;
	import flexlib.scheduling.util.DateUtil;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	public class ScheduleData
	{	
		public function createRandomSimpleScheduleEntries( size : Number ) : ArrayCollection
		{
			var result : Array = new Array();
			
			for( var i : Number = 0; i < size; i++ )
			{
				result.push( createSimpleEntry( 
					i, 
					randomInt( ( 24 - 1 ) * 60 ) * 60 * 1000,								
					( 10 + randomInt( 120 ) ) * 60 * 1000 ) );
			}
			
			return new ArrayCollection( result );			
		}
		
		public function createRandomColoredScheduleEntries( size : Number ) : ArrayCollection
		{
			var result : Array = new Array();
			
			for( var i : Number = 0; i < size; i++ )
			{
				var color : uint = 0x999999 + randomInt( 0x777777 );
				result.push( createColoredEntry( 
					i, 
					randomInt( ( 24 - 1 ) * 60 ) * 60 * 1000,								
					( 10 + randomInt( 120 ) ) * 60 * 1000, color ) );
			}
			
			return new ArrayCollection( result );			
		}
		
		public function createRowsOfRandomColoredEntries( rows : Number, size : Number ) : ArrayCollection
		{
			var result : Array = new Array();			
			for( var i : Number = 0; i < rows; i++ )
			{
				var row : IList = new ArrayCollection();				
				for( var j : Number = 0; j < size; j++ )
				{
					var color : uint = 0x999999 + randomInt( 0x777777 );
					row.addItem( createColoredEntry( 
						j, 
						randomInt( ( 24 - 1 ) * 60 ) * 60 * 1000,								
						( 10 + randomInt( 60 ) ) * 60 * 1000, color ) );
				}
				result.push( row );
			}			
			return new ArrayCollection( result );			
		}
		
		public function createRowsOfSequentialColoredEntries( rows : Number, size : Number ) : ArrayCollection
		{
			var result : Array = new Array();
			var counter : Number = 0;		
			for( var i : Number = 0; i < rows; i++ )
			{				
				var row : IList = new ArrayCollection();
				var currentTime : Number = ( ( 24 - 1 ) * 60 ) / size;
				var color : uint = 0x999999 + randomInt( 0x777777 );
				for( var j : Number = 0; j < size; j++ )
				{
					counter++;
					var startTime : Number = currentTime * j * 60 * 1000;
					var duration : Number = ( randomInt( 60 ) + 30 ) * 60 * 1000;					
					var entry : SimpleScheduleEntry = createColoredEntry( j, startTime, duration, color );										
					entry.label = "Entry " + counter;
					row.addItem( entry );
				}
				result.push( row );
			}			
			return new ArrayCollection( result );			
		}		
		
		private function createSimpleEntry( i : Number, startTime : Number, duration : Number ) : SimpleScheduleEntry
		{
			var entry : SimpleScheduleEntry = new SimpleScheduleEntry();
			entry.startDate = DateUtil.setTime( new Date(), startTime );
			entry.endDate = DateUtil.addTime( DateUtil.copyDate( entry.startDate ), duration );
			entry.label = "Entry " + i; 
			return entry;
		}
		
		private function createColoredEntry( i : Number, startTime : Number, duration : Number, color : uint ) : SimpleScheduleEntry
		{
			var entry : ColoredScheduleEntry = new ColoredScheduleEntry();
			entry.startDate = DateUtil.setTime( new Date(), startTime );
			entry.endDate = DateUtil.addTime( DateUtil.copyDate( entry.startDate ), duration );
			entry.label = "Entry " + i;
			entry.backgroundColor = color;
			return entry;
		}		
		
		private function randomInt( max : Number ) : Number
		{
			return Math.floor( Math.random() * max );
		}
	}
}