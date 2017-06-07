//
//  MathAdditions.c
//  Zmanim
//
//  Created by Moshe Berman on 3/24/11.
//  Copyright 2011 MosheBerman.com. All rights reserved.
//

#include "MathAdditions.h"

//
//  A utility function for converting degrees to radians
//

double toRadians(double degrees){
    return degrees * kMyPI / 180.0;
}

//
//  A utility function for converting radians to degrees
//

double toDegrees(double radians){
    return radians * 180.0 / kMyPI;
}

/**
 * sin of an angle in degrees
 */

double sinDeg(double deg) {
    return sin(deg * 2.0 * kMyPI / 360.0);
}

/**
 * acos of an angle, result in degrees
 */
 double acosDeg(double x) {
    return acos(x) * 360.0 / (2 * kMyPI);
}

/**
 * asin of an angle, result in degrees
 */

 double asinDeg(double x) {
    return asin(x) * 360.0 / (2 * kMyPI);
}

/**
 * tan of an angle in degrees
 */
 double tanDeg(double deg) {
    return tan(deg * 2.0 * kMyPI / 360.0);
}

/**
 * cos of an angle in degrees
 */
 double cosDeg(double deg) {
    return cos(deg * 2.0 * kMyPI / 360.0);
}