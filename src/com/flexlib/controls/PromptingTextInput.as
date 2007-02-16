/*
Adobe Systems Incorporated(r) Source Code License Agreement
Copyright(c) 2005 Adobe Systems Incorporated. All rights reserved.
	
Please read this Source Code License Agreement carefully before using
the source code.
	
Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive,
no-charge, royalty-free, irrevocable copyright license, to reproduce,
prepare derivative works of, publicly display, publicly perform, and
distribute this source code and such derivative works in source or
object code form without any attribution requirements.
	
The name "Adobe Systems Incorporated" must not be used to endorse or promote products
derived from the source code without prior written permission.
	
You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
against any loss, damage, claims or lawsuits, including attorney's
fees that arise or result from your use or distribution of the source
code.
	
THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT
ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. ALSO, THERE IS NO WARRANTY OF
NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT. IN NO EVENT SHALL MACROMEDIA
OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.flexlib.controls
{

import flash.events.Event;
import flash.events.FocusEvent;
import flash.text.TextField;

import mx.controls.TextInput;
import mx.events.FlexEvent;
	
/**
 * The <code>PromptingTextInput</code> component is a small enhancement to
 * standard <code>TextInput</code>.  It adds the ability to specify a prompt
 * value that displays when the text is empty, similar to how the prompt
 * property of the <code>ComboBox</code> behaves when there is no selected value.
 */
public class PromptingTextInput extends TextInput
{
	/** Flag to indicate if the text is empty or not */
	private var _textEmpty:Boolean;
	
	/** 
	 * Flag to prevent us from re-inserting the prompt if the text is cleared
	 * while the component still has focus.
	 */
	private var _currentlyFocused:Boolean = false;
	
	/**
	 * Constructor
	 */
	public function PromptingTextInput()
	{
		_textEmpty = true;
		
		addEventListener( Event.CHANGE, handleChange );
		addEventListener( FocusEvent.FOCUS_IN, handleFocusIn );
		addEventListener( FocusEvent.FOCUS_OUT, handleFocusOut );
	}
	
	// ==============================================================
	//	prompt
	// ==============================================================
	
	/** Storage for the prompt property */
	private var _prompt:String = "";
	
	/** 
	 * The string to use as the prompt value
	 */
	public function get prompt():String
	{
		return _prompt;
	}
	
	[Bindable]
	public function set prompt( value:String ):void
	{
		_prompt = value;
		
		invalidateProperties();
	}
	
	// ==============================================================
	//	promptFormat
	// ==============================================================
	
	/** Storage for the promptFormat property */
	private var _promptFormat:String = '<font color="#999999"><i>[prompt]</i></font>';
	
	/** 
	 * A format string to specify how the prompt is displayed.  This is typically
	 * an HTML string that can set the font color and style.  Use <code>[prompt]</code>
	 * within the string as a replacement token that will be replaced with the actual
	 * prompt text.
	 * 
	 * The default value is "&lt;font color="#999999"&gt;&lt;i&gt;[prompt]&lt;/i&gt;&lt;/font&gt;"
	 */
	public function get promptFormat():String
	{
		return _promptFormat;
	}
	
	public function set promptFormat( value:String ):void
	{
		_promptFormat = value;
		// Check to see if the replacement code is found in the new format string
		if ( _promptFormat.indexOf( "[prompt]" ) < 0 )
		{
			// TODO: Log error with the logging framework, or just use trace?
			//trace( "PromptingTextInput warning: prompt format does not contain [prompt] replacement code." );	
		}
		
		invalidateDisplayList();
	}
	
	// ==============================================================
	//	text
	// ==============================================================
	
	
	/**
	 * Override the behavior of text so that it doesn't take into account
	 * the prompt.  If the prompt is displaying, the text is just an empty
	 * string.
	 */
	[Bindable]
	override public function get text():String
	{
		// If the text has changed
		if ( _textEmpty )
		{
			// Skip the prompt text value
			return "";
		}
		else
		{
			return super.text;
		}
	}
	
	override public function set text( value:String ):void
	{
		_textEmpty = value.length == 0;
		super.text = value;
		invalidateDisplayList();
	}
	
	// ==============================================================
	//	overriden methods
	// ==============================================================
	
	/**
	 * @private
	 * 
	 * Determines if the prompt needs to be displayed.
	 */
	override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
	{
		// If the text is empty and a prompt value is set and the
		// component does not currently have focus, then the component
		// needs to display the prompt
		if ( _textEmpty && _prompt != "" && !_currentlyFocused )
		{
			if ( _promptFormat == "" )
			{
				super.text = _prompt;
			} 
			else
			{
				super.htmlText = _promptFormat.replace( /\[prompt\]/g, _prompt );
			}
		}
		
		super.updateDisplayList( unscaledWidth, unscaledHeight );
	}
	
	// ==============================================================
	//	event handlers
	// ==============================================================
	
	/**
	 * @private
	 */
	protected function handleChange( event:Event ):void
	{
		_textEmpty = super.text.length == 0;
	}
	
	/**
	 * @private
	 * 
	 * When the component recevies focus, check to see if the prompt
	 * needs to be cleared or not.
	 */
	protected function handleFocusIn( event:FocusEvent ):void
	{
		_currentlyFocused = true;
		
		// If the text is empty, clear the prompt
		if ( _textEmpty )
		{
			super.htmlText = "";
			// KLUDGE: Have to validate now to avoid a bug where the format 
			// gets "stuck" even though the text gets cleared.
			validateNow();
		}
	}
	
	/**
	 * @private
	 * 
	 * When the component loses focus, check to see if the prompt needs
	 * to be displayed or not. 
	 */
	protected function handleFocusOut( event:FocusEvent ):void
	{
		_currentlyFocused = false;
		
		// If the text is empty, put the prompt back
		invalidateDisplayList();
	}


} // end class
} // en package