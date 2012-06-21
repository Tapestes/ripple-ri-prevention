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



#import "AlertManager.h"

#define PI 3.141592653589793
#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180
#define RAD2DEG(radians) (radians * 57.2957795) // radians * 180 over pi

@implementation AlertManager

const double MS_TO_KNOTS = 1.9438444924406;
const double M_TO_FEET = 3.2808399;
const double radius = 3440.07; // radius of the earth in nmi
const double threshold = 5;

@synthesize viewDelegate;
@synthesize gpsManager;

-(id)init {
    self = [ super init ];
	if (self != nil) {
        previousRunwayAlert = [[RunwayAlert alloc] init];
    }
    return self;
}

- (void)checkForAlert:(CLLocation*) location withHeading:(double)heading atAirport:(Airport*) airport withCurrentDepartureRunway:(NSString*) departureRunway {
    
    NSString* alertString = [self getAlertStringForLocation:location atAirport:airport withCurrentDepartureRunway:departureRunway];
    NSArray* alertPieces = [alertString componentsSeparatedByString:@","];
		
    NSString* alertType = [alertPieces objectAtIndex:0];
    NSString* runwayName = [alertPieces objectAtIndex:1];
		
    NSLog(@"alert: %@", alertString);
		        
    [viewDelegate newAlert:alertType atLocation:location withHeading:heading onRunway:runwayName];
	
}

