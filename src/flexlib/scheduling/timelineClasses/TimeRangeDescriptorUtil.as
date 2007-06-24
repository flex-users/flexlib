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
	import flexlib.scheduling.util.DateUtil;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	public class TimeRangeDescriptorUtil
	{		
		public static var defaultTimeRangeDescriptor : Array = [ 
			[ DateUtil.MINUTE_IN_MILLISECONDS, "L:NNAA" ], 
			[ 5 * DateUtil.MINUTE_IN_MILLISECONDS, "L:NNAA" ], 
			[ 10 * DateUtil.MINUTE_IN_MILLISECONDS, "L:NNAA" ], 
			[ 15 * DateUtil.MINUTE_IN_MILLISECONDS, "L:NNAA" ], 
			[ 30 * DateUtil.MINUTE_IN_MILLISECONDS, "L:NNAA" ], 
			[ 60 * DateUtil.MINUTE_IN_MILLISECONDS, "L:NNAA" ], 
			[ 2 * DateUtil.HOUR_IN_MILLISECONDS, "L:NNAA" ], 
			[ 6 * DateUtil.HOUR_IN_MILLISECONDS, "L:NNAA" ], 
			[ 12 * DateUtil.HOUR_IN_MILLISECONDS, "L:NNAA" ], 
			[ 24 * DateUtil.HOUR_IN_MILLISECONDS, "DD/MM/YY" ], 
			[ 2 * DateUtil.DAY_IN_MILLISECONDS, "DD/MM/YY" ],
			[ 4 * DateUtil.DAY_IN_MILLISECONDS, "DD/MM/YY" ], 	
			[ 7 * DateUtil.DAY_IN_MILLISECONDS, "DD/MM/YY" ], 
			[ 14 * DateUtil.DAY_IN_MILLISECONDS, "DD/MM/YY" ],	
			[ 30 * DateUtil.DAY_IN_MILLISECONDS, "MMM YY" ], 				
			[ 4 * DateUtil.MONTH_IN_MILLISECONDS, "MMM YY" ],
			[ 6 * DateUtil.MONTH_IN_MILLISECONDS, "MMM YY" ],
			[ 9 * DateUtil.MONTH_IN_MILLISECONDS, "MMM YY" ],
			[ 12 * DateUtil.MONTH_IN_MILLISECONDS, "MMM YY" ],
			[ 2 * DateUtil.YEAR_IN_MILLISECONDS, "YYYY" ],
			[ 5 * DateUtil.YEAR_IN_MILLISECONDS, "YYYY" ],
			[ 10 * DateUtil.YEAR_IN_MILLISECONDS, "YYYY" ],
			[ 25 * DateUtil.YEAR_IN_MILLISECONDS, "YYYY" ], 
			[ 500 * DateUtil.YEAR_IN_MILLISECONDS, "YYYY" ] ];
															
		public static function convertArrayToTimeRangeDescriptor( timeDescriptor : Array ) : IList 
		{
			var dataProvider : IList = new ArrayCollection();
			var len : Number = timeDescriptor.length;
			for( var i : Number = 0; i < len; i++ )
			{
				var item : Array = timeDescriptor[ i ];
				var entry : ITimeDescriptor = new SimpleTimeDescriptor();
				entry.date = new Date( item[ 0 ] );
				entry.description = item[ 1 ];
				dataProvider.addItem( entry );
			}
			return dataProvider;
		}
		
		public static function getDefaultTimeRangeDescriptor() : IList 
		{
			return TimeRangeDescriptorUtil.convertArrayToTimeRangeDescriptor( defaultTimeRangeDescriptor );
		}		
	}
}