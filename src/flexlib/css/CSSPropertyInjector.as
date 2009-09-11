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
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleClient;
import mx.styles.StyleManager;
import mx.utils.ObjectUtil;

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
     *  The style names of the CSSDeclarations to inject from.
     */
    public function get styleNames() : Object 
    {
        return __styleNames;
    }
    public function set styleNames( val : Object ) : void
    {
        if ( val == null || ( !( val is Array ) && !( val is String ) ) ) return;
        
        if ( val is Array )
        {
            __styleNames = val as Array;
         }
         else if ( val is String )
         {
             __styleNames = ( val as String ).split( "," );
         }
     
        __styleNamesChanged = true;
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
             ( __styleName != null || __styleNames != null ) &&  
             ( __targetChanged == true || __targetsChanged == true ||
               __styleNameChanged == true || __styleNamesChanged == true ) )
        {
            if ( __styleNameChanged == true || __styleNamesChanged == true )
            {
                getCSSStyleDeclarations();
            }
            
            __targetChanged = __targetsChanged = __styleNameChanged = false;
            
            applyStyles();
        }
    }
    
    /**
     *  @protected
     * 
     *  Loads the CSSStyleDeclarations from the StyleManager.
     */
    protected function getCSSStyleDeclarations() : void
    {
        __cssStyleDeclarations = [];
        if ( styleName != null )
        {
            __cssStyleDeclarations.push( getCSSStyleDeclaration( styleName ) );
        }
        
        if ( styleNames != null )
        {
            for each ( var name : String in styleNames )
            {
                __cssStyleDeclarations.push( getCSSStyleDeclaration( name ) );
            }
        }
    }
    
    /**
     *  @protected
     * 
     *  Loads the CSSStyleDeclaration from the StyleManager.
     */
    protected function getCSSStyleDeclaration( styleName : String ) : CSSStyleDeclaration
    {
        var cssStyleDeclaration : CSSStyleDeclaration = null;
        cssStyleDeclaration = StyleManager.getStyleDeclaration( styleName );
        
        if ( cssStyleDeclaration == null )
        {
            cssStyleDeclaration = StyleManager.getStyleDeclaration( "." + styleName );
        }
        
        return cssStyleDeclaration;
    }
    
    /**
     *  @protected
     *  
     *  Applies the style values in __cssStyleDeclaration to the target object(s)
     */
    protected function applyStyles() : void
    {
        var styles : Array = []; 
        var styleObj : Object = null;
        
        for each ( var cssStyleDeclaration : CSSStyleDeclaration in __cssStyleDeclarations )
        {
            styleObj = {};
            
            if ( cssStyleDeclaration.factory != null ) 
            {
                cssStyleDeclaration.factory.apply( styleObj );
            }    
            if ( cssStyleDeclaration.defaultFactory != null )
            {
                cssStyleDeclaration.defaultFactory.apply( styleObj );
            }
            
            var temp : Array = ObjectUtil.getClassInfo( styleObj ).properties as Array;
            for ( var propName : String in styleObj ) 
            {
                styles.push( propName );
            }
            
            trace( styles, "\n" );
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
        var cssStyleDeclaration : CSSStyleDeclaration = null;
        var val : * = undefined;
        
        for each ( var style : String in styles )
        {
            for each ( cssStyleDeclaration in __cssStyleDeclarations )
            {
                //  Look for a value for [style] in the CSSStyeDeclaration
                if ( cssStyleDeclaration.getStyle( style ) != null )
                {
                    val = cssStyleDeclaration.getStyle( style );
                }
                //  If the CSSStyeDeclaration lookup is null.. Look for a 
                //  default value on the CSSPropertyInjector
                else if ( this[ style ] != null )
                {
                    val = this[ style ];
                }
                
                //  If there is a property, assign the value
                if ( target.hasOwnProperty( style ) )
                {
                    target[ style ] = val;
                }
                //  If there is no property and target is a UIComponent 
                //  set the value as a style.
                else if ( target is IStyleClient )
                {
                   ( target as IStyleClient ).setStyle( style, val );
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
    
    protected var __styleNames : Array = null;
    protected var __styleNamesChanged : Boolean = false;
    
    protected var __cssStyleDeclarations : Array = [];
    
} //  end class
} //  end package

