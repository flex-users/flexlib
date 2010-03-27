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
  import flash.display.DisplayObject;
  import flash.events.Event;
  import flash.geom.Point;
  import flash.geom.Rectangle;

  import flexlib.scheduling.scheduleClasses.layout.HorizontalLinesLayout;
  import flexlib.scheduling.scheduleClasses.layout.HorizontalLinesLayoutItem;
  import flexlib.scheduling.scheduleClasses.layout.IHorizontalLinesLayout;
  import flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent;
  import flexlib.scheduling.scheduleClasses.lineRenderer.DottedHorizontalLineRenderer;
  import flexlib.scheduling.scheduleClasses.lineRenderer.ILineRenderer;
  import flexlib.scheduling.scheduleClasses.lineRenderer.LineRenderer;

  import mx.core.UIComponent;

  /**
   * @private
   */
  public class HorizontalLinesViewer extends UIComponent implements IHorizontalLinesViewer
  {
    protected var layout:IHorizontalLinesLayout;

    private var _dottedGridLines:Boolean;
    private var _horizontalGridLineThickness:Number;
    private var _horizontalGridLineColor:uint;
    private var _horizontalGridLineAlpha:Number;

    public function get dottedGridLines():Boolean
    {
      return _dottedGridLines;
    }

    public function set dottedGridLines(value:Boolean):void
    {
      _dottedGridLines = value;
    }

    public function get horizontalGridLineThickness():Number
    {
      return _horizontalGridLineThickness;
    }

    public function set horizontalGridLineThickness(value:Number):void
    {
      _horizontalGridLineThickness = value;
    }

    public function get horizontalGridLineColor():uint
    {
      return _horizontalGridLineColor;
    }

    public function set horizontalGridLineColor(value:uint):void
    {
      _horizontalGridLineColor = value;
    }

    public function get horizontalGridLineAlpha():Number
    {
      return _horizontalGridLineAlpha;
    }

    public function set horizontalGridLineAlpha(value:Number):void
    {
      _horizontalGridLineAlpha = value;
    }

    //---------------------------------------------		

    public function update(event:LayoutUpdateEvent):void
    {
      layout = IHorizontalLinesLayout(event.layout);
      invalidateDisplayList();
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      if (layout == null)
        return;
      graphics.clear();
      render(layout);
    }

    protected function render(layout:IHorizontalLinesLayout):void
    {
      var lineRenderer:ILineRenderer = getLineRendererForStyling();

      for each (var item:HorizontalLinesLayoutItem in layout.items)
      {
        drawLineForItem(item, lineRenderer);
      }
    }

    protected function getLineRendererForStyling():ILineRenderer
    {
      var lineRenderer:ILineRenderer;
      if (dottedGridLines)
      {
        lineRenderer = new DottedHorizontalLineRenderer();
      }
      else
      {
        lineRenderer = new LineRenderer();
      }
      lineRenderer.weight = horizontalGridLineThickness;
      lineRenderer.color = horizontalGridLineColor;
      lineRenderer.alpha = horizontalGridLineAlpha;
      return lineRenderer;
    }

    protected function drawLineForItem(item:HorizontalLinesLayoutItem, lineRenderer:ILineRenderer):void
    {
      var y:Number = item.y - layout.yPosition;
      lineRenderer.moveTo(graphics, 0, y);
      FLEX_TARGET_VERSION::flex4
      {
        lineRenderer.apply(graphics, new Rectangle(0, 0, width, height), new Point(0, 0));
      }
      FLEX_TARGET_VERSION::flex3
      {
        lineRenderer.apply(graphics);
      }
      lineRenderer.drawTo(graphics, item.width, y);
    }
  }
}