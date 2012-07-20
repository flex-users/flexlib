package flexlib.mdi.containers
{
	import mx.containers.Canvas;
	import mx.managers.IFocusManagerComponent
	
	// This extended Canvas class allows for a canvas to be focused. This means that an 
	// accessibilityName/Description can be added and read by a screen reader.
	public class FocusableCanvas extends Canvas implements IFocusManagerComponent
	{
		public function FocusableCanvas()
		{
			super();
			
			focusEnabled = true;
			hasFocusableChildren = true;
			mouseFocusEnabled = true;
			tabFocusEnabled = true;
			tabIndex = -1
		}
	}
}