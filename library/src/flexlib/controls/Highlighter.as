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
    import flash.text.TextField;
    import flash.events.Event;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.Rectangle;
    
    import flexlib.controls.textClasses.StringBoundaries;
    import flexlib.controls.textClasses.Finder;
    
    public class Highlighter
    {   
    	/**
    	* The TextField being highlighted.
    	*/
        public var field:TextField;
        
        /**
        * The color used to highlight strings (RGBA).
        * 
        * @default 0xffff0000 (red)
        */
        public var highlightColor:uint;
        
        /**
        * The horizontal offset for highlights.
        * 
        * @default 0
        */
        public var xOffset:Number;
        
        /**
        * The vertical offset for highlights.
        * 
        * @default 0
        */
        public var yOffset:Number;
        
        /**
        * Contains the bounding rectangles of each string to be highlighted.
        */
        private var boundariesToHighlight:Array;
        
        /**
        * The Bitmap object used for drawing the highlights.  Publicly exposed so that effects can be applied if desired.
        */
        public var bitmap:Bitmap;
        
        /**
        * The drawing canvas for the Bitamp object.
        */
        private var canvas:BitmapData;
        
        /**
        * The Finder object used to search the TextField.
        */
        private var finder:Finder;
        
        /**
        * Finds &amp; highlights strings in a text field.
        * 
        * @param textField The TextField containing the text to highlight
        * @param color The color to make the highlight (RGBA).  Default is 0xffff0000 (solid red).
        * @param xOffset If necessary, the horizontal offset of the highlight.  Useful when the TextField has some padding applied to it.  Default is 0.
        * @param yOffset If necessary, the vertical offset of the highlight.  Useful when the TextField has some padding applied to it.  Default is 0.
        */
        public function Highlighter(textField:TextField,color:uint=0xffff0000,xOffset:Number=0,yOffset:Number=0)
        {
            this.field = textField;
            this.highlightColor = color;
        
            this.xOffset = xOffset;
            this.yOffset = yOffset;
            
            this.boundariesToHighlight = new Array();
            
            this.canvas = new BitmapData(2000,2000,true,0x00000000);
            
            this.bitmap = new Bitmap(canvas);
            
            var ind:int = this.field.parent.getChildIndex(this.field);
            this.field.parent.addChildAt(this.bitmap,ind-1);
            
            finder = new Finder(this.field);
            
            this.field.addEventListener(Event.SCROLL,onScroll,false,3,true);
            this.field.parent.addEventListener(Event.RESIZE,onScroll,true,2,true); 
            
        }
        
        /**
        * Fired when the TextField is scrolled.  Clears all highlights and recalculates which characters are visible.
        */
        private function onScroll(evt:Event):void{
            this.clearAllHighlights();
            this.highlightVisibleBoundaries();
        }
        
        /**
        * Resets the Highlighter, clearing all visible highlights and emptying the array of character boundaries.
        */
        public function reset():void{
            this.clearAllHighlights();
            this.boundariesToHighlight = [];
        }
        
        /**
        * Erases all highlights from the bitmap canvas.
        */
        private function clearAllHighlights():void{
            this.canvas.fillRect(new Rectangle(0,0,2000,2000),0x00000000);
        }
        
        /**
        * Traverses the boundariesToHighlight array, tests each rectangle contained therein to see if it is visible within the boundaries of the TextField.  If so, draws the rectangle to the bitmap canvas.
        */
        private function highlightVisibleBoundaries():void{
            var len:int = this.boundariesToHighlight.length;
            for(var i:int=0; i<len; i++){
            	var str:StringBoundaries = this.boundariesToHighlight[i];
            	if(str.isVisible){
            		var rects:Array = str.rectangles;
            		var len2:int = rects.length;
            		for(var j:int=0; j<len2; j++){
            			var rect:Rectangle = rects[j];
			            this.canvas.fillRect(rect,this.highlightColor);
            		}
            	}
            } 
        }

		/**
		* Highlights all instances of a string.
		* 
		* @param word The string to find and highlight.
		*/
        public function highlightWordInstances(word:String, caseSensitive:Boolean=true):void{

            var txt:String = this.field.text;
            
            // Create a StringBoundaries object for every instance
            var instances:Array = this.finder.indexesOf(word, caseSensitive);

            var len:int = word.length-1;
            
            for(var i:int = 0; i<instances.length; i++){
                var bounds:StringBoundaries = new StringBoundaries(this.field,instances[i],instances[i]+len,this.xOffset,this.yOffset);
                this.boundariesToHighlight.push(bounds);
            }
        
            this.highlightVisibleBoundaries();
        }
        
        
        /**
        * Highlights the first instance of a string after the cursor position.
        * 
        * @param word The string to find and highlight.
        */
        public function highlightNext(word:String, caseSensitive:Boolean=true):void{
            this.reset();
            
            var i:int = this.finder.findNext(word, caseSensitive);
            
            var line:int = this.field.getLineIndexOfChar(i);
            this.field.scrollV = line;
            
            var len:int = word.length-1;
            
            var bounds:StringBoundaries = new StringBoundaries(this.field,i,i+len,this.xOffset,this.yOffset);
 
            this.boundariesToHighlight.push(bounds);
            
            this.highlightVisibleBoundaries();
        }
        
        /**
        * Highlights the first instance of a string before the cursor position.
        * 
        * @param word The string to find and highlight.
        */
        public function highlightPrevious(word:String, caseSensitive:Boolean=true):void{
            this.reset();
           	var i:int = this.finder.findPrevious(word, caseSensitive);
            
            var line:int = this.field.getLineIndexOfChar(i);
            this.field.scrollV = line;
            
            var len:int = word.length-1;
            
            var bounds:StringBoundaries = new StringBoundaries(this.field,i,i+len,this.xOffset,this.yOffset);
            this.boundariesToHighlight.push(bounds);
            
            this.highlightVisibleBoundaries();
        }
    }
}