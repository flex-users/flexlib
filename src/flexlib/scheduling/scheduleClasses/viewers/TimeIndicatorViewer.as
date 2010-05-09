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
package flexlib.scheduling.scheduleClasses.viewers
{
  import flash.geom.Point;
  import flash.geom.Rectangle;

  import flexlib.scheduling.scheduleClasses.layout.ITimeIndicatorLayout;
  import flexlib.scheduling.scheduleClasses.layout.IVerticalLinesLayout;
  import flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent;
  import flexlib.scheduling.scheduleClasses.layout.TimeIndicatorLayoutItem;
  import flexlib.scheduling.scheduleClasses.layout.VerticalLinesLayoutItem;
  import flexlib.scheduling.scheduleClasses.lineRenderer.DottedVerticalLineRenderer;
  import flexlib.scheduling.scheduleClasses.lineRenderer.ILineRenderer;
  import flexlib.scheduling.scheduleClasses.lineRenderer.LineRenderer;

  import mx.core.UIComponent;

  /**
   * @private
   */
  public class TimeIndicatorViewer extends UIComponent implements ITimeIndicatorViewer
  {
    private var layout:ITimeIndicatorLayout;

    //---------------------------------------------		

    public function update(event:LayoutUpdateEvent):void
    {
      layout = ITimeIndicatorLayout(event.layout);
      invalidateDisplayList();
    }

    protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      if (layout == null)
        return;
      graphics.clear();
      render(layout);
    }

    protected function render(layout:ITimeIndicatorLayout):void
    {
      for each (var timeIndicatorLayoutItem:TimeIndicatorLayoutItem in layout.timeIndicatorLayoutItems)
      {
        var lineRenderer:ILineRenderer = getTimeIndicatorRenderer(timeIndicatorLayoutItem);
        drawLineForItem(timeIndicatorLayoutItem, lineRenderer);
      }
    }

    protected function getTimeIndicatorRenderer(timeIndicatorLayoutItem:TimeIndicatorLayoutItem):ILineRenderer
    {
      var lineRenderer:ILineRenderer = new LineRenderer();
      lineRenderer.weight = timeIndicatorLayoutItem.thickness;
      lineRenderer.color = timeIndicatorLayoutItem.color;
      lineRenderer.alpha = timeIndicatorLayoutItem.alpha;
      return lineRenderer;
    }

    protected function drawLineForItem(timeIndicatorLayoutItem:TimeIndicatorLayoutItem, lineRenderer:ILineRenderer):void
    {
      var x:Number = timeIndicatorLayoutItem.x - layout.xPosition;
      lineRenderer.moveTo(graphics, x, 0);

      FLEX_TARGET_VERSION::flex4
      {
        lineRenderer.apply(graphics, new Rectangle(0, 0, width, height), new Point(0, 0));
      }
      FLEX_TARGET_VERSION::flex3
      {
        lineRenderer.apply(graphics);
      }
      lineRenderer.drawTo(graphics, x, timeIndicatorLayoutItem.height);

    }
  }
}