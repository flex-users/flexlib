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
*/package flexlib.scheduling.scheduleClasses.viewers
{
	import flexlib.scheduling.scheduleClasses.layout.BackgroundLayout;
	import flexlib.scheduling.scheduleClasses.layout.BackgroundLayoutItem;
	import flexlib.scheduling.scheduleClasses.renderers.BackgroundLayoutItemRenderer;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.ScrollEvent;	
	
	/**
	 * @private
	 */
	public class BackgroundViewer extends UIComponent  
	{		
		private var freeRenderers : Array;
		private var visibleRenderers : Array;
		private var layout : BackgroundLayout;
				
		public function BackgroundViewer()
		{
			freeRenderers = new Array();
			visibleRenderers = new Array();		
		}
		
		public function update( event : Event ) : void
		{
			layout = event.target as BackgroundLayout;
			invalidateDisplayList();
		}
		
		protected override function measure() : void
		{
			super.measure();
			if( layout )
			{ 
				measuredWidth = layout.contentWidth;
				measuredHeight = 100;	
			} 
		}
		
		protected override function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth , unscaledHeight );
			render( layout );	
		}
		
		private function render( layout : BackgroundLayout ) : void 
		{
			if( layout == null ) return;
			
			var oldRenderers : Array = visibleRenderers;
			visibleRenderers = new Array();
			
			for each( var item : BackgroundLayoutItem in layout.items )
			{
				var renderer : BackgroundLayoutItemRenderer = oldRenderers.pop();
				if( renderer != null )
				{
					renderer.x = item.x - layout.xPosition;
					renderer.width = item.width;
					renderer.height = item.height;
					renderer.setStyle( "backgroundColor", item.backgroundColor );
					renderer.toolTip = item.toolTip;
				} 
				else 
				{
					renderer = getRenderer();
					
					renderer.x = item.x - layout.xPosition;
					renderer.width = item.width;
					renderer.height = item.height;
					renderer.setStyle( "backgroundColor", item.backgroundColor );
					renderer.toolTip = item.toolTip;
					
					addChild( renderer );
				}
				visibleRenderers.push( renderer );
			}
			
			removeUnusedRenderers( oldRenderers );			
		}
		
		
		private function removeUnusedRenderers( oldRenderers : Array ) : void
		{
			for each( var freeRenderer : DisplayObject in oldRenderers ){
				freeRenderers.push( removeChild( freeRenderer ));
			}
		}
		
		private function getRenderer() : BackgroundLayoutItemRenderer
		{
			if( freeRenderers.length > 0 )
			{
				return freeRenderers.pop();
			}
			return new BackgroundLayoutItemRenderer();
		}		
	}
}