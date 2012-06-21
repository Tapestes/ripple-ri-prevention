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

#import "SlidingDrawerView.h"


@implementation SlidingDrawerView

@synthesize handleView;
@synthesize handleLabel;
@synthesize airport;
@synthesize alertLabel;
@synthesize alertCountLabel;
@synthesize runwayLabel;
@synthesize runwayButtonView;
@synthesize headerView;

BOOL drawerIsOpen = FALSE;
int moveSize = -100;
int alertIndex = 0;
NSMutableArray* alerts;

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
        runwaySliderViews = [[NSMutableArray alloc] initWithCapacity:0];
		self.backgroundColor	= [UIColor blackColor];
						
		handleView            = [[HandleView alloc] initWithFrame:CGRectMake(0, 320, 320, 41)];

		handleLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 41)];
		handleLabel.text             = @"open";
		handleLabel.backgroundColor  = [UIColor clearColor];
		handleLabel.font             = [UIFont boldSystemFontOfSize:10.0];
		handleLabel.textColor		 = [UIColor whiteColor];
		handleLabel.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		handleLabel.shadowOffset     = CGSizeMake(1, 2);
		handleLabel.textAlignment    = UITextAlignmentCenter;
		[handleView addSubview:handleLabel];
				
		alertLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 200, 25)];
		alertLabel.text             = @"Hold  Short  of";
		//alertLabel.text             = @"Cleared to Cross";
		alertLabel.backgroundColor  = [UIColor clearColor];
		alertLabel.font             = [UIFont boldSystemFontOfSize:24.0];
		alertLabel.textColor		 = [UIColor whiteColor];
		alertLabel.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		alertLabel.shadowOffset     = CGSizeMake(1, 2);
		alertLabel.textAlignment    = UITextAlignmentRight;
		alertLabel.hidden           = YES;
		[handleView addSubview:alertLabel];

		alertCountLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 100, 21)];
		alertCountLabel.text             = @"1 of 1";
		alertCountLabel.backgroundColor  = [UIColor clearColor];
		alertCountLabel.font             = [UIFont boldSystemFontOfSize:12.0];
		alertCountLabel.textColor		 = [UIColor whiteColor];
		alertCountLabel.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		alertCountLabel.shadowOffset     = CGSizeMake(1, 2);
		alertCountLabel.textAlignment    = UITextAlignmentCenter;
		alertCountLabel.hidden           = YES;
		[handleView addSubview:alertCountLabel];

		NSString* buttonImagePath   = [ [ NSBundle mainBundle ] pathForResource: @"Rwy-Slider-Slider-Bright-Red-for-Hold-Short-32" ofType: @"png" ];
		runwayButtonView            = [[UIImageView alloc] initWithFrame:CGRectMake(230, 2, 75, 30)];
		runwayButtonView.image      = [UIImage imageWithContentsOfFile:buttonImagePath];		
		runwayButtonView.hidden     = YES;		
		[handleView addSubview:runwayButtonView];

		runwayLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(230, 2, 75, 30)];
		runwayLabel.text             = @"17-93";
		runwayLabel.backgroundColor  = [UIColor clearColor];
		runwayLabel.font             = [UIFont boldSystemFontOfSize:18.0];
		runwayLabel.textColor		 = [UIColor whiteColor];
		runwayLabel.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		runwayLabel.shadowOffset     = CGSizeMake(1, 2);
		runwayLabel.textAlignment    = UITextAlignmentCenter;
		runwayLabel.hidden           = YES;
		[handleView addSubview:runwayLabel];
						
		alerts = [NSMutableArray arrayWithCapacity:0];
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

//================================================================================
#pragma mark Event Handling
//================================================================================

