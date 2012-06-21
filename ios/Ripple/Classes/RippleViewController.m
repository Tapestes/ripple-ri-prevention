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



#import "RippleViewController.h"

@implementation RippleViewController

@synthesize headerView;

NSString* legalMessage = @"Do not attempt to configure this application or input information while in the runway environment or at any time during which doing so inhibits your situation awareness on the airport surface. Your failure to pay full attention to the operation of your aircraft could result in death, serious injury, or property damage. Reminders provided by this application may not be accurate. Participation in this beta test does not relieve you from the requirements contained in FAR 91.13, FAR 91.21, or any other applicable regulatory requirements. You assume all risk and responsibility of using or relying on this application.\n\nDo you agree with these terms in order to use this app?";

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    if([AppDelegate sharedAppDelegate].expired) {
        return;
    }
	
	NSString* legalAcceptance = [[NSUserDefaults standardUserDefaults] stringForKey:@"LegalAcceptance"];
	if(![legalAcceptance isEqualToString:@"YES"]) {
		[self performSelector:@selector(showDisclaimer) withObject:nil afterDelay:0.1];
	} else {
		[self beginApp];	
	}
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) gpsUpdated:(CLLocation*) location withHeading:(double)heading {
    if(airportNotFound == TRUE) {
        return;
    }
    
    if(airport == nil) {
        airportManager.initialLocation = location;
        airport = [airportManager findClosestAirportToLocation:location];
        if(airport != nil) {
            NSLog(@"My airport: %@", airport.airportCode);
            [headerView configureAirport:airport];

            [airportMapView showAirportMap:airport.imagePath ];
            [setRunwayView updateAirport:airport];
            
            [slidingView updateAirport:airport];
            [slidingView openDrawer];

            
            [loadingView.spinner stopAnimating];
            loadingView.hidden = YES;
            [debugMapView setupMap:airport];


        } else {
            //NSLog(@"Airport not found!");
            if(airportNotFound == FALSE) {
                airportNotFound = TRUE;
                noAirportFoundView = [[UIAlertView alloc] initWithTitle:@"No Airport Found!" message:@"It appears that you are trying to use the Ripple App, but are not located at an airport. You must be within 5 miles of an airport in order for the application to work correctly.\n\nPlease continue by choosing an option below." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Contact MITRE", @"Exit", nil];
            
                [noAirportFoundView show];			
            }
        }
    } else {
        [alertManager checkForAlert:location withHeading:heading atAirport:airport withCurrentDepartureRunway:departureRunway];
        
    }
    
}

- (void) toggleSetDepartureView {
	setRunwayView.hidden = !setRunwayView.hidden;
}

- (void) infoButtonHit {
    NSLog(@"Info button hit");
	if(infoViewController == nil) {
		infoViewController = [[InfoTableViewController alloc] initWithNibName:@"InfoTableViewController" bundle:nil];
		infoViewController.delegate = self;
        [self.view addSubview:infoViewController.view];
	}
    
    infoViewController.view.hidden = NO;
    
    //[self performSegueWithIdentifier:@"showInfoView" sender:self];
    
	//[self.navigationController pushViewController:infoViewController animated:YES];
	//self.navigationController.navigationBar.hidden = NO;
    
    //[self presentViewController:infoViewController animated:YES completion:NULL];
}

- (void) taxiButtonHit {
    NSLog(@"Taxi button hit");
	if(taxiView == nil) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"TaxiView"
                                                          owner:self
                                                        options:nil];
        
        TaxiView* myView = [ nibViews objectAtIndex: 0];
		taxiView = myView;
        [taxiView setupButtonCallBacks];
        [taxiView setupRunways:airport departureRunway:departureRunway];

        taxiView.delegate = self;
        taxiView.taxiDelegate = self;
        [taxiDisplay setupCallbacks];
        [self.view addSubview:taxiView];
	} else {
        [taxiView setRunwayName:departureRunway];
    }
    
    [taxiView showView];
    
}

- (void) taxiPathChanged:(NSString *)text {
    [taxiDisplay taxiPathChanged:text];
    
}

- (void) setDepartureRunway:(NSString *) s {
    if(![s isEqualToString:departureRunway]) {
        departureRunway = s;
        //NSLog(@"DepartureRunway: %@", departureRunway);
        [self updateDepartureButton];	
    }
}

