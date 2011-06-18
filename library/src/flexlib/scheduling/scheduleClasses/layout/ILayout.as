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
	import flash.events.IEventDispatcher;
	
	import mx.collections.IList;
	
	public interface ILayout extends IEventDispatcher
	{
		function get entryLayout() : IEntryLayout;
		function set entryLayout( value : IEntryLayout ) : void;		
		function get items() : IList;
		function get contentWidth() : Number;
		function set contentWidth( value : Number ) : void;
		function get contentHeight() : Number;
		function set contentHeight( value : Number ) : void;
		function get viewportWidth() : Number;
		function set viewportWidth( value : Number ) : void;
		function get viewportHeight() : Number;
		function set viewportHeight( value : Number ) : void;
		function get startDate() : Date;
		function set startDate( value : Date ) : void;
		function get endDate() : Date;
		function set endDate( value : Date ) : void;
		function get totalMilliseconds() : Number;	
		function get xPosition() : Number;
		function set xPosition( value : Number ) : void;
		function get yPosition() : Number;
		function set yPosition( value : Number ) : void;
	}
}