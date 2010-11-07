/*
Copyright (c) 2010 FlexLib Contributors.  See:
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
package flexlib.charts.utils
{
    import flash.display.Graphics;
    import flash.geom.Point;
    
    /**
     * This utility is used to help with geometry.  All angles are specified in Radians.
     */ 
    public class GeomUtils
    {
        /**
         * The number of degrees in a radian
         */  
        public static const DEG_TO_RAD:Number = 57.2957795;
        
        public function GeomUtils()
        {
        }
        
        /**
         * This function is used to get the angle closest to the specified angle which is smaller
         * then the specified angle from the list of angles passed in.
         * 
         * @param angle:Number The angle to use as a benchmark
         * @param angles:Array The angles to search through
         * 
         * @returns The angle closest in size to the specified angle that is not larger then the specified angle
         */ 
        public static function getNextSmallestAngle(angle:Number,angles:Array):Number
        {
            var max:Number = Number.NEGATIVE_INFINITY;
            var retVal:Number = NaN;
            for each(var a:Number in angles)
            {
                if(a > max)
                    max = a;
                
                if(a < angle)
                {
                    if(isNaN(retVal))
                    {
                        retVal = a;    
                    }
                    else if(a > retVal)
                    {
                        retVal = a;
                    }
                }
            }
            
            if(isNaN(retVal))
                retVal = max - (360/GeomUtils.DEG_TO_RAD);
            
            return retVal;
        }
        
        /**
         * This function is used to get the angle closest to the specified angle which is larger
         * then the specified angle from the list of angles passed in.
         * 
         * @param angle:Number The angle to use as a benchmark
         * @param angles:Array The angles to search through
         * 
         * @returns The angle closest in size to the specified angle that is larger then the specified angle
         */ 
        public static function getNextLargestAngle(angle:Number,angles:Array):Number
        {
            var min:Number = Number.POSITIVE_INFINITY;
            var retVal:Number = NaN;
            for each(var a:Number in angles)
            {
                if(a < min)
                    min = a;
                
                if(angle < a )
                {
                    if(isNaN(retVal))
                    {
                        retVal = a;    
                    }
                    else if(a < retVal)
                    {
                        retVal = a;
                    }
                }
            }
            
            if(isNaN(retVal))
                retVal = min + (360/GeomUtils.DEG_TO_RAD);
            
            return retVal;
        }
        
        /**
         * This function is used to determine if the angle passed in is between the min and the max.
         * 
         * @param angle:Number The angle to use as a benchmark
         * @param min:Number The smaller angle
         * @param max:Number The larger angle
         * 
         * @returns true if the angle is between false if not.
         */ 
        public static function angleBetween(angle:Number,min:Number,max:Number):Boolean
        {
            angle = windDownAngle(angle);
            min = windDownAngle(min);
            max = windDownAngle(max);
            
            if(Math.abs(min - max) < .01)
            {
                min -= 360/DEG_TO_RAD;
                max += 360/DEG_TO_RAD;    
            }
            
            if(min > max)
            {
                max += 360/DEG_TO_RAD;
                
                if(min > angle)
                {
                    angle += 360/DEG_TO_RAD;
                }
            }
            
            //trace(min * DEG_TO_RAD + " " + angle * DEG_TO_RAD + " " + max * DEG_TO_RAD);
            return min < angle && angle < max;
        }
        
        /**
         * This function calculates the point specified as a function of the center point an angle and the circles radius
         * 
         * @param center:Point The center of the circle
         * @param angle:Number The angle which the point lays on
         * @param radius:Number The distance from the center that the point is
         * 
         * @return The point which fits the parameters
         */ 
        public static function calcPoint(center:Point, angle:Number, radius:Number):Point
        {
            var retVal:Point = new Point();
            retVal.x = radius * Math.sin(angle) + center.x;
            retVal.y = radius * Math.cos(angle) + center.y;
            return retVal;
        }
        
        /**
         * This function calculates the angle between two points. 
         * 
         * @param a:Point The first point
         * @param b:Point The second point
         * 
         * @return The angle
         */ 
        public static function calcAngle(a:Point,b:Point):Number
        {
            var angle:Number;
            
            // first check to avoid division by 0 errors
            if (Math.abs(b.x - a.x) < 2)
            {
                // this seems backwards, but remember the origin is in the upper left
                if (b.y < a.y)
                    angle = 270/DEG_TO_RAD;
                else 
                    angle = 90/DEG_TO_RAD;
            }
            else 
            {
                angle = Math.atan((b.y - a.y) / (b.x - a.x));
                
                if (b.x < a.x)
                    angle = 180/DEG_TO_RAD + angle;
                else if (b.y < a.y)
                    angle = 360/DEG_TO_RAD + angle;
            }
            
            angle = 360/DEG_TO_RAD - angle + 90/DEG_TO_RAD; 
            
            angle = windDownAngle(angle)
            return angle;
        }
        
        /**
         * This function takes any angle greater then 360 degrees and winds it down to be between 0 and 360 degrees
         * 
         * @param angle:Number The angle to reduce
         * @returns The reduced angle
         */ 
        public static function windDownAngle(angle:Number):Number
        {
            while(angle > 360/DEG_TO_RAD)
            {
                angle -= 360/DEG_TO_RAD;
            }
            
            return angle
        }
        
        
        /**
         * This function draws a smooth arc between the start and end angle starting at the specified point
         * 
         * @param graphics:Graphics The graphics to draw into
         * @param a:Point The start point of the angle
         * @param radius:Number The radius of the arc
         * @param startAngle:Number The angle to start at
         * @param endAngle:Number The angle to stop at
         */ 
        public static function drawArc(graphics:Graphics,a:Point, radius:Number, startAngle:Number, endAngle:Number):void
        {
            if (endAngle <= startAngle)
                endAngle += 360/DEG_TO_RAD;
            
            var step:Number = Math.max(.01,(endAngle - startAngle)/50);
            
            for (var i:Number=startAngle; i <= endAngle + .01; i = i + step)
            {
                var ourX:Number = a.x + radius*Math.sin(i);
                var ourY:Number = a.y + radius*Math.cos(i); 
                
                graphics.lineTo(ourX, ourY);
            }
        }
    }
}