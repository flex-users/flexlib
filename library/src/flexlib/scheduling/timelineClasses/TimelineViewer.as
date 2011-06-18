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
	import flash.display.DisplayObject;
	import flash.events.Event;

	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;	
	
	/**
	 * @private
	 */
	public class TimelineViewer extends UIComponent
	{
		public var itemRenderer : IFactory;
		private var freeRenderers : Array;
		private var visibleRenderers : Array;
		private var layout : TimelineLayout;		
		
		public function TimelineViewer()
		{
			itemRenderer = new ClassFactory( SimpleTimelineEntryRenderer );
			freeRenderers = new Array();
			visibleRenderers = new Array();			
		}
		
		public function update( event : Event ) : void
		{
			layout = event.target as TimelineLayout;
			invalidateDisplayList();
		}
				
		protected override function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth , unscaledHeight );
			render( layout );
		}
		
		private function render( layout : TimelineLayout ) : void 
		{
			if( layout == null ) return;
			
			var oldRenderers : Array = visibleRenderers;
			visibleRenderers = new Array();
			
			var xPosition : Number = layout.xPosition;
			
			for each( var item : TimelineLayoutItem in layout.items )
			{
				var renderer : ITimelineEntryRenderer = oldRenderers.pop();
				if( renderer != null )
				{
					renderer.x = item.x - xPosition;
					renderer.width = item.width;
					renderer.y = item.y;
					renderer.data = item.data;
				}
				else 
				{
					renderer = getRenderer();					
					renderer.x = item.x - xPosition;
					renderer.y = item.y;
					renderer.height = item.height;					
					renderer.data = item.data;
					
					addChild( DisplayObject( renderer ) );
				}
				visibleRenderers.push( renderer );
			}
			
			removeUnusedRenderers( oldRenderers );			
		}
		
		private function removeUnusedRenderers( oldRenderers : Array ) : void
		{
			for each( var freeRenderer : DisplayObject in oldRenderers )
			{
				freeRenderers.push( removeChild( freeRenderer ) );
			}
		}
		
		private function getRenderer() : ITimelineEntryRenderer
		{
			if( freeRenderers.length > 0 )
			{
				return freeRenderers.pop();
			}
			return itemRenderer.newInstance();
		}		
	}
}