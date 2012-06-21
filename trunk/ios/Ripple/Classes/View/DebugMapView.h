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



#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Airport.h"

@interface DebugMapView : UIView <MKMapViewDelegate, CLLocationManagerDelegate, MKOverlay> {
    IBOutlet MKMapView* mapView;
    IBOutlet UILabel* latLabel;
    IBOutlet UILabel* lonLabel;
    IBOutlet UILabel* altLabel;
    IBOutlet UILabel* spdLabel;
    IBOutlet UILabel* hdgLabel;
    IBOutlet UILabel* gpsAccLabel;
    IBOutlet UIButton* backButton;
    
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
    int lastCalculatedHeading;
    MKPointAnnotation *lastAlert;
}

- (void) showView;
- (IBAction) closeview:(id)sender;
- (void) setupMap:(Airport*) airport;

- (double)bearingInRadiansFromLocation:(CLLocation *)startLocation toLocation:(CLLocation *)endLocation;
- (void)newAlert:(NSString*) alertType atLocation:(CLLocation*)currentLocation withHeading:(double)heading onRunway:(NSString*) runwayName;

- (NSString*) getAlert:(NSString*) alert;


@end
