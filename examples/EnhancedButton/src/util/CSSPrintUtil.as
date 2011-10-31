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
package util
{
    import mx.styles.CSSStyleDeclaration;

    /**
     * This is a utility class for outputting CSS values for our given style.
     */
    public class CSSPrintUtil
    {
        public static const COLOR_PROPS : Array = [ "fillColors", "overFillColors", "selectedFillColors", "disabledFillColors", "borderColor",
            "color", "textRollOverColor", "textSelectedColor", "themeColor", "borderColors", "selectedBorderColors", "overBorderColors" ];


        /**
         * Output the delta of newStyle and origStyle.
         * s
         * @param origStyle The original style that we started with.
         * @param newStyle The new style containing whatever altered properties we started with.
         * @param styleProps An array of property keys that we use for comparison.
         * @param styleName The name of the style to output (not discernable from style object itself).
         */
        public static function outputStyles( origStyle:CSSStyleDeclaration, newStyle:CSSStyleDeclaration, styleProps:Array, styleName:String ) : String
        {
            var origVal : *, newVal : *;
            var output : String = "";


             output += "Button {\n" +
	"    upSkin:ClassReference('EnhancedButtonSkin');\n" +
	"    overSkin:ClassReference('EnhancedButtonSkin');\n" +
	"    downSkin:ClassReference('EnhancedButtonSkin');\n" +
	"    disabledSkin:ClassReference('EnhancedButtonSkin');\n" +
	"    selectedUpSkin:ClassReference('EnhancedButtonSkin');\n" +
	"    selectedOverSkin:ClassReference('EnhancedButtonSkin');\n" +
	"    selectedDownSkin:ClassReference('EnhancedButtonSkin');\n" +
	"    selectedDisabledSkin:ClassReference('EnhancedButtonSkin');\n" +
	"}\n\n";


            output += "." + styleName + " {\n"
            for each ( var prop : String in styleProps )
            {
                origVal  = origStyle.getStyle( prop );
                newVal = newStyle.getStyle( prop );
                trace("comparing vals for : " + prop + " : " + origVal + " : " + newVal);
                if ( ! equalVals( origVal, newVal ) )
                {
                    output += "     " + prop + ": " + formatVal( prop, newVal ) + ";\n";
                }

            }

            output += "}\n";

            return output;
        }

        /**
         * @Return whether two values are equals. If the values are arrays, the function compares whether the value of the arrays are equal.
         */
        public static function equalVals( origVal:*, newVal:* ) : Boolean
        {
            if ( origVal == null && newVal == null )
                    return true;
            else if ( newVal is Array )
            {
                if ( origVal == null )
                {
                    return false;
                }

                var origA : Array = origVal as Array;
                var newA : Array = newVal as Array;
                if ( origA.length != newA.length )
                {
                    return false;
                }
                else
                {
                      for ( var i:int = 0; i < newA.length ; i++ )
                      {
                          if ( newA[i] != origA[i] )
                          {
                              return false;
                          }
                      }
                      return true;
                }
            }
            else
            {
                return origVal == newVal;
            }
        }

        /**
         * Convert either an array, or a value from RGB to hex.
         */
        public static function convertRGBToHex( val:* ) : *
        {
            if ( val is Array )
            {
                // duplicate the array
                var valA : Array = (val as Array);
                valA = valA.slice();

                for ( var i:int = 0; i < valA.length; i++ )
                {
                    valA[i] = rgbToHex( valA[i] );
                }
                return valA;
            }
            else
            {
                return rgbToHex( val );
            }
        }

        /**
         * Convert a given RGB value to a hex value.
         */
        public static function rgbToHex(val:Number):String
        {
            var newVal:String = val.toString(16);
            while (newVal.length < 6)
            {
                newVal = "0" + newVal;
            }
            return "#" + newVal.toUpperCase();
        }


        private static function formatVal( prop : String, val : * ) : String
        {
            var colorProp : Boolean = false;
            for each ( var propName:String in COLOR_PROPS )
            {
                if ( propName == prop )
                {
                    colorProp = true;
                    break;
                }
            }

            if ( colorProp )
            {
                val = convertRGBToHex( val );
            }
            if ( val is Array )
            {
                return  ( val as Array ).join(", ");
            }
            return val;
        }


    }
}


