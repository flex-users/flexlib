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
	import flexlib.mdi.effects.IMDIEffectsDescriptor;
	import flexlib.mdi.effects.MDIEffectsDescriptorBase;
	import flexlib.mdi.effects.effectClasses.MDIGroupEffectItem;
	import flexlib.mdi.managers.MDIManager;
	
	import mx.effects.Blur;
	import mx.effects.Effect;
	import mx.effects.Move;
	import mx.effects.Parallel;
	import mx.effects.Resize;
	import mx.effects.Rotate;
	import mx.effects.Sequence;
	import mx.effects.WipeDown;
	import mx.events.EffectEvent;
	import mx.effects.AnimateProperty;
	import mx.effects.Dissolve;
	import flash.geom.Rectangle;
	
	/**
	 * Collection of effects that limit movement to one dimension (horizontal/vertical) at a time.
	 */
	public class MDILinearEffects extends MDIEffectsDescriptorBase implements IMDIEffectsDescriptor
	{
		override public function getWindowMinimizeEffect(window:MDIWindow, manager:MDIManager, moveTo:Point=null):Effect
		{
			var seq:Sequence = new Sequence();
			
			var resizeW:Resize = new Resize(window);
			resizeW.widthTo = window.minWidth;
			resizeW.duration = 100;
			seq.addChild(resizeW);
			
			var resizeH:Resize = new Resize(window);
			resizeH.heightTo = window.minimizeHeight;
			resizeH.duration = 100;
			seq.addChild(resizeH);
			
			var moveX:Move = new Move(window);
			moveX.xTo = moveTo.x;
			moveX.duration = 100;
			seq.addChild(moveX);
			
			var moveY:Move = new Move(window);
			moveY.yTo = moveTo.y;
			moveY.duration = 100;
			seq.addChild(moveY);
			
			seq.end();
			return seq;
		}
		
		override public function getWindowRestoreEffect(window:MDIWindow, manager:MDIManager, restoreTo:Rectangle):Effect
		{
			var seq:Sequence = new Sequence();
			
			var moveY:Move = new Move(window);
			moveY.yTo = restoreTo.y;
			moveY.duration = 100;
			seq.addChild(moveY);
			
			var moveX:Move = new Move(window);
			moveX.xTo = restoreTo.x;
			moveX.duration = 100;
			seq.addChild(moveX);
			
			var resizeW:Resize = new Resize(window);
			resizeW.widthTo = restoreTo.width;
			resizeW.duration = 100;
			seq.addChild(resizeW);
			
			var resizeH:Resize = new Resize(window);
			resizeH.heightTo = restoreTo.height;
			resizeH.duration = 100;
			seq.addChild(resizeH);
			
			seq.end();
			return seq;
		}
		
		override public function getWindowMaximizeEffect(window:MDIWindow, manager:MDIManager, bottomOffset:Number = 0):Effect
		{
			var seq:Sequence = new Sequence(window);
			
			var moveX:Move = new Move(window);
			moveX.xTo = 0;
			moveX.duration = 100;
			seq.addChild(moveX);
			
			var moveY:Move = new Move(window);
			moveY.yTo = 0;
			moveY.duration = 100;
			seq.addChild(moveY);
			
			var resizeW:Resize = new Resize(window);
			resizeW.widthTo = manager.container.width;
			resizeW.duration = 100;
			seq.addChild(resizeW);
			
			var resizeH:Resize = new Resize(window);
			resizeH.heightTo = manager.container.height - bottomOffset;
			resizeH.duration = 100;
			seq.addChild(resizeH);
			
			seq.end();
			return seq;
		}
		
		override public function getWindowCloseEffect(window:MDIWindow, manager:MDIManager):Effect
		{
			window.minWidth = window.minHeight = 1;
			
			var resize:Resize = new Resize(window);
			resize.widthTo = resize.heightTo = 1;
			resize.duration = 100;
			return resize;
		}		
	}
}