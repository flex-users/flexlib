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
package flexlib.scheduling.scheduleClasses.lineRenderer
{
  import flash.display.Graphics;
  FLEX_TARGET_VERSION::flex4
  {
    import flash.display.GraphicsStroke;
	import flash.geom.Point;
  }
  import flash.display.LineScaleMode;
  import flash.geom.Rectangle;

  import flexlib.scheduling.scheduleClasses.utils.GraphicUtils;
  import flash.display.JointStyle;


  /**
   * @private
   */
  public class DottedHorizontalLineRenderer extends Line implements ILineRenderer
  {
    public function moveTo(g:Graphics, x:Number, y:Number):void
    {
      g.moveTo(x, y);
    }

    public function drawTo(g:Graphics, x:Number, y:Number):void
    {
      GraphicUtils.drawDottedHorizontalLineTo(g, y, 0, x);
    }

    public function get scaleMode():String
    {
      return LineScaleMode.NORMAL;
    }

    FLEX_TARGET_VERSION::flex4
    {
      public function createGraphicsStroke(rect:Rectangle, targetOrigin:Point):GraphicsStroke
      {
        return new GraphicsStroke();
      }
	  
	  public function get miterLimit():Number
	  {
		  return 3;
	  }
	  
	  public function get joints():String
	  {
		  return JointStyle.ROUND;
	  }
    }

  }
}