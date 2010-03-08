package flexlib.scheduling.util
{
	
import flexunit.framework.Assert;

import org.flexunit.asserts.assertEquals;

public class DateUtilTest
{
	[Test]
	public function checkValues() : void
	{
		Assert.assertEquals( DateUtil.SECOND_IN_MILLISECONDS,  1000 )
		Assert.assertEquals( DateUtil.MINUTE_IN_MILLISECONDS,  60 * DateUtil.SECOND_IN_MILLISECONDS )
		Assert.assertEquals( DateUtil.HOUR_IN_MILLISECONDS, 60 * DateUtil.MINUTE_IN_MILLISECONDS )
		Assert.assertEquals( DateUtil.DAY_IN_MILLISECONDS, 24 * DateUtil.HOUR_IN_MILLISECONDS )	
		Assert.assertEquals( DateUtil.WEEK_IN_MILLISECONDS, 7 * DateUtil.DAY_IN_MILLISECONDS )
		Assert.assertEquals( DateUtil.MONTH_IN_MILLISECONDS, 30 * DateUtil.DAY_IN_MILLISECONDS )
		Assert.assertEquals( DateUtil.YEAR_IN_MILLISECONDS, 12 * DateUtil.MONTH_IN_MILLISECONDS )	
		Assert.assertEquals( DateUtil.CENTURY_IN_MILLISECONDS, 100 * DateUtil.YEAR_IN_MILLISECONDS )
			
//--> HMM?? Millenium is 1000 years, right? Had been set as 1000 * CENT			
		Assert.assertEquals( "Millenium is 1000 years", DateUtil.MILLENIUM_IN_MILLISECONDS, 1000 * DateUtil.YEAR_IN_MILLISECONDS )	
	}
	
	[Test]
	public function addTime() : void
	{
		var date:Date = new Date()
		var time:Number = 10 * DateUtil.SECOND_IN_MILLISECONDS
		var newDate:Date = DateUtil.addTime( DateUtil.copyDate(date), time ) 
			
		assertEquals( newDate.getTime() - date.getTime(), time )
	}
	
	[Test]
	public function copyDate_validDate_equalResults() : void
	{
		var date:Date = new Date()
		var copiedDate:Date = DateUtil.copyDate( date )	
		Assert.assertEquals( date.getTime(), copiedDate.getTime() )
	}
	
	[Ignore( "Not ready to test, as I have no idea what they're trying to accomplish!" )]
	[Test]
	public function setTime() : void
	{
		var date:Date = new Date()
		var time:Number = DateUtil.CENTURY_IN_MILLISECONDS	
		var newDate:Date = DateUtil.setTime( DateUtil.copyDate(date), time )	
		
		Assert.assertEquals( date.getTime(), newDate.getTime() + DateUtil.CENTURY_IN_MILLISECONDS )
	}
}
}