- (NSString*) getAlertStringForLocation:(CLLocation*) location atAirport:(Airport*) airport withCurrentDepartureRunway:(NSString*) departureRunway {
    double speed = location.speed * MS_TO_KNOTS;    
    double acc = location.horizontalAccuracy * 3.2808399; //meters to feet
    
    if(acc > 50) {
        if(previousRunwayAlert.alertType == 5) {
            return @"100,null";
        } else {
            previousRunwayAlert.alertType = 5;   
            return @"5,null";
        }
    }
    
    if(speed > 25) {
        if(previousRunwayAlert.alertType == 6) {
            return @"100,null";
        } else {
            previousRunwayAlert.alertType = 6;   
            return @"6,null";
        }
    }

    double heading = gpsManager.lastCalculatedHeading;
    
    //NSLog(@"Current Calculated Heading: %f", heading);
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:0];
    BOOL readyForTakeoff = FALSE;
    BOOL isAlertFromSameRunway = FALSE;
    for(Runway* runway in airport.runways) {
        isAlertFromSameRunway = [previousRunwayAlert.runwayName isEqualToString:runway.name];
        if(runway.stateHasChanged) {
            runway.stateHasChanged = FALSE;
            if(isAlertFromSameRunway) {
                [previousRunwayAlert clearAlert];
            }
        }
        
        BOOL myRunway = FALSE;
        NSRange range = [runway.name rangeOfString:departureRunway];
        if((range.location != NSNotFound) && (range.length != 0)) {
            myRunway = TRUE;
        }
        
        //First Pass: Check if within a runway
        BOOL inside = [self isLocationInPoly:location onRunway:runway];
        if(inside) {
            if(![departureRunway isEqualToString:@""]) {
                if((myRunway) && (([self computeTrackAngleError:heading toAngle:runway.heading1] < 20) || ([self computeTrackAngleError:heading toAngle:runway.heading2] < 20))) {
                    readyForTakeoff = TRUE;
                    continue;
                } else if ((speed < 25) && (([self computeTrackAngleError:heading toAngle:runway.heading1] < 20) || ([self computeTrackAngleError:heading toAngle:runway.heading2] < 20))) {
                    readyForTakeoff = FALSE;
                    
                    RunwayAlert* alert = [[RunwayAlert alloc] init];
                    alert.alertType = 4;
                    alert.inside = TRUE;
                    alert.runwayName = runway.name;                    
                    
                    if(isAlertFromSameRunway && (previousRunwayAlert.alertType == 4)) {
                        alert.repeat = TRUE;
                    } else {						
                        alert.repeat = FALSE;
                    }
                    [array addObject:alert];
                    continue;
                }
            }
            
            if(runway.state == RunwayClearState) {
                RunwayAlert* alert = [[RunwayAlert alloc] init];
                alert.alertType = 2;
                alert.inside = TRUE;
                alert.runwayName = runway.name;
                
                if(isAlertFromSameRunway && (previousRunwayAlert.alertType == 2)) {
                    alert.repeat = TRUE;
                } else {						
                    alert.repeat = FALSE;
                }
                [array addObject:alert];
                continue;
            }
            
            if(runway.state == RunwayWatchedState) {
                RunwayAlert* alert = [[RunwayAlert alloc] init];
                alert.alertType = 1;
                alert.inside = TRUE;
                alert.runwayName = runway.name;
                
                if(isAlertFromSameRunway && (previousRunwayAlert.alertType == 1)) {
                    alert.repeat = TRUE;
                } else {						
                    alert.repeat = FALSE;
                }
                [array addObject:alert];
                continue;
            }
            
            if(runway.state == RunwayNeutralState) {
                RunwayAlert* alert = [[RunwayAlert alloc] init];
                alert.alertType = 3;
                alert.inside = TRUE;
                alert.runwayName = runway.name;
                
                if(isAlertFromSameRunway && (previousRunwayAlert.alertType == 3)) {
                    alert.repeat = TRUE;
                } else {						
                    alert.repeat = FALSE;
                }
                [array addObject:alert];
                continue;
            }
            
        }			
        
        
        //Second Pass
        CLLocation* futurePoint = [self futurePointFromLocation:location];
        int size = [runway.vertices count];
        int j = size - 1;
        for(int i=0; i < size; i++) {
            
            CLLocation* intersection = [self intersectionOfPointA:location pointB:futurePoint pointC:[runway.vertices objectAtIndex:j] pointD:[runway.vertices objectAtIndex:i]];
            if(intersection != nil)	{
                if(runway.state == RunwayWatchedState) {
                    if(runway.state == RunwayWatchedState) {
                        RunwayAlert* alert = [[RunwayAlert alloc] init];
                        alert.alertType = 1;
                        alert.inside = FALSE;
                        alert.runwayName = runway.name;
                        
                        if(isAlertFromSameRunway && (previousRunwayAlert.alertType == 1)) {
                            alert.repeat = TRUE;
                        } else {						
                            alert.repeat = FALSE;
                        }
                        [array addObject:alert];
                        continue;
                    }
                    
                } else if(runway.state == RunwayNeutralState) {
                    if(runway.state == RunwayNeutralState) {
                        RunwayAlert* alert = [[RunwayAlert alloc] init];
                        alert.alertType = 3;
                        alert.inside = FALSE;
                        alert.runwayName = runway.name;
                        
                        if(isAlertFromSameRunway && (previousRunwayAlert.alertType == 3)) {
                            alert.repeat = TRUE;
                        } else {						
                            alert.repeat = FALSE;
                        }
                        [array addObject:alert];
                        continue;
                    }
                } else if(runway.state == RunwayClearState) {
                    if(runway.state == RunwayClearState) {
                        RunwayAlert* alert = [[RunwayAlert alloc] init];
                        alert.alertType = 2;
                        alert.inside = FALSE;
                        alert.runwayName = runway.name;
                        
                        if(isAlertFromSameRunway && (previousRunwayAlert.alertType == 2)) {
                            alert.repeat = TRUE;
                        } else {						
                            alert.repeat = FALSE;
                        }
                        [array addObject:alert];
                        continue;
                    }
                    
                }
            }
            j = i;
        }
    }
    [previousRunwayAlert clearAlert];
    
    if(readyForTakeoff) {
        return @"0,null";
    }
    
    int alertCount = [array count];
    //NSLog(@"alert count: %d", alertCount);	
    
    if(alertCount == 0) {
        return @"0,null";
    } else {
        //for(int i=0; i < alertCount; i++) {
        //    RunwayAlert* a2 = [array objectAtIndex:i];
        //    NSLog(@"alertType: %d,%d,%@", a2.alertType, a2.inside, a2.runwayName);
        //}
        
        //Check for Wrong Runway
        for(int i=0; i < alertCount; i++) {
            RunwayAlert* a = [array objectAtIndex:i];
            previousRunwayAlert = a;
            if((a.alertType == 4) && (a.inside)) { 
                if(a.repeat) {
                    return [NSString stringWithFormat:@"100,%@", a.runwayName];
                } else {
                    return [NSString stringWithFormat:@"4,%@", a.runwayName];
                }
            }
        }
        
        //Check for HoldShort + outside
        for(int i=0; i < alertCount; i++) {
            RunwayAlert* a = [array objectAtIndex:i];
            previousRunwayAlert = a;
            if((a.alertType == 1) && !(a.inside)) { 
                if(a.repeat) {
                    return [NSString stringWithFormat:@"100,%@", a.runwayName];
                } else {
                    return [NSString stringWithFormat:@"1,%@", a.runwayName];
                }
            } else if ((a.alertType == 1) && (a.inside) && (a.repeat)) {
                return [NSString stringWithFormat:@"100,%@", a.runwayName];				
            }
        }
        

        //Check for Crossing + outside
        for(int i=0; i < alertCount; i++) {
            RunwayAlert* a = [array objectAtIndex:i];
            if((a.alertType == 2) && !(a.inside)) { 
                [previousRunwayAlert clearAlert];
                return @"0,null";
            }
        }
        
        //Check for Entering / No Clearance + outside
        for(int i=0; i < alertCount; i++) {
            RunwayAlert* a = [array objectAtIndex:i];
            previousRunwayAlert = a;
            if((a.alertType == 3) && !(a.inside)) { 
                if(a.repeat) {
                    return [NSString stringWithFormat:@"100,%@", a.runwayName];
                } else {
                    return [NSString stringWithFormat:@"3,%@", a.runwayName];
                }
            } else if ((a.alertType == 3) && (a.inside) && (a.repeat)) {
                return [NSString stringWithFormat:@"100,%@", a.runwayName];				
            }
        }
        
        //Check for Crossing + inside
        for(int i=0; i < alertCount; i++) {
            RunwayAlert* a = [array objectAtIndex:i];
            previousRunwayAlert = a;
            //NSLog(@"checking inside cross: %d,%d,%@", a.alertType, a.inside, a.runwayName);

            if((a.alertType == 2) && (a.inside)) { 
                if(a.repeat) {
                    return [NSString stringWithFormat:@"100,%@", a.runwayName];
                } else {
                    return [NSString stringWithFormat:@"2,%@", a.runwayName];
                }
            }
        }
    }
    [previousRunwayAlert clearAlert];
    return @"0,null";
}

