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
#import "Airport.h"
#import "Runway.h"
#import "RunwaySliderView.h"
#import "HeaderView.h"
#import "HandleView.h"

@interface SlidingDrawerView : UIView {
	HandleView* handleView;
	UILabel* handleLabel;
	Airport* airport;
	
	UILabel* alertLabel;
	UILabel* alertCountLabel;
	UILabel* runwayLabel;
	UIImageView* runwayButtonView;
	HeaderView* headerView;
    
    NSMutableArray* runwaySliderViews;
	
}

@property (retain) HandleView* handleView;
@property (retain) UILabel* handleLabel;
@property (retain) Airport* airport;
@property (retain) UILabel* alertLabel;
@property (retain) UILabel* alertCountLabel;
@property (retain) UILabel* runwayLabel;
@property (retain) UIImageView* runwayButtonView;
@property (retain) HeaderView* headerView;

- (void) openDrawer;
- (void) closeDrawer;
- (void) animateDrawer;
- (void) updateAirport:(Airport*)a;
- (void) checkAlerts;
- (void) setSliderForRunway:(NSString*)runwayName withState:(RunwayState)state;

@end
