package flexlib.scheduling.scheduleClasses
{
   import flexlib.scheduling.ScheduleViewer;
   import flexlib.scheduling.scheduleClasses.layout.EntryLayoutItem;
   import flexlib.scheduling.scheduleClasses.layout.IEntryLayout;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   
   import mx.controls.scrollClasses.ScrollBar;
   import mx.core.ScrollPolicy;
   import mx.effects.AnimateProperty;
   import mx.events.EffectEvent;
   import mx.events.ScrollEvent;
   import mx.events.ScrollEventDirection;
   
   use namespace schedule_internal;
   
   [Event(name="invalidateDisplayList", type="flash.events.Event")]
   public class ScheduleNavigator extends EventDispatcher
   {
      public static const INVALIDATE_DISPLAY_LIST : String = "invalidateDisplayList";
      
      public var entryLayoutImpl : IEntryLayout;
		public var contentWidthOffset : Number;
		public var contentHeightOffset : Number;      
      private var owner : ScheduleViewer;
      private var _pixelScrollEnabled : Boolean;
      private var hasPixelScrollWhileAnimating : Boolean    
 		private var _xPosition : Number;
		private var _yPosition : Number;
		private var _xPositionWithOffset : Number;
		private var _yPositionWithOffset : Number;		
		private var _xOffset : Number;
		private var _yOffset : Number;	
		private var _zoom : Number;     
      
      public function ScheduleNavigator( owner : ScheduleViewer )
      {
         this.owner = owner;
         
			owner.horizontalScrollPolicy = ScrollPolicy.AUTO;
			owner.verticalScrollPolicy = ScrollPolicy.AUTO;         
         
         pixelScrollEnabled = true;
			_xPosition = 0;
			_yPosition = 0;
			_xPositionWithOffset = 0;
			_yPositionWithOffset = 0;
			_zoom = 100;
			xOffset = 50;
			yOffset = 50;
			contentWidthOffset = 0;
			contentHeightOffset = 0;         
      }
      
 		public function mouseWheelHandler( event : MouseEvent ) : void
		{
        var verticalScrollBar : ScrollBar = owner.verticalScrollBar;
         
      
         var oldPosition : Number = owner.verticalScrollPosition;
         var newPos : int = owner.verticalScrollPosition;
         var lineScrollSize : Number;
         if( !isItemScroll() )
         {
         	lineScrollSize = owner.rowHeight / 3;
         }
         else
         {
         	lineScrollSize = verticalScrollBar.lineScrollSize / 3;
         }
         newPos -= event.delta * lineScrollSize;	   
         newPos = Math.max( 0, Math.min( newPos, verticalScrollBar.maxScrollPosition ) );
         owner.verticalScrollPosition = newPos;
          
         if ( oldPosition != owner.verticalScrollPosition )
         {
             var scrollEvent:ScrollEvent = new ScrollEvent( ScrollEvent.SCROLL );
             scrollEvent.direction = ScrollEventDirection.VERTICAL;
         	 scrollEvent.position = getPixelOrItemScroll( owner.verticalScrollPosition );				     
             scrollEvent.delta = owner.verticalScrollPosition - oldPosition;
             owner.dispatchEvent( scrollEvent );
         }
        
      }
		
		//dispatch item scroll event only when the row item changes.
		public function onScroll( event : ScrollEvent ) : void
		{
			var position : Number = event.position;			
			var newIndex : Number;
			var oldIndex : Number;
			var delta : Number;
			
			if( event.direction == ScrollEventDirection.HORIZONTAL )
			{
				setXPosition( position );
			}
			else
			{
				newIndex = Math.floor( position / owner.rowHeight );
				oldIndex = Math.floor( entryLayoutImpl.yPosition / owner.rowHeight );
				delta = oldIndex - newIndex;
				
				setYPosition( position );
				
				if( delta != 0 )
				{
					var itemScrollEvent : LayoutScrollEvent = new LayoutScrollEvent( LayoutScrollEvent.ITEM_SCROLL );
					itemScrollEvent.direction = event.direction;
					itemScrollEvent.position = newIndex;
					itemScrollEvent.delta = delta;
					itemScrollEvent.detail = event.detail;
					owner.dispatchEvent( itemScrollEvent );			
				}
			}
		}			
		
		public function scrollHandler( event : Event ) : void
		{
			var scrollEvent : ScrollEvent = ScrollEvent( event );
			if( scrollEvent.direction == ScrollEventDirection.VERTICAL )
			{
				scrollEvent.position = getPixelOrItemScroll( scrollEvent.position );
			}
			onScroll( scrollEvent );
		}		
		
		public function updateItemScroll() : void
		{
			if( isItemScroll() )
			{
				owner.yOffset = convertPixelToItemPosition( owner.yOffset );
				owner.verticalScrollBar.lineScrollSize = owner.rowHeight;
			}
		}
		
		public function get pixelScrollEnabled() : Boolean
		{
			return _pixelScrollEnabled;
		}
		
		public function set pixelScrollEnabled( value : Boolean ) : void
		{
			_pixelScrollEnabled = value;
			dispatchEvent( new Event( ScheduleNavigator.INVALIDATE_DISPLAY_LIST ) );
		}
		
		//navigation				
		
		[Bindable]
		public function get zoom() : Number
		{
			return _zoom;
		}
		
		public function set zoom( value : Number ) : void
		{
			_zoom = value;
			var adjustedValue : Number = value / 100 * Math.sqrt( owner.width );
			contentWidth = Math.pow( adjustedValue, 2 );
		}
		
		[Bindable]
		public function get contentWidth() : Number
		{
			return entryLayoutImpl.contentWidth;
		}
		
		public function set contentWidth( value : Number ) : void
		{
			owner.horizontalScrollPosition *= value / entryLayoutImpl.contentWidth;
			if( isNaN( owner.horizontalScrollPosition ) ) owner.horizontalScrollPosition = 0;
			
			entryLayoutImpl.contentWidth = value;
			
			dispatchEvent( new Event( ScheduleNavigator.INVALIDATE_DISPLAY_LIST ) );
		}
		
		[Bindable]
		public function get xPosition() : Number
		{
			return _xPosition;
		}
		
		public function set xPosition( position : Number ) : void
		{
			_xPosition = position;
			setHorizontalScrollPosition( position );
			var overlap : Number = entryLayoutImpl.contentWidth - entryLayoutImpl.viewportWidth;
			if( overlap < position )
			{
				contentWidthOffset = position - overlap;
				dispatchEvent( new Event( ScheduleNavigator.INVALIDATE_DISPLAY_LIST ) );
			}
		}
		
		[Bindable]
		public function get yPosition() : Number
		{
			return _yPosition;
		}
		
		public function set yPosition( position : Number ) : void
		{
			_yPosition = position;
			setVerticalScrollPosition( position );
			var overlap : Number = entryLayoutImpl.contentHeight - entryLayoutImpl.viewportHeight;
			if( overlap < position )
			{
				contentHeightOffset = position - overlap;				
				dispatchEvent( new Event( ScheduleNavigator.INVALIDATE_DISPLAY_LIST ) );
			}
		}
		
		[Bindable]
		public function get xPositionWithOffset() : Number
		{
			return _xPositionWithOffset;
		}
		
		public function set xPositionWithOffset( position : Number ) : void
		{
			_xPositionWithOffset = position - xOffset;
			setHorizontalScrollPosition( _xPositionWithOffset );
		}
		
		[Bindable]
		public function get yPositionWithOffset() : Number
		{
			return _yPositionWithOffset;
		}
							
		public function set yPositionWithOffset( position : Number ) : void
		{
			_yPositionWithOffset = position - yOffset;
			setVerticalScrollPosition( _yPositionWithOffset );
		}
		
		[Bindable]
		public function get xOffset() : Number
		{
			return _xOffset;
		}
		
		public function set xOffset( value : Number ) : void
		{
			_xOffset = value;
		}
		
		[Bindable]
		public function get yOffset() : Number
		{
			return _yOffset;
		}
		
		public function set yOffset( value : Number ) : void
		{
			_yOffset = value;
		}			
		
		public function gotoTime( milliseconds : Number ) : void
		{
			var position : Number = milliseconds * entryLayoutImpl.contentWidth / entryLayoutImpl.totalMilliseconds;
			owner.xPosition = position;
		}

		public function moveToTime( milliseconds : Number ) : void
		{
			var position : Number = milliseconds * entryLayoutImpl.contentWidth / entryLayoutImpl.totalMilliseconds;
			animateHorizontalScrollPosition( position );
		}
		
		public function gotoEntry( entry : IScheduleEntry ) : void
		{
			var milliseconds : Number = entry.startDate.getTime() - entryLayoutImpl.startDate.getTime();
			gotoTime( milliseconds );
			
			var item : EntryLayoutItem = entryLayoutImpl.findLayoutItem( entry );
			owner.yPosition = item.y;
		}
		
		public function moveToEntry( entry : IScheduleEntry ) : void
		{
			var milliseconds : Number = entry.startDate.getTime() - entryLayoutImpl.startDate.getTime();
			moveToTime( milliseconds );
			
			var item : EntryLayoutItem = entryLayoutImpl.findLayoutItem( entry );
			animateVerticalScrollPosition( item.y );
		}		
		
		private function animateHorizontalScrollPosition( position : Number ) : void
		{
			var e : AnimateProperty = new AnimateProperty( this );
			e.property = "xPosition";
			e.fromValue = owner.horizontalScrollPosition;
			e.toValue = position - owner.xOffset;
			e.duration = owner.getStyle( "moveDuration" );
			e.easingFunction = owner.getStyle( "moveEasingFunction" ) as Function;
			e.play();
		}		
		
		
		private function animateVerticalScrollPosition( position : Number ) : void
		{
			if( !pixelScrollEnabled ) 
			{
				pixelScrollEnabled = true;
				hasPixelScrollWhileAnimating = true;
			}
			var e : AnimateProperty = new AnimateProperty( this );
			e.property = "yPosition";
			e.fromValue = owner.verticalScrollPosition;
			e.toValue = position - owner.yOffset;
			e.duration = owner.getStyle( "moveDuration" );
			e.easingFunction = owner.getStyle( "moveEasingFunction" ) as Function;
			e.addEventListener( EffectEvent.EFFECT_END, verticalAnimationEnd );
			e.play();
		}
		
		private function verticalAnimationEnd( event : EffectEvent ) : void
		{
			if( hasPixelScrollWhileAnimating )
			{				
				pixelScrollEnabled = false;
				hasPixelScrollWhileAnimating = false;
			}
		}
				
		private function setHorizontalScrollPosition( value : Number ) : void
		{
			var event : ScrollEvent = new ScrollEvent( ScrollEvent.SCROLL );
			event.direction = ScrollEventDirection.HORIZONTAL;
			event.position = value;
			event.delta = owner.horizontalScrollPosition - value;
			event.detail = "custom";
			owner.horizontalScrollPosition = value;			
			owner.dispatchEvent( event );
			
			var itemScrollEvent : LayoutScrollEvent = new LayoutScrollEvent( LayoutScrollEvent.PIXEL_SCROLL );
			itemScrollEvent.direction = ScrollEventDirection.HORIZONTAL;
			itemScrollEvent.position = value;
			itemScrollEvent.delta = owner.horizontalScrollPosition - value;
			itemScrollEvent.detail = "custom";
			owner.dispatchEvent( itemScrollEvent );
		}
		
		private function setVerticalScrollPosition( value : Number ) : void
		{
			var event : ScrollEvent = new ScrollEvent( ScrollEvent.SCROLL );
			event.direction = ScrollEventDirection.VERTICAL;
			event.position = value;
			event.delta = owner.verticalScrollPosition - value;
			event.detail = "custom";
			owner.verticalScrollPosition = value;			
			owner.dispatchEvent( event );
			
			var itemScrollEvent : LayoutScrollEvent = new LayoutScrollEvent( LayoutScrollEvent.PIXEL_SCROLL );
			itemScrollEvent.direction = ScrollEventDirection.VERTICAL;
			itemScrollEvent.position = value;
			itemScrollEvent.delta = owner.verticalScrollPosition - value;
			itemScrollEvent.detail = "custom";
			owner.dispatchEvent( itemScrollEvent );
		}		
		
		private function isItemScroll() : Boolean
		{
			return ( owner.verticalScrollBar != null && !pixelScrollEnabled );
		}
		
		private function getPixelOrItemScroll( pixelPosition : Number ) : Number
		{
			var position : Number = pixelPosition;
			if( !pixelScrollEnabled ) position = convertPixelToItemPosition( position ); 
			return position;			
		}
		
		private function convertPixelToItemPosition( pixelPosition : Number ) : Number
		{
			var rowCount : Number = pixelPosition / owner.rowHeight;
			return Math.floor( rowCount ) * owner.rowHeight;			
		}
		
		private function setXPosition( position : Number ) : void
		{
			entryLayoutImpl.xPosition = position;
			entryLayoutImpl.update();
		}
		
		private function setYPosition( position : Number ) : void
		{
			entryLayoutImpl.yPosition = position;
			entryLayoutImpl.update();
		}				 
   }
}