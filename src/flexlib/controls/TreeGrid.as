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

import flash.events.Event;
import flash.xml.XMLNode;

import flexlib.controls.treeGridClasses.TreeGridColumn;
import flexlib.controls.treeGridClasses.TreeGridListData;

import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.IViewCursor;
import mx.collections.ListCollectionView;
import mx.collections.XMLListCollection;
import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.treeClasses.DefaultDataDescriptor;
import mx.controls.treeClasses.ITreeDataDescriptor;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;


[Style(name="disclosureOpenIcon", type="Class", format="EmbeddedFile", inherit="no")]	

[Style(name="disclosureClosedIcon", type="Class", format="EmbeddedFile", inherit="no")]

[Style(name="folderOpenIcon", type="Class", format="EmbeddedFile", inherit="no")]

[Style(name="folderClosedIcon", type="Class", format="EmbeddedFile", inherit="no")]

[Style(name="defaultLeafIcon", type="Class", format="EmbeddedFile", inherit="no")]

[Style(name="indentation", type="Number", inherit="no")]

[Style(name="verticalTrunks", type="String", enumeration="none,normal,dotted", inherit="no")]

/**
 * 
 */
public class TreeGrid extends DataGrid
{

	/**
	 *  @private
	 *  Used to hold a list of items that are opened or set opened.
	 */
	private var _openItems : Object = {};
	
	
	/**
	 *  An object that specifies the icons for the items.
	 *  Each entry in the object has a field name that is the item UID
	 *  and a value that is an an object with the following format:
	 *  <pre>
	 *  {iconID: <i>Class</i>, iconID2: <i>Class</i>}
	 *  </pre>
	 *  The <code>iconID</code> field value is the class of the icon for
	 *  a closed or leaf item and the <code>iconID2</code> is the class
	 *  of the icon for an open item.
	 *
	 *  <p>This property is intended to allow initialization of item icons.
	 *  Changes to this array after initialization are not detected
	 *  automatically.
	 *  Use the <code>setItemIcon()</code> method to change icons dynamically.</p>
	 *
	 *  @see #setItemIcon()
	 *  @default undefined
	 */
	public var itemIcons : Object;
	
	/**
	 *  @private
	 *  Storage variable for showRoot flag.
	 */
	private var _showRoot : Boolean = true;

	/**
	 *  @private
	 *  Storage variable for changes to showRoot.
	 */
	private var showRootChanged : Boolean = false;
	
	/** 
	*  @private
	*  Flag to indicate if the model has a root
	*/
	private var _hasRoot : Boolean = false;
	
	/**
	 *  @private
	 *  Storage variable for the original dataProvider
	 */
	private var _rootModel : ICollectionView;
	
	/**
	 *  @private
	 *  Storage variable for the displayed dataProvider
	 */
	private var _displayedModel : ArrayCollection = new ArrayCollection();


	public function TreeGrid()
	{
		super();
		
		setStyle("indentation", 18);
	}
	
