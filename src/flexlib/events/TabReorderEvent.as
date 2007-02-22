////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Doug McCune
//  http://dougmccune.com/blog
//  
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use, misuse,
//  copy, modify, merge, publish, distribute, love, hate, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to no conditions whatsoever.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE. DON'T SUE ME FOR SOMETHING DUMB
//  YOU DO. 
//
////////////////////////////////////////////////////////////////////////////////

package flexlib.events
{
	import flexlib.controls.SuperTabBar;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.events.IndexChangedEvent;
	
	/**
	 *  This is basically an IndexChangedEvent. But different.
	 * 
	 *  @see mx.core.Container
	 */
	public class TabReorderEvent extends IndexChangedEvent
	{
		public function TabReorderEvent(type:String, bubbles:Boolean = false,
									  cancelable:Boolean = false,
									  relatedObject:DisplayObject = null,
									  oldIndex:Number = -1,
									  newIndex:Number = -1,
                                      triggerEvent:Event = null)
		{
			super(type, bubbles, cancelable, relatedObject, oldIndex, newIndex, triggerEvent);
		}
	}
}