////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package flexlib.controls
{

  import flexlib.controls.sliderClasses.ExtendedSlider;

  import mx.controls.sliderClasses.SliderDirection;

  //--------------------------------------
  //  Styles
  //--------------------------------------

  /**
   *  The location of the data tip relative to the thumb.
   *  Possible values are <code>"left"</code>, <code>"right"</code>,
   *  <code>"top"</code>, and <code>"bottom"</code>.
   *
   *  @default "left"
   */
  [Style(name="dataTipPlacement", type="String", enumeration="left,top,right,bottom", inherit="no")]

  //--------------------------------------
  //  Excluded APIs
  //--------------------------------------

  [Exclude(name="direction", kind="property")]

  //--------------------------------------
  //  Other metadata
  //--------------------------------------

  [DefaultBindingProperty(source="value", destination="labels")]

  [DefaultTriggerEvent("change")]

  [IconFile("VSlider.png")]

  /**
   *  An alternative to the VSlider control included in the Flex framework. This
   *  version of the VSlider allows you to drag the region between the thumbs, if
   *  the slider has mutliple thumbs. If there is more than one thumb then the region
   *  between the topmost thumb and the bottommost thumb is draggable.
   *
   *  <p>To use this control an enable the draggable regions between the thumbs you
   *  need to set the <code>thumbCount</code> to something greater than 1, otherwise
   *  this control will work exactly like the original VSlider.</p>
   *
   *  @mxml
   *
   *  <p>The <code>&lt;flexlib:VSlider&gt;</code> tag inherits all of the tag attributes
   *  of its superclass, and adds the following tag attribute:</p>
   *
   *  <pre>
   *  &lt;flexlib:VSlider
   *    <strong>Styles</strong>
   *    dataTipPlacement="top"
   *  /&gt;
   *  </pre>
   *  </p>
   *
   *  @see mx.controls.VSlider
   *  @see flexlib.controls.HSlider
   *  @see flexlib.baseClasses.SliderBase
   */
  public class VSlider extends ExtendedSlider
  {
    //include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function VSlider()
    {
      super();

      direction = SliderDirection.VERTICAL;
    }
  }

}
