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
	import flash.display.DisplayObject;
	
	import mx.controls.Button;
	import mx.core.ContainerLayout;
	import mx.core.LayoutContainer;
	import mx.core.UITextField;
	
	/**
	 * Class that holds window control buttons and handles general titleBar layout.
	 * Provides minimize, maximize/restore and close buttons by default.
	 * Subclass this class to create custom layouts that rearrange, add to, or reduce
	 * the default controls. Set layout property to switch between horizontal, vertical 
	 * and absolute layouts.
	 */
	public class MDIWindowControlsContainer extends LayoutContainer
	{
		public var window:MDIWindow;
		public var minimizeBtn:Button;
		public var maximizeRestoreBtn:Button;
		public var closeBtn:Button;
		
		/**
		 * Base class to hold window controls. Since it inherits from LayoutContainer, literally any layout
		 * can be accomplished by manipulating or subclassing this class.
		 */
		public function MDIWindowControlsContainer()
		{
			layout = ContainerLayout.HORIZONTAL;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!minimizeBtn)
			{
				minimizeBtn = new Button();
				minimizeBtn.buttonMode = true;
				addChild(minimizeBtn);
			}
			
			if(!maximizeRestoreBtn)
			{
				maximizeRestoreBtn = new Button();
				maximizeRestoreBtn.buttonMode = true;
				addChild(maximizeRestoreBtn);
			}
			
			if(!closeBtn)
			{
				closeBtn = new Button();
				closeBtn.buttonMode = true;
				addChild(closeBtn);
			}
		}
		
		/**
		 * Traditional override of built-in lifecycle function used to control visual 
		 * layout of the class. Minor difference is that size is set here as well because
		 * automatic measurement and sizing is not handled by framework since we go into 
		 * rawChildren (of MDIWindow).
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			if(window.showControls)
			{
				// respect window's showCloseButton property
				closeBtn.visible = closeBtn.includeInLayout = window.showCloseButton;
				
				// since we're in rawChildren we don't get measured and laid out by our parent
				// this routine finds the bounds of our children and sets our size accordingly
				var minX:Number = 9999;
				var minY:Number = 9999;
				var maxX:Number = -9999;
				var maxY:Number = -9999;
				for each(var child:DisplayObject in this.getChildren())
				{
					if(child != window.closeBtn || child == window.closeBtn && window.showCloseButton)
					{
						minX = Math.min(minX, child.x);
						minY = Math.min(minY, child.y);
						maxX = Math.max(maxX, child.x + child.width);
						maxY = Math.max(maxY, child.y + child.height);
					}
				}
				this.setActualSize(maxX - minX, maxY - minY);
				
				// now that we're sized we set our position
				// right aligned, respecting border width
				this.x = window.width - this.width - Number(window.getStyle("borderThicknessRight"));
				// vertically centered
				this.y = (window.titleBarOverlay.height - this.height) / 2;
			}
			
			// lay out the title field and icon (if present)
			var tf:UITextField = window.getTitleTextField();
			var icon:DisplayObject = window.getTitleIconObject();
			
			tf.x = Number(window.getStyle("borderThicknessLeft"));
			
			if(icon)
			{
				icon.x = tf.x;
				tf.x = icon.x + icon.width + 4;
			}
			
			// ghetto truncation
			if(!window.minimized)
			{
				tf.width = this.x - tf.x;
			}
			else
			{
				tf.width = window.width - tf.x - 4;
			}
		}
	}
}