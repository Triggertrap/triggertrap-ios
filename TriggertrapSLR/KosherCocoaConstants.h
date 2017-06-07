//
//  KosherCocoaConstants.h
//  Zmanim
//
//  Created by Moshe Berman on 3/24/11.
//  Copyright 2011 MosheBerman.com. All rights reserved.
//


//
//
//

#ifndef kKosherCocoaConstants
#define kKosherCocoaConstants

/* ------------ Zenith constants --------------- */

#define kZenithGeometric 90.0

#define kZenithCivil 96.0

#define kZenithNautical 102.0

#define kZenithAstronomical 108.0

//  These zeniths are defined in the ZmanimCalendar in KosherCocoa

#define kZenithSixteenPointOne (kZenithGeometric + 16.1)

#define kZenithEightPointFive (kZenithGeometric + 8.5)

/* ---- Astronomical Constants --- */

#define kDegreesPerHour (360.0 / 24.0)

#define kSolarRadius (16.0/60.0)

#define kRefraction (34.0/60.0)

#define kEarthRadius 6356.9

/* --- Complex Zmanim Constants --- */

#define kZenithThreePointSeven kZenithGeometric + 3.7

#define kZenithFivePointNinetyFive kZenithGeometric + 5.95

#define kZenithSevenPointZeroEightThree kZenithGeometric + 7 + (5/60)

#define kZenithTenPointTwo kZenithGeometric + 10.2

#define kZenithElevenDegrees kZenithGeometric + 11

#define kZenithElevenPointFive kZenithGeometric + 11.5

#define kZenithThirteenDegrees kZenithGeometric + 13

#define kZenithThirteenPointTwentyFourDegrees kZenithGeometric + 13.24

#define kZenithNineteenPointEight kZenithGeometric + 19.8

#define kZenithTwentySix kZenithGeometric + 26.0

#define kZenithFourPointThirtySeven kZenithGeometric + 4.37 

#define kZenithFourPointSixtyOne kZenithGeometric + 4.61

#define kZenithFourPointEight kZenithGeometric + 4.8

#define kZenithThreePointSixtyFive kZenithGeometric + 3.65

#define kZenithFivePointEightyEight kZenithGeometric + 5.88


/* ------------------------ GeoLocation Constants ----------------------- */

#define kDistance 0
#define kInitialBearing 1
#define kFinalBearing 2

/* ---------------------- Calculation Type Constants ---------------------- */

//
//  Used in the calculation methods to determine which
//  calculation we are performing. (They're essentially 
//  a boolean flag, but here it's expressed as a pair of 
//  ints.)
//

#define kTypeSunrise 0
#define kTypeSunset 1

/* --------------------- Time Constants ---------------------- */

#define kMillisecondsInAMinute 60 * 1000

#define kMillisecondsInAnHour kMillisecondsInAMinute * 60

//
//	These constants are used for determining
//	day offsets from a given date. These constants
//	make the code more readable and easier to maintain.
//

//How many seconds are in a minute (integer)
#define kSecondsInAMinute 60

//How many minutes are in an hour
#define kMinutesInAnHour 60

//how many hours are in a day
#define kHoursInADay 24

//How many seconds are in an hour 
#define kSecondsInAnHour (kSecondsInAMinute * kMinutesInAnHour)

//The number of seconds in a day
#define kSecondsInADay (kSecondsInAMinute * kMinutesInAnHour * kHoursInADay)

//The number of seconds in a thirty day month
#define kSecondsInSolarYear kSecondsInADay * 365

#endif