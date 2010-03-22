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

 */
package flexlib.scheduling.scheduleClasses.renderers
{
  import flash.display.GradientType;
  import flash.geom.Matrix;

  import flexlib.scheduling.scheduleClasses.IScheduleEntry;
  import flexlib.scheduling.scheduleClasses.SimpleScheduleEntry;

  import mx.containers.Box;
  import mx.controls.Label;
  import mx.controls.Text;
  import mx.core.ScrollPolicy;
  import mx.core.mx_internal;
  import mx.formatters.DateFormatter;
  import mx.styles.CSSStyleDeclaration;
  import mx.styles.StyleManager;
  import mx.utils.ColorUtil;

  public class AbstractGradientScheduleEntryRenderer extends Box implements IScheduleEntryRenderer
  {

    public var contentLabel:Label;
    public var contentText:Text;

    private var defaultLabel:String = "";
    private var formatter:DateFormatter;
    private var formatString:String = "L:NNAA";
    private var origFillColors:Array;
    private var changeSelection:Boolean;
    private var _entry:IScheduleEntry;
    private var _selected:Boolean = false;

    private var gradientChanged:Boolean = true;


    public function get entry():IScheduleEntry
    {
      return _entry;
    }

    public function set entry(value:IScheduleEntry):void
    {
      _entry = value;
    }

    public function get selected():Boolean
    {
      return _selected;
    }

    public function set selected(value:Boolean):void
    {
      _selected = value;
      updateSelected();
    }



    public function AbstractGradientScheduleEntryRenderer()
    {
      super();
      formatter = new DateFormatter();
      formatter.formatString = formatString;


      horizontalScrollPolicy = ScrollPolicy.OFF;
      verticalScrollPolicy = ScrollPolicy.OFF;

      //	our style settings
      //	initialize component styles
      if (!this.styleDeclaration)
      {
        this.styleDeclaration = new CSSStyleDeclaration();
      }

      this.styleDeclaration.defaultFactory = function():void
      {
        this.borderStyle = "applicationControlBar";
      };

      mx_internal::initStyles();
      //	properties
      this.styleName = "defaultEntryStyle";
      this.verticalScrollPolicy = "off";
      this.horizontalScrollPolicy = "off";

    }

    mx_internal var stylesInitialized:Boolean = false;

    mx_internal function initStyles():void
    {
      //	only add our style defs to the StyleManager once
      if (mx_internal::stylesInitialized)
      {
        return;
      }
      else
      {
        mx_internal::stylesInitialized = true;
      }

      var style:CSSStyleDeclaration;
      var effects:Array;

      // defaultTimeStyle
      style = StyleManager.getStyleDeclaration(".defaultTimeStyle");
      if (!style)
      {
        style = new CSSStyleDeclaration();
        StyleManager.setStyleDeclaration(".defaultTimeStyle", style, false);
      }
      if (style.factory == null)
      {
        style.factory = function():void
        {
          this.fontWeight = "bold";
          this.color = 0x000000;
          this.fontSize = 9;
        };
      }
      // defaultEntryStyle
      style = StyleManager.getStyleDeclaration(".defaultEntryStyle");
      if (!style)
      {
        style = new CSSStyleDeclaration();
        StyleManager.setStyleDeclaration(".defaultEntryStyle", style, false);
      }
      if (style.factory == null)
      {
        style.factory = function():void
        {
          this.borderStyle = "default";
          this.timeStyleName = "defaultTimeStyle";
          this.paddingTop = 5;
          this.shadowDistance = 2;
          this.cornerRadius = 6;
          this.fontSize = 11;
          this.verticalGap = -2;
          this.fillAlphas = [1, 1];
          this.paddingLeft = 5;
          this.paddingRight = 5;
          this.fontWeight = "normal";
          this.dropShadowEnabled = true;
          this.color = 0xffffff;
          this.borderThickness = 1;
          this.highlightAlphas = [0.08, 0];
          this.fillColors = [0x7aa4bc, 0x53839f];
          this.paddingBottom = 5;
        };
      }
    }

    override protected function createChildren():void
    {
      super.createChildren();
      contentLabel = new Label();
      addChild(contentLabel);

      contentText = new Text();
      addChild(contentText);
    }

    /**
     * @private
     */
    override public function styleChanged(styleProp:String):void
    {
      super.styleChanged(styleProp);
      if (styleProp != null)
      {

        if (styleProp == "fillColors" && !changeSelection)
        {
          origFillColors = getStyle(styleProp);
        }
        else if (changeSelection)
        {
          changeSelection = false;
        }

        if (styleProp == "fillColors")
        {
          gradientChanged = true;
          invalidateDisplayList();
        }
      }
    }

    private function updateSelected():void
    {
      var newColor1:uint;
      var newColor2:uint;
      if (origFillColors == null)
      {
        origFillColors = getStyle("fillColors");
      }

      if (_selected)
      {
        setStyle("dropShadowEnabled", true);
        changeSelection = true;
        newColor1 = ColorUtil.adjustBrightness2(origFillColors[0], 25);
        newColor2 = ColorUtil.adjustBrightness2(origFillColors[1], 25);
        setStyle("fillColors", [newColor1, newColor2]);
      }
      else
      {
        setStyle("dropShadowEnabled", false);
        changeSelection = true;
        newColor1 = ColorUtil.adjustBrightness2(origFillColors[0], 0);
        newColor2 = ColorUtil.adjustBrightness2(origFillColors[1], 0);
        setStyle("fillColors", [newColor1, newColor2]);
      }
    }

    protected function setTextContent(content:SimpleScheduleEntry):void
    {
      if (content.label == null)
      {
        content.label = defaultLabel;
      }

      formatter.error = "";
      var time:String = formatter.format(content.startDate)
        + " - " + formatter.format(content.endDate);

      toolTip = time + "\n" + content.label;
      contentLabel.text = time;
      contentLabel.styleName = getStyle("timeStyleName");
      contentText.text = content.label;

      updateSelected();
    }

    FLEX_TARGET_VERSION::flex4
    {
      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
      {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if (gradientChanged)
        {
          var fillColors:Array = getStyle("fillColors");
          var cornerRadius:int = getStyle("cornerRadius");
          var matrix:Matrix = new Matrix();
          matrix.createGradientBox(unscaledWidth, unscaledHeight, 90);
          graphics.beginGradientFill(GradientType.LINEAR, fillColors, [1, 1], [0, 255], matrix);
          graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius + 4);

          gradientChanged = false;;
        }
      }
    }
  }
}