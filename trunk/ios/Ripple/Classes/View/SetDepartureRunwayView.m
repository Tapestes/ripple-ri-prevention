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

#import "SetDepartureRunwayView.h"
#import <QuartzCore/QuartzCore.h>


@implementation SetDepartureRunwayView

@synthesize arrowView;
@synthesize label1;
@synthesize label2;
@synthesize airport;
@synthesize delegate;
@synthesize sliderViews;

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
        departureRunway = @"";
        // Initialization code.
		self.backgroundColor            = [UIColor lightGrayColor];
		//self.layer.borderColor          = [UIColor darkGrayColor].CGColor;
		//self.layer.borderWidth          = 3.0f;
		[self.layer setCornerRadius:10.0f];
		[self.layer setBorderColor:[UIColor darkGrayColor].CGColor];
		[self.layer setBorderWidth:2.5f];
		[self.layer setShadowColor:[UIColor blackColor].CGColor];
		[self.layer setShadowOpacity:0.8];
		[self.layer setShadowRadius:3.0];
		[self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
				
		label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, -10, 225, 40)];
		label1.text                       = @"Set the assigned departure runway end";
		label1.backgroundColor            = [UIColor clearColor];
		label1.font                       = [UIFont systemFontOfSize:12.0];
		label1.textColor                  = [UIColor whiteColor];
		label1.textAlignment              = UITextAlignmentCenter;
		label1.lineBreakMode              = UILineBreakModeWordWrap;
		label1.numberOfLines              = 0;
		label1.shadowColor                = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		label1.shadowOffset               = CGSizeMake(1, 2);
		label1.hidden                     = NO;
		
		label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 225, 40)];
		label2.text                       = @"Departure Runway set to";
		label2.backgroundColor            = [UIColor clearColor];
		label2.font                       = [UIFont systemFontOfSize:12.0];
		label2.textColor                  = [UIColor whiteColor];
		label2.textAlignment              = UITextAlignmentCenter;
		label2.lineBreakMode              = UILineBreakModeWordWrap;
		label2.numberOfLines              = 0;
		label2.shadowColor                = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		label2.shadowOffset               = CGSizeMake(1, 2);
		label2.hidden                     = YES;
		
		[self addSubview:label1];
		[self addSubview:label2];
        
		
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        departureRunway = @"";

        // Initialization code.
		self.backgroundColor            = [UIColor clearColor];
		//self.layer.borderColor          = [UIColor darkGrayColor].CGColor;
		//self.layer.borderWidth          = 3.0f;
		[self.layer setCornerRadius:10.0f];
		[self.layer setBorderColor:[UIColor darkGrayColor].CGColor];
		[self.layer setBorderWidth:2.5f];
		[self.layer setShadowColor:[UIColor blackColor].CGColor];
		[self.layer setShadowOpacity:0.8];
		[self.layer setShadowRadius:3.0];
		[self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
		
		
		label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, -10, 225, 40)];
		label1.text                       = @"Set the assigned departure runway end";
		label1.backgroundColor            = [UIColor clearColor];
		label1.font                       = [UIFont systemFontOfSize:12.0];
		label1.textColor                  = [UIColor whiteColor];
		label1.textAlignment              = UITextAlignmentCenter;
		label1.lineBreakMode              = UILineBreakModeWordWrap;
		label1.numberOfLines              = 0;
		label1.shadowColor                = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		label1.shadowOffset               = CGSizeMake(1, 2);
		label1.hidden                     = NO;
		
		
		label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 225, 40)];
		label2.text                       = @"Departure Runway set to";
		label2.backgroundColor            = [UIColor clearColor];
		label2.font                       = [UIFont systemFontOfSize:12.0];
		label2.textColor                  = [UIColor whiteColor];
		label2.textAlignment              = UITextAlignmentCenter;
		label2.lineBreakMode              = UILineBreakModeWordWrap;
		label2.numberOfLines              = 0;
		label2.shadowColor                = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		label2.shadowOffset               = CGSizeMake(1, 2);
		label2.hidden                     = YES;
		
		[self addSubview:label1];
		[self addSubview:label2];
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

int sliderSize;

- (void) updateAirport:(Airport*)a {
	airport = a;
	int count = [airport.runways count];
	//NSLog(@"count: %d", count);
	sliderSize = 50 * count;		

	CGRect viewFrame = self.frame;
	viewFrame.size.height += sliderSize;
	self.frame = viewFrame;
	
	sliderViews = [NSMutableArray arrayWithCapacity:0];
	
	int idx = 0;
	for(Runway* runway in airport.runways) {
		SetRunwaySliderView* rv = [[SetRunwaySliderView alloc] initWithRunway:runway index:(int)idx];
		rv.delegate = self;
		[self addSubview:rv];
		idx++;
		[sliderViews addObject:rv];
	}	

	[self setNeedsDisplay];
		
}

- (void) setDepartureRunway:(NSString *) s {

	for(SetRunwaySliderView* rv in sliderViews) {
		[rv clearSlider:s];
	}	
	departureRunway = s;
	[delegate setDepartureRunway:s];

	if(![s isEqualToString:@""]) {
		[UIView animateWithDuration:0.5
						  delay:0.75
						options: UIViewAnimationCurveEaseOut
					 animations:^{
						 self.alpha = 0.0;
					 }
					 completion:^(BOOL finished){
						 self.hidden = YES;
						 self.alpha = 1.0;
					 }];
	}
}

- (void) verifyDepartureRunway:(NSString *) s {
    if(![s isEqualToString:departureRunway]) {
        for(SetRunwaySliderView* rv in sliderViews) {
            if([rv hasRunway:s]) {
                [rv setDepartureRunway:s];
            } else  {
                [rv clearSlider:s];
            }
        }	

        
        
    }
    
}


@end
