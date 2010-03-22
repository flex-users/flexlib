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
  import flexlib.scheduling.scheduleClasses.IScheduleEntry;
  import flexlib.scheduling.scheduleClasses.SimpleScheduleEntry;

  import mx.containers.Box;
  import mx.controls.Alert;
  import mx.controls.Label;
  import mx.controls.Text;
  import mx.core.ScrollPolicy;
  import mx.formatters.DateFormatter;
  import mx.styles.CSSStyleDeclaration;
  import mx.styles.StyleManager;

  import mx.core.mx_internal;

  public class AbstractSolidScheduleEntryRenderer extends Box implements IScheduleEntryRenderer
  {
    public var contentLabel:Label;
    public var contentText:Text;

    private var defaultLabel:String = "";
    private var formatter:DateFormatter;
    private var formatString:String = "L:NNAA";
    private var _entry:IScheduleEntry;
    private var _selected:Boolean = false;

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

    public function AbstractSolidScheduleEntryRenderer()
    {
      super();

      formatter = new DateFormatter();
      formatter.formatString = formatString;

      //	our style settings
      //	initialize component styles
      if (!this.styleDeclaration)
      {
        this.styleDeclaration = new CSSStyleDeclaration();
      }
      this.styleDeclaration.defaultFactory = function():void
      {
        this.borderStyle = "solid";
      };

      mx_internal::initStyles();

      //	properties
      this.verticalScrollPolicy = "off";
      this.horizontalScrollPolicy = "off";
      this.styleName = "defaultEntryStyle";
    }

    mx_internal static var stylesInitialized:Boolean = false;

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
          this.fontWeight = "normal";
          this.timeStyleName = "defaultTimeStyle";
          this.paddingTop = 5;
          this.color = 0x000000;
          this.backgroundColor = 0xcccccc;
          this.fontSize = 11;
          this.verticalGap = -2;
          this.paddingBottom = 5;
          this.paddingLeft = 5;
          this.paddingRight = 5;
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

    private function updateSelected():void
    {
      if (_selected)
      {
        setStyle("dropShadowEnabled", true);
        setStyle("borderColor", 0xffffff);
        setStyle("borderThickness", 2);
        alpha = 1.00;
      }
      else
      {
        setStyle("dropShadowEnabled", false);
        setStyle("borderColor", 0xcccccc);
        setStyle("borderThickness", 1);
        alpha = 0.60;
      }
    }


    protected function setTextContent(content:SimpleScheduleEntry):void
    {
      if (content.label == null)
        content.label = defaultLabel;

      formatter.error = "";
      var time:String = formatter.format(content.startDate)
        + " - " + formatter.format(content.endDate);

      toolTip = time + "\n" + content.label;
      contentLabel.text = time;
      contentLabel.styleName = getStyle("timeStyleName");
      contentText.text = content.label;

      updateSelected();
    }

  }
}