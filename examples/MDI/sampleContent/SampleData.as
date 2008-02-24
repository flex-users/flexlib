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
import mx.collections.ArrayCollection;

private function createSampleData():void
{
	var tmpData:Array = new Array(
							{rainfall: 4.72, high_temp: 58, low_temp: 46, month: 'Jan'},
							{rainfall: 4.15, high_temp: 61, low_temp: 49, month: 'Feb'},
							{rainfall: 3.40, high_temp: 62, low_temp: 49, month: 'Mar'},
							{rainfall: 1.25, high_temp: 65, low_temp: 50, month: 'Apr'},
							{rainfall: 0.54, high_temp: 65, low_temp: 51, month: 'May'},
							{rainfall: 0.13, high_temp: 68, low_temp: 53, month: 'Jun'},
							{rainfall: 0.04, high_temp: 68, low_temp: 54, month: 'Jul'},
							{rainfall: 0.09, high_temp: 69, low_temp: 56, month: 'Aug'},
							{rainfall: 0.28, high_temp: 71, low_temp: 56, month: 'Sep'},
							{rainfall: 1.19, high_temp: 70, low_temp: 55, month: 'Oct'},
							{rainfall: 3.31, high_temp: 64, low_temp: 51, month: 'Nov'},
							{rainfall: 3.18, high_temp: 59, low_temp: 47, month: 'Dec'}
						 );
	this.tmpDataCollection = new ArrayCollection(tmpData);
}
	
[Bindable] 
public var tmpDataCollection:ArrayCollection;