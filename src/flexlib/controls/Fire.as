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
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.BlendMode;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.TimerEvent;
  import flash.filters.DisplacementMapFilter;
  import flash.filters.DisplacementMapFilterMode;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.utils.Timer;

  import mx.core.UIComponent;
  import mx.graphics.GradientEntry;
  import mx.graphics.RadialGradient;

  /**
   * <code>Fire</code> produces a simulated fire or smoke-like effect.
   *
   * <p>By adjusting various parameters you can achieve a wide variety of different effects.
   * <code>Fire</code> allows you to generate a multi-colored flame by setting the <code>colors</code>
   * array.
   * </p>
   */
  public class Fire extends UIComponent
  {
    /**
     * @private
     *
     * The Sprite object that gets distorted to produce the "fire" effect. In this
     * Fire class, the input that gets created is a radial gradient.
     *
     * If you are subclassing and want to use something other than the radial
     * gradient for your base, override the <code>createInput</code> method and set <code>input</code>
     * to something else.
     */
    protected var input:Sprite;

    /**
     * @private
     * This array is used to store Point data that we increment each time we
     * generate a new DisplacementMapFilter
     */
    private var a:Array = new Array();

    /**
     * @private
     * The BitmapData that contains the generated perlin noise that we
     * will use for the DisplacementMapFilter.
     */
    private var noiseBitmap:BitmapData;

    /**
     * @private
     * The BitmapData that we use to draw the fire effect.
     */
    private var fire:BitmapData;

    /**
     * @private
     * The output bitmap that is the visual representation of this component.
     */
    private var output:Bitmap;

    [Bindable]
    /**
     * Determines how much "distortion" there is horizontally. Values must be greater than 0.
     *
     * @defult 6
     */
    public var wFactor:Number = 6;

    [Bindable]
    /**
     * Determines how much "distortion" there is vertically. Values must be greater than 0.
     *
     * @defult 5
     */
    public var hFactor:Number = 5;

    [Bindable]
    /**
     * The <code>scaleX</code> factor that is used to generate the DisplacementMapFilter.
     *
     * @defult 50
     */
    public var displacementScaleX:Number = 50;

    [Bindable]
    /**
     * The <code>scaleY</code> factor that is used to generate the DisplacementMapFilter.
     *
     * @default 50
     */
    public var displacementScaleY:Number = 50;

    /**
     * The speed of the flame moving vertically. Use a positive number to have the flame appear to
     * go up. A negatrive number will make it go downward.
     */
    public var ySpeed:Number = 1;

    /**
     * The speed of the flame moving horizontally. Use a positive number to have the flame appear to
     * go left. A negatrive number will make it go right.
     */
    public var xSpeed:Number = 0;


    [Bindable]
    /**
     * @private
     */
    private var _angle:Number = 90;

    /**
     * The angle that is used to generate the radial gradient that is used for the
     */
    public function set angle(value:Number):void
    {
      _angle = value;

      //since the angle has changed we need to recreate the radial gradient
      createInput(input.graphics, width, height);
    }

    /**
     * @private
     */
    public function get angle():Number
    {
      return _angle;
    }

    /**
     * @private
     */
    private var _blendMode:String = BlendMode.SCREEN;

    [Bindable]
    /**
     * The blendMode to use for the Flame object.
     *
     * @default BlendMode.SCREEN
     */
    public function set fireBlendMode(value:String):void
    {
      _blendMode = value;

      if (output)
      {
        output.blendMode = value;
      }
    }

    /**
     * @private
     */
    public function get fireBlendMode():String
    {
      return _blendMode;
    }

    /**
     * @private
     */
    private var _color:uint = 0xFF6600;

    [Bindable]
    /**
     * Fire can be customized to display in any color by setting the <code>color</code> property.
     * You can also use the <code>colors</code> property to set an array of colors. If you set
     * <code>color</code> instead of <code>colors</code> then it is the same as setting <code>colors</code>
     * to an array with only one color.
     */
    public function set color(value:uint):void
    {
      this.colors = [value];
    }

    /**
     * @private
     */
    public function get color():uint
    {
      return _colors[0];
    }

    /**
     * @private
     */
    private var _colors:Array = [_color];

    [Bindable]
    /**
     * An array of colors that will color the Flame. You can specify any number of colors, they will
     * form a gradient from one to the other. The colors are ordered from the inside of the flame toward
     * the outside.
     */
    public function set colors(value:Array):void
    {
      _colors = value;

      if (input)
      {
        createInput(input.graphics, width, height);
      }
    }

    /**
     * @private
     */
    public function get colors():Array
    {
      return _colors;
    }

    /**
     * @private
     * The public property is called detail, but what it's really doing is adjusting the
     * octave parameter that we use to generate the perlin noise.
     */
    private var _octaves:int = 2;

    /**
     * Level of detail for the flame. What this is actually doing is using this number as the
     * <code>octave</code> parameter for the perlinNoise function. Be careful with values over 3
     * or 4, the CPU usage increases as this property increases. And if you go over about 5 it's
     * hard to see much of a visual difference.
     */
    public function set detail(value:int):void
    {
      //If the offset array isn't the right length then we need to change it
      //this is the only reason we can't just use a public property.
      if (a.length < value)
      {
        for (var i:int = 0; i < value - a.length; i++)
        {
          a.push(new Point());
        }
      }
      else if (a.length > value)
      {
        a.splice(value);
      }

      _octaves = value;
    }

    /**
     * @private
     */
    public function get detail():int
    {
      return _octaves;
    }

    private var timer:Timer;

    private var _delay:Number = 0;

    [Bindable]
    /**
     * The delay in ms between visual updates. Setting this to a higher number will slow
     * the visual updating, maybe enhancing performance. Setting this to 0 makes the effect
     * run based on the <code>ENTER_FRAME</code> event. If you set this to anything higher
     * than 0 you will see choppiness in the effect (the higher the number the less smooth).
     */
    public function set delay(value:Number):void
    {
      _delay = value;

      if (_delay > 0)
      {
        if (!timer)
        {
          timer = new Timer(_delay);
          timer.addEventListener(TimerEvent.TIMER, makeNoise, false, 0, true);
        }
        else
        {
          timer.delay = _delay;
        }

        stopBurning();

        timer.start();
      }
      else
      {
        if (timer)
        {
          timer.stop();
        }

        if (initialized)
        {
          this.systemManager.addEventListener(Event.ENTER_FRAME, makeNoise, false, 0, true);
        }
      }
    }

    /**
     * @private
     */
    public function get delay():Number
    {
      return _delay;
    }

    /**
     * @private
     */
    override public function initialize():void
    {
      super.initialize();

      if (a.length < _octaves)
      {
        for (var i:int = 0; i < _octaves - a.length + 1; i++)
        {
          a.push(new Point());
        }
      }

      if (_delay > 0)
      {
        timer = new Timer(1);

        timer.addEventListener(TimerEvent.TIMER, makeNoise, false, 0, true);
      }
      else
      {
        this.systemManager.addEventListener(Event.ENTER_FRAME, makeNoise, false, 0, true);
      }
    }

    override protected function createChildren():void
    {
      super.createChildren();

      noiseBitmap = new BitmapData(1, 1, true, 0x000000);
      fire = new BitmapData(1, 1, true, 0x000000);

      input = new Sprite();

      output = new Bitmap();
      output.blendMode = _blendMode;
      output.smoothing = true;

      addChild(output);
    }

    /**
     * Stops the animated flame burning. The component will remain with the last flame image
     * that was generated.
     */
    public function stopBurning():void
    {
      if (timer && timer.running)
      {
        timer.stop();
      }
      else
      {
        if (this.systemManager)
          this.systemManager.removeEventListener(Event.ENTER_FRAME, makeNoise);
      }
    }

    /**
     * Re-starts the animated flame animation, if it has been previously stopped by using the
     * <code>stopBurning</code> funtion.
     */
    public function startBurning():void
    {
      if (_delay > 0)
      {
        timer.start();
      }
      else
      {
        this.systemManager.addEventListener(Event.ENTER_FRAME, makeNoise, false, 0, true);
      }
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {

      super.updateDisplayList(unscaledWidth, unscaledHeight);

      if (unscaledWidth > 0 && unscaledHeight > 0)
      {
        // we need to create a new bitmap that we use for the DisplacemnetMapFilter in
        // the makeNoise()
        createInput(input.graphics, unscaledWidth, unscaledHeight);

        // since we're creating new BitmapData objects for these, we need to call
        // dispose() on the old ones or else they won't go away in memory
        if (noiseBitmap)
        {
          noiseBitmap.dispose();
        }

        if (fire)
        {
          fire.dispose();
        }

        noiseBitmap = new BitmapData(unscaledWidth, unscaledHeight, true, 0x000000);
        fire = new BitmapData(unscaledWidth, unscaledHeight, true, 0x000000);
      }
    }

    /**
     * Creates the base bitmap that we're going to be applying the DisplacementMapFilter to.
     * Override this to create different types of Fire (or water) effects.
     */
    protected function createInput(g:Graphics, w:Number, h:Number):void
    {

      g.clear();

      var fill:RadialGradient = new RadialGradient();

      var entries:Array = new Array();
      for (var i:int = 0; i < _colors.length; i++)
      {
        entries.push(new GradientEntry(_colors[i]));
      }
      entries.push(new GradientEntry(0x000000, .6));

      fill.entries = entries;

      fill.angle = _angle;
      fill.focalPointRatio = .6;

      FLEX_TARGET_VERSION::flex4
      {
        fill.begin(g, new Rectangle(0, 0, w, h), new Point(0, 0));
      }
      FLEX_TARGET_VERSION::flex3
      {
        fill.begin(g, new Rectangle(0, 0, w, h));
      }

      g.drawRect(0, 0, w, h);
      fill.end(g);
    }

    /**
     * Rawr! OK, not that type of noise.
     * This does all the heavy lifting to create the fire effect. If you wanted to extend this
     * component and use your own algorithm for distortion, you can override this method. This method
     * should set the <code>bitmapData</code> of the <code>output</code> variable.
     */
    protected function makeNoise(event:Event):void
    {

      // We add xSpeed and ySpeed to the points in the a Array.
      // This array gets passed to the DisplacementMapFilter below.
      for (var i:int = 0; i < _octaves; i++)
      {
        var pt:Point = a[i] as Point;
        pt.x += xSpeed;
        pt.y += ySpeed;
      }

      /* Here's where the magic happens.
       * We use the perlinNoise function of BitmapData to generate a funky
       * looking perlin noise pattern. Then we use that pattern as the map bitmap
       * for the DisplacementMapFilter.
       *
       * Both functions below, perlinNoise and DisplacementMapFilter, take a bunch
       * of arguments. By playing with these we can get a variety of cool effects.
       * I do not have a good understanding of what the hell I'm doing, I just try
       * some settings and see how it looks. There's no method to my madness.
       *
       * This technique has been discussed by others in the Flash community. I cetainly
       * didn't invent it, and in fact I have very little understanding of how to really control
       * these two functions. They're beasts.
       */
      noiseBitmap.perlinNoise(input.width / wFactor, input.height / hFactor, _octaves, Math.random(),
                              true, false, 7, true, a);

      var d:DisplacementMapFilter = new DisplacementMapFilter(noiseBitmap, new Point(0, 0), 1, 2, displacementScaleX,
                                                              displacementScaleY, DisplacementMapFilterMode.
                                                              IGNORE);

      /* OK, so we've got our DisplacementMapFilter created, now we just draw the input
       * BitmapData and apply the DisplacementMapFilter.
       */
      fire.draw(input);
      fire.applyFilter(fire, fire.rect, new Point(0, 0), d);

      //Now just drop the resulting bitmapData intop our output Bitmap and we're all done! 
      output.bitmapData = fire;
    }
  }
}