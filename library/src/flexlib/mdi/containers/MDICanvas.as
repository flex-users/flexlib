/*
Copyright (c) 2007 FlexLib Contributors.  See:
    http://code.google.com/p/flexlib/wiki/ProjectContributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package flexlib.mdi.containers
{
	import flexlib.mdi.effects.IMDIEffectsDescriptor;
	import flexlib.mdi.managers.MDIManager;

	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	/**
	 * Convenience class that allows quick MXML implementations by implicitly creating
	 * container and manager members of MDI. Will auto-detect MDIWindow children
	 * and add them to list of managed windows.
	 */
	public class MDICanvas extends Canvas
	{
		public var windowManager:MDIManager;

		public function MDICanvas()
		{
			super();
			windowManager = new MDIManager(this);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}

		private function onCreationComplete(event:FlexEvent):void
		{
			for each(var child:UIComponent in getChildren())
			{
				if(child is MDIWindow)
				{
					windowManager.add(child as MDIWindow);
				}
			}
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}

		/**
		 * Proxy to MDIManager effects property.
		 *
		 * @deprecated use effects and class
		 *
		 */
		public function set effectsLib(clazz:Class):void
		{
			this.windowManager.effects = new clazz();
		}

		/**
		 * Proxy to MDIManager property of same name.
		 */
		public function set effects(effects:IMDIEffectsDescriptor):void
		{
			this.windowManager.effects = effects;
		}

		/**
		 * Proxy to MDIManager property of same name.
		 */
		public function get enforceBoundaries():Boolean
		{
			return windowManager.enforceBoundaries;
		}

		public function set enforceBoundaries(value:Boolean):void
		{
			windowManager.enforceBoundaries = value;
		}

		/**
		 * Proxy to MDIManager property of same name.
		 */
		public function get snapDistance():Number
		{
			return windowManager.snapDistance;
		}
		public function set snapDistance(value:Number):void
		{
			windowManager.snapDistance = value;
		}

		/**
		 * Proxy to MDIManager property of same name.
		 */
		public function get tilePadding():Number
		{
			return windowManager.tilePadding;
		}
		public function set tilePadding(value:Number):void
		{
			windowManager.tilePadding = value;
		}
	}
}