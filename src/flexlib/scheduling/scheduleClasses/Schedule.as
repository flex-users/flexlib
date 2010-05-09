package flexlib.scheduling.scheduleClasses
{
  import flexlib.scheduling.ScheduleViewer;
  import flexlib.scheduling.scheduleClasses.layout.BackgroundLayout;
  import flexlib.scheduling.scheduleClasses.layout.BestFitLayout;
  import flexlib.scheduling.scheduleClasses.layout.HorizontalLinesLayout;
  import flexlib.scheduling.scheduleClasses.layout.IBackgroundLayout;
  import flexlib.scheduling.scheduleClasses.layout.IEntryLayout;
  import flexlib.scheduling.scheduleClasses.layout.IHorizontalLinesLayout;
  import flexlib.scheduling.scheduleClasses.layout.ITimeIndicatorLayout;
  import flexlib.scheduling.scheduleClasses.layout.IVerticalLinesLayout;
  import flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent;
  import flexlib.scheduling.scheduleClasses.layout.TimeIndicatorLayout;
  import flexlib.scheduling.scheduleClasses.layout.VerticalLinesLayout;
  import flexlib.scheduling.scheduleClasses.viewers.BackgroundViewer;
  import flexlib.scheduling.scheduleClasses.viewers.EntryViewer;
  import flexlib.scheduling.scheduleClasses.viewers.HorizontalLinesViewer;
  import flexlib.scheduling.scheduleClasses.viewers.IHorizontalLinesViewer;
  import flexlib.scheduling.scheduleClasses.viewers.ITimeIndicatorViewer;
  import flexlib.scheduling.scheduleClasses.viewers.IVerticalLinesViewer;
  import flexlib.scheduling.scheduleClasses.viewers.TimeIndicatorViewer;
  import flexlib.scheduling.scheduleClasses.viewers.VerticalLinesViewer;

  import mx.collections.IList;
  import mx.core.ClassFactory;
  import mx.core.IFactory;
  import mx.core.UIComponent;

  public class Schedule
  {
    public var isViewlayersInitialized:Boolean;
    public var navigator:ScheduleNavigator;

    public var backgroundLayoutImpl:IBackgroundLayout;
    public var horizontalLinesLayoutImpl:IHorizontalLinesLayout;
    public var verticalLinesLayoutImpl:IVerticalLinesLayout;
    public var timeIndicatorLayoutImpl:ITimeIndicatorLayout;
    public var horizontalLinesViewerImpl:IHorizontalLinesViewer;
    public var verticalLinesViewerImpl:IVerticalLinesViewer;
    public var timeIndicatorViewerImpl:ITimeIndicatorViewer;

    public var entryViewer:EntryViewer;
    public var backgroundViewer:BackgroundViewer;

    public var content:UIComponent;

    private var owner:ScheduleViewer;
    private var _entryLayoutImpl:IEntryLayout;

    private var _entryLayout:IFactory;
    private var _backgroundLayout:IFactory;
    private var _horizontalLinesLayout:IFactory;
    private var _verticalLinesLayout:IFactory;
    private var _timeIndicatorLayout:IFactory;

    private var _horizontalLinesViewer:IFactory;
    private var _verticalLinesViewer:IFactory;
    private var _timeIndicatorViewer:IFactory;

    public function Schedule(owner:ScheduleViewer)
    {
      this.owner = owner;
    }

    public function initialize():void
    {
      isViewlayersInitialized = false;
      createEntryLayout();
      createEntryViewer();
      createBackgroundLayout();
      createHorizontalLinesLayout();
      createHorizontalLinesViewer();
      createVerticalLinesLayout();
      createVerticalLinesViewer();
      createTimeIndicatorLayout();
      createTimeIndicatorViewer();
    }

    public function initializeCompileTimeViewLayers():void
    {
      backgroundViewer = new BackgroundViewer();
      createEntryViewer();
    }

    public function initializeRuntimeViewLayers():void
    {
      createEntryLayout();
      createBackgroundLayout();
      createHorizontalLinesLayout();
      createHorizontalLinesViewer();
      createVerticalLinesLayout();
      createVerticalLinesViewer();
      createTimeIndicatorLayout();
      createTimeIndicatorViewer();

      entryLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, entryViewer.update);
      backgroundLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, backgroundViewer.update);
      horizontalLinesLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, horizontalLinesViewerImpl.
                                                 update);
      verticalLinesLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, verticalLinesViewerImpl.update);
      timeIndicatorLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, timeIndicatorViewerImpl.update);

      entryLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, backgroundLayoutImpl.update);
      entryLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, horizontalLinesLayoutImpl.update);
      entryLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, verticalLinesLayoutImpl.update);
      entryLayoutImpl.addEventListener(LayoutUpdateEvent.UPDATE, timeIndicatorLayoutImpl.update);

      initializeViewLayerProperties();
    }

    [Bindable]
    public function get entryLayout():IFactory
    {
      return _entryLayout;
    }

    public function set entryLayout(value:IFactory):void
    {
      if (value != null && value != _entryLayout)
      {
        _entryLayout = value;
      }
    }

    [Bindable]
    public function get entryRenderer():IFactory
    {
      return entryViewer.entryRenderer;
    }

    public function set entryRenderer(value:IFactory):void
    {
      if (value != null && value != entryViewer.entryRenderer)
      {
        entryViewer.entryRenderer = value;
      }
    }

    [Bindable]
    public function get backgroundLayout():IFactory
    {
      return _backgroundLayout;
    }

    public function set backgroundLayout(value:IFactory):void
    {
      if (value != null && value != _backgroundLayout)
      {
        _backgroundLayout = value;
      }
    }

    [Bindable]
    public function get horizontalLinesLayout():IFactory
    {
      return _horizontalLinesLayout;
    }

    public function set horizontalLinesLayout(value:IFactory):void
    {
      if (value != null && value != _horizontalLinesLayout)
      {
        _horizontalLinesLayout = value;
      }
    }

    [Bindable]
    public function get horizontalLinesViewer():IFactory
    {
      return _horizontalLinesViewer;
    }

    public function set horizontalLinesViewer(value:IFactory):void
    {
      if (value != null && value != _horizontalLinesViewer)
      {
        _horizontalLinesViewer = value;
      }
    }

    [Bindable]
    public function get verticalLinesLayout():IFactory
    {
      return _verticalLinesLayout;
    }

    public function set verticalLinesLayout(value:IFactory):void
    {
      if (value != null && value != _verticalLinesLayout)
      {
        _verticalLinesLayout = value;
      }
    }

    [Bindable]
    public function get verticalLinesViewer():IFactory
    {
      return _verticalLinesViewer;
    }

    public function set verticalLinesViewer(value:IFactory):void
    {
      if (value != null && value != _verticalLinesViewer)
      {
        _verticalLinesViewer = value;
      }
    }

    [Bindable]
    public function get timeIndicatorLayout():IFactory
    {
      return _timeIndicatorLayout;
    }

    public function set timeIndicatorLayout(value:IFactory):void
    {
      if (value != null && value != _timeIndicatorLayout)
      {
        _timeIndicatorLayout = value;
      }
    }

    [Bindable]
    public function get timeIndicatorViewer():IFactory
    {
      return _timeIndicatorViewer;
    }

    public function set timeIndicatorViewer(value:IFactory):void
    {
      if (value != null && value != _timeIndicatorViewer)
      {
        _timeIndicatorViewer = value;
      }
    }

    public function get entryLayoutImpl():IEntryLayout
    {
      return _entryLayoutImpl;
    }

    public function set entryLayoutImpl(value:IEntryLayout):void
    {
      navigator.entryLayoutImpl = value;
      _entryLayoutImpl = value;
    }

    private function createEntryLayout():void
    {
      if (_entryLayout == null)
      {
        entryLayout = new ClassFactory(BestFitLayout);
        entryLayoutImpl = IEntryLayout(_entryLayout.newInstance());
      }
      else
      {
        var contentWidth:Number = entryLayoutImpl.contentWidth;
        var contentHeight:Number = entryLayoutImpl.contentHeight;
        var startDate:Date = entryLayoutImpl.startDate;
        var endDate:Date = entryLayoutImpl.endDate;
        var rowHeight:Number = entryLayoutImpl.rowHeight;

        entryLayoutImpl = IEntryLayout(_entryLayout.newInstance());
        entryLayoutImpl.contentWidth = contentWidth;
        entryLayoutImpl.contentHeight = contentHeight;
        entryLayoutImpl.startDate = startDate;
        entryLayoutImpl.endDate = endDate;
        entryLayoutImpl.rowHeight = rowHeight;
      }
    }

    private function createEntryViewer():void
    {
      if (entryViewer == null)
      {
        entryViewer = new EntryViewer();
      }
    }

    private function createBackgroundLayout():void
    {
      if (_horizontalLinesLayout == null)
      {
        backgroundLayout = new ClassFactory(BackgroundLayout);
        backgroundLayoutImpl = IBackgroundLayout(_backgroundLayout.newInstance());
      }
      else
      {
        var backgroundItems:IList = backgroundLayoutImpl.backgroundItems;
        var timeRanges:IList = backgroundLayoutImpl.timeRanges
        var minimumTimeRangeWidth:Number = backgroundLayoutImpl.minimumTimeRangeWidth;

        backgroundLayoutImpl = IBackgroundLayout(_backgroundLayout.newInstance());
        backgroundLayoutImpl.backgroundItems = backgroundItems;
        backgroundLayoutImpl.timeRanges = timeRanges;
        backgroundLayoutImpl.minimumTimeRangeWidth = minimumTimeRangeWidth;
      }
    }

    private function createHorizontalLinesLayout():void
    {
      if (_horizontalLinesLayout == null)
      {
        horizontalLinesLayout = new ClassFactory(HorizontalLinesLayout);
        horizontalLinesLayoutImpl = IHorizontalLinesLayout(_horizontalLinesLayout.newInstance());
      }
      else
      {
        horizontalLinesLayoutImpl = IHorizontalLinesLayout(_horizontalLinesLayout.newInstance());
      }
    }

    private function createHorizontalLinesViewer():void
    {
      if (_horizontalLinesViewer == null)
      {
        horizontalLinesViewer = new ClassFactory(HorizontalLinesViewer);
        horizontalLinesViewerImpl = IHorizontalLinesViewer(_horizontalLinesViewer.newInstance());
      }
      else
      {
        horizontalLinesViewerImpl = IHorizontalLinesViewer(_horizontalLinesViewer.newInstance());
      }
    }

    private function createVerticalLinesLayout():void
    {
      if (_verticalLinesLayout == null)
      {
        verticalLinesLayout = new ClassFactory(VerticalLinesLayout);
        verticalLinesLayoutImpl = IVerticalLinesLayout(_verticalLinesLayout.newInstance());
      }
      else
      {
        var timeRanges:IList = verticalLinesLayoutImpl.timeRanges
        var minimumTimeRangeWidth:Number = verticalLinesLayoutImpl.minimumTimeRangeWidth;

        verticalLinesLayoutImpl = IVerticalLinesLayout(_verticalLinesLayout.newInstance());
        verticalLinesLayoutImpl.timeRanges = timeRanges;
        verticalLinesLayoutImpl.minimumTimeRangeWidth = minimumTimeRangeWidth;
      }
    }

    private function createVerticalLinesViewer():void
    {
      if (_verticalLinesViewer == null)
      {
        verticalLinesViewer = new ClassFactory(VerticalLinesViewer);
        verticalLinesViewerImpl = IVerticalLinesViewer(_verticalLinesViewer.newInstance());
      }
      else
      {
        verticalLinesViewerImpl = IVerticalLinesViewer(_verticalLinesViewer.newInstance());
      }
    }

    private function createTimeIndicatorLayout():void
    {
      if (_timeIndicatorLayout == null)
      {
        timeIndicatorLayout = new ClassFactory(TimeIndicatorLayout);
        timeIndicatorLayoutImpl = ITimeIndicatorLayout(_timeIndicatorLayout.newInstance());
      }
      else
      {
        var timeIndicators:IList = timeIndicatorLayoutImpl.timeIndicators;
        timeIndicatorLayoutImpl = ITimeIndicatorLayout(_timeIndicatorLayout.newInstance());
        timeIndicatorLayoutImpl.timeIndicators = timeIndicators;
      }
    }

    private function createTimeIndicatorViewer():void
    {
      if (_timeIndicatorViewer == null)
      {
        timeIndicatorViewer = new ClassFactory(TimeIndicatorViewer);
        timeIndicatorViewerImpl = ITimeIndicatorViewer(_timeIndicatorViewer.newInstance());
      }
      else
      {
        timeIndicatorViewerImpl = ITimeIndicatorViewer(_timeIndicatorViewer.newInstance());
      }
    }

    private function initializeViewLayerProperties():void
    {
      if (entryRenderer == null)
      {
        entryRenderer = entryViewer.entryRenderer;
      }
      else
      {
        entryViewer.entryRenderer = entryRenderer;
      }

      horizontalLinesViewerImpl.dottedGridLines = owner.getStyle("dottedGridLines");
      horizontalLinesViewerImpl.horizontalGridLineThickness = owner.getStyle("horizontalGridLineThickness");
      horizontalLinesViewerImpl.horizontalGridLineColor = owner.getStyle("horizontalGridLineColor");
      horizontalLinesViewerImpl.horizontalGridLineAlpha = owner.getStyle("horizontalGridLineAlpha");

      verticalLinesViewerImpl.dottedGridLines = owner.getStyle("dottedGridLines");
      verticalLinesViewerImpl.verticalGridLineThickness = owner.getStyle("verticalGridLineThickness");
      verticalLinesViewerImpl.verticalGridLineColor = owner.getStyle("verticalGridLineColor");
      verticalLinesViewerImpl.verticalGridLineAlpha = owner.getStyle("verticalGridLineAlpha");

      var entryViewerIndex:int = content.getChildIndex(entryViewer);
      content.addChildAt(UIComponent(horizontalLinesViewerImpl), entryViewerIndex);
      content.addChildAt(UIComponent(verticalLinesViewerImpl), entryViewerIndex);
      content.addChildAt(UIComponent(timeIndicatorViewerImpl), entryViewerIndex);
    }

    public function initializeEntryLayout():void
    {
      if (owner.dataProvider != null)
      {
        entryLayoutImpl.dataProvider = IList(owner.dataProvider);
      }
    }
  }
}