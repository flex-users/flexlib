package flexlib.scheduling.scheduleClasses.lineRenderer
{
	import flash.display.Graphics;
	import mx.graphics.Stroke;
	
	public class Line
	{
		private var _weight : Number;
		private var _color : uint;
		private var _alpha : Number;
		
		public function get weight() : Number
		{
			return _weight;
		}
		public function set weight( value : Number ) : void
		{
			_weight = value;
		}
		
		public function get color() : uint
		{
			return _color;
		}
		public function set color( value : uint ) : void
		{
			_color = value;
		}	
			
		public function get alpha() : Number
		{
			return _alpha;
		}		
		public function set alpha( value : Number ) : void
		{
			_alpha = value;
		}
		
		public function apply( g : Graphics ) : void
		{
			g.lineStyle( weight, color, alpha );
		}
	}
}