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

package flexlib.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.skins.halo.BrokenImageBorderSkin;
	import flash.display.BlendMode;
	import flexlib.controls.iconLoaderClasses.IIconParser;
	import flexlib.controls.iconLoaderClasses.IconParserFactory;
	
	/**
	 * Skin used to display border around "broken link" image
	 * @default BrokenImageBorderSkin
	 */

	[Style(name="brokenImageBorderSkin", type="Class", inherit="no")]
	
	/**
	 * Skin displayed when a URL cannot be loaded
	 * @default BrokenImageSkin
	 */
	
	[Style(name="brokenImageSkin", type="Class", inherit="no")]
	
	/**
	 * The <code>IconLoader</code> component converts a Macintosh OS X (.icns) or Windows XP (.ico) icon
	 * file, along with its alpha mask, to a Flex 2 UIComponent. The interface is similar to that of 
	 * <code>mx:Image</code> in that the <code>source</code> property can be set to either an
	 * embedded icon or a URL that an asset can be loaded from.
	 * 
	 * <p>The current implementations of the .ico and .icns parsers only support 32 bit icons. For .icns
	 * files, this means that the following types are supported, along with their associated masks:
	 * 'is32', 'il32', 'ih32', and 'it32'. For .ico files, only "XP" style icons, where an 8-bit alpha
	 * mask is included in the image data, are supported.</p>
	 * 
	 * <p>Example MXML usage:</p>
	 * 
	 * <pre>
	 * &lt;IconLoader xmlns="flexlib.controls.&#42;"
	 * 		source="&#64;Embed( source='assets/app_icon.icns', mime-type='application/octet-stream' )"
	 * 		scaleContent="true"&gt;
	 * </pre>
	 */
	 
	public class IconLoader extends UIComponent
	{
		/**
		 * Constructor
		 */
		 
		public function IconLoader()
		{
			super();
		}
		
		/**
		 * Sets the location of the icon data.
		 * 
		 * <p>This property can be set to either a String or a class that extends ByteArray. In the case
		 * where the source is a String, it is treated as a URL from which an icon file can be
		 * retrieved. Setting <code>source</code> to a String initiates a process where the 
		 * image is retrieved from the URL. In the case of a ByteArray subclass, the class is
		 * immediately parsed and the display list is updated. The latter scenario is the
		 * result of using the &#64;Embed(...) compiler directive.</p>
		 * 
		 * <p>Note that when using the &#64;Embed(...) directive, the <code>mime-type</code> property of
		 * the &#64;Embed directive must be set to <code>application/octet-stream</code></p>
		 */
		
		[Bindable( "sourceChange" )]
		public function get source() : Object
		{
			return _source;
		}
		
		public function set source( val : Object ) : void
		{
			if( _source != val )
			{
				_source = val;
				
				if( _source is Class )
				{
					var inst	: Object = new _source();
					if( inst is ByteArray )
					{
						parseIcon( inst as ByteArray );
						invalidateSize();
						invalidateDisplayList();
					}
				}
				else if( _source is String )
				{
					loadImageUrl( _source as String );
				}
				
				dispatchEvent( new Event( "sourceChange" ) );
			}
		}
		
		/**
		 * @private
		 * The icon file source
		 */
		 
		private var _source 	: Object;
		
		/**
		 * Enables or disables scaling of the icon content to fit this control's bounds.
		 * 
		 * <p>When this property is set to <code>true</code>, the icon's image will be scaled
		 * to fill the bounds of this control. When calculating the scale ratio, the lesser
		 * of the bouding width and height is used.</p>
		 * 
		 * <p>If this property is set to <code>false</code> an icon is chosen from those 
		 * contained in the source file based on the size of this control.</p>
		 * 
		 * <p>Icon files typically contain icons at multiple sizes. When choosing which icon
		 * to display, this control considers the value of the <code>scaleContents</code>
		 * propety. If <code>scaleContents</code> is <code>false</code>, the largest icon that 
		 * does not exceed the control's bounds is chosen. When the value is <code>true</code>,
		 * the icon chosen is the smallest icon that exceeds this control's bounds.</p>
		 * 
		 * @default false
		 */
		
		[Bindable( "scaleContentSchange" )]
		public function get scaleContent() : Boolean
		{
			return _scaleContent;
		}
		
		/**
		 * @private
		 */
		 
		public function set scaleContent( val : Boolean ) : void
		{
			if( _scaleContent != val )
			{
				_scaleContent = val;
				invalidateDisplayList();
				dispatchEvent( new Event( "scaleContentSchange" ) );
			}
		}
		
		/**
		 * @private
		 * Flags indicating that the icon should be scaled to fill this control's bounds.
		 */
		 
		private var _scaleContent	: Boolean = false;
		
		/**
		 * @private
		 */
		 
		override protected function createChildren() : void
		{
			super.createChildren();
			
			mask = new Sprite();
			addChild( mask );
		}
		
		/**
		 * @private
		 */
		
		override protected function measure() : void
		{
			super.measure();
			
			if( _parser != null  && _parser.validIcon && _parser.sizes.length > 0 )
			{
				var s	: int = _parser.sizes[ 0 ];
				
				measuredHeight = s;
				measuredWidth = s;
			}
		}
		
		/**
		 * @private
		 */
		
		override protected function updateDisplayList( w : Number, h : Number ) : void
		{
			super.updateDisplayList( w, h );
			
			var g	 : Graphics = ( mask as Sprite ).graphics;
			
			g.clear();
			g.beginFill( 0, 0 );
			g.drawRect( 0, 0, w + 1, h + 1 );
			g.endFill();
			
			var child	: DisplayObject = getChildByName( "iconImage" );
			if( child != null )
			{
				removeChild( child );
			}
			
			child = getChildByName( "brokenImageBorder" );
			if( child != null )
			{
				removeChild( child );
			}
		
			if( _brokenImage )
			{					
				var brokenImageSkin			: Class = getStyle( "brokenImageSkin" );
				var brokenImageBorderSkin	: Class = getStyle( "brokenImageBorderSkin" );
				
				if( brokenImageSkin == null )
				{					
					brokenImageSkin = _brokenImageSkin;
				}
				
				if( brokenImageBorderSkin == null )
				{
					brokenImageBorderSkin = BrokenImageBorderSkin;
				}
				
				var brokenImage	: IFlexDisplayObject = new brokenImageSkin() as IFlexDisplayObject;
				if( brokenImage is ISimpleStyleClient )
				{
					( brokenImage as ISimpleStyleClient ).styleName = this;
				}				
				brokenImage.name = "iconImage";
				addChild( brokenImage as DisplayObject );				
				
				var border	: IFlexDisplayObject = new brokenImageBorderSkin() as IFlexDisplayObject;				
				if( border is ISimpleStyleClient )
				{
					( border as ISimpleStyleClient ).styleName = this;
				}				
				border.setActualSize( w, h );
				border.name = "brokenImageBorder";
				addChild( border as DisplayObject );
			}
			else if( _parser != null )
			{
				var s	: int = Math.min( w, h );
				
				if( scaleContent )
				{
					//--	Use the size one larger than the required size to get best
					//		results from scaling
					
					var sizes	: Array = _parser.sizes;
					var targetS	: int = s;
					
					for each( var newS : int in sizes )
					{
						if( newS < targetS )
						{
							break;
						}
						
						s = newS;
					}
				}
				
				var bmd	: BitmapData = _parser.getIconForSize( s );
				var bm	: Bitmap = new Bitmap( bmd );
				bm.smoothing = true;
				
				bm.name = "iconImage";
				
				var xPos		: Number = 0;
				var yPos		: Number = 0;
				
				if( scaleContent )
				{
					var scaleRatio	: Number = Math.min( w / bm.width, h / bm.height );
					
					bm.scaleX = scaleRatio;
					bm.scaleY = scaleRatio;	
				}	
				else
				{
					yPos = Math.max( 0, ( h - bm.height ) / 2 );		
					xPos = Math.max( 0, ( w - bm.width ) / 2 );
				}
				
				bm.x = xPos;
				bm.y = yPos;
				
				addChild( bm );
			}
		}
		
		/**
		 * @private
		 * Creates a parser for the icon data and parses the data.
		 */
		
		private function parseIcon( ba : ByteArray ) : void
		{			
			_parser = IconParserFactory.newParser( ba );
			
			if( _parser != null )
			{
				_parser.data = ba;
				_parser.parse();
			}
			
			if( _parser == null || ! _parser.validIcon || _parser.sizes.length == 0 )
			{
				_brokenImage = true;
			}
			else
			{
				_brokenImage = false;
			}
		}
		
		/**
		 * @private
		 * Creats a URLLoader to retrieve the icon data, and begins the loading process
		 */
		 
		private function loadImageUrl( url : String ) : void
		{
			var req		: URLRequest = new URLRequest( url );
			var loader	: URLLoader = new URLLoader();
			
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			loader.addEventListener( Event.COMPLETE, onLoaderComplete );
			loader.addEventListener( IOErrorEvent.IO_ERROR, onLoaderIOError );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError );
			
			loader.load( req );
		}
		
		/**
		 * @private
		 * Handler for the URLLoader COMPLETE event
		 */
		 
		private function onLoaderComplete( e : Event ) : void
		{	
			parseIcon( e.target.data as ByteArray );
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Handler for the URLLoader IO_ERROR event
		 */
		
		private function onLoaderIOError( e : IOErrorEvent ) : void
		{
			trace( "IO error loading icon: " + e.text );
			
			_parser = null;
			_brokenImage = true;
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * @private
		 * Handler for the URLLoader SECURITY_ERROR event
		 */
		
		private function onLoaderSecurityError( e : SecurityErrorEvent ) : void
		{
			trace( "Security error loading icon: " + e.text );
			
			_parser = null;
			_brokenImage = true;
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * @private
		 *	Icon parser instance 
		 */
		 
		private var _parser					: IIconParser;
		private var _brokenImage			: Boolean = false;
		
		/**
		 * @private
		 * Default "broken link" image
		 */
		 
		[Embed( source="iconLoaderClasses/assets/Assets.swf", symbol="__brokenImage" )]
		private static var _brokenImageSkin	: Class
	}
}