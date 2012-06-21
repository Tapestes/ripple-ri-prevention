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


#import "DebugMapView.h"

@implementation DebugMapView

@synthesize coordinate;
@synthesize boundingMapRect;

const double SPEED_TO_KNOTS = 1.9438444924406;
const double METERS_TO_FEET = 3.2808399;
#define MAPRAD2DEG(radians) (radians * 57.2957795) // radians * 180 over pi
#define MAPPI 3.141592653589793
#define MAPDEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void) setupMap:(Airport*)airport  {
        
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self; // send loc updates to myself	
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];

    
    mapView.mapType = MKMapTypeHybrid;
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MKUserTrackingModeNone;
    mapView.delegate = self;
    

    CLLocationCoordinate2D coord = {.latitude=airport.location.coordinate.latitude, .longitude=airport.location.coordinate.longitude};
    MKCoordinateSpan span = {.latitudeDelta=0.005, .longitudeDelta=0.005};
    MKCoordinateRegion region = {coord, span};
    [mapView setRegion:region animated:TRUE];

    
    CLLocationCoordinate2D annotationCoord;
    
    annotationCoord.latitude = airport.location.coordinate.latitude;
    annotationCoord.longitude = airport.location.coordinate.longitude;
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
    annotationPoint.title = airport.airportCode;
    annotationPoint.subtitle = airport.airportCode;
    [mapView addAnnotation:annotationPoint]; 
    
    for(Runway* runway in airport.runways) {
        int counter = 0;
        int size = [runway.vertices count];
        
        CLLocationCoordinate2D coords[size];
        for(CLLocation* loc in runway.vertices) {
            CLLocationCoordinate2D coord = {loc.coordinate.latitude, loc.coordinate.longitude};
            coords[counter++] = coord;
        }
        
        MKPolyline* line = [MKPolyline polylineWithCoordinates:coords count:size];
        [mapView addOverlay:line];
    }
    
    
}

- (MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *aView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
    
    //aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
    aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
    
    aView.lineWidth = 5;
    
    return aView;
    
}



- (void) showView {
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    self.hidden = NO;
}

- (IBAction) closeview:(id)sender {
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    self.hidden = YES;
}

- (void)mapView:(MKMapView *)mkMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //mapView.centerCoordinate = userLocation.location.coordinate;
} 

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
	currentLocation = newLocation;	
    if(oldLocation != nil) {
        lastCalculatedHeading = (int) round(MAPRAD2DEG([self bearingInRadiansFromLocation:oldLocation toLocation:currentLocation ]));
                
        if(lastCalculatedHeading >= 360) {
            lastCalculatedHeading =  lastCalculatedHeading - 360;
        }

    }

    
    latLabel.text = [NSString stringWithFormat:@"Lat: %f", currentLocation.coordinate.latitude];
    lonLabel.text = [NSString stringWithFormat:@"Lon: %f", currentLocation.coordinate.longitude];
    altLabel.text = [NSString stringWithFormat:@"Alt: %.2f ft", (currentLocation.altitude*METERS_TO_FEET)];
    gpsAccLabel.text = [NSString stringWithFormat:@"GPS Acc: %.1f m", currentLocation.horizontalAccuracy];
    hdgLabel.text = [NSString stringWithFormat:@"Course: %d", lastCalculatedHeading];
    spdLabel.text = [NSString stringWithFormat:@"Speed: %.1f kn/hr", (currentLocation.speed * SPEED_TO_KNOTS)];
}

- (double)bearingInRadiansFromLocation:(CLLocation *)startLocation toLocation:(CLLocation *)endLocation {		
	if((startLocation == nil) || (endLocation == nil))
		return 0;
	
	double lat1 = MAPDEG2RAD(startLocation.coordinate.latitude);
	double lon1 = MAPDEG2RAD(startLocation.coordinate.longitude);
	double lat2 = MAPDEG2RAD(endLocation.coordinate.latitude);
	double lon2 = MAPDEG2RAD(endLocation.coordinate.longitude);
	double dLon = lon2 - lon1;
	double y = sin(dLon) * cos(lat2);
	double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
	double bearing = atan2(y, x) + (2 * MAPPI);
	// atan2 works on a range of -π to 0 to π, so add on 2π and perform a modulo check
	if (bearing > (2 * MAPPI)) {
		bearing = bearing - (2 * MAPPI);
	}
    
	
	return bearing;
	
}

- (void)newAlert:(NSString*) alertType atLocation:(CLLocation*)loc withHeading:(double)heading onRunway:(NSString*) runwayName {
 
    if((![alertType isEqualToString:@"0"]) || (![alertType isEqualToString:@"100"])) { 
        if(lastAlert == nil) {
            
            CLLocationCoordinate2D annotationCoord;
            
            annotationCoord.latitude = loc.coordinate.latitude;
            annotationCoord.longitude = loc.coordinate.longitude;
            
            lastAlert = [[MKPointAnnotation alloc] init];
            lastAlert.coordinate = annotationCoord;
            lastAlert.title = [self getAlert:alertType];
            lastAlert.subtitle = [NSString stringWithFormat: @"Heading: %.0f\nRunway: %@", heading, runwayName];
            [mapView addAnnotation:lastAlert]; 
            
        } else {
            CLLocationCoordinate2D annotationCoord;
            
            annotationCoord.latitude = loc.coordinate.latitude;
            annotationCoord.longitude = loc.coordinate.longitude;
            
            lastAlert.coordinate = annotationCoord;
            lastAlert.title = [self getAlert:alertType];
            lastAlert.subtitle = [NSString stringWithFormat: @"Heading: %.0f Runway: %@", heading, runwayName];
            
        }
    }
}

- (NSString*) getAlert:(NSString*) alert {
    if([alert isEqualToString:@"1"]) {
        return @"HOLD SHORT";
    } else if([alert isEqualToString:@"2"]) {
        return @"CROSSING";
    } else if([alert isEqualToString:@"3"]) {
        return @"APPROACHING";
    } else if([alert isEqualToString:@"4"]) {
        return @"WRONG RUNWAY";
    } else if([alert isEqualToString:@"5"]) {
        return @"BAD ACCURACY";
    } else if([alert isEqualToString:@"6"]) {
        return @"TOO FAST";
    }
    return @"";
}

@end
