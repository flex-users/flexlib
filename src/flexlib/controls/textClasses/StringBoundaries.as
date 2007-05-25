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
package flexlib.controls.textClasses
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class StringBoundaries
	{
		/**
		* The TextField the string is in.
		*/
		private var textField:TextField;
		
		/**
		* The first line of text the string inhabits.
		*/
		private var startLine:int;
		
		/**
		* The last line of text the string inhabits.
		*/
		private var endLine:int;
		
		/**
		* The index of the first character in the string.
		*/
		private var startIndex:int;
		
		/**
		* The index of the last character in the string.
		*/
		private var endIndex:int;
		
		/**
		* The horizontal offset to apply to the bounding rectangle.
		*/
		private var xOffset:Number;
		
		/**
		* The vertical offset to apply to the bounding rectangle.
		*/
		private var yOffset:Number;
		
		/**
		* TextField.getCharBoundaries seems to be consistently innaccurate by this amount in the x-axis.
		*/
		public const X_CORRECTION:Number = 1;
		
		/**
		* TextField.getCharBoundaries seems to be consistently innaccurate by this amount in the y-axis.
		*/
		public const Y_CORRECTION:Number = 2;
		
		/**
		* Finds the bounding rectangle of a character range within a TextField object.  If the character range spans multiple lines, bounding rectangles are calculated for each line.
		* 
		* @param textField The TextField the string is in.
		* @param startIndex The start index of the character range.
		* @param endIndex The end index of the character range.
		* @param xOffset The horizontal offset to apply to the boundary rectangle.
		* @param yOffset The vertical offset to apply to the bounding rectangle.
		*/
		public function StringBoundaries(textField:TextField,startIndex:int,endIndex:int,xOffset:Number=0,yOffset:Number=0)
		{
			this.textField = textField;
			this.startLine = textField.getLineIndexOfChar(startIndex);
			this.endLine = textField.getLineIndexOfChar(endIndex);
			this.startIndex = startIndex;
			this.endIndex = endIndex;
			this.xOffset = xOffset;
			this.yOffset = yOffset;
		}
		
		/**
		* Returns the bounding rectangles of the current character range.
		*/
		public function get rectangles():Array{
			var rects:Array;

			// Only return rects in the visible area of the TextField
			var firstVisibleIndex:int = this.textField.getLineOffset(this.textField.scrollV-1);
			var lastVisibleIndex:int = this.getLineEndOffset(this.textField.bottomScrollV-1);
			
			// If the visible area of the TextField is larger than the actual character range, only return rects within the character range instead.
			firstVisibleIndex = Math.max(firstVisibleIndex, this.startIndex);
			lastVisibleIndex = Math.min(lastVisibleIndex, this.endIndex);
			
			// If the character range spans multiple lines, get bounding rects for each line.
			// Otherwise, just get one bounding rect for the whole character range.
			if(this.isMultiline){
				rects = this.getLineRects(firstVisibleIndex, lastVisibleIndex);
			}else{
				rects = [this.stringRect(firstVisibleIndex, lastVisibleIndex)];
			}
			
			return rects;
		}
		
		/**
		* Indicates whether or not the character range spans multiple lines.
		*/
		private function get isMultiline():Boolean{
			if(this.endLine > this.startLine){
				return true;
			}
			return false;
		}
		
		/**
		* Indicates whether or not the character range has visible characters.
		*/
		public function get isVisible():Boolean{
			var firstVisibleChar:int = this.textField.getLineOffset(this.textField.scrollV-1);
			var lastVisibleChar:int = this.getLineEndOffset(this.textField.bottomScrollV-1)
			
			if(this.endIndex >= firstVisibleChar && this.startIndex <= lastVisibleChar){
				return true;
			}
			
			return false;
		}
		
		/** 	
		* Returns an array of Rectangles representing the boundaries of a multiline character range.
		* 
		* @param startIndex The start index of the character range
		* @param endIndex The end index of the character range
		*/
		private function getLineRects(startIndex:int, endIndex:int):Array{
			var r:Array = new Array();
			
			var startLn:int = this.textField.getLineIndexOfChar(startIndex);
			var endLn:int = this.textField.getLineIndexOfChar(endIndex);
			
			var numLines:int = endLn - startLn;
			
			var startLineEndOffset:int = this.getLineEndOffset(startLn);
			
			r.push(this.stringRect(startIndex,startLineEndOffset));
			
			for(var i:int=1; i<numLines; i++){
				var line:int = startLn + i;
				var ind1:int = textField.getLineOffset(line);
				var ind2:int = this.getLineEndOffset(line);
				r.push(this.stringRect(ind1,ind2));
			}
			
			var endLineOffset:int = textField.getLineOffset(endLn);
			r.push(this.stringRect(endLineOffset,endIndex));
			
			return r;
		}
		
		/**	
		* Returns a Rectangle representing the boundaries of a singleline character range.
		* 
		* @param startIndex The start index of the character range
		* @param endIndex The end index of the character range
		*/
		private function stringRect(startIndex:int, endIndex:int):Rectangle{
			
			// If this is a single character, simply return the character boundaries
			if(startIndex == endIndex){
				var rect:Rectangle = this.getAdjustedCharBoundaries(startIndex,true);
				return rect;
			}
			
			// Use lineHeight instead of Rectangle.height so that multi-line 
			// highlights don't have spaces between lines
			var thisLine:int = this.textField.getLineIndexOfChar(startIndex);
			var lineHeight:Number = this.textField.getLineMetrics(thisLine).height;
			
			var rect1:Rectangle = this.getAdjustedCharBoundaries(startIndex,true);
			var rect2:Rectangle = this.getAdjustedCharBoundaries(endIndex,false);
			
			var r:Rectangle = new Rectangle(rect1.x, rect1.y, rect2.right - rect1.x, lineHeight);
			return r;
		}
		
		/**
		* Returns the index of the last character in a line of text 
		*/
		private function getLineEndOffset(lineIndex:int):int{
			return textField.getLineOffset(lineIndex) + textField.getLineLength(lineIndex);
			//return textField.getLineOffset(lineIndex+1) - 1;
		}
        
        /**
        * Returns the Y position of a character's bounding rect in consideration of the vertical scroll position of the TextField.
        * <p>Because getCharBoundaries returns the same bounding rect regardless of the TextField's scroll position, it is necessary to adjust for it.</p> 
        * <p>adjustedCharY = the Y position of the character - the Y position of the first visible line of text.</p>
        */
        private function get adjustedCharY():int{
        	
            /*
                Get the rect of the first visible character
            */
            var lineIndex:int = this.textField.scrollV-1;
            var ind:int = this.textField.getLineOffset(lineIndex);
            var rect:Rectangle = this.textField.getCharBoundaries(ind);
            
            /*
                For some characters (such as carriage returns), getCharBoundaries returns null.
                In those situations, we find the next character that does not return null,
                sum the line heights up to that point, and subtract that sum from the y
                position of the character.
            */
            var lineHeights:Number = 0;
            while(rect == null){
                lineHeights += this.textField.getLineMetrics(lineIndex).height;
                lineIndex++;
                if(lineIndex == (this.textField.maxScrollV+this.textField.bottomScrollV-1)){
                    rect = new Rectangle(0,0,0,0);
                    break;
                }
                rect = this.textField.getCharBoundaries(this.textField.getLineOffset(lineIndex));
            }
            rect.y -= lineHeights;

            return rect.y;
        }
        
		/**
		* Returns the bounding rectangle of a character in consideration of the vertical scroll position of the TextField and other manual offsets.  Also, prevents TextField.getCharBoundaries from returning null and causing an error.
		*
		* @param index The index of the character to get boundaries for.
		* @param applyScrollVOffset Controls whether or not to adjust for the TextField's vertical scroll position.  Since calls to get adjustedCharY can be expensive, we only call it when necessary.
		*/
		private function getAdjustedCharBoundaries(index:int, applyScrollVOffset:Boolean):Rectangle{
			var rect:Rectangle = this.textField.getCharBoundaries(index);
			if(rect == null){
				rect = new Rectangle(0,0,0,0);
			}else{
				var scrollVOffset:Number = 0;
				if(applyScrollVOffset){
					scrollVOffset = this.adjustedCharY;
				}
				rect.x += this.X_CORRECTION + this.xOffset;
				rect.y += this.Y_CORRECTION + this.yOffset - scrollVOffset;
			}
			return rect;
		}
	}
}