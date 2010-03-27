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

package flexlib.charts
{

  import flash.display.Graphics;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Point;

  import mx.charts.chartClasses.CartesianChart;
  import mx.charts.chartClasses.ChartElement;
  import mx.charts.chartClasses.IChartElement2;
  import mx.charts.chartClasses.Series;
  import mx.core.EventPriority;
  import mx.styles.CSSStyleDeclaration;
  import mx.styles.StyleManager;


  // =================================================
  //  E V E N T S
  // =================================================

  /**
   * Dispatched when the selected data on the horizontal axis changes.
   *
   * @eventType flash.events.Event.CHANGE
   */
  [Event(name="change", type="flash.events.Event")]

  // =================================================
  //  S T Y L E S
  // =================================================

  /**
   * Color of the vertical line that appears for the selected x value
   * The default value is <code>0xFF0000</code>.
   *
   * @default 0xFF0000
   */
  [Style(name="selectorColor", type="uint", format="Color", inherit="no")]


  /**
   * Allows for the selection of a specific data value on the horizontal
   * axis.
   */
  public class HorizontalAxisDataSelector extends ChartElement
  {
    /** Flag for initializing the styles */
    private static var classConstructed:Boolean = classConstruct();

    /** Initialize styles to default values */
    private static function classConstruct():Boolean
    {
      if (!StyleManager.getStyleDeclaration("HorizontalAxisDataSelector"))
      {
        // If HorizontalAxisDataSelector has no CSS definition, 
        // create one and set the default value.
        var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
        newStyleDeclaration.setStyle("selectorColor", 0xFF0000);

        StyleManager.setStyleDeclaration("HorizontalAxisDataSelector", newStyleDeclaration, true);
      }
      return true;
    }

    /**
     * Flag to determine if the mouse is pressed and we should update selected
     * data index on mouse move.
     */
    private var mouseIsDown:Boolean = false;

    //	/**
    //	 * When <code>true</code>, instructs the selector to snap to the nearest data point.
    //	 * When <code>false</code>, the selector will interpolate values based on mouse positions.
    //	 * 
    //	 * @default true
    //	 */
    //	public var snap:Boolean = true;

    /**
     * The last x location of the mouse.  Used when snapping is disabled to determine at which
     * point values should be interpolated.
     */
    private var lastX:Number;

    /** The selected index in the data provider for the chart.  Used when snapping is enabled. */
    private var selectedDataIndex:int = -1;


    /**
     * Constructor.
     */
    public function HorizontalAxisDataSelector()
    {
      super();

      // Register for mouse events to handle data selection
      addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, EventPriority.DEFAULT, false);
      addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, EventPriority.DEFAULT, true);

      // Wait for us to be added to the stage before adding the mouse up handler
      // otherwise we get null reference errors when accessing stage
      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, EventPriority.DEFAULT, true);
    }

    /**
     * Event handler; Invoked when we're added to the stage.
     */
    private function onAddedToStage(event:Event):void
    {
      // Listen on the stage for mouse up so we detect mouse up anywhere
      stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, EventPriority.DEFAULT, true);

      removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    /**
     * Draws the vertical selection line overlay.
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
      super.updateDisplayList(unscaledWidth, unscaledHeight);

      var g:Graphics = graphics;
      g.clear();

      // Draw a big transparent square over the entire chart area
      // so Flash Player sees us for mouse events
      g.moveTo(0, 0);
      g.lineStyle(0, 0, 0);
      g.beginFill(0, 0);
      g.drawRect(0, 0, unscaledWidth, unscaledHeight);
      g.endFill();

      // Only draw the overlay if there is a selection
      if (selectedDataIndex >= 0)
      {
        var values:Array = dataValues;
        // Get the location of where the selection line should be drawn
        var location:Point = chart.dataToLocal(values[0], values[1]);

        // KLUDGE: We seem to off here by the width of the vertical axis.  Strange, not
        // quite what I expected.  Fix it by subtracting the different coordinate systems
        // from the x location.
        var diff:Number = chart.mouseX - this.mouseX;
        location.x -= diff;

        // TODO: Add style for selectorThickness
        // TODO: Add style for selectorThickness alpha
        g.lineStyle(1.5, getStyle("selectorColor"), .8);

        // Draw a vertical line at the point's x location across the entire height of the area
        g.moveTo(location.x, 0);
        g.lineTo(location.x, unscaledHeight);
      }
    }

    /**
     * Gets a list of data values for the currently selected data item on the horizontal
     * axis.  The x field value is always the first element in the array.  Then, for each
     * series, the y value is added to a values array in the same order that the series
     * are defined.
     */
    public function get dataValues():Array
    {
      // Create a new array time so that someone gettnig the data values cannot
      // change them by hanging on to the reference
      var values:Array = new Array();
      var xField:String = chart.series[0].xField;

      // Save the x field value first
      values.push(chart.dataProvider.getItemAt(selectedDataIndex)[xField]);

      // Loop over all the series and get the y information from each series
      for (var i:int = 0; i < chart.series.length; i++)
      {
        var currentSeries:* = chart.series[i];
        // Add the y field values for the values array
        values.push(chart.dataProvider.getItemAt(selectedDataIndex)[currentSeries.yField]);
      }

      return values;
    }

    /**
     * Event handler; invoked when the mouse is pressed.
     */
    private function handleMouseDown(event:MouseEvent):void
    {
      mouseIsDown = true;

      setSelectedDataIndex(event);
    }

    /**
     * Event handler; invoked when the mouse is moved.
     */
    private function handleMouseMove(event:MouseEvent):void
    {
      // Change the value as the user drags the mouse
      if (mouseIsDown)
      {
        setSelectedDataIndex(event);
      }
    }

    /**
     * Event handler; invoked when the mouse is released.
     */
    private function handleMouseUp(event:MouseEvent):void
    {
      mouseIsDown = false;
    }

    /**
     * Helper function to set the selected data index based on mouse coordinates.
     */
    private function setSelectedDataIndex(event:MouseEvent):void
    {
      // Keep track of the old value to determine if it actually changes
      var oldSelectedDataIndex:int = selectedDataIndex;

      // Get the coordinates of the mouse relative to the chart
      var point:Point = new Point(chart.mouseX, chart.mouseY);

      // Get the data values that the point represents
      var dataValues:Array = chart.localToData(point);

      // The first value in the dataValues in the target x field value
      var targetXFieldValue:Number = dataValues[0];

      // Get the xField value to know what to look for in the
      // chart data provider
      var series:* = chart.series[0];
      var xField:String = series.xField;

      // Covert the point's x value to the nearest x value
      // from the horizontal axis.  Loop over the data provider
      // and find the xField value closest to the target value.
      // TODO: This would be better as a binary search!
      for (var i:int = 0; i < chart.dataProvider.length; i++)
      {
        var item:* = chart.dataProvider.getItemAt(i);
        try
        {
          var nextItem:* = chart.dataProvider.getItemAt(i + 1);
          if (item[xField] <= targetXFieldValue
            && nextItem[xField] > targetXFieldValue)
          {
            // Find out which of the two valus is closer
            var diff1:Number = Math.abs(targetXFieldValue - item[xField]);
            var diff2:Number = Math.abs(targetXFieldValue - nextItem[xField]);

            if (diff1 < diff2) // closer to item
            {
              selectedDataIndex = i;
            }
            else // closer to nextItem
            {
              selectedDataIndex = i + 1;
            }

            break;
          }
        }
        catch (re:RangeError)
        {
          // Reached the last item, which means the value to be used is
          // chart.dataProvider.length - 1
          selectedDataIndex = chart.dataProvider.length - 1;
        }
      }

      // Special case, check for click before the first item
      if (chart.dataProvider.getItemAt(0)[xField] > targetXFieldValue)
      {
        selectedDataIndex = 0;
      }

      // Determine if the selected data index changed or not
      if (selectedDataIndex != oldSelectedDataIndex)
      {
        // Since the value changed, the display list needs updating
        invalidateDisplayList();

        // Send out the event letting the everyone know the value changed.  When
        // the change event is picked up, examine the dataValues property of the
        // selector to get a list of the selected values.
        var changeEvent:Event = new Event(Event.CHANGE, true, false);
        dispatchEvent(changeEvent);
      }

    }

  } // end class
} // end package