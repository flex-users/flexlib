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
	import flexlib.scheduling.scheduleClasses.IScheduleEntry;
	import flexlib.scheduling.scheduleClasses.layout.EntryLayoutItem;
	import flexlib.scheduling.scheduleClasses.layout.IEntryLayout;
	import flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent;
	import flexlib.scheduling.scheduleClasses.renderers.GradientScheduleEntryRenderer;
	import flexlib.scheduling.scheduleClasses.renderers.IScheduleEntryRenderer;
	import flexlib.scheduling.scheduleClasses.utils.Selection;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	
	/**
	 *  Name of CSS style declaration that specifies styles for the schedule entries
	 */
	[Style(name="entryStyleName", type="String", inherit="yes")]			

	/**
	 * @private
	 */
	public class EntryViewer extends UIComponent 
	{
		public var entryRenderer : IFactory;
		private var freeRenderers : Array;
		private var visibleRenderers : Dictionary;
		private var layout : IEntryLayout;		
		private var selection : Selection;
		private var isShiftKey : Boolean;
		private var isCtrlKey : Boolean;
		
		public function EntryViewer()
		{
			entryRenderer = new ClassFactory( GradientScheduleEntryRenderer );
			
			freeRenderers = new Array();
			visibleRenderers = new Dictionary();	
			
			selection = new Selection();
			
			addEventListener( MouseEvent.MOUSE_UP, onClickEntry );
			addEventListener( Event.ACTIVATE, addKeyListeners );
			addEventListener( Event.DEACTIVATE, removeKeyListeners );
		}
		
		public function get allowMultipleSelection() : Boolean
		{
			return selection.allowMultipleSelection;
		}
		
		public function set allowMultipleSelection( value : Boolean ) : void
		{
			selection.allowMultipleSelection = value;
		}		
		
		public function get selectedItem() : IScheduleEntry
		{
			return IScheduleEntry( selection.selectedItem );
		}
		
		public function set selectedItem( value : IScheduleEntry ) : void
		{
			selection.selectedItem = value;
			invalidateDisplayList();
		}
		
		public function get selectedItems() : Array
		{
			return selection.selectedItems
		}
		
		public function set selectedItems( value : Array ) : void
		{
			selection.selectedItems = value;			
		}
		
		public function update( event : LayoutUpdateEvent ) : void
		{
			layout = IEntryLayout( event.layout );
			invalidateDisplayList();
		}
		
		override protected function measure() : void
		{
			super.measure();
			if( layout == null ) return;
			
			measuredWidth = layout.contentWidth;
			measuredHeight = layout.contentHeight;
		}
		
		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth , unscaledHeight );			
			render( layout );
		}
		
		override protected function keyDownHandler( event : KeyboardEvent ) : void
		{
			super.keyDownHandler( event );
			if( event.ctrlKey )
			{
				isCtrlKey = true;
			}
		}
		
		override protected function keyUpHandler( event : KeyboardEvent ) : void 
		{
			super.keyUpHandler( event );
			if( !event.ctrlKey )
			{
				isCtrlKey = false;
			}
		}
		
		private function addKeyListeners( event : Event ) : void
		{
			if( stage == null ) return;
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );	
		}
		
		private function removeKeyListeners( event : Event ) : void
		{
			if( stage == null ) return;
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.removeEventListener( KeyboardEvent.KEY_UP, keyUpHandler );	
		}		
		
		private function onClickEntry( event : MouseEvent ) : void 
		{
			event.stopPropagation();
			
			var renderer : IScheduleEntryRenderer = findRendererInParentChain( event.target );
			if( renderer == null ) return;
			
			var entry : IScheduleEntry = renderer.entry;
			createSelections( entry );
		}
		
		private function createSelections( entry : IScheduleEntry ) : void
		{
			if( entry == null ) return;
			
			if( !allowMultipleSelection )
			{
				selectOrDeselect( entry );
			}
			else
			{
				var hasZeroItems : Boolean = ( selection.selectedItems.length == 0 );					
				if( hasZeroItems )
				{
					selection.addItem( entry );						
				}
				else
				{
					if( !isCtrlKey )
					{
						selection.clear();
						selectOrDeselect( entry );
					}
					else
					{						
						selectOrDeselect( entry );
					}	
				}
			}
			
			updateSelection();
			dispatchEvent( new Event( "change" ) );
		}
		
		private function selectOrDeselect( entry : IScheduleEntry ) : void
		{
			if( selection.hasItem( entry ) )
			{
				selection.removeItem( entry );
			}
			else 
			{
				selection.addItem( entry );
			}		
		}
		
		/**
		 * Because we are relying on bubbling we 
		 * have to make sure, that the event comes from the renderer 
		 * actually and not from one of its child components. 
		 * We traverse up the parent chain of the clicked target 
		 * until we found an entryRenderer or null.
		 * 
		 * THINK : Normally i'd say, this is not our business, but 
		 * we want to keep the renderer as simple as possible to make 
		 * it easier for users to implement a renderer. Otherwise 
		 * the renderer would have to catch events from its child 
		 * components and redispatch them 
		 */
		private function findRendererInParentChain( target : Object ) : IScheduleEntryRenderer
		{
			while( target != null )
			{
				if( target is IScheduleEntryRenderer ) return target as IScheduleEntryRenderer;
				target = target.parent;
			}
			return null;
		}
		
		private function updateSelection() : void
		{
			for each( var renderer : IScheduleEntryRenderer in visibleRenderers )
			{
				renderer.selected = selection.hasItem( renderer.data );
			}
		}
		
		private function render( layout : IEntryLayout ) : void 
		{
			if( layout == null ) return;
			
			var oldRenderers : Dictionary = visibleRenderers;
			visibleRenderers = new Dictionary();
			
			for each( var item : EntryLayoutItem in layout.items )
			{
				var renderer : IScheduleEntryRenderer = oldRenderers[ item ];
				if( renderer != null )
				{
					renderer.x = item.x / item.zoom - layout.xPosition;
					renderer.y = item.y - layout.yPosition + 2;
					renderer.width = item.width / item.zoom;
					renderer.height = item.height - 4;
					delete oldRenderers[ item ];
				}
				else 
				{
					renderer = getRenderer();
					var style : Object = getStyle( "entryStyleName" );
					if( style != null ) renderer.styleName = style;
					renderer.x = item.x / item.zoom - layout.xPosition;
					renderer.y = item.y - layout.yPosition + 2;
					renderer.width = item.width / item.zoom;
					renderer.height = item.height - 4;
					
					addChild( DisplayObject( renderer ) );
					renderer.data = item.data;
				}
				visibleRenderers[ item ] = renderer;
			}
			
			removeUnusedRenderers( oldRenderers );			
			updateSelection();
		}
		
		private function removeUnusedRenderers( oldRenderers : Dictionary ) : void
		{
			for each( var freeRenderer : DisplayObject in oldRenderers )
			{
				freeRenderers.push( removeChild( freeRenderer ));
			}
		}
		
		private function getRenderer() : IScheduleEntryRenderer
		{
			if( freeRenderers.length > 0 )
			{
				return freeRenderers.pop();
			}			
			return entryRenderer.newInstance();
		}
	}
}