-(BOOL) isLocationInPoly:(CLLocation*) location onRunway:(Runway*)runway {
	BOOL inside = FALSE;
	int polysides = runway.vertices.count;
	int j = polysides - 1;
	for(int i=0; i < polysides; i++) {
		CLLocation* iLoc = [runway.vertices objectAtIndex:i]; 
		CLLocation* jLoc = [runway.vertices objectAtIndex:j]; 
		
		double LATi = iLoc.coordinate.latitude;
		double LONi = iLoc.coordinate.longitude;
		double LATj = jLoc.coordinate.latitude;
		double LONj = jLoc.coordinate.longitude;
		double LAT = location.coordinate.latitude;
		double LON = location.coordinate.longitude;
        
		if (((LONi < LON) && (LONj >= LON)) || ((LONj < LON && LONi >= LON))) {			
			if ((LATi + (((LON - LONi) / (LONj - LONi)) * (LATj - LATi))) < LAT) {
				inside = !inside;
			}
		}
		
		j = i;
	}
	
	return inside;
}

-(double) computeTrackAngleError:(double)heading toAngle:(int)angle {
	double tke = heading - angle;
	return fabs(tke);
}

- (CLLocation*) futurePointFromLocation:(CLLocation*) currentLocation {
	
	double oldLat = currentLocation.coordinate.latitude * M_PI / 180; 
	double oldLon = currentLocation.coordinate.longitude * M_PI / 180; 
	
	double distance = ((currentLocation.speed * MS_TO_KNOTS) * (threshold / 3600)) * (M_PI / (180 * 60));
    double radial = (360 - gpsManager.lastCalculatedHeading) * (M_PI / 180);
	
	double newLat = asin((sin(oldLat) * cos(distance)) + (cos(oldLat) * sin(distance) * cos(radial)));
	double newLon;
	
	if(cos(newLat) == 0) {
		newLon = oldLon;
	} else {
		double y = oldLon - (asin(sin(radial) * sin(distance) / cos(newLat)) + M_PI);
		double x = 2 * M_PI;
		newLon = (y - x * floor(y / x)) - M_PI;
	}
	
	newLat = newLat * 180 / M_PI;
	newLon = newLon * 180 / M_PI;
	
	CLLocation* newLoc = [[CLLocation alloc] initWithLatitude:newLat longitude:newLon];
	return newLoc;
}

- (CLLocation*) intersectionOfPointA:(CLLocation*)pMe pointB:(CLLocation*)pFuture pointC:(CLLocation*)pOne pointD:(CLLocation*)pTwo {
    
	double A1 = pFuture.coordinate.longitude - pMe.coordinate.longitude;
	double B1 = pMe.coordinate.latitude - pFuture.coordinate.latitude;
	double C1 = A1 * pMe.coordinate.latitude + B1 * pMe.coordinate.longitude;
    
	double A2 = pTwo.coordinate.longitude - pOne.coordinate.longitude;
	double B2 = pOne.coordinate.latitude - pTwo.coordinate.latitude;
	double C2 = A2 * pOne.coordinate.latitude + B2 * pOne.coordinate.longitude;
	
	double det = A1 * B2 - A2 * B1;
	if(det == 0) {
		return nil;
	} else {
		double x = (B2 * C1 - B1 * C2) / det;
		double y = (A1 * C2 - A2 * C1) / det;
		
		if(fmin(pOne.coordinate.latitude, pTwo.coordinate.latitude) <= x &&
		   x <= fmax(pOne.coordinate.latitude, pTwo.coordinate.latitude) &&
		   fmin(pOne.coordinate.longitude, pTwo.coordinate.longitude) <= y &&
		   y <= fmax(pOne.coordinate.longitude, pTwo.coordinate.longitude) &&
		   fmin(pMe.coordinate.latitude, pFuture.coordinate.latitude) <= x &&
		   x <= fmax(pMe.coordinate.latitude, pFuture.coordinate.latitude) &&
		   fmin(pMe.coordinate.longitude, pFuture.coordinate.longitude) <= y &&
		   y <= fmax(pMe.coordinate.longitude, pFuture.coordinate.longitude)) {
			
			CLLocation* newLoc = [[CLLocation alloc] initWithLatitude:x longitude:y];
			return newLoc;
		} else {
			return nil;
		}
	}
}
    

@end
