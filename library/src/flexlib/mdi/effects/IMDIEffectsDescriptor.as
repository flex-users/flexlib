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

package flexlib.mdi.effects
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flexlib.mdi.containers.MDIWindow;
	import flexlib.mdi.managers.MDIManager;
	
	import mx.effects.Effect;
	
	/**
	 * Interface expected by MDIManager. All effects classes must implement this interface.
	 */
	public interface IMDIEffectsDescriptor
	{
		// window effects
		
		function getWindowAddEffect(window:MDIWindow, manager:MDIManager):Effect;
		
		function getWindowMinimizeEffect(window:MDIWindow, manager:MDIManager, moveTo:Point = null):Effect;
	
		function getWindowRestoreEffect(window:MDIWindow, manager:MDIManager, restoreTo:Rectangle):Effect;
		
		function getWindowMaximizeEffect(window:MDIWindow, manager:MDIManager, bottomOffset:Number = 0):Effect;
	
		function getWindowCloseEffect(window:MDIWindow, manager:MDIManager):Effect;
		
		function getWindowFocusStartEffect(window:MDIWindow, manager:MDIManager):Effect;
	
		function getWindowFocusEndEffect(window:MDIWindow, manager:MDIManager):Effect;
		
		function getWindowDragStartEffect(window:MDIWindow, manager:MDIManager):Effect;
		
		function getWindowDragEffect(window:MDIWindow, manager:MDIManager):Effect;
		
		function getWindowDragEndEffect(window:MDIWindow, manager:MDIManager):Effect;
	
		function getWindowResizeStartEffect(window:MDIWindow, manager:MDIManager):Effect;
		
		function getWindowResizeEffect(window:MDIWindow, manager:MDIManager):Effect;
		
		function getWindowResizeEndEffect(window:MDIWindow, manager:MDIManager):Effect;
	
		// group effects
		
		function getTileEffect(items:Array, manager:MDIManager):Effect;
		
		function getCascadeEffect(items:Array, manager:MDIManager):Effect;
		
		function reTileMinWindowsEffect(window:MDIWindow, manager:MDIManager, moveTo:Point):Effect;
	}
}