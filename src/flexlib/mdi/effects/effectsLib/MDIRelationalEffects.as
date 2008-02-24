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
package flexlib.mdi.effects.effectsLib
{
	import flash.geom.Point;
	
	import flexlib.mdi.containers.MDIWindow;
	import flexlib.mdi.effects.MDIEffectsDescriptorBase;
	import flexlib.mdi.managers.MDIManager;
	
	import mx.effects.Effect;
	import mx.effects.Parallel;
	import mx.effects.Resize;
	
	import mx.events.EffectEvent;
	import mx.effects.Move;
	import flash.geom.Rectangle;
	
	public class MDIRelationalEffects extends MDIVistaEffects
	{
		override public function getWindowMinimizeEffect(window:MDIWindow, manager:MDIManager, moveTo:Point=null):Effect
		{
			
			var parallel:Parallel = super.getWindowMinimizeEffect(window,manager,moveTo) as Parallel;
			
			parallel.addEventListener(EffectEvent.EFFECT_END, function():void {manager.tile(true, 10); } );
			
			
			return parallel;
		}
		
		override public function getWindowRestoreEffect(window:MDIWindow, manager:MDIManager, restoreTo:Rectangle):Effect
		{
			var parallel:Parallel = super.getWindowRestoreEffect(window, manager, restoreTo) as Parallel;
			
			parallel.addEventListener(EffectEvent.EFFECT_START, function():void {manager.tile(true, 10); } );
			
			return parallel;
		}
		
		override public function reTileMinWindowsEffect(window:MDIWindow, manager:MDIManager, moveTo:Point):Effect
		{
			var move:Move = super.reTileMinWindowsEffect(window, manager, moveTo) as Move;
			manager.bringToFront(window);
			return move;
		}
		
		
		
	}
}