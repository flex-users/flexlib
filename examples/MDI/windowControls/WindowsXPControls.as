package windowControls
{
	import flexlib.mdi.containers.MDIWindowControlsContainer;

	public class WindowsXPControls extends MDIWindowControlsContainer
	{
		public function WindowsXPControls()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			setStyle("horizontalGap", 2);
		}
	}
}