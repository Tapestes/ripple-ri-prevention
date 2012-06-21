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

#import "MiniAlertView.h"


@implementation MiniAlertView

@synthesize alertType;
@synthesize delegate;
@synthesize label;

//alertType == 1   ->   HOLD SHORT
//alertType == 2   ->   CROSSING
//alertType == 3   ->   APPROACHING
//alertType == 4   ->   WRONG RUNWAY

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.hidden = YES;

		NSString* redImagePath = [ [ NSBundle mainBundle ] pathForResource: @"red-hatch-minimized-32" ofType: @"png" ];
		NSString* orangeImagePath = [ [ NSBundle mainBundle ] pathForResource: @"Reminder_Disabled_Background_Minimizedl" ofType: @"png" ];
        
        redBackground = [UIImage imageWithContentsOfFile:redImagePath];	
        orangeBackground = [UIImage imageWithContentsOfFile:orangeImagePath];	
		self.image = redBackground;

		[self setUserInteractionEnabled:YES];

		CGRect rect = self.frame;
		rect.origin.x = 0;
		rect.origin.y = 0;
		
		label                  = [[UILabel alloc] initWithFrame:rect];
		label.backgroundColor  = [UIColor clearColor];
		label.font             = [UIFont boldSystemFontOfSize:28.0];
		label.textColor		  = [UIColor whiteColor];
		label.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		label.shadowOffset     = CGSizeMake(1, 2);
		label.textAlignment    = UITextAlignmentCenter;
		[self addSubview:label];
		
	}
	return self;
}

/*- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		NSString* redImagePath = [ [ NSBundle mainBundle ] pathForResource: @"red-hatch-minimized-32" ofType: @"png" ];
		NSString* orangeImagePath = [ [ NSBundle mainBundle ] pathForResource: @"Reminder_Disabled_Background_Minimizedl" ofType: @"png" ];
        
        redBackground = [UIImage imageWithContentsOfFile:redImagePath];	
        orangeBackground = [UIImage imageWithContentsOfFile:orangeImagePath];	
		self.image = redBackground;
		[self setUserInteractionEnabled:YES];
		

    }
    return self;
}
*/

- (void) setAlert:(int)t {		
	if(t == 0) {
		self.hidden = YES;		
	} else {
		if(t == 1) {
            self.image = redBackground;
			label.text = @"Hold Short";
		} else if(t == 2) {
			label.text = @"";
		} else if(t == 3) {
            self.image = redBackground;
			label.text = @"Hold Short";
		} else if(t == 4) {
            self.image = redBackground;
			label.text = @"Wrong Runway";
		} else if(t == 5) {
            self.image = orangeBackground;
			label.text = @"Reminders Disabled";
		} else if(t == 6) {
            self.image = orangeBackground;
			label.text = @"Reminders Disabled";
		}
	}
	
	if(t != 100) {
		self.hidden = YES;		
		alertType = t;
		[self setNeedsDisplay];	
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate showMaxAlert];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}

@end
