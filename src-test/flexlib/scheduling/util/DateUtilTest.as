package flexlib.scheduling.util
{
	import flexunit.framework.Assert;

	public class DateUtilTest
	{
		[Test]
		public function checkValues() : void
		{
			/*
			public static const MINUTE_IN_MILLISECONDS : Number = 60 * 1000;
			public static const HOUR_IN_MILLISECONDS : Number = 60 * 60 * 1000;
			public static const DAY_IN_MILLISECONDS : Number = 24 * 60 * 60 * 1000;
			public static const WEEK_IN_MILLISECONDS : Number = 7 * 24 * 60 * 60 * 1000;
			public static const MONTH_IN_MILLISECONDS : Number = 30 * 24 * 60 * 60 * 1000;
			public static const YEAR_IN_MILLISECONDS : Number = 12 * 30 * 24 * 60 * 60 * 1000;
			public static const CENTURY_IN_MILLISECONDS : Number = 100 * 12 * 30 * 24 * 60 * 60 * 1000;
			public static const MILLENIUM_IN_MILLISECONDS : Number = 1000 * 100 * 12 * 30 * 24 * 60 * 60 * 1000;
			*/
			Assert.assertTrue( DateUtil.MINUTE_IN_MILLISECONDS == (60 * 1000) )
		}

	}
}