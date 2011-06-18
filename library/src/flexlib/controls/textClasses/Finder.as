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
	import flash.text.TextField;
	
	import flash.events.MouseEvent;
	
	public class Finder
	{
		/**
		* The TextField to be searched.
		*/
		private var textField:TextField;
		
		/**
		* The current starting index for searches. 
		*/
		private var caratIndex:int;
		
		/**
		* Finds strings in a TextField.
		* 
		* @param textField The TextField to search.
		*/
		public function Finder(textField:TextField){
			this.caratIndex = 0;
			this.textField = textField;
			this.textField.addEventListener(MouseEvent.CLICK,setCarat,false,1,true);
		}
		
		/**
		* Synchronizes the Finder's internal carat position with the TextField's carat position when the user manually sets it by clicking in the TextField.
		*/
		public function setCarat(evt:MouseEvent):void{
            this.caratIndex = this.textField.caretIndex;
        }
        
		/**
		* Gets all indexes of a string in the TextField.
		* 
		* @param string The string to search for.
		* @return An array of all the indexes of the string. 
		*/
        public function indexesOf(string:String, caseSensitive:Boolean=true):Array{
            var pos:int = 0;
            var r:Array = [];
            
            var txt:String = this.textField.text;
            var len:int = string.length;
            
            if(!caseSensitive) {
            	txt = txt.toLowerCase();
            	string = string.toLowerCase();
            }
            
            do{
                if ((pos = txt.indexOf(string, pos)) != -1){
                    r.push(pos);
                }else{
                    break;
                } 
            }while(pos += len);
            return r;
        }
        
        /**
        * Finds the first instance of a string after the Finder's current carat position.
        * 
        * @param string The string to search for.
        * @return The character index of the string.
        */
        public function findNext(string:String, caseSensitive:Boolean=true):int{
        	var str:String = this.textField.text;
            
            if(!caseSensitive) {
            	str = str.toLowerCase();
            	string = string.toLowerCase();
            }
            
            var len:int = string.length;
            var i:int = str.indexOf(string,this.caratIndex+len);
            
            if(i == -1){
                this.caratIndex = 0;
                i= str.indexOf(string,this.caratIndex);
            }
            
            if(i == -1){
                return -1;
            }
            
            this.caratIndex = i+1;
            
            return i;
            
        }
        
        /**
        * Finds the first instance of a string before the Finder's current carat position.
        * 
        * @param string The string to search for.
        * @return The character index of the string.
        */
        public function findPrevious(string:String, caseSensitive:Boolean=true):int{
       		 
            if(this.caratIndex == 0){
                this.caratIndex = this.textField.text.length;
            }
            var txt:String = this.textField.text;
            var str:String = txt.substring(0,this.caratIndex);
            
            if(!caseSensitive) {
            	txt = txt.toLowerCase();
            	str = str.toLowerCase();
            }
            
            var len:int = string.length;
            var i:int = str.lastIndexOf(string);
            
            if(i == -1){
                this.caratIndex = txt.length;
                i = txt.lastIndexOf(string);
            }
            
            if(i == -1){
                return -1;
            }
            
            this.caratIndex = i;
            
            return i;
        }
	}
}