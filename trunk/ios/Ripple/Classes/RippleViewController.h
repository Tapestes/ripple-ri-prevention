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
#import "GPSManager.h"
#import "AirportManager.h"
#import "Airport.h"
#import "AirportMapView.h"
#import "HeaderView.h"
#import "FooterView.h"
#import "InfoTableViewController.h"
#import "SetDepartureRunwayView.h"
#import "GPSAccuracyView.h"
#import "LoadingView.h"
#import "SlidingDrawerView.h"
#import "AlertManager.h"
#import "AlertView.h"
#import "MiniAlertView.h"
#import "AlertRecord.h"
#import "AppDelegate.h"
#import "BetaFeedbackView.h"
#import "TaxiView.h"
#import "TaxiDisplay.h"
#import "DebugMapView.h"

@interface RippleViewController : UIViewController <GPSManagerDelegate, UIAlertViewDelegate, AlertManagerDelegate, AlertViewDelegate, MiniAlertViewDelegate, SetDepartureRunwayDelegate, TaxiViewDelegate> {
    
    GPSManager* gpsManager;
    AlertManager* alertManager;
    AirportManager* airportManager;
    Airport* airport;
    NSString* departureRunway;
    BOOL airportNotFound;

    IBOutlet AirportMapView* airportMapView;
    IBOutlet HeaderView* headerView;
    IBOutlet FooterView* footerView;
    IBOutlet LoadingView* loadingView;
    IBOutlet GPSAccuracyView* gpsView;
    IBOutlet SlidingDrawerView* slidingView;
    IBOutlet SetDepartureRunwayView* setRunwayView;
	IBOutlet AlertView* alertView;
	IBOutlet MiniAlertView* miniAlertView;
    IBOutlet TaxiDisplay* taxiDisplay;
    IBOutlet DebugMapView* debugMapView;
    

    BetaFeedbackView* betaFeedbackView;
    InfoTableViewController* infoViewController;
	UIAlertView* legalView;
	UIAlertView* noAirportFoundView;
    AlertRecord* currentAlert;
    TaxiView* taxiView;

}

@property (retain) HeaderView* headerView;

- (void) infoButtonHit;
- (void) updateDepartureButton;
- (void) beginApp;
- (void) showDisclaimer;
- (void) showDebugMap;
    

@end
