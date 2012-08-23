	// ShortStrawJS, a javascript implementation
	// http://www.lab4games.net/zz85/blog/2010/01/21/geeknotes-shortstrawjs-fast-and-simple-corner-detection/
	//
	// Derived heavily from the AS3 implementation of the ShortStraw Corner Finder (Wolin et al. 2008)
	// by Felix Raab. 21 July 2009.
	// http://www.betriebsraum.de/blog/2009/07/21/efficient-gesture-recognition-and-corner-finding-in-as3/
	//
	// Based on the paper ShortStraw: A Simple and Effective Corner Finder for Polylines
	// http://srlweb.cs.tamu.edu/srlng_media/content/objects/object-1246294647-350817e4b0870da27e16472ed36475db/Wolin_SBIM08.pdf
	//
	// For comments on this JS port, email Joshua Koo (zz85nus @ gmail.com)
	//
	// Released under MIT license: http://www.opensource.org/licenses/mit-license.php
	
	var shortStraw = function(points){
		shortStraw.DIAGONAL_INTERVAL = 40;
		shortStraw.STRAW_WINDOW = 3;
		shortStraw.MEDIAN_THRESHOLD = 0.65;
		shortStraw.LINE_THRESHOLD = 0.99;
		
		// 1. get resample spacing.
		var s = shortStraw.determineResampleSpacing(points);		
		
		// 2. get resample points.
		var resampled = shortStraw.resamplePoints(points, s);
		
		// 3. get corners
		var corners = shortStraw.getCorners(resampled);
		//debug(corners);
		
		var cornerPoints = [];
			for (var i in corners) {
				cornerPoints.push(resampled[corners[i]]);
			}
			// debug(cornerPoints);
		
		//4. return corners.
		return cornerPoints;
	};
	
	
	shortStraw.determineResampleSpacing = function(points) {
            var b = shortStraw.boundingBox(points);
            var p1 = {x:b.x, y:b.y}; // topleft
            var p2 = {x:b.x + b.w, y:b.y + b.h};// bottomRight
            var d = shortStraw.distance(p1, p2);
            return d / shortStraw.DIAGONAL_INTERVAL;
        }
        
        shortStraw.resamplePoints = function(points,s) {	
        	var distance = 0;
        	var resampled = [];
        	resampled.push(points[0]);
        	for (var i=1; i<points.length; i++) {
        		var p1 = points[i-1];
        		var p2 = points[i];
        		var d2 = shortStraw.distance(p1,p2);
        		// This resampling algorithm was described in $1 paper
        		if ((distance+d2) >= s) {
        			var qx = 
        				p1.x + ((s - distance) /d2) *
        				(p2.x - p1.x);
				var qy = 
        				p1.y + ((s - distance) /d2) *
        				(p2.y - p1.y);
				var q = {x:qx, y:qy};
				resampled.push (q);
				points.splice(i, 0, q);
				distance= 0;
        		} else {
        			distance += d2; // Add path distance to total distance
        		}
        	} // End the loop and return resampled points
        	return resampled;
        }
        
        shortStraw.getCorners = function (points) {
        	
        	var corners = [0];
        	var w = shortStraw.STRAW_WINDOW;
        	var straws = [];
        	var i;
        	for (i=w; i<points.length-w; i++) {
        		straws[i] = (shortStraw.distance(points[i-w],points[i+w]));
        		// The AS3 implemention starts from index 0 while this
        		// as with the paper starts with index w
        		// Both works
        	}
        	
        	var t = shortStraw.median(straws) * shortStraw.MEDIAN_THRESHOLD;
        	
        	for (i=w; i<points.length-w; i++) {
        		if ( straws[i] < t) { 
        			var localMin =  Number.POSITIVE_INFINITY;
        			var localMinIndex = i;
        			while (i < straws.length && straws[i] < t) {
        				if (straws[i] < localMin) {
					    localMin = straws[i];
					    localMinIndex = i;
					}
					i++;
					
				    }
				    corners.push(localMinIndex);
			}
        	}
        	corners.push(points.length - 1);
        	corners = shortStraw.postProcessCorners(points, corners, straws);
        	return corners;
        }
        
        shortStraw.postProcessCorners = function(points, corners, straws) {
        	var go = false;
        	var i, c1,c2;
        	while(!go) {
        		go = true;
        		for (i=1;i<corners.length;i++) {
        			c1 = corners[i-1];
        			c2 = corners[i];
        			if (!shortStraw.isLine(points, c1, c2)) {
        				var newCorner =
        					shortStraw.halfwayCorner(straws, c1, c2);
					// This checking was not in the paper,
					// but prevents adding undefined points
					if (newCorner > c1 && newCorner < c2) {
						corners.splice(i,0,newCorner);
						go = false;
					}
        			}
        		}
        	}
        	
        	for (i = 1; i < corners.length - 1; i++) {
			c1 = corners[i - 1];
			c2 = corners[i + 1];
			if (this.isLine(points, c1, c2)) {
			    corners.splice(i, 1);
			    i--;
			}
		}
		return corners;
        }
        
        shortStraw.halfwayCorner = function(straws,a,b) {
        	var quarter = (b - a) / 4;
		var minValue = Number.POSITIVE_INFINITY;
		var minIndex;
		var w = shortStraw.STRAW_WINDOW;
		for (var i = a + quarter; i < (b - quarter); i++) {
			//var s = straws[i - w];
			if (straws[i] < minValue) {
			    minValue = straws[i];
			    minIndex = i;
			}
		}
		return minIndex;
        }
               
        shortStraw.boundingBox = function(points) {
		var minX = Number.POSITIVE_INFINITY;
		var maxX = Number.NEGATIVE_INFINITY;
		var minY = Number.POSITIVE_INFINITY;
		var maxY = Number.NEGATIVE_INFINITY;
		for (var i in points) {
			var p = points[i];
			if (p.x < minX) {
			    minX = p.x;
			}
			if (p.x > maxX) {
			    maxX = p.x;
			}
			if (p.y < minY) {
			    minY = p.y;
			}
			if (p.y > maxY) {
			    maxY = p.y;
			}
		}
		return {x:minX, y:minY, w:maxX - minX,h:maxY - minY};
        }
        
        shortStraw.distance = function (p1, p2) {
        	var dx = p2.x - p1.x;
        	var dy = p2.y - p1.y;
        	return Math.pow((dx*dx + dy*dy), 1/2);
        }
	
        shortStraw.isLine = function(points, a, b) {
		var distance = shortStraw.distance(points[a], points[b]);
		var pathDistance = shortStraw.pathDistance(points, a, b);
		return (distance / pathDistance) > shortStraw.LINE_THRESHOLD;
        }
	
	
	shortStraw.pathDistance = function(points, a, b) {
		var d = 0;
            for (var i= a; i < b; i++) {
                d += shortStraw.distance(points[i], points[i + 1]);
            }
            return d;
        }
        
         
        shortStraw.median = function(values) {
            var s = values.concat();
            s.sort();
            var m;
            if (s.length % 2 == 0) {
                m = s.length / 2;
                return (s[m - 1] + s[m]) / 2;
            } else {
                m = (s.length + 1) / 2;
                return s[m - 1];
            }
        }
        
        /*
	function debug(o) {
		alert(JSON.stringify(o));
	}*/
