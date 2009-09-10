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

package flexlib.css
{
import flash.utils.describeType;

import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

/**
 *  A utility to dynamically inject values from CSSStyleDeclarations into a target 
 *  object.
 * 
 *  NOTE: This code is being developed and has not be thoroughly tested... 
 *        Also, changes to a CSSStyleDeclaration are not being handled
 *  
 *  @author Adam Flater
 */ 
public dynamic class CSSPropertyInjector
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */    
    public function CSSPropertyInjector()
    {
        super();
    }
    

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  Uses introspection to determine the properties of the target object. These
     *  properties are used in place of <code>styles</code>.
     */    
    public function get useIntrospection() : Boolean 
    {
        return __useIntrospection;
    }
    public function set useIntrospection( val : Boolean ) : void
    {
        __useIntrospection = val;
        __useIntrospectionChanged = true;
        invalidateProperties();
    }
    
    /**
     *  The target object to apply the CSS values to.
     */
    public function get target() : Object 
    {
        return __target;
    }
    public function set target( val : Object ) : void
    {
        __target = val;
        __targetChanged = true;
        invalidateProperties();
    }

    /**
     *  The target objects to apply the CSS values to.
     */
    public function get targets() : Array 
    {
        return __targets;
    }
    public function set targets( val : Array ) : void
    {
        __targets = val;
        __targetsChanged = true;
        invalidateProperties();
    }

    /**
     *  The style name of the CSSDeclaration to inject from.
     */
    public function get styleName() : String 
    {
        return __styleName;
    }
    public function set styleName( val : String ) : void
    {
        __styleName = val;
        __styleNameChanged = true;
        invalidateProperties();
    }

    /**
     *  A set of styles to read from the CSSStyleDeclration and set on the target(s). If
     *  useIntrospection is true, these are ignored. 
     * 
     *  Note: it is much more efficient to specify a set of styles and set 
     *  useIntrospection to false.
     */
    public function get styles() : Array 
    {
        return __styles;
    }
    public function set styles( val : Array ) : void
    {
        __styles = val;
        __stylesChanged = true;
        invalidateProperties();
    }


    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Added to adhere to the framework lifecycle naming convention. Just calls 
     *  commitProperties().
     */    
    public function invalidateProperties() : void
    {
        commitProperties();
    }
    
    /**
     *  @protected
     * 
     *  Applies the injection when all the required properties have been committed. 
     */
    protected function commitProperties() : void
    {
        //  if at least target or targets is set as well as styleName
        //  and styles.. and one of these values has changed... 
        //  the style declaration is retreived and applied
        if ( ( __target != null || __targets != null ) && 
             ( __styles != null || __useIntrospection == true ) &&
             __styleName != null &&  
             ( __targetChanged == true || __targetsChanged == true ||
               __styleNameChanged == true || __stylesChanged == true ) )
        {
            if ( __styleNameChanged == true )
            {
                getCSSStyleDeclaration();
            }
            
            __targetChanged = __targetsChanged = __styleNameChanged = __stylesChanged = false;
            
            applyStyles();
        }
    }
    
    /**
     *  @protected
     * 
     *  Loads the CSSStyleDeclaration from the StyleManager.
     */
    protected function getCSSStyleDeclaration() : void
    {
        __cssStyleDeclaration = StyleManager.getStyleDeclaration( styleName );
        
        if ( __cssStyleDeclaration == null )
        {
            __cssStyleDeclaration = StyleManager.getStyleDeclaration( "." + styleName );
        }
    }
    
    /**
     *  @protected
     *  
     *  Applies the style values in __cssStyleDeclaration to the target object(s)
     */
    protected function applyStyles() : void
    {
        var styles : Array = this.styles;
        
        if ( useIntrospection == true )
        {
            var description : XML = describeType( target );
            var propNames : Array = [];
            for each ( var accessor : XML in description.accessor )
            {
                propNames.push( accessor.@name.toString() );
            }
            for each ( var variable : XML in description.variable )
            {
                propNames.push( variable.@name.toString() );
            }
            styles = propNames;
        }
        
        if ( target != null )
        {
            assignStylesToTarget( styles, this.target );
        }
        
        if ( targets != null )
        {
            for each ( var target : Object in targets )
            {
                assignStylesToTarget( styles, target );
            }
        }
    }
    
    /**
     *  @protected
     * 
     *  Assigns a set of styles to a target object
     */
    protected function assignStylesToTarget( styles : Array, target : Object ) : void
    {
        for each ( var style : String in styles )
        {
            if ( target.hasOwnProperty( style ) )
            {
                //  Look for a value for [style] in the CSSStyeDeclaration
                if ( __cssStyleDeclaration.getStyle( style ) != null )
                {
                    target[ style ] = __cssStyleDeclaration.getStyle( style );
                }
                //  If the CSSStyeDeclaration lookup is null.. Look for a 
                //  default value on the CSSPropertyInjector
                else if ( this[ style ] != null )
                {
                    target[ style ] = this[ style ];
                }
            }
        }
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    protected var __target : Object = null;
    protected var __targetChanged : Boolean = false;
    
    protected var __targets : Array = null;
    protected var __targetsChanged : Boolean = false;
    
    protected var __styleName : String = null;
    protected var __styleNameChanged : Boolean = false;
    
    protected var __styles : Array = null;
    protected var __stylesChanged : Boolean = false;
    
    protected var __useIntrospection : Boolean = true;
    protected var __useIntrospectionChanged : Boolean = false;
    
    protected var __cssStyleDeclaration : CSSStyleDeclaration = null;
    
} //  end class
} //  end package

