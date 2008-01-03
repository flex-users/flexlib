package flexlib.events
{
	import flash.events.Event;

	public class SuperTabEvent extends Event
	{
		public static const TAB_CLOSE:String = "tabClose";
		public static const TAB_UPDATED:String = "tabUpdated";
		
		public var tabIndex:Number;
		
		public function SuperTabEvent(type:String, tabIndex:Number=-1, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.tabIndex = tabIndex;
			
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new SuperTabEvent(type, tabIndex, bubbles, cancelable);
		}
		
	}
}