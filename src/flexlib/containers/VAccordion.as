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
	import flexlib.containers.accordionClasses.AccordionHeaderLocation;
	
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.IUIComponent;
	import mx.core.mx_internal;
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	use namespace mx_internal;
	
	[IconFile("VAccordion.png")]
	
	public class VAccordion extends AccordionBase
	{
		[Inspectable(enumeration="below,above", defaultValue="above")]
		/**
		 * Location of the header renderer for each content item. Must be either
		 * <code>AccordionHeaderLocation.ABOVE</code> or <code>AccordionHeaderLocation.BELOW</code>
		 * 
		 * @see flexlib.containers.accordionClasses.AccordionHeaderLocation
		 */
		public var headerLocation:String = AccordionHeaderLocation.ABOVE;
		
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("VAccordion");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.backgroundColor = 0xFFFFFF;
				this.borderStyle = "solid";
				this.paddingBottom = -1;
				this.paddingLeft = -1;
				this.paddingRight = -1;
				this.paddingTop = -1;
				this.verticalGap = -1;
				this.horizontalGap = -1;
			}
			
			StyleManager.setStyleDeclaration("VAccordion", selector, false);
				
		}
		
		initializeStyles();
		
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
				
				if(headerLocation != AccordionHeaderLocation.BELOW) {
		            header.move(x, y);
		            header.setActualSize(localContentWidth, headerHeight);
		            y += headerHeight;
				}
				
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
	            
	            if(headerLocation == AccordionHeaderLocation.BELOW) {
		            header.move(x, y);
		            header.setActualSize(localContentWidth, headerHeight);
		            y += headerHeight;
				}
	
	            y += verticalGap;
	        }
	
	        // Make sure blocker is in front
	        if (blocker)
	            rawChildren.setChildIndex(blocker, numChildren - 1);
	
	        // refresh the focus rect, the dimensions might have changed.
	        drawHeaderFocus(focusedIndex, showFocusIndicator);
	    }
	    
	    
	    
	    
	    
	    /**
	     *  @private
	     */
	    override mx_internal function onTweenUpdate(value:Number):void
	    {
	        // Fetch the tween invariants we set up in startTween.
	        var vm:EdgeMetrics = tweenViewMetrics;
	        var contentWidth:Number = tweenContentWidth;
	        var contentHeight:Number = tweenContentHeight;
	        var oldSelectedIndex:int = tweenOldSelectedIndex;
	        var newSelectedIndex:int = tweenNewSelectedIndex;
	
	        // The tweened value is the height of the new content area, which varies
	        // from 0 to the contentHeight. As the new content area grows, the
	        // old content area shrinks.
	        var newContentHeight:Number = value;
	        var oldContentHeight:Number = contentHeight - value;
	
	        // These offsets for the Y position of the content clips make the content
	        // clips appear to be pushed up and pulled down.
	        var oldOffset:Number = oldSelectedIndex < newSelectedIndex ? -newContentHeight : newContentHeight;
	        var newOffset:Number = newSelectedIndex > oldSelectedIndex ? oldContentHeight : -oldContentHeight;
	
	        // Loop over all the headers to arrange them vertically.
	        // The loop is intentionally over ALL the headers, not just the ones that
	        // need to move; this makes the animation look equally smooth
	        // regardless of how many headers are moving.
	        // We also reposition the two visible content clips.
	        var y:Number = vm.top;
	        var verticalGap:Number = getStyle("verticalGap");
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var header:Button = getHeaderAt(i);
	            var content:Container = Container(getChildAt(i));
	
				if(headerLocation == AccordionHeaderLocation.ABOVE) {
	            	header.$y = y;
	            	y += header.height;
				}
				
	            if (i == oldSelectedIndex)
	            {
	                content.cacheAsBitmap = true;
	                content.scrollRect = new Rectangle(0, -oldOffset,
	                        contentWidth, contentHeight);
	                content.visible = true;
	                y += oldContentHeight;
	
	            }
	            else if (i == newSelectedIndex)
	            {
	                content.cacheAsBitmap = true;
	                content.scrollRect = new Rectangle(0, -newOffset,
	                        contentWidth, contentHeight);
	                content.visible = true;
	                y += newContentHeight;
	            }
	            
	            if(headerLocation == AccordionHeaderLocation.BELOW) {
	            	header.$y = y;
	            	y += header.height;
				}
	
	            y += verticalGap;
	        }
	        
	       
	    }
	
	    /**
	     *  @private
	     */
	    override mx_internal function onTweenEnd(value:Number):void
	    {
	        bSliding = false;
	
	        var oldSelectedIndex:int = tweenOldSelectedIndex;
	
	        var vm:EdgeMetrics = tweenViewMetrics;
	
	        var verticalGap:Number = getStyle("verticalGap");
	        var headerHeight:Number = getHeaderHeight();
	
	        var localContentWidth:Number = calcContentWidth();
	        var localContentHeight:Number = calcContentHeight();
	
	        var y:Number = vm.top;
	        var content:Container;
	
			/*
			 * OK, so we got a problem here. I *think* the problem is that the old
			 * tween gets run a bit too much (ie if you select an item while a tween is
			 * in progress, then the previous tween still finishes, which causes this function
			 * to run and get passed an invaid value). The result is that the header jumps for
			 * an instant before going back to the right position (which gets reset once the next 
			 * onTweenUpdate of the new, correct Tween gets run).
			 *
			 * So what to do? Ideally we would check if the tween that triggered this function is
			 * the current this.tween object. If not then we would ignore it. But Tween is pretty
			 * stupid and doesn't allow us to know this basic information. Soo... my solution is
			 * to not update the header positions on tween end. I think this is OK since basically
			 * onTweenUpdate gets run enough to put the headers in the right spots.
			 *
			 * Another note: this bug only appeared once I tried allowing the headers to be below the 
			 * content. Otherwise it was unoticeable (but I believe still technically incorrect). 
			 * 
			 * -Doug McCune
			 * 
			 * UPDATE: 12-26-2007
			 * Well, turns out that if you use the normal VAccordion then my hack to try to fix the animation
			 * problem makes things worse. The lines I commented out actually do server a purpose, so
			 * commenting them out is not a good fix for the issue I ran into before. Well shit, I guess
			 * I'll have to play around with it more, but for now I'm leaving the function as it is in
			 * the Flex SDK.
			 */
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var header:Button = getHeaderAt(i);
	            
	            if(headerLocation == AccordionHeaderLocation.ABOVE) {
	            	//
	            	header.$y = y;
	            	y += headerHeight;
				}
	
	            if (i == selectedIndex)
	            {
	                content = Container(getChildAt(i));
	                content.cacheAsBitmap = false;
	                //
	                content.scrollRect = null;
	                //
	                content.visible = true;
	                y += localContentHeight;
	            }
	            
	            if(headerLocation == AccordionHeaderLocation.BELOW) {
	            	//
	            	header.$y = y;
	            	y += headerHeight;
				}
				
	            y += verticalGap;
	        }
	
	        if (oldSelectedIndex != -1)
	        {
	            content = Container(getChildAt(oldSelectedIndex));
	            content.cacheAsBitmap = false;
	            content.scrollRect = null;
	            content.visible = false;
	            content.tweeningProperties = null;
	        }
	
	        // Delete the temporary tween invariants we set up in startTween.
	        tweenViewMetrics = null;
	        tweenContentWidth = NaN;
	        tweenContentHeight = NaN;
	        tweenOldSelectedIndex = 0;
	        tweenNewSelectedIndex = 0;
	
	        tween = null;
	
	        UIComponent.resumeBackgroundProcessing();
	
	        Container(getChildAt(selectedIndex)).tweeningProperties = null;
	
	        // If we interrupted a Dissolve effect, restart it here
	        if (currentDissolveEffect)
	        {
	            if (currentDissolveEffect.target != null)
	            {
	                currentDissolveEffect.play();
	            }
	            else
	            {
	                currentDissolveEffect.play([this]);
	            }
	        }
	
	        // Let the screen render the last frame of the animation before
        	// we begin instantiating the new child.
        	callLater(instantiateChild, [selectedChild]);
	    }
	    
	    override protected function startTween(oldSelectedIndex:int, newSelectedIndex:int):void
    	{
    		if(tween)
    			tween.pause();
    			
    		super.startTween(oldSelectedIndex, newSelectedIndex);
    		
    		 invalidateSize();
	        invalidateDisplayList();
	        validateNow();
	       
    	}
	}
}