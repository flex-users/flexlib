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

package flexlib.controls.treeGridClasses
{

import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.core.IUIComponent;
	
/**
 * 
 */
public class TreeGridListData extends DataGridListData
{
		
	public function TreeGridListData(
		text : String, 
		dataField : String,
		columnIndex : int, 
		uid : String,
		owner : IUIComponent, 
		rowIndex : int = 0)
	{
		super( text, dataField, columnIndex, uid, owner, rowIndex );
	}
	
	
	//----------------------------------
	//  depth
    //----------------------------------

	/**
	 *  The level of the item in the tree. The top level is 1.
	 */
	public var depth:int;

    //----------------------------------
	//  disclosureIcon
    //----------------------------------

	/**
	 *  A Class representing the disclosure icon for the item in the TreeGrid control.
	 */
	public var disclosureIcon:Class;

    //----------------------------------
	//  hasChildren
    //----------------------------------

	/**
	 *  Contains <code>true</code> if the node has children.
	 */
	public var hasChildren:Boolean; 
	
	
	public var hasSibling : Boolean;

    //----------------------------------
	//  icon
    //----------------------------------
	
	/**
	 *  A Class representing the icon for the item in the TreeGrid control.
	 */
	public var icon:Class;

    //----------------------------------
	//  indent
    //----------------------------------

	/**
	 *  The default indentation for this row of the TreeGrid control.
	 */
	public var indent:int;
	
	public var indentationGap:int;

	//----------------------------------
	//  icon
    //----------------------------------
	
	/**
	 *  A String that enumerate the trunk style for the item in the TreeGrid control.
	 */
	public var trunk:String;
	
	public var trunkOffsetTop : Number;
	
	public var trunkOffsetBottom : Number;
	
	public var trunkColor:uint = 0xffffff;
	
    //----------------------------------
	//  node
    //----------------------------------

	/**
	 *  The data for this item in the TreeGrid control.
	 */
	public var item:Object;

    //----------------------------------
	//  open
    //----------------------------------

	/**
	 *  Contains <code>true</code> if the node is open.
	 */
	public var open:Boolean; 
	
} // end class
} // end package