- (void) updateDepartureButton {
	[headerView setDepartureRunwayName:departureRunway];
    [setRunwayView verifyDepartureRunway:departureRunway];
    [taxiView setRunwayName:departureRunway];
}

- (void) beginApp {    
    
    departureRunway = @"";
	self.view.backgroundColor = [ UIColor blackColor ];
	airportNotFound = FALSE;
    loadingView.label.hidden = NO;
    [loadingView.spinner startAnimating];
    
    currentAlert = [[AppDelegate sharedAppDelegate] getAlertRecord];    

    gpsManager = [[GPSManager alloc] init];
    gpsManager.delegate = self;
    airportManager = [[AirportManager alloc] init];
    airport = nil;

    alertManager = [[AlertManager alloc] init];
    alertManager.viewDelegate = self;
    alertManager.gpsManager = gpsManager;
    
    headerView.delegate = self;
    footerView.delegate = self;
	[footerView setupInfoButtonCallBack];
    
    setRunwayView.delegate = self;
	setRunwayView.hidden = YES;
    
    slidingView.headerView = headerView;
    miniAlertView.delegate = self;
	alertView.delegate = self;
    [gpsView.locationManager startUpdatingLocation];
    
	betaFeedbackView = [[BetaFeedbackView alloc] initWithFrame:CGRectMake(0, 360, 320, 60)];
	betaFeedbackView.hidden = YES;
	betaFeedbackView.alert = currentAlert;
	//[self.view addSubview:betaFeedbackView];
    
    
}

- (void) showDisclaimer {
	legalView = [[UIAlertView alloc] initWithTitle:@"Legal Disclaimer" message:legalMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
	[legalView show];	
}

- (void)alertView : (UIAlertView *)alertView1 clickedButtonAtIndex : (NSInteger)buttonIndex
{
	if(alertView1 == legalView) {
		if(buttonIndex == 1) {
			exit(0);
		} else {
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"LegalAcceptance"];
			[self beginApp];
		}
	} else if(alertView1 == noAirportFoundView) {
	
        if(buttonIndex == 0) {
			//NSString* msg = [currentAlert sendReport:@""];
			
			//dataSentView = [[UIAlertView alloc] initWithTitle:@"Upload Saved Data" message:msg delegate:self cancelButtonTitle:@"Close App" otherButtonTitles:nil];			
			//[dataSentView show];			
			
		//} else if(buttonIndex == 1) {
			NSString *emailIDString = @"mailto:ripple@mitre.org";
			if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailIDString]]) {
			}
		} else if(buttonIndex == 1) {
			exit(0);			
		}
    } 
    
    /*else if(alertView1 == dataSentView) {
		exit(0);		
       
	}
       */
}

- (void)newAlert:(NSString*) alertType atLocation:(CLLocation*)currentLocation withHeading:(double)heading onRunway:(NSString*) runwayName {
    //NSLog(@"rvc: new alert %@,%@", alertType, runwayName);
    
    int prox = [alertType intValue];
    [alertView setAlert:prox onRunway:runwayName];
    [miniAlertView setAlert:prox];
    
    if((prox == 0) && (currentAlert.activeAlert)) {
        [currentAlert closeAlertWithLocation:currentLocation heading:heading reason:1];
        betaFeedbackView.hidden = YES;
    } else if((prox != 100) && (prox != 0)) {
        if(currentAlert.activeAlert) {
            [currentAlert closeAlertWithLocation:currentLocation heading:heading reason:0];
        }
        
        [currentAlert reset];
        [currentAlert startAlertWithAlertType:prox airportCode:airport.airportCode runwayName:runwayName location:currentLocation heading:heading];
        //betaFeedbackView.hidden = NO;
        
        [debugMapView newAlert:alertType atLocation:currentLocation withHeading:heading onRunway: runwayName];
    }
     
}

- (void) showMiniAlert {
	alertView.hidden = YES;
	miniAlertView.hidden = NO;
}

- (void) showMaxAlert {
	alertView.hidden = NO;
	miniAlertView.hidden = YES;	
}

- (void) updateSliderForRunway:(NSString*) runwayName withState:(RunwayState) state {
    [slidingView setSliderForRunway:runwayName withState:state];
    
}

-(void) showDebugMap {
    [debugMapView showView];
}



@end
