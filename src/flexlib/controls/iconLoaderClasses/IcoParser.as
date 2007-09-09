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
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Dictionary;
	import flash.geom.Rectangle;
	
	/**
	 * A parser for the Windows .ico icon file.
	 * Currently supports only Windows XP style icons, where an 8 bit alpha mask is included
	 * with each image bitmap.
	 */

	public class IcoParser implements IIconParser
	{
		/**
		 * @inheritDoc
		 */
		 
		public function get validIcon() : Boolean
		{
			return _validIcon;
		}
		
		private var _validIcon	: Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		 
		public function get sizes() : Array
		{
			return _sizes;
		}
		
		private var _sizes	: Array = [];
		
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
			_data.endian = Endian.LITTLE_ENDIAN;
		}
		
		private var _data			: ByteArray;
		
		/**
		 * Constructor
		 */
		 
		public function IcoParser() 
		{
		}
		
		/**
		 * @inheritDoc
		 */
		 
		public function parse() : void
		{			
			_validIcon = parseHeader();
			
			if( _validIcon )
			{
				_validIcon = parseIconDirs();
			}
			if( _validIcon )
			{
				_validIcon = parseIconImages();
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
			
			var result	: BitmapData = new BitmapData( s, s );
			var icon	: IconImage = _iconImages[ s ] as IconImage;
			var ba		: ByteArray = processImage( icon.icXOR );
						
			ba.position = 0;			
			result.setPixels( new Rectangle( 0, 0, s, s ), ba );
			
			mirrorBitmap( result );
			
			return result;
		}
		
		/**
		 * @private
		 * Parses header information from the icon data
		 */
		 
		private function parseHeader() : Boolean
		{			
			var idReserved	 : uint = _data.readUnsignedShort();
			var idType		 : uint = _data.readUnsignedShort();
			
			if( idReserved != 0 || idType != 1 )
			{
				return false;	
			}
			
			_numIcons = _data.readUnsignedShort();
			
			return true;
		}
		
		/**
		 * @private
		 * Reads the directory information for each icon in the icon data
		 */
		 
		private function parseIconDirs() : Boolean
		{
			for( var i : int = 0; i < _numIcons; i++ )
			{
				var iconDirEntry	: IconDirEntry = new IconDirEntry();
				
				iconDirEntry.bWidth = 			_data.readUnsignedByte();
				iconDirEntry.bHeight = 			_data.readUnsignedByte();
				iconDirEntry.bColorCount = 		_data.readUnsignedByte();
				iconDirEntry.bReserved = 		_data.readUnsignedByte();
				iconDirEntry.wPlanes = 			_data.readUnsignedShort();
				iconDirEntry.wBitCount = 		_data.readUnsignedShort();
				iconDirEntry.dwBytesInRes = 	_data.readUnsignedInt();
				iconDirEntry.dwImageOffset = 	_data.readUnsignedInt();
				
				_iconDirEntries.push( iconDirEntry );
			}
			
			return true;
		}
		
		/**
		 * @private
		 * Reads icon information and bitmap data for each icon directory in the icon data
		 */
		 
		private function parseIconImages() : Boolean
		{
			for each( var dir : IconDirEntry in _iconDirEntries )
			{
				_data.position = dir.dwImageOffset;
				
				var header	: BitmapInfoHeader = new BitmapInfoHeader();
				
				header.biSize = _data.readUnsignedInt();
				header.biWidth = _data.readUnsignedInt();
				header.biHeight = _data.readUnsignedInt();
				header.biPlanes = _data.readUnsignedShort();
				header.biBitCount = _data.readUnsignedShort();
				header.biCompression = _data.readUnsignedInt();
				header.biSizeImage = _data.readUnsignedInt();
				header.biXPelsPerMeter = _data.readUnsignedInt();
				header.biYPelsPerMeter = _data.readUnsignedInt();
				header.biClrUsed = _data.readUnsignedInt();
				header.biClrImportant = _data.readUnsignedInt();
								
				//--	No support yet for bpp < 24
				
				if( header.biBitCount < 24 )
				{
					_data.position = dir.dwImageOffset + dir.dwBytesInRes;
					continue;
				}
								
				var iconImage	: IconImage = new IconImage();
				
				iconImage.icHeader = header;
				iconImage.icAND = new ByteArray();
				iconImage.icXOR = new ByteArray();
				
				//--	Skip the color table
				
				var colorTableLen	: int = 0;
				
				if( header.biBitCount == 32 && header.biCompression == BI_BITFIELDS )
				{
					colorTableLen = 12;	// 3 DWORDS
				}
				
				_data.position += colorTableLen;
				
				var imageLen	: int = ( ( header.biHeight / 2 ) * header.biWidth ) * 4;
				iconImage.icXOR.writeBytes( _data, _data.position, imageLen );
				
				//--	Don't bother reading the AND data -- we're not going to use it.
				
				_iconImages[ dir.bWidth ] = iconImage;
				_sizes.push( dir.bWidth );
				_sizes.sort( Array.NUMERIC | Array.DESCENDING );
			}
			
			return true;
		}
		
		/**
		 * @private
		 * Converts each byte in the icon's XOR data from BGRA to ARGB.
		 */
		
		private function processImage( bm : ByteArray ) : ByteArray
		{
			var result	: ByteArray = new ByteArray();
			result.endian = Endian.LITTLE_ENDIAN;
			
			bm.position = 0;
			
			while( bm.bytesAvailable >= 4 )
			{				
				var b		: uint = bm.readUnsignedByte();
				var g		: uint = bm.readUnsignedByte();
				var r		: uint = bm.readUnsignedByte();				
				var a		: uint = bm.readUnsignedByte();
				var color   : uint = ( a << 24 ) | ( r << 16 ) | ( g << 8 ) | b;	
				
				result.writeUnsignedInt( color );
			}
			
			return result;
		}
		
		/**
		 * @private
		 * Flips the icon about the horizontal axis
		 */
		 
		private function mirrorBitmap( bmd : BitmapData ) : void
		{		
			for( var i : int = 0; i < bmd.height / 2; i++ )
			{
				var r1		: Rectangle = new Rectangle( 0, i, bmd.width, 1 );
				var line1	: ByteArray = bmd.getPixels( r1 );
				var r2		: Rectangle = new Rectangle( 0, bmd.height - i - 1, bmd.width, 1 )
				var line2	: ByteArray = bmd.getPixels( r2 );
				
				line1.position = 0;
				line2.position = 0;
				
				bmd.setPixels( r1, line2 );	
				bmd.setPixels( r2, line1 );	
			}
		}
		
		/**
		 * @private
		 * Storage for the number of icons in the icon daa.
		 */
		 
		private var _numIcons		: int;
		
		/**
		 * @private
		 * Storage for the icon directories
		 */
		
		private var _iconDirEntries	: Array = []
		
		/**
		 * @private
		 * Storage for the icon images
		 */
		private var _iconImages		: Dictionary = new Dictionary();
		
		/**
		 * @private
		 * Constants defined in Wingdi.h
		 */
		private static const BI_RGB			: int = 0;
		private static const BI_RLE8		: int = 1;
		private static const BI_RLE4		: int = 2;
		private static const BI_BITFIELDS	: int = 3;
	}
}