CGPoint gestureStartPoint;
int kMinimumGestureLength = 25;
int kMaximumVariance = 10;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	gestureStartPoint = [touch locationInView:self];
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];

	int direction = 1;
	CGFloat deltaX = gestureStartPoint.x - point.x;
	CGFloat deltaY = fabsf(gestureStartPoint.y - point.y);
	if(deltaX < 0)
		direction = -1;
	deltaX = fabsf(deltaX);
	
	if(([alerts count] > 0) && !drawerIsOpen) {
		if(deltaX >= kMinimumGestureLength && deltaY <= kMaximumVariance) {
			alertIndex += direction;
			if(alertIndex == [alerts count]) {
				alertIndex = 0;
			} else if (alertIndex < 0) {
				alertIndex = [alerts count] - 1;
			}
			
			NSString* alert = [alerts objectAtIndex:alertIndex];
			NSArray* pieces = [alert componentsSeparatedByString:@","];
			runwayLabel.text = [pieces objectAtIndex:0];
			alertLabel.text = [pieces objectAtIndex:1];
			alertCountLabel.text	    = [NSString stringWithFormat:@"%d of %d", (alertIndex + 1), [alerts count]];
		}
	} 
	
	if((point.x > 130) && (point.x < 200) && (deltaX < kMinimumGestureLength)) {
		if(point.y > 335) {
			//NSLog(@"touch point: %f, %f", point.x, point.y);
			if(drawerIsOpen) {
				[self closeDrawer];
			} else {
				[self openDrawer];
			}
		}
	}
	
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}

- (void) openDrawer {
	moveSize = -moveSize;
	handleLabel.text = @"close";	
	drawerIsOpen = !drawerIsOpen;	
	
	runwayLabel.hidden          = YES;
	runwayButtonView.hidden     = YES;
	alertLabel.hidden			= YES; 
	alertCountLabel.hidden		= YES; 

	alertIndex = 0;
	[alerts removeAllObjects];
	
	[headerView showShadow];
	
	[self animateDrawer];

}

- (void) closeDrawer {
	moveSize = -moveSize;
	handleLabel.text = @"open";	
	drawerIsOpen = !drawerIsOpen;	

	[headerView hideShadow];

	[self animateDrawer];
	
	[self checkAlerts];
}

- (void) animateDrawer {
	CGRect viewFrame = self.frame;
	viewFrame.origin.y += moveSize;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	self.frame = viewFrame;
	[UIView commitAnimations];
}

- (void) updateAirport:(Airport *)a {
	airport = a;
	int count = [airport.runways count];
	NSLog(@"######### Updating Airport count: %d", count);
	if(drawerIsOpen) {
		moveSize = 50 * count;
	} else {
		moveSize = -50 * count;		
	}
	
	int idx = 0;
	for(int i = ([airport.runways count] - 1); i >= 0 ; i--) {
		Runway* runway = [airport.runways objectAtIndex:i];

        NSLog(@"###################Building RSV with: %@", runway.name);
		RunwaySliderView* rv = [[RunwaySliderView alloc] initWithRunway:runway index:(int)idx];
		[self addSubview:rv];
        [runwaySliderViews addObject:rv];
		idx++;
	}
	
	[self addSubview:handleView];

	[self setNeedsDisplay];
}

- (void) checkAlerts {
	
	int count = 0;
	
	for(Runway* runway in airport.runways) {
		if(runway.state != RunwayNeutralState) {
			count++;
			
			if(runway.state == RunwayClearState) {
				[alerts addObject:[NSString stringWithFormat:@"%@,Cleared to Cross", runway.name]];
			} else {
				[alerts addObject:[NSString stringWithFormat:@"%@,Hold  Short  of", runway.name]];				
			}
			
		}
	}
	
	if(count > 0) {
		NSString* alert = [alerts objectAtIndex:alertIndex];
		NSArray* pieces = [alert componentsSeparatedByString:@","];
		runwayLabel.text = [pieces objectAtIndex:0];
		alertLabel.text = [pieces objectAtIndex:1];
		alertCountLabel.text	    = [NSString stringWithFormat:@"1 of %d", count];

		runwayLabel.hidden          = NO;
		runwayButtonView.hidden     = NO;
		alertLabel.hidden			= NO; 
		alertCountLabel.hidden		= NO; 
	}
}

- (void) setSliderForRunway:(NSString*)runwayName withState:(RunwayState)state {
    
    for(RunwaySliderView* rsView in runwaySliderViews) {
        [rsView setSliderForRunway:runwayName withState:state];
    }
    
}


@end
