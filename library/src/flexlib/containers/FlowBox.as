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

package flexlib.containers
{

import flexlib.containers.utilityClasses.FlowLayout;

import mx.containers.Box;
import mx.containers.BoxDirection;
import mx.core.mx_internal;

use namespace mx_internal;
	
/**
 * The FlowBox is an extension of Box that implements a
 * FlowLayout algorithm for laying out children.  FlowBox
 * will lay out children in a horizontal fashion.  When
 * the width of the children exceeds the width of the container,
 * the child is placed on a new row.
 */	
public class FlowBox extends Box
{
	/**
	 * Constructor
	 */
	public function FlowBox()
	{
		super();
		
		// Force horizontal direction
		direction = BoxDirection.HORIZONTAL;
		
		// Use a FlowLayout to lay out the children
		layoutObject = new FlowLayout();
		layoutObject.target = this;	
	}
	
	/**
	 * A FlowBox container can only be horizontal, so override the
	 * direction and don't allow the user to change it.
	 */
	override public function set direction( value:String ):void
	{
		super.direction = BoxDirection.HORIZONTAL;
		// Do nothing -- direction cannot be changed and we force
		// a horizontal layout.
	}

} // end class
} // end package