import flash.utils.ByteArray;	

/**
 * @private
 * ICONDIRENTRY struct from Windows headers
 */
internal class IconDirEntry
{
	public var bWidth			: int;	// Width, in pixels, of the image
	public var bHeight			: int;	// Height, in pixels, of the image
	public var bColorCount		: int;	// Number of colors in image (0 if >=8bpp)
	public var bReserved		: int;	// Reserved ( must be 0)
	public var wPlanes			: int;	// Color Planes
	public var wBitCount		: int;	// Bits per pixel
	public var dwBytesInRes		: int;	// How many bytes in this resource?
	public var dwImageOffset	: int;	// Where in the file is this image?
}

/**
 * @private
 * ICONIMAGE struct from Windows headers
 */
 
internal class IconImage
{
	public var icHeader			: BitmapInfoHeader;		// DIB header
	public var icColors			: ByteArray;			// Color table
	public var icXOR			: ByteArray;			// DIB bits for XOR mask
	public var icAND			: ByteArray;		   	// DIB bits for AND mask
}

/**
 * @private
 * BITMAPINFOHEADER from Windows headers
 */

internal class BitmapInfoHeader
{
	public var biSize			: int;
	public var biWidth			: int;
	public var biHeight			: int;
	public var biPlanes			: int;
	public var biBitCount		: int;
	public var biCompression	: int;
	public var biSizeImage		: int;
	public var biXPelsPerMeter	: int;
	public var biYPelsPerMeter	: int;
	public var biClrUsed		: int;
	public var biClrImportant	: int;
}