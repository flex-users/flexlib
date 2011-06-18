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

package flexlib.controls.iconLoaderClasses
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * A parser for Macintosh .icns files.
	 * Supports the all 32 bit icons: 'is32', 'il32', 'ih32', 'it32', and their 
	 * associated masks.
	 */
	 
	public class IcnsParser implements IIconParser
	{
		/**
		 * @inheritDoc
		 */
		 
		public function get validIcon() : Boolean
		{
			return _validIcon;
		}
		
		private var _validIcon : Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		
		public function get sizes() : Array
		{
			return _sizes;
		}
		
		private var _sizes		: Array = [];
		
		/**
		 * @inheritDoc
		 */
		
		public function get data() : ByteArray
		{
			return _data;
		}
		
		public function set data( val : ByteArray ) : void
		{
			_data = val;
			_data.position = 0;
			
			//--	Mac .icns resources are always big-endian, even on Intel systems.
			
			_data.endian = Endian.BIG_ENDIAN;
		}
		
		private var _data 		: ByteArray;
		
		/**
		 * Constructor
		 */
		
		public function IcnsParser() 
		{
		}
		
		/**
		 * Parse the raw icon data.
		 */
		
		public function parse() : void
		{			
			var result	 : Boolean;
			
			result = ReadHeader();
			
			if( ! result )
			{
				return;
			}
			
			while( _data.bytesAvailable >= 4 )
			{
				var iconType	: int = _data.readInt();
				result = processIcon( iconType )
				
				if( ! result )
				{
					break;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		
		public function getIconForSize( s : int ) : BitmapData
		{
			if( _sizes.indexOf( s ) == -1 )
			{				
				var oldS	: int = s;
				
				for each( s  in _sizes )
				{
					if( s < oldS )
					{
						break;
					}
				}
			}
			
			if( _bitmaps[ s ] == undefined ||
				_masks[ s ] == undefined )
			{
				return null;
			}
			
			return mergeAlpha( _bitmaps[ s ], _masks[ s ] );
		}
		
		/**
		 * @private
		 * Processes one icon in the icon data.
		 */
		
		private function processIcon( iconType : int ) : Boolean
		{
			var result	 : Boolean = false;
			
			if( iconType == fourCharCode( "is32" ) )
			{
				result = process32BitIcon( 16 );
			}
			else if( iconType == fourCharCode( "s8mk" ) )
			{
				result = process8BitMask( 16 );
			}			
			else if( iconType == fourCharCode( "il32" ) )
			{
				result = process32BitIcon( 32 );
			}
			else if( iconType == fourCharCode( "l8mk" ) )
			{
				result = process8BitMask( 32 );
			}			
			else if( iconType == fourCharCode( "ih32" ) )
			{
				result = process32BitIcon( 48 );
			}
			else if( iconType == fourCharCode( "h8mk" ) )
			{
				result = process8BitMask( 48 );
			}			
			else if( iconType == fourCharCode( "it32" ) )
			{
				result = process32BitIcon( 128 );
			}
			else if( iconType == fourCharCode( "t8mk" ) )
			{
				result = process8BitMask( 128 );
			}
			else
			{
				result = skipIcon();
			}
			
			return result;
		}
		
		/**
		 * @private
		 * Skips an icon by moving the position in the data buffer.
		 */
		
		private function skipIcon() : Boolean
		{
			var result	: Boolean = true;			
			var len		: int = _data.readInt() - 8;
			
			_data.position += len;
			
			return result;
		}
		
		/**
		 * @private
		 * Reads and decompresses a 32 bit icon.
		 * @param s The width and height of the icon to be procesed.
		 */
		
		private function process32BitIcon( s : int ) : Boolean
		{
			var result	: Boolean = true;			
			var len		: int = _data.readInt() - 8;
			var ba		: ByteArray = new ByteArray();
			var bmd		: BitmapData = new BitmapData( s, s, true );
			
			ba.writeBytes( _data, _data.position, len );
			_data.position += len;
			
			ba = decompressBitmap( ba, s * s );
			
			ba.position = 0;
			bmd.setPixels( new Rectangle( 0, 0, s, s ), ba );
			
			_bitmaps[ s ] = bmd;
			
			if( _masks[ s ] != undefined && _sizes.indexOf( s ) == -1 )
			{
				_sizes.push( s );
				_sizes = _sizes.sort( Array.NUMERIC | Array.DESCENDING );
			}
		
			return result;	
		}
		
		/**
		 * @private
		 * Reads an 8 bit icon mask from the icon data.
		 * @param s The height and width of the icon mask.
		 */
		
		private function process8BitMask( s : int ) : Boolean
		{
			var result	: Boolean = true;			
			var len		: int = _data.readInt() - 8;
			var ba		: ByteArray = new ByteArray();
			var bmd		: BitmapData = new BitmapData( s, s, true );
			
			for( var i : int = 0; i < len; i++ )
			{
				var b : int = _data.readUnsignedByte();
				ba.writeInt( ( b << 24 ) );
			}
			
			ba.position = 0;
			bmd.setPixels( new Rectangle( 0, 0, s, s ), ba );
			
			_masks[ s ] = bmd;
			
			if( _bitmaps[ s ] != undefined && _sizes.indexOf( s ) == -1 )
			{
				_sizes.push( s );
				_sizes = _sizes.sort( Array.NUMERIC | Array.DESCENDING );
			}
		
			return result;	
		}
		
		/**
		 * @private
		 * Processes the icon data header
		 */
		
		private function ReadHeader() : Boolean
		{
			var marker	: int = _data.readInt();
			var len	 	: int = _data.readInt();
			
			if( marker == fourCharCode( "icns" ) &&
				len == _data.length )
			{
				_validIcon = true; 
			}
			
			return _validIcon;
		}
		
		/**
		 * @private
		 * Converts a four character string into a 32 bit integer. Many Mac OS resources
		 * use these 'four character code' integers to identify themselves. 
		 */
		 
		private static function fourCharCode( s : String ) : int
		{
			var ba	: ByteArray = new ByteArray();
			
			ba.endian = Endian.BIG_ENDIAN;
			ba.writeUTFBytes( s );
			ba.position = 0;
			
			var result : int = ba.readInt();

			//--	should really be caching the results
			return result;
		}
		
		/**
		 * @private
		 * Decompresses icon bitmpa data using an undocumented Apple run-length encoding scheme.
		 */
		
		private static function decompressBitmap( bm : ByteArray, channelLen : int ) : ByteArray
		{
			//--	Compression scheme is not documented by Apple, but has been reverse engineered:
			//		http://www.macdisk.com/maciconen.php3
			
			var result 	: ByteArray = new ByteArray();
			var red		: ByteArray = new ByteArray();
			var blue	: ByteArray = new ByteArray();
			var green	: ByteArray = new ByteArray();
			
			bm.position = 0;
			
			for each( var channel : ByteArray in [ red, green, blue ] )
			{
				var i : int = 0;
				
				while( i < channelLen )
				{
					var b		: uint = bm.readUnsignedByte();
					var runLen	: uint;
					
					if( b & 0x80 )
					{
						//--	Compressed run
						
						var val		: uint = bm.readUnsignedByte();
						
						runLen = b - 125;
						
						for( var j : int = 0; j < runLen; j++ )
						{
							channel.writeByte( val );
						}
					}
					else
					{
						//--	Uncompressed run
						
						runLen = b + 1;
						channel.writeBytes( bm, bm.position, runLen );
						bm.position += runLen;
					}
					
					i += runLen;
				}
			}
			
			red.position = 0;
			green.position = 0;
			blue.position = 0;
			
			for( var k : int = 0; k < channelLen; k++ )
			{
				var pixel	: uint = 0xff000000 |
					( red.readUnsignedByte() << 16 ) |
					( green.readUnsignedByte() << 8 ) |
					blue.readUnsignedByte();
				
				result.writeInt( pixel );
			}
			
			return result;
		}
		
		/**
		 * @private
		 * Combine a 32 bit icon with an 8 bit mask to create a Flash BitmapData object.
		 */
		
		private static function mergeAlpha( bm : BitmapData, alpha : BitmapData ) : BitmapData
		{
			if( bm.width != alpha.width ||
				bm.height != alpha.height )
			{
				throw new Error( "Alpha and bitmap dimensions do not match" )
			}
			
			var r				: Rectangle = new Rectangle( 0, 0, bm.width, bm.height );
			var bitmapPixels	: ByteArray = bm.getPixels( r );
			var alphaPixels		: ByteArray = alpha.getPixels( r );
			var merged 			: ByteArray = new ByteArray();
			var result			: BitmapData = new BitmapData( r.width, r.height );
		
			bitmapPixels.position = 0;
			alphaPixels.position = 0;
		
			while( bitmapPixels.bytesAvailable > 0 )
			{
				var c	: uint = bitmapPixels.readUnsignedInt();
				var a	: uint = alphaPixels.readUnsignedInt();
				
				merged.writeInt( a | ( c & 0x00ffffff ) );	
			}
			
			merged.position = 0;
			result.setPixels( r, merged );
			
			return result;
		}
		
		/**
		 * @private
		 * Dictionary to hold all the bitmaps parsed from the icon data
		 */
		 
		private var _bitmaps	: Dictionary = new Dictionary();
		
		/**
		 * @private
		 * Dictionary to hold all the masks parsed from the image data.
		 */
		 
		private var _masks		: Dictionary = new Dictionary();
	}
}