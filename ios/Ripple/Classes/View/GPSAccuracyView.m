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

#import "GPSAccuracyView.h"


@implementation GPSAccuracyView

@synthesize gpsLabel;
@synthesize locationManager;

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.backgroundColor	= [UIColor blackColor];
		
		gpsLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(80, 3, 160, 14)];
		gpsLabel.text             = @"GPS Accuracy: N/A";
		gpsLabel.backgroundColor  = [UIColor clearColor];
		gpsLabel.font             = [UIFont boldSystemFontOfSize:11.0];
		gpsLabel.textColor		  = [UIColor whiteColor];
		gpsLabel.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		gpsLabel.shadowOffset     = CGSizeMake(1, 2);
		gpsLabel.textAlignment    = UITextAlignmentCenter;
		[self addSubview:gpsLabel];
		
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self; // send loc updates to myself	
	
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"Location: %@", [newLocation description]);
	
	double acc = newLocation.horizontalAccuracy * 3.2808399; //meters to feet
	gpsLabel.text = [NSString stringWithFormat:@"GPS Accuracy: %.0f ft", acc];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	//NSLog(@"Error: %@", [error description]);
}

@end