	public function dispatchTreeEvent(type:String,
										   listData:TreeGridListData,
										   renderer:IListItemRenderer,
										   trigger:Event = null,
										   opening:Boolean = true, 
										   dispatch:Boolean = true) : void
	{
		if( opening )
		{
			openItemAt( getItemIndex( listData.item ), listData.item );//listData.rowIndex - 1
		}
		else
		{
			closeItemAt( getItemIndex( listData.item ), listData.item ); //listData.rowIndex - 1
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  DataProvider
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var dataProviderChanged : Boolean = false;
	
	[Inspectable(category="Data", defaultValue="undefined")]
	override public function set dataProvider( value : Object ) : void
	{
		if (_rootModel)
			_rootModel.removeEventListener(
							CollectionEvent.COLLECTION_CHANGE, 
							collectionChangeHandler);
											
		// handle strings and xml
		if (typeof(value)=="string")
			value = new XML(value);
		else if (value is XMLNode)
			value = new XML(XMLNode(value).toString());
		else if (value is XMLList)
			value = new XMLListCollection(value as XMLList);
		
		if (value is XML)
		{
			_hasRoot = true;
			var xl:XMLList = new XMLList();
			xl += value;
			_rootModel = new XMLListCollection(xl);
		}
		//if already a collection dont make new one
		else if (value is ICollectionView)
		{
			_rootModel = ICollectionView(value);
		}
		else if (value is Array)
		{
			_rootModel = new ArrayCollection(value as Array);
		}
		//all other types get wrapped in an ArrayCollection
		else if (value is Object)
		{
			_hasRoot = true;
			// convert to an array containing this one item
			var tmp:Array = [];
			   tmp.push(value);
			_rootModel = new ArrayCollection(tmp);
		  }
		  else
		  {
			  _rootModel = new ArrayCollection();
		  }
		
		//flag for processing in commitProps
		dataProviderChanged = true;
		invalidateProperties();
	}
	
	override public function get dataProvider() : Object
	{
		return _rootModel;
	}
	
	
	//--------------------------------------------------------------------------
	// dataDescriptor
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var _dataDescriptor : ITreeDataDescriptor =
		new DefaultDataDescriptor();

	[Inspectable(category="Data")]
	public function set dataDescriptor( value : ITreeDataDescriptor ) : void
	{
		_dataDescriptor = value;
	}

	public function get dataDescriptor() : ITreeDataDescriptor
	{
		return ITreeDataDescriptor( _dataDescriptor );
	}
	
	/**
	 *  Sets the visibility of the root item.
	 *
	 *  If the dataProvider data has a root node, and this is set to 
	 *  <code>false</code>, the Tree control does not display the root item. 
	 *  Only the decendants of the root item are displayed.  
	 * 
	 *  This flag has no effect on non-rooted dataProviders, such as List and Array. 
	 *
	 *  @default true
	 *  @see #hasRoot
	 */
	public function get showRoot() : Boolean
	{
		return _showRoot;
	}

	/**
	 *  @private
	 */
	public function set showRoot( value : Boolean ) : void
	{
		if ( _showRoot != value )
		{
			_showRoot = value;
			showRootChanged = true;
			invalidateProperties();
		}
	}
	
	/**
	 *  Indicates that the current dataProvider has a root item; for example, 
	 *  a single top node in a hierarchical structure. XML and Object 
	 *  are examples of types that have a root. Lists and arrays do not.
	 * 
	 *  @see #showRoot
	 */
	public function get hasRoot() : Boolean
	{
		return _hasRoot;
	}
	
	override protected function commitProperties() : void
	{
		if ( showRootChanged )
		{
			if ( !_hasRoot )
				showRootChanged = false;			
		}
		
		if ( dataProviderChanged || showRootChanged )
		{
			var tmpCollection : ICollectionView;
			var row : Object;
			
			//we always reset the displayed rows on a dataprovider assignment or when the showRoot property change
			_displayedModel = new ArrayCollection();
			
			//reset flags 
			dataProviderChanged = false;
			showRootChanged = false;
			
			//we always reset the open and selected items on a dataprovider assignment
			if ( !openItemsChanged )
				  _openItems = {};
		
			// are we swallowing the root?
			if ( _rootModel && !_showRoot && _hasRoot )
			{
				var rootItem : * = _rootModel.createCursor().current;
				if ( rootItem != null &&
					 _dataDescriptor.isBranch( rootItem, _rootModel ) &&
					 _dataDescriptor.hasChildren( rootItem, _rootModel ))
				{
					// then get rootItem children
					tmpCollection = getChildren( rootItem, _rootModel );
					
					for each( row in tmpCollection )
					{
						_displayedModel.addItem( row );
					}
				}
			}
			else
			{
				if( _hasRoot )
				{
					if( _rootModel != null && _rootModel.length > 0 )
					{
						_displayedModel.addItem( _rootModel[0] );
					}	
				}
				else
				{
					for each( row in _rootModel )
					{
						_displayedModel.addItem( row );
					}
				}	
			}
			
			super.dataProvider = _displayedModel;

		 //TODO: maybe we can use HierarchicalCollectionView?

			/*// at this point _rootModel may be null so we dont need to continue
			if ( _rootModel )
			{
				//wrap userdata in a TreeCollection and pass that collection to the List
				super.dataProvider = wrappedCollection = new HierarchicalCollectionView(
															tmpCollection != null ? tmpCollection : _rootModel,
														   _dataDescriptor,
														   _openItems);
														   
				
				   // not really a default handler, but we need to be later than the wrapper
				wrappedCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE,
										  collectionChangeHandler,
										  false,
										  EventPriority.DEFAULT_HANDLER, true);
			}
			else
			{
				super.dataProvider = null;
			}*/
		 }
		
		if ( openItemsChanged )
		{
			openItemsChanged = false;
			//setting open items resets the collection
			var event : CollectionEvent =
				new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			   event.kind = CollectionEventKind.RESET;
			   collection.dispatchEvent(event);
		}
		
		super.commitProperties();
	}
	
	override protected function makeListData(
		data : Object, 
		uid : String, 
		rowNum : int, 
		columnNum : int, 
		column : DataGridColumn ) : BaseListData
	{
		var treeGridListData : TreeGridListData;
		
		if ( data is DataGridColumn )
		{
			treeGridListData = new TreeGridListData(
				(column.headerText != null) ? column.headerText : column.dataField, 
				column.dataField, 
				columnNum, 
				uid, 
				this, 
				rowNum);
		}
		else
		{ 
			treeGridListData = new TreeGridListData(
				column.itemToLabel(data), 
				column.dataField, 
				columnNum, uid, 
				this, 
				rowNum);
				
			initListData( data, treeGridListData );
		}
		
		return treeGridListData;
	}
	
	protected function initListData( item : Object, treeListData : TreeGridListData ) : void
	{
		if (item == null)
			return;

		var open:Boolean = isItemOpen(item);
		var branch:Boolean = isBranch(item);
		var uid:String = itemToUID(item);

		// this is hidden by non-branches but kept so we know how wide it is so things align
		treeListData.disclosureIcon = getStyle(open ? "disclosureOpenIcon" :
													  "disclosureClosedIcon");
		treeListData.open = open;
		treeListData.hasChildren = branch;
		treeListData.depth = getItemDepth( item, treeListData.rowIndex );
		treeListData.indent = (treeListData.depth - ( _showRoot ? 1 : 2 ) ) * getStyle("indentation");
		treeListData.indentationGap = getStyle("indentation");
		treeListData.item = item;
		treeListData.icon = itemToIcon( item );
		
		treeListData.trunk = getStyle("verticalTrunks");
		if( treeListData.trunk )
		{
			treeListData.trunkOffsetTop = getStyle("paddingTop");
			treeListData.trunkOffsetBottom = getStyle("paddingBottom");
			treeListData.hasSibling = !isLastItem( treeListData );
		}
	}
	
	private function getChildren( item : Object, view : Object) : ICollectionView
	{
		//get the collection of children
		var children : ICollectionView = _dataDescriptor.getChildren( item, view );
		
		return children;
	}
	
	/**
	* This method find if the current node is the last displayed sibling 
	* 
	* Used to draw the vertical trunk lines, 
	* if it is the last child then the vertical trunk line should stop in the middle of the row
	**/
	protected function isLastItem( listData : TreeGridListData ) : Boolean
	{
		//TODO: find a way to optimize this method, it's SLOOOWWWW maybe by using HierarchicalCollectionView? ...

		/*
		var rowIndex : int = getItemIndex( listData.item );
		
		var data : Object = IList( dataProvider ).getItemAt( rowIndex );
		
		if( IList( dataProvider ).length > rowIndex + 1 )
		{
			for(var i:int = rowIndex + 1; i < IList( dataProvider ).length; i++)
			{
				var nextData : Object = IList( dataProvider ).getItemAt( i );
				
				var nextDataDepth : int = getItemDepth( nextData, i );
				
				if( nextDataDepth == listData.depth )
					return false;
			}
		}
		*/
		
		return false;
	}
	
	protected function getItemDepth( item : Object, offset : int ) : int
	{
		var depth : int;
	
		//if the dataprovider have a root, we begin from the root.
		if( hasRoot )
		{
			depth = searchForCurrentDepth( dataProvider[0], item );
		}
		//If the dataprovider don't have a root, we need to parse all items from the first level.
		else
		{
			var i : int = 0;
			do
			{
				depth = searchForCurrentDepth( dataProvider[i++], item );
			}
			while( depth == -1)
		}
		
		if( depth == -1 )
			throw new Error("item not found");
		
		return depth;
		
	}
	
	/**
	 * 
	 */	
	private function searchForCurrentDepth( 
		value : Object, 
		item : Object, 
		depth : int = 1 ) : int
	{
		if( value == item )
			return depth;
		
		if( value == null || _dataDescriptor.getChildren( value ) == null )	
			return -1;
		
		depth++;
		for( var i : int = 0; i < _dataDescriptor.getChildren( value ).length; i++ )
		{
			var result : int = 
				searchForCurrentDepth( _dataDescriptor.getChildren( value )[i], item, depth );
			
			if( result != -1)
				return result;
		}
		
		return -1;
	}

	/**
	 *  @private
	 */
	private function getItemIndex(item:Object):int
	{
		var cursor:IViewCursor = collection.createCursor();
		var i:int = 0;
		
		do
		{
			if (cursor.current === item)
				break;
			i++;
		}
		while ( cursor.moveNext() );
		
		return i;
	}
   
	//--------------------------------------------------------------------------
	//
	//  public methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private 
	 */
	private var openItemsChanged : Boolean = false;
		
	/**
	 *  The items that have been opened or set opened.
	 * 
	 *  @default null
	 */
	public function get openItems():Object
	{
		var openItemsArray:Array = [];
		for each(var item:* in _openItems) 
		{
			openItemsArray.push(item);
		}
		return openItemsArray;
	}
	
	/**
	 *  @private 
	 */
	public function set openItems(value:Object):void
	{
		if (value != null)
		{
			for each (var item:* in value)
			{
				_openItems[itemToUID(item)] = item;
			}
			
			openItemsChanged = true;
			invalidateProperties();
		}
	}

	/**
	 * 
	 */
	public function isBranch( item : Object ) : Boolean
	{
		if (item != null)
			return _dataDescriptor.isBranch( item, iterator.view );

		return false;
	}
	
	/**
	 * 
	 */
	public function isItemOpen( item : Object) : Boolean
	{
		var uid : String = itemToUID( item );
		
		return _openItems[ uid ] != null;
	}
	
	/**
	 *  @private
	 */
	override public function itemToIcon( item : Object ) : Class
	{ 
		if ( item == null )
		{
			return null;
		}

		var icon : *;
		var open : Boolean = isItemOpen( item );
		var branch : Boolean = isBranch( item );
		var uid : String = itemToUID( item );

		//first lets check the component
		var iconClass : Class =
				itemIcons && itemIcons[uid] ?
				itemIcons[uid][open ? "iconID2" : "iconID"] :
				null;

		if ( iconClass )
		{
			return iconClass;
		}
		else if ( iconFunction != null )
		{
			return iconFunction( item );
		}
		else if ( branch )
		{
			return getStyle(open ? "folderOpenIcon" : "folderClosedIcon");
		}
		else
		//let's check the item itself
		{
			if ( item is XML )
			{
				try
				{
					if (item[ iconField ].length() != 0)
						icon = String( item[iconField] );
				}
				   catch( e : Error )
				   {
				   }
			}
			else if ( item is Object )
			{
				try
				{
					if ( iconField && item[iconField] )
						icon = item[ iconField ];
					else if ( item.icon )
						icon = item.icon;
				}
				catch ( e : Error )
				{
				}
			}
		}

		//set default leaf icon if nothing else was found
		if ( icon == null )
			icon = getStyle("defaultLeafIcon");

		//convert to the correct type and class
		if ( icon is Class )
		{
			return icon;
		}
		else if ( icon is String )
		{
			iconClass = Class( systemManager.getDefinitionByName(String(icon)) );
			if ( iconClass )
				return iconClass;

			return document[icon];
		}
		else
		{
			return Class(icon);
		}

	}
	
	/**
	 *  Sets the associated icon for the item.  Calling this method overrides the
	 *  <code>iconField</code> and <code>iconFunction</code> properties for
	 *  this item if it is a leaf item. Branch items don't use the
	 *  <code>iconField</code> and <code>iconFunction</code> properties.
	 *  They use the <code>folderOpenIcon</code> and <code>folderClosedIcon</code> properties.
	 *
	 *  @param item Item to affect.
	 *  @param iconID Linkage ID for the closed (or leaf) icon.
	 *  @param iconID2 Linkage ID for the open icon.
	 *
	 *  @tiptext Sets the icons for the specified item
	 *  @helpid 3201
	 */
	public function setItemIcon(item:Object, iconID:Class, iconID2:Class):void
	{
		if ( !itemIcons )
			itemIcons = {};

		if ( !iconID2 )
			iconID2 = iconID;

		itemIcons[ itemToUID(item) ] = { iconID: iconID, iconID2: iconID2 };

		itemsSizeChanged = true;
		invalidateDisplayList();
	}

	/**
	 * 
	 */
	public function closeAllItems() : void
	{
		for( var i : int = 0; i < ICollectionView( _displayedModel ).length; i++ )
		{
			this.closeItemAt( i );
		}	
	}
	
	/**
	 * 
	 */
	public function closeItemAt( rowNum : Number, item : Object = null, closeItem : Boolean = true ) : void
	{
		if( item == null )
			item = ListCollectionView( _displayedModel ).getItemAt( rowNum );
		
		if( closeItem )
		{
			var uid : String = itemToUID( item );
			delete _openItems[ uid ];
		}

		if( _dataDescriptor.getChildren( item ) )
		{
			// recursively remove the rows that were added for child records
			// but don't remove item from _openItems[] to keep opened items.
			for( var i : int = 0; i < _dataDescriptor.getChildren( item ).length; i++ )
			{
				if( isItemOpen( _dataDescriptor.getChildren( item )[ i ] ) )
				{
				closeItemAt( rowNum, _dataDescriptor.getChildren( item )[ i ], false );
				}
			
				ListCollectionView( _displayedModel ).removeItemAt( rowNum + 1 );
			}
		 }
	}
	
	/**
	 * 
	 */
	public function openItemAt( rowNum : Number, item : Object = null ) : void
	{
		var uid : String = itemToUID( item );
		_openItems[ uid ] = item;
		
		this.selectedIndex = -1;
		
		if ( item == null )
			item = ListCollectionView( _displayedModel ).getItemAt( rowNum );
		
		// add the rows for the children at this level
		for ( var i : int = 0; i < _dataDescriptor.getChildren( item ).length; i++ )
		{
			ListCollectionView( _displayedModel ).addItemAt( _dataDescriptor.getChildren( item )[i], rowNum + i + 1 );
		}
		
		for ( i = 0; i < _dataDescriptor.getChildren( item ).length; i++ )
		{
			if ( isItemOpen( _dataDescriptor.getChildren( item )[ i ] ) )
			{
				openItemAt( rowNum + i + 1, _dataDescriptor.getChildren( item )[i] );
			}
		}
	}
	
} // end class
} // end package