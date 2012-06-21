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

#import "BetaFeedbackView.h"


@implementation BetaFeedbackView

@synthesize alert;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor blackColor];

		NSString* imagePath = [ [ NSBundle mainBundle ] pathForResource: @"earlyAlert-32" ofType: @"png" ];
		UIImage* image = [UIImage imageWithContentsOfFile:imagePath];				
		earlyAlertButton	= [[UIButton alloc] initWithFrame:CGRectMake(5, 6, 76, 38)];
		[earlyAlertButton setBackgroundImage:image forState:UIControlStateNormal];
		[earlyAlertButton addTarget:self action:@selector(handleEarlyAlert) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:earlyAlertButton];
		
		imagePath = [ [ NSBundle mainBundle ] pathForResource: @"goodAlert-32" ofType: @"png" ];
		image = [UIImage imageWithContentsOfFile:imagePath];				
		goodAlertButton	= [[UIButton alloc] initWithFrame:CGRectMake(83, 6, 76, 38)];
		[goodAlertButton setBackgroundImage:image forState:UIControlStateNormal];
		[goodAlertButton addTarget:self action:@selector(handleGoodAlert) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:goodAlertButton];
		
		imagePath = [ [ NSBundle mainBundle ] pathForResource: @"lateAlert-32" ofType: @"png" ];
		image = [UIImage imageWithContentsOfFile:imagePath];				
		lateAlertButton	= [[UIButton alloc] initWithFrame:CGRectMake(161, 6, 76, 38)];
		[lateAlertButton setBackgroundImage:image forState:UIControlStateNormal];
		[lateAlertButton addTarget:self action:@selector(handleLateAlert) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:lateAlertButton];
		
		imagePath = [ [ NSBundle mainBundle ] pathForResource: @"falseAlert-32" ofType: @"png" ];
		image = [UIImage imageWithContentsOfFile:imagePath];				
		falseAlertButton	= [[UIButton alloc] initWithFrame:CGRectMake(239, 6, 76, 38)];
		[falseAlertButton setBackgroundImage:image forState:UIControlStateNormal];
		[falseAlertButton addTarget:self action:@selector(handleFalseAlert) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:falseAlertButton];
				
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

- (void) handleEarlyAlert {
	//NSLog(@"Early Alert: %d", alertRecord.alertType);		
	alert.userFeedback = 0;
	self.hidden = YES;
}

- (void) handleGoodAlert {
	//NSLog(@"Good Alert: %d", alertRecord.alertType);	
	alert.userFeedback = 1;
	self.hidden = YES;
	
}

- (void) handleLateAlert {
	//NSLog(@"Late Alert: %d", alertRecord.alertType);	
	alert.userFeedback = 2;
	self.hidden = YES;

}

- (void) handleFalseAlert {
	//NSLog(@"False Alert: %d", alertRecord.alertType);	
	alert.userFeedback = 3;
	self.hidden = YES;

	
}

@end
