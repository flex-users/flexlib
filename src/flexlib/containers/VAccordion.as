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

package flexlib.containers
{
	import flexlib.baseClasses.AccordionBase;
	
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.IUIComponent;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	[IconFile("VAccordion.png")]
	
	public class VAccordion extends AccordionBase
	{
		
		/**
	     *  @private
	     */
	    override protected function measure():void
	    {
	        super.measure();
	
	        var minWidth:Number = 0;
	        var minHeight:Number = 0;
	        var preferredWidth:Number = 0;
	        var preferredHeight:Number = 0;
	
	        var paddingLeft:Number = getStyle("paddingLeft");
	        var paddingRight:Number = getStyle("paddingRight");
	        var headerHeight:Number = getHeaderHeight();
	
	        // Only measure once, unless resizeToContent='true'
	        // Thereafter, we'll just use cached values.
	        // (However, if a layout style like headerHeight changes,
	        // we have to re-measure.)
	        //
	        // We need to copy the cached values into the measured fields
	        // again to handle the case where scaleX or scaleY is not 1.0.
	        // When the Accordion is zoomed, code in UIComponent.measureSizes
	        // scales the measuredWidth/Height values every time that
	        // measureSizes is called.  (bug 100749)
	        if (accPreferredWidth && !_resizeToContent && !layoutStyleChanged)
	        {
	            measuredMinWidth = accMinWidth;
	            measuredMinHeight = accMinHeight;
	            measuredWidth = accPreferredWidth;
	            measuredHeight = accPreferredHeight;
	            return;
	        }
	
	        layoutStyleChanged = false;
	
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var button:Button = getHeaderAt(i);
	            var child:IUIComponent = IUIComponent(getChildAt(i));
	
	            minWidth = Math.max(minWidth, button.minWidth);
	            minHeight += headerHeight;
	            preferredWidth = Math.max(preferredWidth, minWidth);
	            preferredHeight += headerHeight;
	
	            // The headers preferredWidth is messing up the accordion measurement. This may not
	            // be needed anyway because we're still using the headers minWidth to determine our overall
	            // minWidth.
	
	            if (i == selectedIndex)
	            {
	                preferredWidth = Math.max(preferredWidth, child.getExplicitOrMeasuredWidth());
	                preferredHeight += child.getExplicitOrMeasuredHeight();
	
	                minWidth = Math.max(minWidth, child.minWidth);
	                minHeight += child.minHeight;
	            }
	
	        }
	
	        // Add space for borders and margins
	        var vm:EdgeMetrics = viewMetricsAndPadding;
	        var widthPadding:Number = vm.left + vm.right;
	        var heightPadding:Number = vm.top + vm.bottom;
	
	        // Need to adjust the widthPadding if paddingLeft and paddingRight are negative numbers
	        // (see explanation in updateDisplayList())
	        if (paddingLeft < 0)
	            widthPadding -= paddingLeft;
	
	        if (paddingRight < 0)
	            widthPadding -= paddingRight;
	
	        minWidth += widthPadding;
	        preferredWidth += widthPadding;
	        minHeight += heightPadding;
	        preferredHeight += heightPadding;
	
	        measuredMinWidth = minWidth;
	        measuredMinHeight = minHeight;
	        measuredWidth = preferredWidth;
	        measuredHeight = preferredHeight;

	        // If we're called before instantiateSelectedChild, then bail.
	        // We'll be called again later (instantiateSelectedChild calls
	        // invalidateSize), and we don't want to load values into the
	        // cache until we're fully initialized.  (bug 102639)
	        // This check was moved from the beginning of this function to
	        // here to fix bugs 103665/104213.
	        if (selectedChild && Container(selectedChild).numChildrenCreated == -1)
	            return;
	
	        // Don't remember sizes if we don't have any children
	        if (numChildren == 0)
	            return;
	
	        accMinWidth = minWidth;
	        accMinHeight = minHeight;
	        accPreferredWidth = preferredWidth;
	        accPreferredHeight = preferredHeight;
	    }
	    
	    
	    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	
	        // Don't do layout if we're tweening because the tweening
	        // code is handling it.
	        if (tween)
	            return;
	
	        // Measure the border.
	        var bm:EdgeMetrics = borderMetrics;
	        var paddingLeft:Number = getStyle("paddingLeft");
	        var paddingRight:Number = getStyle("paddingRight");
	        var paddingTop:Number = getStyle("paddingTop");
	        var verticalGap:Number = getStyle("verticalGap");
	
	        // Determine the width and height of the content area.
	        var localContentWidth:Number = calcContentWidth();
	        var localContentHeight:Number = calcContentHeight();
	
	        // Arrange the headers, the content clips,
	        // based on selectedIndex.
	        var x:Number = bm.left + paddingLeft;
	        var y:Number = bm.top + paddingTop;
	
	        // Adjustments. These are required since the default halo
	        // appearance has verticalGap and all margins set to -1
	        // so the edges of the headers overlap each other and the
	        // border of the accordion. These overlaps cause problems with
	        // the content area clipping, so we adjust for them here.
	        var contentX:Number = x;
	        var adjContentWidth:Number = localContentWidth;
	        var headerHeight:Number = getHeaderHeight();
	
	        if (paddingLeft < 0)
	        {
	            contentX -= paddingLeft;
	            adjContentWidth += paddingLeft;
	        }
	
	        if (paddingRight < 0)
	            adjContentWidth += paddingRight;
	
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var header:Button = getHeaderAt(i);
	            var content:IUIComponent = IUIComponent(getChildAt(i));
	
	            header.move(x, y);
	            header.setActualSize(localContentWidth, headerHeight);
	            y += headerHeight;
	
	            if (i == selectedIndex)
	            {
	                content.move(contentX, y);
	                content.visible = true;
	
	                var contentW:Number = adjContentWidth;
	                var contentH:Number = localContentHeight;
	
	                if (!isNaN(content.percentWidth))
	                {
	                    if (contentW > content.maxWidth)
	                        contentW = content.maxWidth;
	                }
	                else
	                {
	                    if (contentW > content.getExplicitOrMeasuredWidth())
	                        contentW = content.getExplicitOrMeasuredWidth();
	                }
	
	                if (!isNaN(content.percentHeight))
	                {
	                    if (contentH > content.maxHeight)
	                        contentH = content.maxHeight;
	                }
	                else
	                {
	                    if (contentH > content.getExplicitOrMeasuredHeight())
	                        contentH = content.getExplicitOrMeasuredHeight();
	                }
	
	                if (content.width != contentW ||
	                    content.height != contentH)
	                {
	                    content.setActualSize(contentW, contentH);
	                }
	
	                y += localContentHeight;
	            }
	            else
	            {
	                content.move(contentX, i < selectedIndex
	                        ? y : y - localContentHeight);
	                content.visible = false;
	            }
	
	            y += verticalGap;
	        }
	
	        // Make sure blocker is in front
	        if (blocker)
	            rawChildren.setChildIndex(blocker, numChildren - 1);
	
	        // refresh the focus rect, the dimensions might have changed.
	        drawHeaderFocus(focusedIndex, showFocusIndicator);
	    }
	}
}