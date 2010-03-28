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
/*
   Class that provides Reset and Undo/Redo functionality for a Form
 */
package flexlib.containers
{

  import flash.events.*;
  import flash.ui.KeyLocation;
  import flash.ui.Keyboard;
  import flash.utils.describeType;

  import mx.containers.*;
  import mx.controls.*;
  import mx.core.Container;
  import mx.core.UIComponent;
  import mx.events.ValidationResultEvent;
  import mx.messaging.errors.MessagingError;
  import mx.validators.ValidationResult;
  import mx.validators.Validator;

  [IconFile("AdvancedForm.png")]

  /**
   *  The Advanced Form component provides Reset, Undo and Redo functionality.
   *
   *  <p>The Advanced Form component provides Reset, Undo and Redo functionality.
   * 	Undo and Redo are accessed by pressing "ctrl-Z" and "ctrl-Y" repsectively.</p>
   *
   *  @mxml
   *
   *  <pre>
   *  &lt;flexlib:AdvancedForm
   * 	  <strong>Properties</strong>
   * 	  undoHistorySize="5"
   * 	  modelType="shared|memory"
   *
   *    &gt;
   *    ...
   *      <i>child tags</i>
   *    ...
   *  &lt;/flexlib:AdvancedForm&gt;
   *  </pre>
   */
  public class AdvancedForm extends Form
  {

    //[Bindable]
    //public var debug:String = "";

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var noSnapshotFlag:Boolean = false;

    /**
     *  @private Key for reset snapshot
     */
    private var resetSnapshotKey:String = "reset";

    /**
     *  @private
     */
    private var undoCounter:int = 0;

    /**
     *  @private
     */
    private var undoCurrentIndex:int = -1;

    /**
     *  @private
     */
    private var modelStack:Object;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  validators
    //----------------------------------

    /**
     *  @private LookupTable of isValid flags
     */
    private var validators:Object;

    //----------------------------------
    //  undoHistorySize
    //----------------------------------

    /**
     *  @private
     */
    private var _undoHistorySize:int = 5;

    /**
     *  The undoHistorySize defaults the number of undos.
     *
     *  @default true
     */
    public function set undoHistorySize(value:int):void
    {
      _undoHistorySize = value;
    }

    public function get undoHistorySize():int
    {
      return _undoHistorySize;
    }

    //----------------------------------
    //  modelType
    //----------------------------------

    /**
     *  @private
     */
    private var _modelType:String = "shared";

    [Inspectable(category="General", enumeration="shared,memory", defaultValue="shared")]
    /**
     *  The modelStack handles the data.
     *
     *  @default true
     */
    public function set modelType(value:String):void
    {
      if (value == "shared")
      {

      }
      else
      {

      }
    }

    public function get modelType():String
    {
      return _modelType;
    }

    //----------------------------------
    //  isValid
    //----------------------------------

    /**
     *  Property that allows for one place to know if the From is valid
     *
     *  Default to true, if any Validators are present then it will be set to false
     */
    [Bindable]
    public var isValid:Boolean = true;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Resets values of the form
     */
    public function resetForm():void
    {
      var children:Array = this.getChildren();
      resetValues(children, resetSnapshotKey);
      undoCounter = 0;
      undoCurrentIndex = -1;
      modelStack = new Object();
      snapshotValues(this.getChildren(), resetSnapshotKey);
    }

    /**
     * @private
     */
    private function myKeyDownHandler(event:KeyboardEvent):void
    {

      if (event.ctrlKey && event.keyCode == 90 && !(event.target is NumericStepper))
      {
        event.stopPropagation();
        event.preventDefault()
        doUndo();

      }
      else if (event.ctrlKey && event.keyCode == 89 && !(event.target is NumericStepper))
      {
        doRedo();
      }
      else
      {
        super.keyDownHandler(event);
      }
    }

    /**
     * Creates snapshot of values for reseting
     */
    override protected function childrenCreated():void
    {
      super.childrenCreated();
      // Find Validators and add EventListeners
      parent.addEventListener("creationComplete", setValidatorListenerEvents);

      this.parent.addEventListener(KeyboardEvent.KEY_DOWN, myKeyDownHandler, false, 0, true);
    }

    /**
     * 	Loop through all Validtors at the same level as the Form and set a Event listener for Valid and Invalid
     */
    private function setValidatorListenerEvents(event:Event):void
    {
      // Take First Snapshot After All Children have been created
      snapshotValues(this.getChildren(), resetSnapshotKey);

      var container:Object = document;

      // Check parent control to make sure its capable of having children
      if (!(container is Container))
        return;

      // Describe Parent
      var classInfo:XML = describeType(container);

      // Reset Defaults
      validators = new Array();
      isValid = true;

      // Loop over all parentDocument's properties looking for Validators
      for each (var a:XML in classInfo..accessor)
      {
        try
        {
          if (container[a.@name] is Validator)
          {
            //Logger.debug( "setValidatorListenerEvents:Property is Validator: " + a.@name );

            // If Validator is found default to false
            isValid = false;

            var obj:Object = new Object();
            obj.reference = container[a.@name];
            obj.isValid = false;
            validators.push(obj);

            // Set Valid and Invalid week reference listeners on the Validators
            Validator(container[a.@name]).addEventListener(ValidationResultEvent.VALID, setValidFlag,
                                                           false, 0, true);
            Validator(container[a.@name]).addEventListener(ValidationResultEvent.INVALID, setValidFlag,
                                                           false, 0, true);
          }
        }
        catch (err:Error)
        {
          if (err.errorID != 1077)
          {
            //Logger.error( "AdvancedForm:setValidatorListenerEvents: " + err.message );
          }
        }
      }
    }

    /**
     * 	Handles all valid and invalid events on the validators
     */
    private function setValidFlag(event:ValidationResultEvent):void
    {
      var tmpFlag:Boolean = true;
      for (var i:int = 0; i < validators.length; i++)
      {
        if (validators[i].reference == event.target)
        {
          //Logger.debug( "setValidFlag:event.target: " + event.type );
          validators[i].isValid = (event.type == ValidationResultEvent.VALID);
        }
        tmpFlag = (tmpFlag && validators[i].isValid);
      }
      isValid = tmpFlag;
    }

    /**
     *
     */
    private function snapshotValues(obj:Object, snapshotKey:String):void
    {
      try
      {
        if (modelStack == null)
          modelStack = new Object();

        if (modelStack[snapshotKey] == null)
          modelStack[snapshotKey] = new Object();

        var snapshotModel:Object = modelStack[snapshotKey];

        for (var a:String in obj)
        {
          if (obj[a] is FormItem)
          {
            snapshotValues(obj[a].getChildren(), snapshotKey);
          }
          else
          {
            var tmpObj:Object = obj[a];

            var tmpID:String = tmpObj.toString();
            if (snapshotModel[tmpID] == undefined)
              snapshotModel[tmpID] = new Object();
            var value:Object;
            if (tmpObj is TextInput || tmpObj is TextArea)
              value = tmpObj.text;
            if (tmpObj is RadioButton || tmpObj is CheckBox)
              value = tmpObj.selected;
            if (tmpObj is ComboBox)
              value = tmpObj.selectedIndex;
            if (tmpObj is NumericStepper)
              value = tmpObj.value;

            if (tmpObj is TextInput || tmpObj is TextArea)
              UIComponent(tmpObj).addEventListener(FocusEvent.FOCUS_OUT, textInputChange);
            else
              UIComponent(tmpObj).addEventListener(Event.CHANGE, controlChange);

            snapshotModel[tmpID] = value;
          }
        }
      }
      catch (err:Error)
      {
        //Logger.error( "AdvancedForm:snapshotValues: " + err.message );
      }
    }

    /**
     * 	@private
     */
    private function textInputChange(event:FocusEvent):void
    {
      var snapshotModel:Object = getLastestSnapshot();
      var tmpKey:String = event.target.parent.toString();
      if (snapshotModel[tmpKey] == undefined)
      {
        //throw new Error( "Snapshot not defined for key = " + tmpKey );
      }
      if (snapshotModel[tmpKey] != event.target.parent.text)
      {
        takeSnapshot();
      }
    }

    /**
     * 	@private
     */
    private function controlChange(event:Event):void
    {
      if (event.target is RadioButton && !event.target.selected)
        takeSnapshot();
      if (!(event.target is RadioButton))
        takeSnapshot();

    }

    /**
     * 	@private
     */
    private function doUndo():void
    {
      //debug += "\ndoUndo: undoCurrentIndex: " + undoCurrentIndex + " undoCounter: " + undoCounter;
      noSnapshotFlag = true;
      var index:int = undoCurrentIndex - 1;
      if (index >= (undoCounter - 1 - undoHistorySize) && index > -2)
      {
        undoCurrentIndex--;
        //debug += "\ndoUndo: resetValues: " + undoCurrentIndex;
        resetValues(this.getChildren(), getSnapshotKey(undoCurrentIndex));

      }
      noSnapshotFlag = false;
    }

    /**
     * 	@private
     */
    private function doRedo():void
    {
      //debug += "\ndoRedo: undoCurrentIndex: " + undoCurrentIndex + " undoCounter: " + undoCounter;
      noSnapshotFlag = true;
      var index:int = undoCurrentIndex + 1;
      if (index < undoCounter)
      {
        undoCurrentIndex++;
        resetValues(this.getChildren(), getSnapshotKey(undoCurrentIndex));
      }
      noSnapshotFlag = false;
    }

    /**
     * 	@private
     */
    private function takeSnapshot():void
    {
      if (!noSnapshotFlag)
      {
        if (undoCurrentIndex < undoCounter - 1)
          undoCounter = undoCurrentIndex + 1;
        //debug += "\ntakeSnaphost: undoCurrentIndex: " + undoCurrentIndex + " undoCounter: " + undoCounter;
        snapshotValues(this.getChildren(), undoCounter + "");
        undoCurrentIndex = undoCounter;
        undoCounter++;
      }
    }

    /**
     * 	@private
     */
    private function getLastestSnapshot():Object
    {
      if (undoCurrentIndex > -1)
        return modelStack[undoCurrentIndex + ""];
      else
        return modelStack[resetSnapshotKey];
    }

    /**
     * 	@private
     */
    private function getSnapshotKey(coutner:int):String
    {
      if (coutner >= 0)
        return coutner + "";
      else
        return resetSnapshotKey;
    }

    /**
     *
     */
    private function resetValues(obj:Object, snapshotKey:String):void
    {
      if (modelStack[snapshotKey] == undefined)
        throw new Error("Invalid snapshot");

      // Disable all Validators
      try
      {
        for (var i:int = 0; i < validators.length; i++)
        {
          isValid = false;
          Validator(validators[i].reference).enabled = false;
          validators[i].isValid = false;
        }
      }
      catch (err:Error)
      {
        //Logger.error( "AdvancedForm:resetValues:Disabling Validators: " + err.message );
      }

      var snapshotModel:Object = modelStack[snapshotKey];

      for (var a:String in obj)
      {
        if (obj[a] is FormItem)
        {
          resetValues(obj[a].getChildren(), snapshotKey);
        }
        else
        {
          var tmpObj:Object = obj[a];

          var tmpID:String = tmpObj.toString();
          if (snapshotModel[tmpID] == undefined
            && (tmpObj is Container
            || (!(tmpObj is TextInput)
            && !(tmpObj is RadioButton)
            && !(tmpObj is ComboBox)
            && !(tmpObj is NumericStepper))
            ))
            continue;
          if (snapshotModel[tmpID] == undefined)
            throw new Error("Invalid obj in snapshot: " + tmpID);
          var value:Object;
          if (tmpObj is TextInput || tmpObj is TextArea)
            tmpObj.text = snapshotModel[tmpID];
          if (tmpObj is RadioButton || tmpObj is CheckBox)
            tmpObj.selected = snapshotModel[tmpID];
          if (tmpObj is ComboBox)
            tmpObj.selectedIndex = snapshotModel[tmpID];
          if (tmpObj is NumericStepper)
            tmpObj.value = snapshotModel[tmpID];
        }
      }

      // Enable all Validators
      try
      {
        for (i = 0; i < validators.length; i++)
        {
          Validator(validators[i].reference).enabled = true;
        }
      }
      catch (err:Error)
      {
        //Logger.error( "AdvancedForm:resetValues:Disabling Validators: " + err.message );
      }
    }

    /**
     * 	Gather references and defaults of all the children
     */
    private function strChildren(obj:Object):String
    {
      var str:String = "";
      for (var a:String in obj)
      {
        str += a + "=[" + obj[a] + "]\n";
      }
      return str;
    }


  }
}