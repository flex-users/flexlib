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
package flexlib.scheduling.scheduleClasses.layout
{
  import flexlib.scheduling.scheduleClasses.TimeIndicatorItem;

  import mx.collections.ArrayCollection;
  import mx.collections.IList;

  [Event(name="update", type="flexlib.scheduling.scheduleClasses.layout.LayoutUpdateEvent")]
  public class TimeIndicatorLayout extends Layout implements ITimeIndicatorLayout
  {
    private var _timeIndicators:IList;
    private var _timeIndicatorLayoutItems:IList;
    private var _contentWidth:Number;

    public function TimeIndicatorLayout()
    {
      _timeIndicators = new ArrayCollection();
      _timeIndicatorLayoutItems = new ArrayCollection();
    }

    public function get timeIndicators():IList
    {
      return _timeIndicators;
    }

    public function set timeIndicators(value:IList):void
    {
      _timeIndicators = value;
    }

    public function get timeIndicatorLayoutItems():IList
    {
      return _timeIndicatorLayoutItems;
    }

    override public function get contentWidth():Number
    {
      return _contentWidth;
    }

    override public function set contentWidth(value:Number):void
    {
      xPosition *= value / _contentWidth;
      _contentWidth = value;
    }

    public function update(event:LayoutUpdateEvent):void
    {
      entryLayout = IEntryLayout(event.layout);
      contentWidth = entryLayout.contentWidth;
      startDate = entryLayout.startDate;
      endDate = entryLayout.endDate;
      viewportWidth = entryLayout.viewportWidth;
      viewportHeight = entryLayout.viewportHeight;
      xPosition = entryLayout.xPosition;
      yPosition = entryLayout.yPosition;
      calculateTimeItems();
      dispatchEvent(new LayoutUpdateEvent(this));
    }

    protected function calculateTimeItems():void
    {
      _timeIndicatorLayoutItems.removeAll();

      var length:Number = timeIndicators.length;
      for (var i:Number = 0; i < length; i++)
      {
        var indicator:TimeIndicatorItem = (TimeIndicatorItem)(timeIndicators.getItemAt(i));

        if (indicator.date.getTime() >= startDate.getTime() && indicator.date.getTime() <= endDate.getTime())
        {
          var millisToIndicatorTime:Number = indicator.date.getTime() - startDate.getTime();
          var timeIndicatorLayoutItem:TimeIndicatorLayoutItem = new TimeIndicatorLayoutItem();

          timeIndicatorLayoutItem.x = contentWidth * millisToIndicatorTime / totalMilliseconds;
          timeIndicatorLayoutItem.height = viewportHeight;
          timeIndicatorLayoutItem.y = 0;
          timeIndicatorLayoutItem.color = indicator.color;
          timeIndicatorLayoutItem.thickness = indicator.thickness;
          timeIndicatorLayoutItem.alpha = indicator.alpha;
          _timeIndicatorLayoutItems.addItem(timeIndicatorLayoutItem);
        }
      }
    }

  }
}