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
	import mx.collections.XMLListCollection;
	import mx.containers.Canvas;
	import mx.containers.ViewStack;
	import mx.controls.List;
	import mx.controls.Tree;
	import mx.controls.listClasses.ListBase;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.effects.Dissolve;
	import mx.effects.WipeDown;
	import mx.events.ListEvent;
	import mx.utils.ObjectUtil;
	
	/**
	 *  Dispatched when the <code>selectedIndex</code> or <code>selectedItem</code> property
	 *  changes as a result of user interaction.
	 *
	 *  @eventType mx.events.ListEvent.CHANGE
	 */
	[Event(name="change", type="mx.events.ListEvent")]

	/**
	 * A control that combines the functionality of the Tree component and the List component.
	 * 
	 * <p>The ConvertibleTreeList allows you to use one control and have it display the dataProvider either
	 * as a Tree or as a List. You only have to set the dataProvider once. You can set the <code>mode</code> 
	 * at any time to change the display mode.</p>
	 * 
	 * @see mx.controls.List
	 * @see mx.controls.Tree
	 */
	public class ConvertibleTreeList extends Canvas
	{
		/**
		 * @private
		 * Our internal Tree component
		 */
		private var _tree:Tree;
		
		/**
		 * @private
		 * Our internal List component
		 */
		private var _list:List;
		
		/**
		 * @private
		 * Our internal ViewStack that holds the Tree and the List
		 */
		private var viewstack:ViewStack;
		
		[Bindable]
		/**
		 * @private
		 * Bindable dataprovider for the Tree control, this is the main dataProvider, the
		 * listDataProvider is created by flattening the heirarchy of this DP.
		 */
		private var _treeDataProvider:Object;
		
		[Bindable]
		/**
		 * @private
		 * Bindable dataProvider that is used to populate the List control. This is a flattened
		 * version of the Tree's dataProvider.
		 */
		private var _listDataProvider:Object;
		
		/**
		 * @private
		 */
		private var _mode:String = ConvertibleTreeList.TREE;
		
		/**
		 * The display mode for the ConvertibleTreeList control. 
		 * <p>Must be one of the static variables of ConvertibleTreeList,
		 * either TREE, FULL_LIST, TEXT_LIST, or ICON_LIST.</p>
		 */
		public function get mode():String {
			return _mode;
		}
		
		/**
		 * @private
		 */
		public function set mode(value:String):void {
			_mode = value;
		
			// If we're setting the mode after we've created the children
			// then we should make sure we actually do the work
			if(viewstack && tree && list) {
				modeChanged();
			}
		}
		
		/**
		 * @private
		 */
		private function modeChanged():void {
			// We're either displaying the Tree or the List, so here we
			// figure out which one, and we have to set the selectedChild to
			// the parent of either tree or list, because that's the Canvas
			// container that we added to the ViewStack
			if(_mode==ConvertibleTreeList.FULL_LIST ||
				 _mode==ConvertibleTreeList.ICON_LIST || '' + 
				 		_mode==ConvertibleTreeList.TEXT_LIST) {
				viewstack.selectedChild = _list.parent as Canvas;
			}
			else if(_mode==ConvertibleTreeList.TREE) {
				viewstack.selectedChild = _tree.parent as Canvas;	
			}
			
			// If we're showing one of the list controls then we're aither showing it
			// with or without the labels.
			if(_mode==ConvertibleTreeList.FULL_LIST || _mode==ConvertibleTreeList.TEXT_LIST) { 
				list.labelField = _labelField;
			}
			else {
				list.labelField = undefined;
			}
			
			// Same here, either we're showing the icons or not
			if(_mode==ConvertibleTreeList.FULL_LIST || _mode==ConvertibleTreeList.ICON_LIST) { 
				list.iconField = _iconField;
			}
			else {
				list.iconField = undefined;
			}
			
			
		}
		
		/**
		 * If mode is set to TREE then the Tree control is used for
		 * display.
		 */
		public static const TREE:String = "tree";
		
		/**
		 * If mode is set to FULL_LIST then the List control is used for
		 * display and both icons and labels are shown.
		 */
		public static const FULL_LIST:String = "list";
		
		/**
		 * If mode is set to ICON_LIST then the List control is used for
		 * display and only icons are shown.
		 */
		public static const ICON_LIST:String = "icon";
		
		/**
		 * If mode is set to TEXT_LIST then the List control is used for
		 * display and only labels are shown.
		 */
		public static const TEXT_LIST:String = "text";
		
		[Bindable]
		/**
		 * @private
		 * Internal var used to simulate the same showRoot functionality of the 
		 * Tree control.
		 */ 
		private var _showRoot:Boolean = true;
		
		[Bindable]
		/**
		 * @private
		 * Internal var to pass on the functionality of the iconField of
		 * the list based controls.
		 */
		private var _iconField:String;
		
		/**
	     *  The name of the field in the data provider object that determines what to 
	     *  display as the icon. By default, the list class does not try to display 
	     *  icons with the text in the rows.  However, by specifying an icon 
	     *  field, you can specify a graphic that is created and displayed as an 
	     *  icon in the row.  This property is ignored by DataGrid.
	     *
	     *  <p>The renderers will look in the data provider object for a property of 
	     *  the name supplied as the iconField.  If the value of the property is a 
	     *  Class, it will instantiate that class and expect it to be an instance 
	     *  of an IFlexDisplayObject.  If the value of the property is a String, 
	     *  it will look to see if a Class exists with that name in the application, 
	     *  and if it can't find one, it will also look for a property on the 
	     *  document with that name and expect that property to map to a Class.</p>
	     *
	     *  @default null
	     *  @see mx.controls.listClasses.ListBase
	     */
		public function set iconField(value:String):void {
			_iconField = value;
		}
		
		/**
		 * @private
		 */
		public function get iconField():String {
			return _iconField;
		}
		
		[Bindable]
		/**
		 * @private
		 */
		private var _labelField:String;
		
		/**
	     *  The name of the field in the data provider items to display as the label. 
	     *  By default the list looks for a property named <code>label</code> 
	     *  on each item and displays it.
	     *  However, if the data objects do not contain a <code>label</code> 
	     *  property, you can set the <code>labelField</code> property to
	     *  use a different property in the data object. An example would be 
	     *  "FullName" when viewing a set of people names fetched from a database.
	     *
	     *  @default "label"
	     *  @see mx.controls.listClasses.ListBase
	     */
		public function set labelField(value:String):void {
			_labelField = value;
		}
		
		/**
		 * @private
		 */
		public function get labelField():String {
			return _labelField;
		}
		
		/**
		 * @private
		 */
		private var _listField:String = "showInList";
		
		/**
		 * The name of the attribute that is used to check if an item in the dataProdiver 
		 * should be included in the List control. The XML entry in the dataProvider should
		 * be something like: <code>&lt;entry showInList='true' label='Item' /></code>, where 
		 * you could set showInList to be false if you wanted the item to show up when this 
		 * component is in Tree mode, but not in List mode. 
		 * 
		 * @default "showInList"
		 */
		public function set listField(value:String):void {
			_listField = value;
		}
		
		/**
		 * @private
		 */
		public function get listField():String {
			return _listField;
		}
		
		
		
		public function ConvertibleTreeList()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_tree = new Tree();
			_list = new List();
			
			
			viewstack = new ViewStack();
		
			viewstack.setStyle("borderStyle", "none");
			_tree.setStyle("borderStyle", "none");
			_list.setStyle("borderStyle", "none");
			
			
			var canvas1:Canvas = new Canvas();
			canvas1.addChild(_tree);
			_tree.percentHeight = _tree.percentWidth = 100;
			
			var canvas2:Canvas = new Canvas();
			canvas2.addChild(_list);

			canvas1.horizontalScrollPolicy = canvas2.horizontalScrollPolicy = ScrollPolicy.OFF;
			
			_list.percentHeight = _list.percentWidth = 100;
			
			
					
			canvas1.percentHeight = canvas1.percentWidth = 100;
			canvas2.percentHeight = canvas2.percentWidth = 100;
			
			viewstack.addChild(canvas2);
			viewstack.addChild(canvas1);
				
			
			addListEventListeners(_tree);
			addListEventListeners(_list);
			
			
			_tree.dataProvider = _treeDataProvider;
			_list.dataProvider = _listDataProvider;
			
			_tree.iconField = _list.iconField = _iconField;
			_tree.labelField = _list.labelField = _labelField;
			_tree.showRoot = _showRoot;
			
			_tree.allowMultipleSelection = _list.allowMultipleSelection = _allowMultipleSelection;
			
			modeChanged();
			
			
			addChild(viewstack);
		}
		
		/**
		 * @private
		 * 
		 * Function that adds some of the List-based control listeners to the passed in 
		 * component. This is used so we can add the item events to both the List and Tree 
		 * child components.
		 */
		private function addListEventListeners(obj:*):void {
			obj.addEventListener(ListEvent.CHANGE, changeListener);
			
			obj.addEventListener(ListEvent.ITEM_CLICK, redispatchEvent);
			obj.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, redispatchEvent);
			obj.addEventListener(ListEvent.ITEM_FOCUS_IN, redispatchEvent);
			obj.addEventListener(ListEvent.ITEM_FOCUS_OUT, redispatchEvent);
			obj.addEventListener(ListEvent.ITEM_ROLL_OUT, redispatchEvent);
			obj.addEventListener(ListEvent.ITEM_ROLL_OVER, redispatchEvent);	
		}
		
		/**
		 * @private
		 * 
		 * We make sure to select the appropriate item in the other control, so the same
		 * item (if it exists) is selected in both the Tree and the List.
		 */
		private function changeListener(event:ListEvent):void {
			if(event.target == _list) {
				_tree.selectedItems = _list.selectedItems;
			}
			else if(event.target == tree) {
				_list.selectedItems = _tree.selectedItems;
			}
			
			redispatchEvent(event);
		}
		
		/**
		 * @private
		 * Simply redispatch the event.
		 */
		private function redispatchEvent(event:ListEvent):void {
			this.dispatchEvent(event);
		}
		
		public function set dataProvider(value:Object):void {
			this._treeDataProvider = value;
			
			var listDP:XMLListCollection;
			
			if(_showRoot) {
				listDP = flattenXMLList(new XMLList(value));
			}
			else {
				var children:XMLList = new XMLList(value).children();
				
				listDP = flattenXMLList(new XMLList(value).children());
			}
			
			this._listDataProvider = listDP;
			
			if(_list) list.dataProvider = _listDataProvider;
			if(_tree) tree.dataProvider = _treeDataProvider;
			
		}
		
		public function get dataProvider():Object {
			return this._treeDataProvider;
		}
		
		/**
		 * @private
		 * This takes a heirarchical data provider for a Tree control and flattens it out
		 * so we can use it in a List control. It takes an XMLList and checks each item 
		 * for the attribute that is defined by listField. If that is set to true then
		 * the item is included in the flat data provider. This allows us to exclude certiain
		 * items from the List control that are in the Tree control (folders come to mind).
		 */
		private function flattenXMLList(input:XMLList):XMLListCollection {
			var flat:XMLListCollection = new XMLListCollection();
			
			var n:int = input.length();
			
			for(var i:int=0; i<n; i++) {
				var item:Object = input[i];
				
				if(item is XML && (item as XML).children().length() > 0) {
					
					if((item as XML).attribute(_listField).toString() == "true") {
						var loneItem:XML = (item as XML).copy();
						loneItem.setChildren(undefined);
						
						flat.addItem(loneItem);
					}
					
					var others:XMLListCollection = flattenXMLList(item.children());
					for(var j:int=0; j<others.length; j++) {
						if((others[j] as XML).attribute(_listField).toString() == "true") {
							flat.addItem((others[j] as XML).copy());
						}
					}
				}
				else if(item is XML) {
					flat.addItem((item as XML).copy());
				}
			}
			
			return flat;
		}
		
		/**
		 * The Tree control that is displayed when the <code>mode</code> is set to <code>ConvertibleTreeList.TREE</code>
		 */
		public function get tree():Tree {
			return _tree;
		}
		
		/**
		 * The List control that is displayed when the <code>mode</code> is set to <code>FULL_LIST</code>, 
		 * <code>TEXT_LIST</code>, or <code>ICON_LIST</code>.
		 */
		public function get list():List {
			return _list;
		}
		
		
		public function get selectedItem():Object {
			if(this._mode == ConvertibleTreeList.TREE) {
				return tree.selectedItem;
			}
			else {
				return list.selectedItem;
			}
		}
		
		public function set selectedItem(value:Object):void {
			if(this._mode == ConvertibleTreeList.TREE) {
				tree.selectedItem = value;
			}
			else {
				list.selectedItem = value;
			}
		}
		
		public function get selectedItems():Array {
			if(this._mode == ConvertibleTreeList.TREE) {
				return tree.selectedItems;
			}
			else {
				return list.selectedItems;
			}
		}
		
		public function set selectedItems(value:Array):void {
			if(this._mode == ConvertibleTreeList.TREE) {
				tree.selectedItems = value;
			}
			else {
				list.selectedItems = value;
			}
		}
		
		public function get selectedIndex():Object {
			if(this._mode == ConvertibleTreeList.TREE) {
				return tree.selectedIndex;tree;
			}
			else {
				return list.selectedIndex;
			}
		}
		
		private var _allowMultipleSelection:Boolean = false;
		
		public function get allowMultipleSelection():Boolean {
			return _allowMultipleSelection;
		}
		
		public function set allowMultipleSelection(value:Boolean):void {
			_allowMultipleSelection = value;
			
			if(list) list.allowMultipleSelection = value;
			if(tree) tree.allowMultipleSelection = value;
			
		}
		
		
		
		
		public function set showRoot(value:Boolean):void {
			var different:Boolean = value != _showRoot;
			
			_showRoot = value;
			
			if(different) dataProvider = _treeDataProvider;
		}
		
		public function get showRoot():Boolean {
			return _showRoot;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			viewstack.setActualSize(unscaledWidth, unscaledHeight);
		}
		
	}
}