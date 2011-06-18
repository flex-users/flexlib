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
*/package flexlib.scheduling.util
{
	public class DateUtil
	{
		public static const MINUTE_IN_MILLISECONDS : Number = 60 * 1000;
		public static const HOUR_IN_MILLISECONDS : Number = 60 * 60 * 1000;
		public static const DAY_IN_MILLISECONDS : Number = 24 * 60 * 60 * 1000;
		public static const WEEK_IN_MILLISECONDS : Number = 7 * 24 * 60 * 60 * 1000;
		public static const MONTH_IN_MILLISECONDS : Number = 30 * 24 * 60 * 60 * 1000;
		public static const YEAR_IN_MILLISECONDS : Number = 12 * 30 * 24 * 60 * 60 * 1000;
		public static const CENTURY_IN_MILLISECONDS : Number = 100 * 12 * 30 * 24 * 60 * 60 * 1000;
		public static const MILLENIUM_IN_MILLISECONDS : Number = 1000 * 100 * 12 * 30 * 24 * 60 * 60 * 1000;
		
		public static function clearTime( date : Date ) : Date 
		{	
			date.hours = 0;
			date.minutes = 0;
			date.seconds = 0;
			date.milliseconds = 0;
			
			return date;
		}
		
		public static function copyDate( date : Date ) : Date 
		{
			return new Date( date.getTime() );
		}
		
		public static function setTime( date : Date, time : Number ) : Date
		{
			date.hours = Math.floor(( time / (1000 * 60 * 60)) % 24);
			date.minutes = Math.floor(( time / (1000 * 60)) % 60);
			date.seconds = Math.floor(( time / 1000) % 60);
			date.milliseconds = Math.floor( time % 1000); 
			
			return date;
		}
		
		public static function addTime( date : Date, time : Number ) : Date 
		{
			date.milliseconds += time;
			
			return date;
		}
	}
}