package flexlib.containers.accordionClasses
{
	/**
	 * Defines static constants to specify the header location for a VAccordion or HAccordion.
	 * 
	 * @see flexlib.containers.VAccordion
	 * @see flexlib.containers.HAccordion
	 */
	public class AccordionHeaderLocation
	{
		/**
		 * Only applicable for a VAccordion. Places the header above the content. This
		 * is the normal Accordion functionality and is the default setting for a VAccordion.
		 */
		static public const ABOVE:String = "above";
		
		/**
		 * Only applicable for a VAccordion. Places the header below the content. 
		 */
		static public const BELOW:String = "below";
		
		/**
		 * Only applicable for a HAccordion. Places the header to the left of the content. 
		 * This is the default setting for a HAccordion.
		 */
		static public const LEFT:String = "left";
		
		/**
		 * Only applicable for a HAccordion. Places the header to the right of the content.
		 */
		static public const RIGHT:String = "right";
	}
}