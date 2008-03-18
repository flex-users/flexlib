/*
Copyright (c) 2008 FlexLib Contributors.  See:
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

package flexlib.events {

    import flash.events.Event;

    import flash.events.TextEvent;


    /**
     *   The WindowShadeEvent class represents event objects that are specific to
     *   the WindowShade container.
     *
     *  @see flexlib.containers.WindowShade
     */
    public class WindowShadeEvent extends Event {



        /**
         *  The WindowShadeEvent.OPENED_CHANGED constant defines the value of the 
         *  <code>type</code> property of the event object for a 
         *  <code>openedChanged</code> event, which indicates that the value of the
         * <code>opened</code> property has been toggled, either through user action
         * or programattically.
         * 
         * <p>This is the only WindowShadeEvent type that can be cancelled by a listener function. If the
         * <code>preventDefault()</code> method is called, the previous value of the <code>opened</code> property
         * will be restored. The restoration will trigger an additonal PropertyChangeEvent to keep properties bound to
         * the <code>opened</code> property in sync, but it will not trigger another <code>openChanged</code> event.</p>
         */
        public static const OPENED_CHANGED:String = "openedChanged";

        /**
         * The WindowShadeEvent.OPEN_BEGIN constant defines the value of the <code>type</code>
         * property of a WindowShadeEvent object used to indicate that a WindowShade is about to be opened. This
         * type of WindowShadeEvent is not cancelable.
         * 
         * <p>In most cases, an event of this type will be followed by an event of type WindowShadeEvent.OPEN_END (<code>openEnd</code>); however,
         * if the user clicks the header button before the opening transition has run to completion, the <code>openEnd</code> event will
         * not be dispatched, since the WindowShade will not be left in the open state.</p>
         */
        public static const OPEN_BEGIN:String = "openBegin";


        /**
         * The WindowShadeEvent.OPEN_END constant defines the value of the <code>type</code>
         * property of a WindowShadeEvent object used to indicate that a WindowShade has been completely opened. The WindowShade, however,
         * is not guaranteed to have been rendered in the fully open state when this event is dispatched. (Use callLater in the event handler
         * if this is a problem.) This type of WindowShadeEvent is not cancelable.
         * 
         */
        public static const OPEN_END:String = "openEnd";


        /**
         * The WindowShadeEvent.CLOSE_BEGIN constant defines the value of the <code>type</code>
         * property of a WindowShadeEvent object used to indicate that a WindowShade is about to be closed. This
         * type of WindowShadeEvent is not cancelable.
         * 
         * <p>In most cases, an event of this type will be followed by an event of type WindowShadeEvent.CLOSE_END (<code>closeEnd</code>); however,
         * if the user clicks the header button before the closing transition has run to completion, the <code>closeEnd</code> event will
         * not be dispatched, since the WindowShade will not be left in the closed state.</p>
         */
        public static const CLOSE_BEGIN:String = "closeBegin";

        /**
         * The WindowShadeEvent.CLOSE_END constant defines the value of the <code>type</code>
         * property of a WindowShadeEvent object used to indicate that a WindowShade has been completely opened. The WindowShade, however,
         * is not guaranteed to have been rendered in the fully open state when this event is dispatched. (Use callLater in the event handler
         * if this is a problem.) This type of WindowShadeEvent is not cancelable.
         * 
         */
        public static const CLOSE_END:String = "closeEnd";


        /**
         * Constructs a new WindowShadeEvent.
         */
        public function WindowShadeEvent(type:String, bubbles:Boolean = false,
                                  cancelable:Boolean = false) {

            super(type, bubbles, cancelable);
        }
    }

}
