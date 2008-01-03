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
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.utils.Base64Decoder;

	public class Base64Image extends Image
	{

		private var _base64String:String;


		public function Base64Image() :void
		{
			super();
		}

		public function get value() :String
		{
			return _base64String;
		}

		public function set value( value:String ) :void
		{
			_base64String = value;
			source = value;
		}

		private var _source:Object;
		
		/**
		 * Attempt to auto detect if we're receiving a base64 encoded string
		 * or a traditional value for the image source
		 */
		override public function set source( value:Object ) :void
		{
			_source = value;
			
			var decoder:Base64Decoder = new Base64Decoder();
			var byteArray:ByteArray;

			try
			{
				decoder.decode( value as String );
				byteArray = decoder.flush();

				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onBytesLoaded );
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.loadBytes( byteArray );
			}
			catch (error:Error)
			{
				super.source = value
			}
		}
		
		override public function get source():Object {
			return _source;
		}
		
		private function onIOError(event:IOErrorEvent):void {
			super.source = _source;
		}

		/**
		 * After the bytearray is loaded we need to convert to a bitmap
		 * in order to set the source of the parent image
		 */
		private function onBytesLoaded( event:Event ) :void
		{
			var content:DisplayObject = LoaderInfo( event.target ).content;
			var bitmapData:BitmapData = new BitmapData( content.width, content.height );
			bitmapData.draw( content );

			super.source = new Bitmap( bitmapData );
		}

	}
}