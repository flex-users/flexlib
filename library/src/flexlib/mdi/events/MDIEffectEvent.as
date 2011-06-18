package flexlib.mdi.events
{
	import mx.events.EffectEvent;
	
	/**
	 * Event class dispatched at beginning and end of mdi effects for things like minimize, maximize, etc.
	 */
	public class MDIEffectEvent extends EffectEvent
	{
		/**
		 * Corresponds to type property of corresponding MDIManagerEvent.
		 */
		public var mdiEventType:String;
		
		/**
		 * List of windows involved in effect.
		 */
		public var windows:Array;
		
		/**
		 * Constructor
		 * 
		 * @param type EffectEvent.EFFECT_START or EfectEvent.EFFECT_END
		 * @param mdiEventType Corresponding mdi event type like minimize, maximize, tile, etc. Will be one of MDIManagerEvent's static types.
		 * @param windows List of windows involved in effect. Will be a single element except for cascade and tile.
		 */
		public function MDIEffectEvent(type:String, mdiEventType:String, windows:Array)
		{
			super(type);
			
			this.mdiEventType = mdiEventType;
			this.windows = windows;
		}
	}
}