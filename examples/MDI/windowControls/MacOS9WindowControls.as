package windowControls
{
	import flash.display.DisplayObject;
	
	import flexlib.mdi.containers.MDIWindowControlsContainer;
	
	import mx.core.ContainerLayout;
	import mx.core.UITextField;

	public class MacOS9WindowControls extends MDIWindowControlsContainer
	{
		public function MacOS9WindowControls()
		{
			layout = ContainerLayout.ABSOLUTE;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			this.setActualSize(window.width, window.titleBarOverlay.height);
			this.x = this.y = 0;
			
			closeBtn.x = Number(window.getStyle("borderThicknessLeft")) + 2;
			closeBtn.y = (window.titleBarOverlay.height - closeBtn.height) / 2;
			
			minimizeBtn.x = window.width - minimizeBtn.width - Number(window.getStyle("borderThicknessRight")) - 2;
			minimizeBtn.y = (window.titleBarOverlay.height - closeBtn.height) / 2;
			
			maximizeRestoreBtn.x = minimizeBtn.x - maximizeRestoreBtn.width - 5;
			maximizeRestoreBtn.y = (window.titleBarOverlay.height - closeBtn.height) / 2;
			
			// place icon and title textfield
			var tf:UITextField = window.getTitleTextField();
			var icon:DisplayObject = window.getTitleIconObject();
			var startX:Number = closeBtn.x + closeBtn.width + 4;
			var availWidth:Number = maximizeRestoreBtn.x - startX - 6;
			
			// make it as big as we've got room for
			tf.width = availWidth;
			// furthest left it will go is just after the close button
			tf.x = startX;
			
			// if there is room to spare center it
			if(tf.textWidth < availWidth)
			{
				tf.x += (availWidth - tf.textWidth) / 2;
			}
			
			// if an icon is present we adjust
			if(icon)
			{
				// start at the base position
				icon.x = startX;
				
				// how much room do we need?
				var fullWidth:Number = icon.width + 4 + tf.textWidth;
				
				// again, if we have room we center
				if(fullWidth < availWidth)
				{
					icon.x += (availWidth - fullWidth) / 2;					
				}
				
				// position and size textfield
				tf.x = icon.x + icon.width + 4;
				tf.width = maximizeRestoreBtn.x - tf.x - 4;
			}
			
			closeBtn.visible = minimizeBtn.visible = maximizeRestoreBtn.visible = window.hasFocus;
		}
	}
}