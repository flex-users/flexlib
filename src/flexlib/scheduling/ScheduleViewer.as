/*

   Copyright (c) 2006. Adobe Systems Incorporated.
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of Adobe Systems Incorporated nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.

   @ignore
 */
package flexlib.scheduling
{
  import flexlib.scheduling.scheduleClasses.IScheduleEntry;
  import flexlib.scheduling.scheduleClasses.LayoutScrollEvent;
  import flexlib.scheduling.scheduleClasses.Schedule;
  import flexlib.scheduling.scheduleClasses.ScheduleNavigator;
  import flexlib.scheduling.scheduleClasses.layout.IEntryLayout;
  import flexlib.scheduling.scheduleClasses.schedule_internal;

  import flash.events.Event;
  import flash.events.MouseEvent;

  import mx.collections.ArrayCollection;
  import mx.collections.ICollectionView;
  import mx.collections.IList;
  import mx.controls.scrollClasses.ScrollBar;
  import mx.core.IFactory;
  import mx.core.ScrollControlBase;
  import mx.core.UIComponent;
  import mx.events.CollectionEvent;
  import mx.events.CollectionEventKind;
  import mx.events.ScrollEvent;
  import mx.styles.CSSStyleDeclaration;
  import mx.styles.StyleManager;

  [Event(name="itemScroll", type="flexlib.scheduling.scheduleClasses.LayoutScrollEvent")]
  [Event(name="pixelScroll", type="flexlib.scheduling.scheduleClasses.LayoutScrollEvent")]
  //[Event(name="scroll", type="mx.events.ScrollEvent")]

  /**
   *  Length of the transition when moving around the canvas.
   *
   *  @default 250
   */
  [Style(name="moveDuration", type="Number", format="Time", inherit="yes")]

  /**
   *  An easing function to control the canvas movment transition. Easing functions can
   *  be used to control the acceleration and deceleration of the transition.
   *
   *  @default undefined
   */
  [Style(name="moveEasingFunction", type="Function", inherit="yes")]


  /**
   *  Name of CSS style declaration that specifies styles for the schedule entries
   */
  [Style(name="entryStyleName", type="String", inherit="yes")]

  /**
   *  The color of the horizontal grid lines.
   *  @default 0x666666
   */
  [Style(name="dottedGridLines", type="Boolean", inherit="yes")]
  [Style(name="horizontalGridLineThickness", type="Number", format="Length", inherit="yes")]
  [Style(name="horizontalGridLineColor", type="uint", format="Color", inherit="yes")]
  [Style(name="horizontalGridLineAlpha", type="Number", inherit="yes")]

  [Style(name="verticalGridLineThickness", type="Number", format="Length", inherit="yes")]
  [Style(name="verticalGridLineColor", type="uint", format="Color", inherit="yes")]
  [Style(name="verticalGridLineAlpha", type="Number", inherit="yes")]

  /**
   * ScheduleViewer is the main scheduling component. It allows you to render and manipulate
   * schedule entries in an efficient and very customizable way.
   * <p><strong>ScheduleViewerSample1 - Introduction</strong></p>
   * <p>
   * The ScheduleViewerSample1.mxml in the example section shows how to setup
   * a ScheduleViewer with default values and 3 entries.
   * </p>
   * <p>
   * To render schedule entries the dataProvider property by default accepts a collection of
   * flexlib.scheduling.scheduleClasses.IScheduleEntry objects.
   * ScheduleViewerSample1 uses flexlib.scheduling.scheduleClasses.SimpleScheduleEntry,
   * an implementation of IScheduleEntry.
   * </p>
   * <p>
   * The dataProvider item gets passed into the entryRenderer, which by default
   * is flexlib.scheduling.scheduleClasses.renderers.GradientScheduleEntryRenderer.mxml.
   * You can customize various styles of the entry renderer via the entryStyleName style of ScheduleViewer.
   * In ScheduleViewerSample1, we use the default styles but there is an example CSS inlcuded.
   * Try to assign the included myEntryStyle class selector to the entryStyleName style property
   * of the ScheduleViewer instance.
   * </p>
   * <p>
   * In addition, for maximum flexibility, you can provide a fully customized entry renderer
   * via the entryRenderer property. The entryRenderer has to implement
   * flexlib.scheduling.scheduleClasses.renderers.IScheduleEntryRenderer.
   * </p>
   * <p>
   * ScheduleViewer layouts the entries according to the rules of a layout manager. You can
   * specify the layout manager with the entryLayout property. Furthermore,
   * the layout manager can handle any changes that occur to the data provider as any updates,
   * additions, deletions etc to the entries.
   * </p>
   * <p>
   * By default, the flexlib.scheduling.scheduleClasses.layout.BestFitLayout
   * is used, which assigns entries to the top most rows without causing any overlaps
   * between entries.
   * </p>
   * <p><strong>ScheduleViewerSample2 - Layout Manager: SimpleLayout</strong></p>
   * <p>
   * Another supplied layout manager is the
   * flexlib.scheduling.scheduleClasses.layout.SimpleLayout which places entries exactly as
   * defined in the dataProvider. This means, that when using SimpleLayout, each item
   * of the dataProvider is expected to be of type mx.collection.IList since it represents a row.
   * Each row IList collection is expected to contain IScheduleEntry objects.
   * You can write your own layout manager, check the BestFitLayout and SimpleLayout and their
   * base classes and implemented interfaces for how to do that.
   * </p>
   * <p>
   * The ScheduleViewerSample2.mxml shows how to setup
   * a ScheduleViewer with the supplied SimpleLayout manager. Notice the different structure of
   * the dataProvider, which now exactly determines how entries are being laid out.
   * Furthermore, SimpleLayout does not check entries for overlapping. Therefore,
   * in the second row of ScheduleViewerSample2 you can see one entry overlapping.
   * </p>
   * <p>
   * Notice that we use a different entry renderer in ScheduleViewerSample2.
   * Instead the default gradient renderer we now use
   * flexlib.scheduling.scheduleClasses.renderers.SolidScheduleEntryRenderer
   * </p>
   * <p><strong>ScheduleViewerSample3 - Adding Navigation and Zooming</strong></p>
   * <p>
   * The ScheduleViewerSample3 sample shows how to add a navigation and a zooming tool.
   * In order to achieve maximum flexibility both features are meant to be
   * driven by external components that talk to an API of ScheduleViewer.</p>
   * <p><em>Zooming</em></p>
   * <p>
   * The ScheduleViewer's zoom property can be manipulated in order to achieve zooming.
   * You could use i.e. a mx:HSlider component that manipulates zoom on each change event
   * as the ScheduleViewerSample3 example shows. A zoom value of 100 always shows the complete
   * dataProvider on the currently visible canvas (no scrollbars have to appear).</p>
   * <p><em>Navigation</em></p>
   * <p>
   * The ScheduleViewer's xPosition and yPosition properties can be manipulated in order
   * to navigate along ScheduleViewer's content.
   * You could use the scroll events of the Timeline component and the pixelScroll events
   * of ScheduleViewer to connect both components and achieve navigation via Timeline.
   * </p>
   * <p>
   * ScheduleViewer offers APIs to navigate (and animate) to specific entries or times.
   * See the gotoNow and gotoSelectedEntry methods of ScheduleViewerSample3.
   * </p>
   * <p>
   * You can select single or multiple entries via the selectedItem and selectedItems property.
   * To switch to the multiple selection mode, set the allowMultipleSelection to true.
   * </p>
   * <p>
   * Furthermore, in this example, the background color of each schedule entry shall be
   * data provider driven. To make this possible, we've specified another supplied entry renderer;
   * flexlib.scheduling.scheduleClasses.renderers.ColoredGradientScheduleEntryRenderer.
   * This enry renderer accepts only flexlib.scheduling.scheduleClasses.ColoredScheduleEntry objects.
   * We've extracted the creation of schedule entries (of type ColoredScheduleEntry)
   * into a separate class. Check out flexlib.scheduling.samples.ScheduleData in the example
   * section below.
   * </p>
   * <p><strong>ScheduleViewerSample4 - Adding Background areas</strong></p>
   * <p>
   * You can add customized background areas to ScheduleViewer using the backgroundItems property.
   * backgroundItems expects an Array of BackgroundItem objects. You can specify a time range,
   * a color and a description. The latter will be used as a tool tip when the user mouses over
   * area.
   * </p>
   * <p>
   * For further customizations of the background area in ScheduleViewer, you could
   * create your customized version of the background layout manager via the backgroundLayout property.
   * Take a look into the default layout manager
   * flexlib.scheduling.scheduleClasses.layout.BackgroundLayout for more information.
   * i.e. you could add a colored current time area, which moves by the current time.
   * </p>
   * <p>
   * You can also customize the background grid via the supplied styles. See style section.
   * To customize further, you could define custom layout managers via the
   * horizontalLinesLayout and verticalLinesLayout properties. See default implementation is
   * flexlib.scheduling.scheduleClasses.layout.HorizontalLinesLayout and
   * flexlib.scheduling.scheduleClasses.layout.VerticalLinesLayout. i.e. you could
   * add thicker horizontal lines, after certain items.</p>
   * <p><strong>ScheduleViewerSample5 - Row based schedulers</strong></p>
   * <p>
   * ScheduleViewerSample5 shows how you can synchronize a List control
   * with ScheduleViewer. The pixelScrollEnabled flag lets ScheduleViewer
   * scroll on rows instead of pixels. Animations are still supported for pixels. The itemScroll
   * and pixelScroll events allow to connect external components to ScheduleViewer such as the List
   * shown in this example.</p>
   * <p><strong>ScheduleViewerSample6 - Customization of background lines</strong></p>
   * <p>
   * ScheduleViewerSample6 shows how you can customize vertical and
   * horizontal background lines with the exposed horizontalLinesViewer and
   * verticalLinesViewer properties of ScheduleViewer. The custom viewers used in this
   * example are
   * flexlib.scheduling.samples.AlternatingHorizontalLinesViewer and
   * flexlib.scheduling.samples.SolidVerticalLinesViewer</p>
   *
   * @see flexlib.scheduling.scheduleClasses.IScheduleEntry
   * @see flexlib.scheduling.scheduleClasses.SimpleScheduleEntry
   * @see flexlib.scheduling.scheduleClasses.ColoredScheduleEntry
   * @see flexlib.scheduling.scheduleClasses.renderers.GradientScheduleEntryRenderer
   * @flexlib.scheduling.scheduleClasses.renderers.ColoredGradientScheduleEntryRenderer
   * @see flexlib.scheduling.scheduleClasses.renderers.SolidScheduleEntryRenderer
   * @see flexlib.scheduling.scheduleClasses.renderers.IScheduleEntryRenderer
   * @see flexlib.scheduling.scheduleClasses.layout.BestFitLayout
   * @see flexlib.scheduling.scheduleClasses.layout.SimpleLayout
   * @see flexlib.scheduling.scheduleClasses.layout.BackgroundLayout
   * @see flexlib.scheduling.scheduleClasses.BackgroundItem
   * @see flexlib.scheduling.scheduleClasses.layout.HorizontalLinesLayout
   * @see flexlib.scheduling.scheduleClasses.layout.VerticalLinesLayout
   * @see flexlib.scheduling.controls.Timeline
   * @see flexlib.scheduling.util.DateUtil
   *
   */
  public class ScheduleViewer extends ScrollControlBase
  {
    protected var collection:ICollectionView;
    private var schedule:Schedule;
    private var navigator:ScheduleNavigator;
    private var content:UIComponent;
    private var _timeRanges:IList;
    private var _minimumTimeRangeWidth:Number;

    private static var classConstructed:Boolean = classConstruct();

    // Define a static method to initialize the style.
    private static function classConstruct():Boolean
    {
      if (!StyleManager.getStyleDeclaration(".scheduleViewer"))
      {
        // If ScheduleViewer has no CSS definition,
        // create one and set the default value.
        var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
        newStyleDeclaration.setStyle("moveDuration", 1000);
        newStyleDeclaration.setStyle("dottedGridLines", true);
        newStyleDeclaration.setStyle("horizontalGridLineThickness", 1);
        newStyleDeclaration.setStyle("horizontalGridLineColor", 0x000000);
        newStyleDeclaration.setStyle("horizontalGridLineAlpha", .5);
        newStyleDeclaration.setStyle("verticalGridLineThickness", 1);
        newStyleDeclaration.setStyle("verticalGridLineColor", 0x000000);
        newStyleDeclaration.setStyle("verticalGridLineAlpha", .5);

        StyleManager.setStyleDeclaration(".scheduleViewer", newStyleDeclaration, true);
      }
      return true;
    }

    public function ScheduleViewer()
    {
      styleName = "scheduleViewer";
      schedule = new Schedule(this);

      navigator = new ScheduleNavigator(this);
      navigator.addEventListener(ScheduleNavigator.INVALIDATE_DISPLAY_LIST, onInvalidateDisplayList);

      schedule.navigator = navigator;
      schedule.initialize();
    }

    schedule_internal function get verticalScrollBar():ScrollBar
    {
      return verticalScrollBar;
    }

    /**
     * @private
     */
    override protected function createChildren():void
    {
      super.createChildren();

      addEventListener(ScrollEvent.SCROLL, navigator.onScroll);
      addEventListener(LayoutScrollEvent.PIXEL_SCROLL, scrollHandler);

      content = new UIComponent();
      schedule.content = content;
      addChild(content);
      content.mask = maskShape;

      schedule.initializeCompileTimeViewLayers();

      content.addChild(schedule.backgroundViewer);
      content.addChild(schedule.entryViewer);

      invalidateProperties();
    }

    /**
     * @private
     */
    override protected function commitProperties():void
    {
      if (!schedule.isViewlayersInitialized)
      {
        schedule.isViewlayersInitialized = true;
        if (isNaN(contentWidth) && width != 0)
          contentWidth = width;
        schedule.initializeRuntimeViewLayers();
      }
    }

    /**
     * @private
     */
    override protected function updateDisplayList(
      unscaledWidth:Number,
      unscaledHeight:Number):void
    {
      super.updateDisplayList(unscaledWidth, unscaledHeight);

      //other layouters get updated by entryLayoutImpl.
      schedule.entryLayoutImpl.viewportWidth = unscaledWidth;
      schedule.entryLayoutImpl.viewportHeight = unscaledHeight;
      schedule.entryLayoutImpl.update();

      navigator.updateItemScroll();

      setScrollBarProperties(
        schedule.entryLayoutImpl.contentWidth + navigator.contentWidthOffset, unscaledWidth,
        schedule.entryLayoutImpl.contentHeight + navigator.contentHeightOffset, unscaledHeight);
    }

    /**
     * @private
     */
    override public function styleChanged(styleProp:String):void
    {
      super.styleChanged(styleProp);
      if (styleProp != null)
      {
        if (Object(schedule.horizontalLinesViewerImpl).hasOwnProperty(styleProp))
        {
          schedule.horizontalLinesViewerImpl[styleProp] = getStyle(styleProp);
        }
        if (Object(schedule.verticalLinesViewerImpl).hasOwnProperty(styleProp))
        {
          schedule.verticalLinesViewerImpl[styleProp] = getStyle(styleProp);
        }
        if (Object(schedule.timeIndicatorViewerImpl).hasOwnProperty(styleProp))
        {
          schedule.timeIndicatorViewerImpl[styleProp] = getStyle(styleProp);
        }
      }

      var entryStyleName:String = getStyle("entryStyleName");
      if (entryStyleName)
      {
        schedule.entryViewer.setStyle("entryStyleName", entryStyleName);
      }
    }

    /**
     * @private
     */
    protected function modelChangedHandler(event:CollectionEvent):void
    {
      if (schedule.isViewlayersInitialized)
      {
        var entryLayoutImpl:IEntryLayout = IEntryLayout(schedule.entryLayoutImpl);
        if (event.kind == CollectionEventKind.ADD)
        {
          entryLayoutImpl.addItem(event);
        }
        else if (event.kind == CollectionEventKind.REMOVE)
        {
          entryLayoutImpl.removeItem(event);
        }
        else if (event.kind == CollectionEventKind.REPLACE)
        {
          entryLayoutImpl.replaceItem(event);
        }
        else if (event.kind == CollectionEventKind.UPDATE)
        {
          entryLayoutImpl.updateItem(event);
        }
        else if (event.kind == CollectionEventKind.REFRESH)
        {
          entryLayoutImpl.refreshItem(event);
        }
        else if (event.kind == CollectionEventKind.RESET)
        {
          entryLayoutImpl.resetItem(event);
        }
        else if (event.kind == CollectionEventKind.MOVE)
        {
          entryLayoutImpl.moveItem(event);
        }
        invalidateDisplayList();
      }
    }

    override protected function mouseWheelHandler(event:MouseEvent):void
    {
      if (verticalScrollBar)
      {
        event.stopPropagation();
        navigator.mouseWheelHandler(event);
      }
    }

    override protected function scrollHandler(event:Event):void
    {
      navigator.scrollHandler(event);
    }

    public function get dataProvider():Object
    {
      return collection;
    }

    public function set dataProvider(value:Object):void
    {
      if (collection)
      {
        collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, modelChangedHandler);
      }
      if (value is ICollectionView)
      {
        collection = ICollectionView(value);
      }
      else if (value is Array)
      {
        collection = new ArrayCollection(value as Array);
      }
      else
      {
        // convert it to an array containing this one item
        var tmp:Array = [];
        if (value != null)
          tmp.push(value);
        collection = new ArrayCollection(tmp);
      }

      collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, modelChangedHandler);

      var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
      event.kind = CollectionEventKind.RESET;
      schedule.initializeEntryLayout();
      modelChangedHandler(event);
      dispatchEvent(event);
    }

    [Bindable]
    public function get startDate():Date
    {
      return schedule.entryLayoutImpl.startDate;
    }

    public function set startDate(value:Date):void
    {
      schedule.entryLayoutImpl.startDate = value;
      invalidateDisplayList();
    }

    [Bindable]
    public function get endDate():Date
    {
      return schedule.entryLayoutImpl.endDate;
    }

    public function set endDate(value:Date):void
    {
      schedule.entryLayoutImpl.endDate = value;
      invalidateDisplayList();
    }

    [Bindable]
    public function get timeRanges():IList
    {
      return _timeRanges;
    }

    public function set timeRanges(value:IList):void
    {
      _timeRanges = value;
      schedule.backgroundLayoutImpl.timeRanges = _timeRanges;
      schedule.verticalLinesLayoutImpl.timeRanges = _timeRanges;
      invalidateDisplayList();
    }

    [Bindable]
    public function get minimumTimeRangeWidth():Number
    {
      return _minimumTimeRangeWidth;
    }

    public function set minimumTimeRangeWidth(value:Number):void
    {
      _minimumTimeRangeWidth = value;
      schedule.backgroundLayoutImpl.minimumTimeRangeWidth = _minimumTimeRangeWidth;
      schedule.verticalLinesLayoutImpl.minimumTimeRangeWidth = _minimumTimeRangeWidth;
      invalidateDisplayList();
    }

    [Bindable]
    public function get rowHeight():Number
    {
      return schedule.entryLayoutImpl.rowHeight;
    }

    public function set rowHeight(value:Number):void
    {
      schedule.entryLayoutImpl.rowHeight = value;
      schedule.entryLayoutImpl.createLayout();
      invalidateDisplayList();
    }

    [Bindable]
    public function get selectedItem():IScheduleEntry
    {
      return schedule.entryViewer.selectedItem;
    }

    public function set selectedItem(value:IScheduleEntry):void
    {
      schedule.entryViewer.selectedItem = value;
    }

    [Bindable]
    public function get selectedItems():Array
    {
      return schedule.entryViewer.selectedItems;
    }

    public function set selectedItems(value:Array):void
    {
      schedule.entryViewer.selectedItems = value;
    }

    [Bindable]
    public function get allowMultipleSelection():Boolean
    {
      return schedule.entryViewer.allowMultipleSelection;
    }

    public function set allowMultipleSelection(value:Boolean):void
    {
      schedule.entryViewer.allowMultipleSelection = value;
    }

    [Bindable]
    public function get backgroundItems():IList
    {
      return schedule.backgroundLayoutImpl.backgroundItems
    }

    public function set backgroundItems(value:IList):void
    {
      schedule.backgroundLayoutImpl.backgroundItems = value;
    }

    [Bindable]
    public function get timeIndicators():IList
    {
      return schedule.timeIndicatorLayoutImpl.timeIndicators;
    }

    public function set timeIndicators(value:IList):void
    {
      schedule.timeIndicatorLayoutImpl.timeIndicators = value;
    }

    //Core--------------------------

    [Bindable]
    public function get entryLayout():IFactory
    {
      return schedule.entryLayout;
    }

    public function set entryLayout(value:IFactory):void
    {
      schedule.entryLayout = value;
    }

    [Bindable]
    public function get entryRenderer():IFactory
    {
      return schedule.entryRenderer;
    }

    public function set entryRenderer(value:IFactory):void
    {
      schedule.entryRenderer = value;
    }

    [Bindable]
    public function get backgroundLayout():IFactory
    {
      return schedule.backgroundLayout;
    }

    public function set backgroundLayout(value:IFactory):void
    {
      schedule.backgroundLayout = value;
    }

    [Bindable]
    public function get horizontalLinesLayout():IFactory
    {
      return schedule.horizontalLinesLayout;
    }

    public function set horizontalLinesLayout(value:IFactory):void
    {
      schedule.horizontalLinesLayout = value;
    }

    [Bindable]
    public function get horizontalLinesViewer():IFactory
    {
      return schedule.horizontalLinesViewer;
    }

    public function set horizontalLinesViewer(value:IFactory):void
    {
      schedule.horizontalLinesViewer = value;
    }

    [Bindable]
    public function get verticalLinesLayout():IFactory
    {
      return schedule.verticalLinesLayout;
    }

    public function set verticalLinesLayout(value:IFactory):void
    {
      schedule.verticalLinesLayout = value;
    }

    [Bindable]
    public function get verticalLinesViewer():IFactory
    {
      return schedule.verticalLinesViewer;
    }

    public function set verticalLinesViewer(value:IFactory):void
    {
      schedule.verticalLinesViewer = value;
    }

    [Bindable]
    public function get timeIndicatorLayout():IFactory
    {
      return schedule.timeIndicatorLayout;
    }

    public function set timeIndicatorLayout(value:IFactory):void
    {
      schedule.timeIndicatorLayout = value;
    }

    [Bindable]
    public function get timeIndicatorViewer():IFactory
    {
      return schedule.timeIndicatorViewer;
    }

    public function set timeIndicatorViewer(value:IFactory):void
    {
      schedule.timeIndicatorViewer = value;
    }

    //Navigation--------------------------

    [Bindable]
    public function get zoom():Number
    {
      return navigator.zoom;
    }

    public function set zoom(value:Number):void
    {
      navigator.zoom = value;
    }

    [Bindable]
    public function get contentWidth():Number
    {
      return navigator.contentWidth;
    }

    public function set contentWidth(value:Number):void
    {
      navigator.contentWidth = value;
    }

    [Bindable]
    public function get xPosition():Number
    {
      return navigator.xPosition;
    }

    public function set xPosition(value:Number):void
    {
      navigator.xPosition = value;
    }

    [Bindable]
    public function get yPosition():Number
    {
      return navigator.yPosition;
    }

    public function set yPosition(value:Number):void
    {
      navigator.yPosition = value;
    }

    [Bindable]
    public function get xPositionWithOffset():Number
    {
      return navigator.xPositionWithOffset;
    }

    public function set xPositionWithOffset(value:Number):void
    {
      navigator.xPositionWithOffset = value;
    }

    [Bindable]
    public function get yPositionWithOffset():Number
    {
      return navigator.yPositionWithOffset;
    }

    public function set yPositionWithOffset(value:Number):void
    {
      navigator.yPositionWithOffset = value;
    }

    [Bindable]
    public function get xOffset():Number
    {
      return navigator.xOffset;
    }

    public function set xOffset(value:Number):void
    {
      navigator.xOffset = value;
    }

    [Bindable]
    public function get yOffset():Number
    {
      return navigator.yOffset;
    }

    public function set yOffset(value:Number):void
    {
      navigator.yOffset = value;
    }

    [Bindable]
    public function get pixelScrollEnabled():Boolean
    {
      return navigator.pixelScrollEnabled;
    }

    public function set pixelScrollEnabled(value:Boolean):void
    {
      navigator.pixelScrollEnabled = value;
    }

    public function gotoTime(milliseconds:Number):void
    {
      navigator.gotoTime(milliseconds);
    }

    public function moveToTime(milliseconds:Number):void
    {
      navigator.moveToTime(milliseconds);
    }

    public function gotoEntry(entry:IScheduleEntry):void
    {
      navigator.gotoEntry(entry);
    }

    public function moveToEntry(entry:IScheduleEntry):void
    {
      navigator.moveToEntry(entry);
    }

    private function onInvalidateDisplayList(event:Event):void
    {
      invalidateDisplayList();
    }
  }
}