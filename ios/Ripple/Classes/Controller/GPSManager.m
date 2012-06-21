/*******************************************************************************
 * This is the copyright work of The MITRE Corporation, and was produced for the 
 * U. S. Government under Contract Number DTFAWA-10-C-00080, as well as subject 
 * to the Apache Licence, Version 2.0 dated January 2004. 
 * 
 * For further information, please contact The MITRE Corporation, Contracts Office, 
 * 7515 Colshire Drive, McLean, VA  22102-7539, (703) 983-6000.
 * 
 * Copyright 2011 The MITRE Corporation
 * 
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 * 
 *        http://www.apache.org/licenses/LICENSE-2.0
 * 
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 ******************************************************************************/



#import "GPSManager.h"

#define PI 3.141592653589793
#define MS_TO_KNOTS = 1.9438444924406;
#define M_TO_FEET = 3.2808399;

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180
#define RAD2DEG(radians) (radians * 57.2957795) // radians * 180 over pi


@implementation GPSManager

@synthesize lastCalculatedHeading;
@synthesize delegate;

-(id)init {
    self = [ super init ];
	if (self != nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self; // send loc updates to myself	
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        
        //NSLog(@"GPS Manager started");    
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
	lastLocation = oldLocation;
	currentLocation = newLocation;	
    if(oldLocation != nil) {
        lastCalculatedHeading = RAD2DEG([self bearingInRadiansFromLocation:lastLocation toLocation:currentLocation ]);
    }
    //NSLog(@"Old Location: %@", [oldLocation description]);
    //NSLog(@"Current Location: %@", [newLocation description]);
    //NSLog(@"Heading: %@", [manager heading]);
    //NSLog(@"Calculated Heading: %f", lastCalculatedHeading);
    
    if(oldLocation != nil)
        [delegate gpsUpdated:currentLocation withHeading:lastCalculatedHeading];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	//NSLog(@"Error: %@", [error description]);
}

- (double)bearingInRadiansFromLocation:(CLLocation *)startLocation toLocation:(CLLocation *)endLocation {		
	if((startLocation == nil) || (endLocation == nil))
		return 0;
	
	double lat1 = DEG2RAD(startLocation.coordinate.latitude);
	double lon1 = DEG2RAD(startLocation.coordinate.longitude);
	double lat2 = DEG2RAD(endLocation.coordinate.latitude);
	double lon2 = DEG2RAD(endLocation.coordinate.longitude);
	double dLon = lon2 - lon1;
	double y = sin(dLon) * cos(lat2);
	double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
	double bearing = atan2(y, x) + (2 * PI);
	// atan2 works on a range of -π to 0 to π, so add on 2π and perform a modulo check
	if (bearing > (2 * PI)) {
		bearing = bearing - (2 * PI);
	}
    
	
	return bearing;
	
}


@end
