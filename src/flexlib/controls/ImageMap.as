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
  import flash.display.Graphics;
  import flash.display.SpreadMethod;
  import flash.display.Sprite;
  import flash.events.MouseEvent;

  import flexlib.events.ImageMapEvent;

  import mx.collections.ArrayCollection;
  import mx.controls.Image;
  import mx.core.UIComponent;
  import mx.core.mx_internal;
  import mx.styles.CSSStyleDeclaration;
  import mx.styles.StyleManager;

  use namespace mx_internal;

  /**
   *  Thickness of the outline of each area.
   *
   *  @default 1
   */
  [Style(name="outlineThickness", type="Number", format="Length", inherit="no")]

  /**
   *  Color of the outline of each area.
   *
   *  @default 0xff0000
   */
  [Style(name="outlineColor", type="uint", format="Color", inherit="no")]

  /**
   *  Alpha transparency of the outline of each area. Default is 0 so the outlines are invisible.
   *
   *  @default 0
   */
  [Style(name="outlineAlpha", type="Number", format="Length", inherit="no")]

  /**
   *  Fill color of each area.
   *
   *  @default 0xff0000
   */
  [Style(name="fillColor", type="uint", format="Color", inherit="no")]

  /**
   *  Alpha transparency of the fill of each area. Default is 0 so the areas are invisible.
   *
   *  @default 0
   */
  [Style(name="fillAlpha", type="Number", format="Length", inherit="no")]

  /**
   * Fired when an area is clicked.
   *
   * @eventType flexlib.events.ImageMapEvent.SHAPE_CLICK
   */
  [Event(name="shapeClick", type="flexlib.events.ImageMapEvent")]

  /**
   * Fired when an area is double clicked.
   *
   * @eventType flexlib.events.ImageMapEvent.SHAPE_DOUBLECLICK
   */
  [Event(name="shapeDoubleClick", type="flexlib.events.ImageMapEvent")]

  /**
   * Fired when the mouse moves over an area.
   *
   * @eventType flexlib.events.ImageMapEvent.SHAPE_OVER
   */
  [Event(name="shapeOver", type="flexlib.events.ImageMapEvent")]

  /**
   * Fired when the mouse moves out of an area.
   *
   * @eventType flexlib.events.ImageMapEvent.SHAPE_OUT
   */
  [Event(name="shapeOut", type="flexlib.events.ImageMapEvent")]

  /**
   * Fired when the mouse is pressed down on an area.
   *
   * @eventType flexlib.events.ImageMapEvent.SHAPE_DOWN
   */
  [Event(name="shapeDown", type="flexlib.events.ImageMapEvent")]

  /**
   * Fired when the mouse is released on an area.
   *
   * @eventType flexlib.events.ImageMapEvent.SHAPE_UP
   */
  [Event(name="shapeUp", type="flexlib.events.ImageMapEvent")]

  [IconFile("ImageMap.png")]

  /**
   * The <code>ImageMap</code> control is an implementation of a client-side image map component, like it is supported in HTML.
   * <p><code>ImageMap</code> is an extension of the Image class, so you can specify the <code>source</code> attribute
   * just like you would for a standard <code>Image</code> component. The <code>map</code> property is used to define the actual
   * image map and all the <code>area</code> items that make up the map. The <code>map</code> property can be defined
   * either in MXML or by setting it with Actionscript.
   * </p>
   *
   * <p>The intent is for you to be able to generate your image map in whatever program you use to create image maps,
   * and be able to cut and paste it into your MXML component with minimal changes.
   * </p>
   *
   * <p>Example MXML usage:</p>
   *
   * <pre>
   * &lt;ImageMap xmlns="flexlib.controls.*"
   * 		source="usa.jpg"
   * 		showToolTips="true"
   * 		shapeClick="navigateToURL(new URLRequest(event.href), event.linkTarget)"
   * 		&gt;
   *
   * 		&lt;map&gt;
   * 			&lt;area alt="WA" shape="POLY" coords="85,11,133,11,134,42,114,42,100,47,96,45,91,48,83,40,76,40,75,29,70,23,71,18,82,20,87,18" href="http://en.wikipedia.org/wiki/Washington" target="_blank"/&gt;
   * 			&lt;area alt="OR" shape="POLY" coords="76,40,83,40,90,48,96,45,101,47,115,43,134,43,138,46,133,57,134,84,72,84,71,71,76,56" href="http://en.wikipedia.org/wiki/Oregon" target="_blank"/&gt;
   * 		&lt;/map&gt;
   *
   * &lt;/ImageMap&gt;
   * </pre>
   *
   * @see http://www.w3.org/TR/html4/struct/objects.html#client-side-maps
   */
  public class ImageMap extends Image
  {
    /**
     * @private
     * The array of area object that specifies all the areas we are going to draw.
     */
    private var _map:Array;

    /**
     * @private
     * The UIComponent that holds all the shapes we'll be drawing.
     */
    private var areaHolder:UIComponent;

    /**
     * Indicates whether tool tips should be shown for each area.
     *
     * @default false
     */
    public var showToolTips:Boolean = false;

    /**
     * Field of the <code>&lt;area /&gt;</code> item that will be used for the tooltip.
     * @default "alt"
     */
    public var toolTipField:String = "alt";

    /**
     * @private
     *
     * We initialize the default styles for outline and fill styles by calling
     * initStyles() when the component is instantiated.
     */
    private static var stylesInitialised:Boolean = initStyles();

    /**
     * @private
     *
     * The default styes are defined here.
     */
    private static function initStyles():Boolean
    {
      var sd:CSSStyleDeclaration =
        StyleManager.getStyleDeclaration("ImageMap");

      if (!sd)
      {
        sd = new CSSStyleDeclaration();
        StyleManager.setStyleDeclaration("ImageMap", sd, false);
      }

      sd.defaultFactory = function():void
      {
        this.outlineColor = 0xff0000;
        this.outlineAlpha = 1;
        this.outlineThickness = 1;
        this.fillColor = 0xff0000;
        this.fillAlpha = 0;
      }
      return true;
    }

    public function ImageMap()
    {
      super();
    }

    override protected function createChildren():void
    {
      super.createChildren();

      areaHolder = new UIComponent();

      this.addChild(areaHolder);
    }

    /**
     * The <code>&lt;map /&gt;</code> HTML block that is normally used for the image map in an HTML file.
     * This should be wrapped as an XMLList and can either be cuopy/pasted straight into the MXML
     * file, or set via Actionscript.
     */
    public function set map(value:Array):void
    {
      _map = value;

      invalidateDisplayList();
    }

    /**
     * @private
     */
    public function get map():Array
    {
      return _map;
    }

    /**
     * @private
     *
     * Draws each of the areas as a UIComponent. UIComponent is used (as opposed to Sprite) so we
     * can get the useHandCursor and toolTip functionality. Each shape is drawn and
     * added to the areaHolder component.
     */
    private function drawShapes():void
    {
      removeChildren();

      FLEX_TARGET_VERSION::flex4
      {
        //TODO: this shouldn't be hardcoded...
        // for some reason, flex4 won't pickup the outlineThickness style,
        // fixing with a hardcoded thickness of 1 for now.
        var outlineThickness:Number = 1;
      }
      FLEX_TARGET_VERSION::flex3
      {
        var outlineThickness:Number = getStyle("outlineThickness");
      }

      var outlineColor:uint = getStyle("outlineColor");
      var outlineAlpha:Number = getStyle("outlineAlpha");
      var fillColor:uint = getStyle("fillColor");
      var fillAlpha:Number = getStyle("fillAlpha");


      for each (var item:area in _map)
      {
        var shape:String = item.shape;
        //we split up the coordinates into an Array. The coords are in the format 23,56,34,57,89,...
        var coords:Array = item.coords.split(",");

        var sprite:UIComponent = new UIComponent();

        sprite.addEventListener(MouseEvent.CLICK, sprite_clickHandler, false, 0, true);
        sprite.addEventListener(MouseEvent.DOUBLE_CLICK, sprite_dblclickHandler, false, 0, true);
        sprite.addEventListener(MouseEvent.MOUSE_DOWN, sprite_downHandler, false, 0, true);
        sprite.addEventListener(MouseEvent.MOUSE_OUT, sprite_outHandler, false, 0, true);
        sprite.addEventListener(MouseEvent.MOUSE_OVER, sprite_overHandler, false, 0, true);
        sprite.addEventListener(MouseEvent.MOUSE_UP, sprite_upHandler, false, 0, true);

        sprite.useHandCursor = this.useHandCursor;
        sprite.buttonMode = true;

        if (showToolTips)
        {
          sprite.toolTip = item[toolTipField];
        }


        var g:Graphics = sprite.graphics;
        g.lineStyle(outlineThickness, outlineColor, outlineAlpha);
        g.beginFill(fillColor, fillAlpha);

        switch (shape.toLowerCase())
        {
          case "rect":
            g.drawRect(coords[0], coords[1], coords[2] - coords[0], coords[3] - coords[1]);
            break;
          case "poly":
            drawPoly(g, coords);
            break;
          case "circle":
            g.drawCircle(coords[0], coords[1], coords[2]);
            break;
        }

        g.endFill();

        areaHolder.addChild(sprite);
      }
    }

    /*
     * After we finish drawing we make sure that the areaHolder is on top of our loaded image.
     * If we don't have the call to setChildIndex then the shapes will all be under the image.
     *
     * We set the x and y scale of the areaHolder to match the content, since we might be
     * scaling the content to fit the size of this Image component. We also implement the clipping
     * of the shapes by using the content's scrollRect boundaries.
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
      super.updateDisplayList(unscaledWidth, unscaledHeight);

      if (contentHolder)
      {
        areaHolder.scaleX = contentHolder.scaleX;
        areaHolder.scaleY = contentHolder.scaleY;
        areaHolder.scrollRect = contentHolder.scrollRect;
      }

      drawShapes();

      //without this the shapes would get stuck underneath the main loaded content
      setChildIndex(areaHolder, numChildren - 1);
    }

    /**
     * @private
     * Simple utility function to draw a polygon from an array of points.
     */
    private function drawPoly(g:Graphics, coords:Array):void
    {
      g.moveTo(coords[0], coords[1]);

      //since we moved to the first point, we loop over all points starting on the second point	
      for (var i:int = 2; i < coords.length; i += 2)
      {
        g.lineTo(coords[i], coords[i + 1]);
      }

      //got to remember to reconnect from the last point to the first point
      g.lineTo(coords[0], coords[1]);
    }

    /**
     * @private
     * I don't know why UIComponent doesn't have a removeAllChildren() method, but this
     * method just does that, removes all children of the areaHolder.
     */
    private function removeChildren():void
    {
      while (areaHolder.numChildren > 0)
      {
        areaHolder.removeChildAt(0);
      }
    }

    /**
     * @private
     * We're basically re-creating the functionality of all the mouse events. But we need
     * to dispatch our custom ImageMapEvent so we can pass back the link information as well
     * as the basic mouse event info. So I've recreated the click, double-click, down, up, over,
     * and out mouse events.
     */
    private function sprite_clickHandler(event:MouseEvent):void
    {
      var sprite:UIComponent = event.currentTarget as UIComponent;
      doDispatchEvent(sprite, ImageMapEvent.SHAPE_CLICK);
    }

    /**
     * @private
     */
    private function sprite_dblclickHandler(event:MouseEvent):void
    {
      var sprite:UIComponent = event.currentTarget as UIComponent;
      doDispatchEvent(sprite, ImageMapEvent.SHAPE_DOUBLECLICK);
    }

    /**
     * @private
     */
    private function sprite_downHandler(event:MouseEvent):void
    {
      var sprite:UIComponent = event.currentTarget as UIComponent;
      doDispatchEvent(sprite, ImageMapEvent.SHAPE_DOWN);
    }

    /**
     * @private
     */
    private function sprite_upHandler(event:MouseEvent):void
    {
      var sprite:UIComponent = event.currentTarget as UIComponent;
      doDispatchEvent(sprite, ImageMapEvent.SHAPE_UP);
    }

    /**
     * @private
     */
    private function sprite_overHandler(event:MouseEvent):void
    {
      var sprite:UIComponent = event.currentTarget as UIComponent;
      doDispatchEvent(sprite, ImageMapEvent.SHAPE_OVER);
    }

    /**
     * @private
     */
    private function sprite_outHandler(event:MouseEvent):void
    {
      var sprite:UIComponent = event.currentTarget as UIComponent;
      doDispatchEvent(sprite, ImageMapEvent.SHAPE_OUT);
    }

    /**
     * @private
     *
     * This lets us dispatch one of these ImageMapEvents. Basically we need to figure
     * out which shape was clicked, and when we dispatch the event we reference the href link
     * for that shape, and we also pass back the entire XML item for that shape. This is because
     * someone might want to use this component for something other than the standard image map linking
     * scenario. Passing back the XML item should give maximum flexibility.
     */
    private function doDispatchEvent(sprite:UIComponent, type:String):void
    {
      if (sprite.parent != areaHolder)
        return;

      var index:int = areaHolder.getChildIndex(sprite);
      var item:area = _map[index];

      var target:String = "";
      if (item.target)
      {
        target = item.target;
      }

      var href:String = "";
      if (item.href)
      {
        href = item.href;
      }
      dispatchEvent(new ImageMapEvent(type, false, false, href, item, target));
    }
  }
}
