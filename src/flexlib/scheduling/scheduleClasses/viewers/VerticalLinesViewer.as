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

  import flexlib.scheduling.scheduleClasses.layout.IVerticalLinesLayout;
  import flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent;
  import flexlib.scheduling.scheduleClasses.layout.VerticalLinesLayoutItem;
  import flexlib.scheduling.scheduleClasses.lineRenderer.DottedVerticalLineRenderer;
  import flexlib.scheduling.scheduleClasses.lineRenderer.ILineRenderer;
  import flexlib.scheduling.scheduleClasses.lineRenderer.LineRenderer;

  import mx.core.UIComponent;

  /**
   * @private
   */
  public class VerticalLinesViewer extends UIComponent implements IVerticalLinesViewer
  {
    private var layout:IVerticalLinesLayout;

    private var _dottedGridLines:Boolean;
    private var _verticalGridLineThickness:Number;
    private var _verticalGridLineColor:uint;
    private var _verticalGridLineAlpha:Number;

    public function get dottedGridLines():Boolean
    {
      return _dottedGridLines;
    }

    public function set dottedGridLines(value:Boolean):void
    {
      _dottedGridLines = value;
    }

    public function get verticalGridLineThickness():Number
    {
      return _verticalGridLineThickness;
    }

    public function set verticalGridLineThickness(value:Number):void
    {
      _verticalGridLineThickness = value;
    }

    public function get verticalGridLineColor():uint
    {
      return _verticalGridLineColor;
    }

    public function set verticalGridLineColor(value:uint):void
    {
      _verticalGridLineColor = value;
    }

    public function get verticalGridLineAlpha():Number
    {
      return _verticalGridLineAlpha;
    }

    public function set verticalGridLineAlpha(value:Number):void
    {
      _verticalGridLineAlpha = value;
    }

    //---------------------------------------------		

    public function update(event:LayoutUpdateEvent):void
    {
      layout = IVerticalLinesLayout(event.layout);
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

    protected function render(layout:IVerticalLinesLayout):void
    {
      var lineRenderer:ILineRenderer = getLineRendererForStyling();

      for each (var item:VerticalLinesLayoutItem in layout.items)
      {
        drawLineForItem(item, lineRenderer);
      }
    }

    protected function getLineRendererForStyling():ILineRenderer
    {
      var lineRenderer:ILineRenderer;
      if (dottedGridLines)
      {
        lineRenderer = new DottedVerticalLineRenderer();
      }
      else
      {
        lineRenderer = new LineRenderer();
      }
      lineRenderer.weight = verticalGridLineThickness;
      lineRenderer.color = verticalGridLineColor;
      lineRenderer.alpha = verticalGridLineAlpha;
      return lineRenderer;
    }

    protected function drawLineForItem(item:VerticalLinesLayoutItem, lineRenderer:ILineRenderer):void
    {
      var x:Number = item.x - layout.xPosition;
      lineRenderer.moveTo(graphics, x, 0);
      FLEX_TARGET_VERSION::flex4
      {
        lineRenderer.apply(graphics, new Rectangle(0, 0, width, height), new Point(0, 0));
      }
      FLEX_TARGET_VERSION::flex3
      {
        lineRenderer.apply(graphics);
      }
      lineRenderer.drawTo(graphics, x, item.height);
    }
  }
}