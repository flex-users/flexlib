package flexlib.scheduling.scheduleClasses.lineRenderer
{
  import flash.display.Graphics;
  import flash.geom.Point;
  import flash.geom.Rectangle;

  public class Line
  {
    private var _weight:Number;
    private var _color:uint;
    private var _alpha:Number;

    public function get weight():Number
    {
      return _weight;
    }

    public function set weight(value:Number):void
    {
      _weight = value;
    }

    public function get color():uint
    {
      return _color;
    }

    public function set color(value:uint):void
    {
      _color = value;
    }

    public function get alpha():Number
    {
      return _alpha;
    }

    public function set alpha(value:Number):void
    {
      _alpha = value;
    }

    FLEX_TARGET_VERSION::flex4
    {
      public function apply(g:Graphics, bounds:Rectangle, targetPoint:Point):void
      {
        g.lineStyle(weight, color, alpha);
      }
    }

    FLEX_TARGET_VERSION::flex3
    {
      public function apply(g:Graphics):void
      {
        g.lineStyle(weight, color, alpha);
      }
    }
  }
}