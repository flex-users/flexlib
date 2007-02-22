package flexlib.containers
{
	import flexlib.baseClasses.AccordionBase;
	
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.core.ClassFactory;
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.Tween;
	
	use namespace mx_internal;
	
	[IconFile("HAccordion.png")]
	
	
	public class HAccordion extends AccordionBase
	{
			

		/**
	     *  The height of the area, in pixels, in which content is displayed.
	     *  You can override this getter if your content
	     *  does not occupy the entire area of the container.
	     */
	    override protected function get contentHeight():Number
	    {
	        // Start with the width of the entire accordion.
	        var contentHeight:Number = unscaledHeight;
	
	        // Subtract the widths of the left and right borders.
	        var vm:EdgeMetrics = viewMetricsAndPadding;
	        contentHeight -= vm.top + vm.bottom;
	
	        contentHeight -= getStyle("paddingTop") +
	                        getStyle("paddingBottom");
	
	        return contentHeight;
	    }
	    
	    override protected function get contentWidth():Number
	    {
	        // Start with the height of the entire accordion.
	        var contentWidth:Number = unscaledWidth;
	
	        // Subtract the heights of the top and bottom borders.
	        var vm:EdgeMetrics = viewMetricsAndPadding;
	        contentWidth -= vm.left + vm.right;
	
	        // Subtract the header heights.
	        var horizontalGap:Number = getStyle("horizontalGap");
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            contentWidth -= getHeaderAt(i).width;
	
	            if (i > 0)
	                contentWidth -= horizontalGap;
	        }
	        
	        return contentWidth;
	    }
	    
	    override protected function measure():void
	    {
	        super.measure();
	
	        var minWidth:Number = 0;
	        var minHeight:Number = 0;
	        var preferredWidth:Number = 0;
	        var preferredHeight:Number = 0;
	
	        var paddingLeft:Number = getStyle("paddingLeft");
	        var paddingRight:Number = getStyle("paddingRight");
	        var paddingTop:Number = getStyle("paddingTop");
	        var paddingBottom:Number = getStyle("paddingBottom");
	       
	        var headerWidth:Number = getHeaderWidth();
	
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
	
	            minWidth += headerWidth;
	            minHeight = Math.max(minHeight, button.minHeight);
	            
	            preferredHeight = Math.max(preferredHeight, minHeight);
	            preferredWidth += headerWidth;
	
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
	    
	    
	    
	    /**
	     *  @private
	     *  Arranges the layout of the accordion contents.
	     *
	     *  @tiptext Arranges the layout of the Accordion's contents
	     *  @helpid 3017
	     */
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
	        var paddingBottom:Number = getStyle("paddingBottom");
	        var horizontalGap:Number = getStyle("horizontalGap");
	
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
	        var contentY:Number = y;
	        var adjContentHeight:Number = localContentHeight;
	        var headerWidth:Number = getHeaderWidth();
	
	        if (paddingTop < 0)
	        {
	            contentY -= paddingTop;
	            adjContentHeight += paddingTop;
	        }
	
	        if (paddingBottom < 0)
	            adjContentHeight += paddingBottom;
	
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var header:Button = getHeaderAt(i);
	            var content:IUIComponent = IUIComponent(getChildAt(i));
	
	            
	            header.rotation = -90;
	            header.move(x, y + localContentHeight);
	            header.setActualSize(localContentHeight, headerWidth);
	            
	            
	            x += headerWidth;
	
	            if (i == selectedIndex)
	            {
	                content.move(x, contentY);
	                content.visible = true;
	
	                var contentW:Number = localContentWidth;
	                var contentH:Number = adjContentHeight;
	
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
	
	                x += localContentWidth;
	            }
	            else
	            {
	                content.move(i < selectedIndex
	                        ? x : x - localContentWidth, contentY);
	                content.visible = false;
	            }
	
	            x += horizontalGap;
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
	    override protected function calcContentHeight():Number
	    {
	        // Start with the height of the entire accordion.
	        var contentHeight:Number = unscaledHeight;
	
	        // Subtract the heights of the top and bottom borders.
	        var vm:EdgeMetrics = viewMetricsAndPadding;
	        contentHeight -= vm.top + vm.bottom;
	
	        return contentHeight;
	    }
	
	    /**
	     *  @private
	     */
	    override protected function calcContentWidth():Number
	    {
	        // Start with the width of the entire accordion.
	        var contentWidth:Number = unscaledWidth;
	
	        // Subtract the widths of the left and right borders.
	        var vm:EdgeMetrics = viewMetricsAndPadding;
	        contentWidth -= vm.left + vm.right;
	
	        // Subtract the header widths.
	        var horizontalGap:Number = getStyle("horizontalGap");
	        var headerWidth:Number = getHeaderWidth();
	
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            contentWidth -= headerWidth;
	
	            if (i > 0)
	                contentWidth -= horizontalGap;
	        }
	
	        return contentWidth;
	    }
	    
	    
	    /**
	     *  @private
	     */
	    override protected function startTween(oldSelectedIndex:int, newSelectedIndex:int):void
	    {
	        bSliding = true;
	
	        // To improve the animation performance, we set up some invariants
	        // used in onTweenUpdate. (Some of these, like contentHeight, are
	        // too slow to recalculate at every tween step.)
	        tweenViewMetrics = viewMetricsAndPadding;
	        tweenContentWidth = calcContentWidth();
	        tweenContentHeight = calcContentHeight();
	        tweenOldSelectedIndex = oldSelectedIndex;
	        tweenNewSelectedIndex = newSelectedIndex;
	
	        // A single instance of Tween drives the animation.
	        var openDuration:Number = getStyle("openDuration");
	        tween = new Tween(this, 0, tweenContentWidth, openDuration);

	        var easingFunction:Function = getStyle("openEasingFunction") as Function;
	        if (easingFunction != null)
	            tween.easingFunction = easingFunction;
	
	        // Ideally, all tweening should be managed by the EffectManager.  Since
	        // this tween isn't managed by the EffectManager, we need this alternate
	        // mechanism to tell the EffectManager that we're tweening.  Otherwise, the
	        // EffectManager might try to play another effect that animates the same
	        // properties.
	        if (oldSelectedIndex != -1)
	            Container(getChildAt(oldSelectedIndex)).tweeningProperties = ["x", "y", "width", "height"];
	        Container(getChildAt(newSelectedIndex)).tweeningProperties = ["x", "y", "width", "height"];
	
	        // If the content of the new child hasn't been created yet, set the new child
	        // to the content width/height. This way any background color will show up
	        // properly during the animation.
	        var newSelectedChild:Container = Container(getChildAt(newSelectedIndex));
	        if (newSelectedChild.numChildren == 0)
	        {
	            var paddingTop:Number = getStyle("paddingTop");
	            var contentY:Number = borderMetrics.top + (paddingTop > 0 ? paddingTop : 0);
	
	            newSelectedChild.move(newSelectedChild.x, contentY);
	            newSelectedChild.setActualSize(tweenContentWidth, tweenContentHeight);
	        }

	        UIComponent.suspendBackgroundProcessing();
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
	        var newContentWidth:Number = value;
	        var oldContentWidth:Number = contentWidth - value;
	
	        // These offsets for the Y position of the content clips make the content
	        // clips appear to be pushed up and pulled down.
	        var oldOffset:Number = oldSelectedIndex < newSelectedIndex ? -newContentWidth : newContentWidth;
	        var newOffset:Number = newSelectedIndex > oldSelectedIndex ? oldContentWidth : -oldContentWidth;
	
	        // Loop over all the headers to arrange them vertically.
	        // The loop is intentionally over ALL the headers, not just the ones that
	        // need to move; this makes the animation look equally smooth
	        // regardless of how many headers are moving.
	        // We also reposition the two visible content clips.
	        var x:Number = vm.left;
	        var horizontalGap:Number = getStyle("horizontalGap");
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var header:Button = getHeaderAt(i);
	            var content:Container = Container(getChildAt(i));
	
	            header.$x = x;
	            x += header.height;

	            if (i == oldSelectedIndex)
	            {
	                content.cacheAsBitmap = true;
	                content.scrollRect = new Rectangle(-oldOffset, 0,
	                        contentWidth, contentHeight);
	                content.visible = true;
	                x += oldContentWidth;
	
	            }
	            else if (i == newSelectedIndex)
	            {
	                content.cacheAsBitmap = true;
	                content.scrollRect = new Rectangle(-newOffset, 0,
	                        contentWidth, contentHeight);
	                content.visible = true;
	                x += newContentWidth;
	            }
	
	            x += horizontalGap;
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
	
	        var horizontalGap:Number = getStyle("horizontalGap");
	        var headerWidth:Number = getHeaderWidth();
	
	        var localContentWidth:Number = calcContentWidth();
	        var localContentHeight:Number = calcContentHeight();
	
	        var x:Number = vm.left;
	        var content:Container;
	
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var header:Button = getHeaderAt(i);
	            header.$x = x;
	            x += headerWidth;
	
	            if (i == selectedIndex)
	            {
	                content = Container(getChildAt(i));
	                content.cacheAsBitmap = false;
	                content.scrollRect = null;
	                content.visible = true;
	                x += localContentWidth;
	            }
	            x += horizontalGap;
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
	        callLater(instantiateSelectedChild);
	    }
		
	}
}