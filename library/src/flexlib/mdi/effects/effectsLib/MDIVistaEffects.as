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
	import flash.geom.Rectangle;
	
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
	
	/**
	 * Collection of effects inspired by Windows Vista.
	 */
	public class MDIVistaEffects extends MDIEffectsDescriptorBase implements IMDIEffectsDescriptor
	{		
		public function MDIVistaEffects(duration:Number = 150):void
		{
			this.duration = duration;	
		}		
		
		override public function getWindowAddEffect(window:MDIWindow, manager:MDIManager):Effect
		{			
			var parallel:Parallel = new Parallel(window);

			var blurSequence:Sequence = new Sequence();

			var blurOut:Blur = new Blur();
				blurOut.blurXFrom = 0;
				blurOut.blurYFrom = 0;
				blurOut.blurXTo = 10;
				blurOut.blurYTo = 10;
			
			
			blurSequence.addChild(blurOut);
			
			var blurIn:Blur = new Blur();
				blurIn.blurXFrom = 10;
				blurIn.blurYFrom = 10;
				blurIn.blurXTo  = 0;
				blurIn.blurYTo = 0;
				
			
			blurSequence.addChild(blurIn);

			parallel.addChild(blurSequence);
	
			
			parallel.duration = this.duration;
			return parallel;
		}
		
		override public function getWindowMinimizeEffect(window:MDIWindow, manager:MDIManager, moveTo:Point = null):Effect
		{
			var sequence : Sequence = new Sequence(window);
				//sequence.duration = 200;
			var parallel : Parallel = new Parallel();
			
			var resize:Resize = new Resize(window);
				resize.widthTo = window.minWidth;
				resize.heightTo = window.minimizeHeight;
				resize.duration = this.duration;
			parallel.addChild(resize);
			

			var blurOut : Blur = new Blur();
				blurOut.blurXFrom = 1;
				blurOut.blurXTo = .2;
				blurOut.blurYFrom = 1;
				blurOut.blurYTo = .2;
				
			//parallel.addChild(blurOut);
		
			sequence.addChild(parallel);

			var move:Move = new Move(window);
				move.xTo = moveTo.x;
				move.yTo = moveTo.y;
				//move.easingFunction = minEasingFunction;
				move.duration = 150;
			sequence.addChild(move);
				
				var blurIn : Blur = new Blur();
					blurOut.blurXFrom = .2;
					blurOut.blurXTo = 1;
					blurOut.blurYFrom = .2;
					blurOut.blurYTo = 1;
				
				
			//sequence.addChild(blurIn);
			
			return sequence;
		}
		
		private function minEasingFunction(t:Number, b:Number, c:Number, d:Number):Number
		{
  			var ts:Number=(t/=d)*t;
 			var tc:Number=ts*t;
  			return b+c*(0*tc*ts + -2*ts*ts + 10*tc + -15*ts + 8*t);
		}
		
		override public function getWindowRestoreEffect(window:MDIWindow, manager:MDIManager, restoreTo:Rectangle):Effect
		{
			var parallel:Parallel = new Parallel(window);
			
			var move:Move = new Move(window);
			move.xTo = restoreTo.x;
			move.yTo = restoreTo.y;
			move.duration = 150;
			parallel.addChild(move);
			
			var resize:Resize = new Resize(window);
			resize.widthTo = restoreTo.width;
			resize.heightTo = restoreTo.height;
			resize.duration = this.duration;
			parallel.addChild(resize);
			
			parallel.end();
			return parallel;
		}
		
		override public function getWindowMaximizeEffect(window:MDIWindow, manager:MDIManager, bottomOffset:Number = 0):Effect
		{
			var parallel:Parallel = new Parallel(window);
			
			var move:Move = new Move(window);
			move.xTo = 0;
			move.yTo = 0;
			move.duration = 300;
			parallel.addChild(move);
			
			var resize:Resize = new Resize(window);
			resize.heightTo = manager.container.height - bottomOffset;
			resize.widthTo = manager.container.width;
			resize.duration = this.duration;
			parallel.addChild(resize);
			
			parallel.end();
			return parallel;
		}
		
		override public function getWindowCloseEffect(window:MDIWindow, manager:MDIManager):Effect
		{
			var blur:Blur = new Blur(window);
				blur.blurXFrom = 0;
				blur.blurYFrom = 0;
				blur.blurXTo = 10;
				blur.blurYTo = 10;
				blur.duration = this.duration;
				return blur;
		}
		
		override public function getTileEffect(items:Array,manager:MDIManager):Effect
		{			
			var effect : Parallel = new Parallel();
			
			for each(var item:MDIGroupEffectItem  in items)
			{	
				
				
				
				if( ! item.isCorrectPosition )
				{
				
					var move:Move = new Move(item.window);
						move.xTo = item.moveTo.x;
						move.yTo = item.moveTo.y;
	
					effect.addChild(move);
				}
				
				if( ! item.isCorrectSize )
				{
					item.setWindowSize();
				}
			}
			
			effect.duration = this.duration;
			
			return effect;
		}
		
		private function cascadeEasingFunction(t:Number, b:Number, c:Number, d:Number):Number 
		{
			var ts:Number=(t/=d)*t;
  			var tc:Number=ts*t;
  			return b+c*(33*tc*ts + -106*ts*ts + 126*tc + -67*ts + 15*t);
		}
		
		override public function getCascadeEffect(items:Array,manager:MDIManager):Effect
		{
			var parallel:Parallel = new Parallel();
			
			for each(var item:MDIGroupEffectItem  in items)
			{
				var move:Move = new Move(item.window);
					move.xTo = item.moveTo.x;
					move.yTo = item.moveTo.y;
					//move.easingFunction = this.cascadeEasingFunction;
					move.duration = this.duration;
					parallel.addChild(move);
					
				var resize:Resize = new Resize(item.window);
					resize.widthTo = item.widthTo;
					resize.heightTo = item.heightTo;
					resize.duration = this.duration;
					parallel.addChild(resize);
			}
			
			return parallel;
		}
			
		override public function reTileMinWindowsEffect(window:MDIWindow, manager:MDIManager, moveTo:Point):Effect
		{
			var move:Move = new Move(window);
			move.xTo = moveTo.x;
			move.yTo = moveTo.y;
			move.duration = this.duration;
			move.end();
			return move;
		}		
	}
}