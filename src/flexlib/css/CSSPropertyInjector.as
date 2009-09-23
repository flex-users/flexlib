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
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.binding.utils.BindingUtils;
import mx.events.FlexEvent;
import mx.events.StateChangeEvent;
import mx.events.StyleEvent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleClient;
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
	protected static const TARGET : String = "target";
	protected static const STYLENAME : String = "styleName";
	protected static const STYLENAMES : String = "styleNames";
	
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

	public static function loadStyleDeclarations( url : String, update : Boolean = false,
						                          trustContent : Boolean = false,
						                          applicationDomain : ApplicationDomain = null,
						                          securityDomain : SecurityDomain = null 
						                        ) : IEventDispatcher
	{
		var dispatcher : IEventDispatcher =
			StyleManager.loadStyleDeclarations( 
				url, update, trustContent, 
				applicationDomain, securityDomain 
			);
		
		dispatcher.addEventListener( 
			StyleEvent.COMPLETE, 
			CSSPropertyInjector.handleStyleEventComplete 
		);
		
		return dispatcher;
	}
	
	protected static function handleStyleEventComplete( event : StyleEvent ) : void
	{
		dispatcher.dispatchEvent( event.clone() );
	}
	
	protected static var dispatcher : EventDispatcher = null;
	{
		dispatcher = new EventDispatcher();
	}


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
        
        CSSPropertyInjector.dispatcher.addEventListener( 
        	StyleEvent.COMPLETE, 
			this.handleStyleEventComplete, 
        	false, 0, true 
        );
    }
    

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  The target object to apply the CSS values to.
     */
    public function get state() : String 
    {
        return __state;
    }
    public function set state( val : String ) : void
    {
        __state = val;
        __stateChanged = true;
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

	protected function handleStyleEventComplete( event : StyleEvent ) : void
	{
		__styleNameChanged = true;
		
		invalidateProperties();
	}

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
    	if ( __stateChanged == true )
    	{
    		__stateChanged = false;
    		
    		applyStyles( state );
    	}
    	
    	var skinnableComponentType : Class = null;
    	try
    	{
    		skinnableComponentType = getDefinitionByName( "flex.core.SkinnableComponent" ) as Class; 
	    	if ( __targetChanged == true && target is skinnableComponentType )
	    	{
	    		if ( target.skin == null ) 
	    		{
	    			target.addEventListener( 
	    				FlexEvent.CREATION_COMPLETE, function( event : FlexEvent ) : void
							{
								event.target.skin.addEventListener( StateChangeEvent.CURRENT_STATE_CHANGE, handleCurrentStateChange );
							}
					);
	    		}
	    		else
	    		{
		    		target.skin.addEventListener( 
		    			StateChangeEvent.CURRENT_STATE_CHANGE, 
		    			handleCurrentStateChange 
					);
		    	}
	    	} 
    	}
    	catch( error : Error ) {}
    	
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
                buildAggregateMappings();
            }
            
            __targetChanged = __targetsChanged = __styleNameChanged = false;
            
            applyStyles();
        }
    }
    
    protected function handleCurrentStateChange( event : StateChangeEvent ) : void
    {
    	applyStyles( event.newState );
    }
    
    /**
     *  @protected
     * 
     *  Loads the CSSStyleDeclarations from the StyleManager.
     */
    protected function getCSSStyleDeclarations() : void
    {
    	__pseudoSelectors = new Dictionary();
        __cssStyleDeclarations = [];
        
        if ( styleName != null && getCSSStyleDeclaration( styleName ) != null )
        {
            __cssStyleDeclarations.push( getCSSStyleDeclaration( styleName ) );
        }
        
        if ( styleNames != null )
        {
            for each ( var name : String in styleNames )
            {
                if ( getCSSStyleDeclaration( name ) != null )
                {
                    __cssStyleDeclarations.push( getCSSStyleDeclaration( name ) );
                }
            }
        }
        
        var isTargetIStyleClient : Boolean = target is IStyleClient;
        
        if ( isTargetIStyleClient == false && targets != null )
        {
        	for each ( var obj : Object in targets )
        	{
        		isTargetIStyleClient = obj is IStyleClient;
        		if ( isTargetIStyleClient == true ) break;
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
        
        if ( cssStyleDeclaration == null )
        {
        	var qualClassName : String = null;
        	if ( target != null )
        	{
	        	qualClassName = getQualifiedClassName( target ).split( "::" ).join( "." );
				cssStyleDeclaration = StyleManager.getStyleDeclaration( 
											qualClassName + 
									   	    ( styleName.charAt( 0 ) == "." ? "" : "." ) + 
									   	    styleName 
								   	  );
			}
			
			if ( targets != null && cssStyleDeclaration == null )
			{
				for each ( var target : Object in targets )
				{
		        	qualClassName = getQualifiedClassName( target ).split( "::" ).join( "." );
					cssStyleDeclaration = StyleManager.getStyleDeclaration( 
												qualClassName + 
										   	    ( styleName.charAt( 0 ) == "." ? "" : "." ) + 
										   	    styleName 
									   	  );
									   	  
					if ( cssStyleDeclaration != null ) break;
				}
			}
        }
        
		var pseudoName : String = null;
		for each ( var selector : String in StyleManager.selectors )
		{
			pseudoName = null;
			
			//  Flex 4
			if ( selector.indexOf( styleName + ":" ) != -1  )
			{
				pseudoName = selector.split( ":" )[ 1 ];
				if ( __pseudoSelectors[ pseudoName ] == null ) __pseudoSelectors[ pseudoName ] = [];	
				__pseudoSelectors[ pseudoName ].push( StyleManager.getStyleDeclaration( selector ) );
			}
			
			// Flex 3
			else if ( selector.indexOf( styleName ) != -1 )
			{
				pseudoName = selector.substr( selector.indexOf( styleName ) + styleName.length );
				pseudoName = pseudoName.toLowerCase();
			}
			
			if ( pseudoName != null )
			{
				if ( __pseudoSelectors[ pseudoName ] == null ) __pseudoSelectors[ pseudoName ] = [];	
				__pseudoSelectors[ pseudoName ].push( StyleManager.getStyleDeclaration( selector ) );
			}
		}
        
        return cssStyleDeclaration;
    }

    /**
     *  @protected
     * 
     *  Builds the dictionaries that map the aggregate selectors and pseudo selectors
     */
    protected function buildAggregateMappings() : void
    {
    	__aggregateStyles = createAggregateMapping( __cssStyleDeclarations );

    	__aggregatePseudoMappings = new Dictionary();
    	
    	var mapping : Dictionary = null;
    	for ( var key : String in __pseudoSelectors )
    	{
    		mapping = createAggregateMapping( __pseudoSelectors[ key ] as Array );
    		__aggregatePseudoMappings[ key ] =  mapping;
    	}
    	
    	return;
    }
    
    /**
     *  @protected
     * 
     *  Aggregates a set of CSSStyleDeclarations into a dictionary mapping
     */
    protected function createAggregateMapping( cssStyleDeclarations : Array ) : Dictionary 
    {
    	var styles : Array = null;
    	var mapping : Dictionary = new Dictionary();
    	
    	for each ( var styleDec : CSSStyleDeclaration in cssStyleDeclarations )
    	{
    		styles = getStyles( styleDec );
    		for each ( var style : String in styles )
    		{
    			mapping[ style ] = styleDec.getStyle( style );
    		}
    	}
    	
    	return mapping;
    }
    
    /**
     *  @protected
     *  
     *  Applies the style values in __cssStyleDeclaration to the target object(s)
     */
    protected function applyStyles( state : String = null ) : void
    {
        if ( this.target != null )
        {
            assignStylesToTarget( this.target, state );
        }
        
        if ( targets != null )
        {
            for each ( var target : Object in targets )
            {
                assignStylesToTarget( target, state );
            }
        }
    }
    
    /**
     *  @protected
     * 
     *  Returns a set of style names for a given CSSStyleDeclaration.
     * 
     *  NOTE: This only works for CSS that is compiled into the app as it relies on the proto
     *        chaining mechanism.
     */
    protected function getStyles( cssStyleDeclaration : CSSStyleDeclaration, arr : Array = null ) : Array 
    {
        var styleObj : Object = {};
        var ret : Array = ( arr != null ? arr : [] );
        
        if ( cssStyleDeclaration.factory != null ) 
        {
            cssStyleDeclaration.factory.apply( styleObj );
        }    
        if ( cssStyleDeclaration.defaultFactory != null )
        {
            cssStyleDeclaration.defaultFactory.apply( styleObj );
        }
        
        for ( var propName : String in styleObj ) 
        {
            ret.push( propName );
        } 
        
        return ret;   	
    }
    
    /**
     *  @protected
     * 
     *  Assigns a set of styles to a target object
     */
    protected function assignStylesToTarget( target : Object, state : String = null,
    										 styles : Dictionary = null ) : void
    {
        var val : * = undefined;
        
        if ( styles == null ) styles = __aggregateStyles;
        
        for ( var key : String in __aggregateStyles )
        {
        	val = styles[ key ];
        	
            //  If the CSSStyeDeclaration lookup is null.. Look for a 
            //  default (overriding) value on the CSSPropertyInjector
            if ( this[ key ] != null )
            {
                val = this[ key ];
            }
            
        	var propName : String = null;
        	var injector : CSSPropertyInjector = null;
        	
            //  If there is a property, assign the value
            if ( target.hasOwnProperty( key ) && target[ key ] != val )
            {
        		target[ key ] = val;
            }
            
        	else if ( key.indexOf( STYLENAMES ) == 0 )
        	{
        		propName = key.substr( STYLENAMES.length, 1 ).toLowerCase() + key.substr( STYLENAMES.length+1 );
        		injector = new CSSPropertyInjector();
        		BindingUtils.bindProperty( injector, TARGET, target, propName );
        		injector.styleNames = val;
        	}     
            
        	else if ( key.indexOf( STYLENAME ) == 0 )
        	{
        		propName = key.substr( STYLENAME.length, 1 ).toLowerCase() + key.substr( STYLENAME.length+1 );
        		injector = new CSSPropertyInjector();
        		BindingUtils.bindProperty( injector, TARGET, target, propName );
        		injector.styleName = val;
        	}
        	
            //  If there is no property and target is an IStyleClient 
            //  set the value as a style.
            else if ( target is IStyleClient )
            {
               ( target as IStyleClient ).setStyle( key, val );
            }
        }
        
        if ( state != null )
        {
        	assignStylesToTarget( target, null, __aggregatePseudoMappings[ state ] ); 
        }
    
//		if ( target is UIComponent ) (target as UIComponent).invalidateDisplayList();
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
    
    protected var __state : String = null;
    protected var __stateChanged : Boolean = false;
    
    protected var __styleName : String = null;
    protected var __styleNameChanged : Boolean = false;
    
    protected var __styleNames : Array = null;
    protected var __styleNamesChanged : Boolean = false;
    
    protected var __cssStyleDeclarations : Array = [];
    protected var __pseudoSelectors : Dictionary = null;
    protected var __aggregateStyles : Dictionary = null;
    protected var __aggregatePseudoMappings : Dictionary = null;
    
} //  end class
} //  end package

