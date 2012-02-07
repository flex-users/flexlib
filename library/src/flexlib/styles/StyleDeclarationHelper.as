package flexlib.styles
{
	import flash.utils.getQualifiedClassName;
	
	import mx.core.FlexVersion;

	public class StyleDeclarationHelper
	{
		
		/**
		 * Gets the style selector for the specified class.
		 * @see getStyleSelectorForClassName
		 * 
		 * @param c The component class to get the style selector for
		 * @return style selector string for given class
		 * 
		 */
		public static function getStyleSelectorForClass(c:Class):String
		{
			return getStyleSelectorForClassName(flash.utils.getQualifiedClassName(c));
		}
		
		/**
		 * Gets the style selector for the specified class name.
		 * 
		 * Starting in Flex 4, component selectors passed to StyleManager.getStyleDeclaration and StyleManager.setStyleDeclaration
		 * must be fully qualified class names. In versions of Flex &lt; 4, the class name itself was used.
		 * 
		 * @see http://flexdevtips.blogspot.com/2009/03/setting-default-styles-for-custom.html
		 * 
		 * @param fullyQualifiedName The fully qualified name of the class to get the selector for
		 * @return style selector string
		 * 
		 */
		public static function getStyleSelectorForClassName(fullyQualifiedName:String):String
		{
			if (FlexVersion.compatibilityVersion >= FlexVersion.VERSION_4_0)
				return fullyQualifiedName.replace("::", ".");
			
			var classNameStart:int = fullyQualifiedName.lastIndexOf(":");
			if(classNameStart != -1)
				return fullyQualifiedName.substr(classNameStart + 1);
			return fullyQualifiedName;
		}
	}
}