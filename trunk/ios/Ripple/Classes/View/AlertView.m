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

#import "AlertView.h"


@implementation AlertView

@synthesize maxBackgroundView;
@synthesize crossingBackgroundView;
@synthesize holdShortLabel;
@synthesize noClearanceLabel;
@synthesize noTakeoffLabel;
@synthesize crossingLabel;
@synthesize alertType;
@synthesize delegate;
@synthesize player;
@synthesize alertSequence;
@synthesize alertIndex;

//alertType == 1   ->   HOLD SHORT
//alertType == 2   ->   CROSSING
//alertType == 3   ->   APPROACHING
//alertType == 4   ->   WRONG RUNWAY

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.hidden = YES;
		
		maxBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
		NSString* redImagePath = [ [ NSBundle mainBundle ] pathForResource: @"red-hatch-maximized-32" ofType: @"png" ];
		NSString* orangeImagePath = [ [ NSBundle mainBundle ] pathForResource: @"Reminder_Disabled_Background_Full" ofType: @"png" ];
        
        redBackground = [UIImage imageWithContentsOfFile:redImagePath];		
        orangeBackground = [UIImage imageWithContentsOfFile:orangeImagePath];		
        
		maxBackgroundView.image = redBackground;
		maxBackgroundView.hidden = YES;
		
		holdShortLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 200)];
		holdShortLabel.text              = @"Hold\nShort of\nRunway";
		holdShortLabel.backgroundColor   = [UIColor clearColor];
		holdShortLabel.font              = [UIFont systemFontOfSize:48.0];
		holdShortLabel.textColor		 = [UIColor whiteColor];
		holdShortLabel.textAlignment     = UITextAlignmentCenter;
		holdShortLabel.lineBreakMode	 = UILineBreakModeWordWrap;
		holdShortLabel.numberOfLines	 = 0;
		holdShortLabel.shadowColor       = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		holdShortLabel.shadowOffset      = CGSizeMake(1, 2);
		holdShortLabel.hidden = YES;
		
		noClearanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 400)];
		noClearanceLabel.text              = @"Hold\nShort of\nRunway\n\nNo\nClearance";
		noClearanceLabel.backgroundColor   = [UIColor clearColor];
		noClearanceLabel.font              = [UIFont systemFontOfSize:40.0];
		noClearanceLabel.textColor		   = [UIColor whiteColor];
		noClearanceLabel.textAlignment     = UITextAlignmentCenter;
		noClearanceLabel.lineBreakMode	   = UILineBreakModeWordWrap;
		noClearanceLabel.numberOfLines	   = 0;
		noClearanceLabel.shadowColor       = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		noClearanceLabel.shadowOffset      = CGSizeMake(1, 2);
		noClearanceLabel.hidden = YES;
		
		noTakeoffLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 400)];
		noTakeoffLabel.text              = @"No\nTakeoff\nClearance\nfor\nRunway";
		noTakeoffLabel.backgroundColor   = [UIColor clearColor];
		noTakeoffLabel.font              = [UIFont systemFontOfSize:40.0];
		noTakeoffLabel.textColor         = [UIColor whiteColor];
		noTakeoffLabel.textAlignment     = UITextAlignmentCenter;
		noTakeoffLabel.lineBreakMode     = UILineBreakModeWordWrap;
		noTakeoffLabel.numberOfLines	 = 0;
		noTakeoffLabel.shadowColor       = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		noTakeoffLabel.shadowOffset      = CGSizeMake(1, 2);
		noTakeoffLabel.hidden = YES;

		crossingBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 303, 320, 50)];
		NSString* imagePath2 = [ [ NSBundle mainBundle ] pathForResource: @"Grey-Banner-Background-32" ofType: @"png" ];
		crossingBackgroundView.image           = [UIImage imageWithContentsOfFile:imagePath2];		
		crossingBackgroundView.backgroundColor = [UIColor lightGrayColor];
		crossingBackgroundView.hidden          = YES;

		crossingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, 300, 50)];
		crossingLabel.text              = @"Crossing Runway";
		crossingLabel.backgroundColor   = [UIColor clearColor];
		crossingLabel.font              = [UIFont systemFontOfSize:36.0];
		crossingLabel.textColor         = [UIColor whiteColor];
		crossingLabel.textAlignment     = UITextAlignmentCenter;
		crossingLabel.shadowColor       = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		crossingLabel.shadowOffset      = CGSizeMake(1, 2);
		crossingLabel.hidden = YES;

        badGpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 250)];
		badGpsLabel.text              = @"Reminders\nDisabled:\n\nGPS accuracy\ninsufficient";
		badGpsLabel.backgroundColor   = [UIColor clearColor];
		badGpsLabel.font              = [UIFont systemFontOfSize:40.0];
		badGpsLabel.textColor		 = [UIColor whiteColor];
		badGpsLabel.textAlignment     = UITextAlignmentCenter;
		badGpsLabel.lineBreakMode	 = UILineBreakModeWordWrap;
		badGpsLabel.numberOfLines	 = 0;
		badGpsLabel.shadowColor       = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		badGpsLabel.shadowOffset      = CGSizeMake(1, 2);
		badGpsLabel.hidden = YES;
		
        badGpsLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 285, 300, 50)];
		badGpsLabel2.text              = @"(50 feet required)";
		badGpsLabel2.backgroundColor   = [UIColor clearColor];
		badGpsLabel2.font              = [UIFont systemFontOfSize:28.0];
		badGpsLabel2.textColor		 = [UIColor whiteColor];
		badGpsLabel2.textAlignment     = UITextAlignmentCenter;
		badGpsLabel2.lineBreakMode	 = UILineBreakModeWordWrap;
		badGpsLabel2.numberOfLines	 = 0;
		badGpsLabel2.shadowColor       = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		badGpsLabel2.shadowOffset      = CGSizeMake(1, 2);
		badGpsLabel2.hidden = YES;
		
        tooFastLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 300)];
		tooFastLabel.text              = @"Reminders\nDisabled:\n\nSpeed\ngreater than\n25 knots";
		tooFastLabel.backgroundColor   = [UIColor clearColor];
		tooFastLabel.font              = [UIFont systemFontOfSize:40.0];
		tooFastLabel.textColor		 = [UIColor whiteColor];
		tooFastLabel.textAlignment     = UITextAlignmentCenter;
		tooFastLabel.lineBreakMode	 = UILineBreakModeWordWrap;
		tooFastLabel.numberOfLines	 = 0;
		tooFastLabel.shadowColor       = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		tooFastLabel.shadowOffset      = CGSizeMake(1, 2);
		tooFastLabel.hidden = YES;
		

		
		[self addSubview:crossingBackgroundView];			
		[self addSubview:crossingLabel];					
		
		[self addSubview:maxBackgroundView];			
		[self addSubview:holdShortLabel];			
		[self addSubview:noClearanceLabel];			
		[self addSubview:noTakeoffLabel];			
		[self addSubview:badGpsLabel];			
		[self addSubview:badGpsLabel2];			
		[self addSubview:tooFastLabel];			

		alertSequence = [[NSMutableArray alloc] initWithCapacity:0];
		alertIndex = 0;
	}
	return self;
}

- (void) setAlert:(int)t onRunway:(NSString*) rw {	

	if(t == 0) {
		self.hidden = YES;		
		[self stopAndClearPlayer];
	} else {
		if(t != 100) {
			self.hidden = NO;
		}
		if(t == 1) {
            maxBackgroundView.image = redBackground;
			maxBackgroundView.hidden      = NO;			
			holdShortLabel.hidden         = NO;
			noClearanceLabel.hidden       = YES;
			noTakeoffLabel.hidden         = YES;
			
			crossingBackgroundView.hidden = YES;
			crossingLabel.hidden          = YES;
            badGpsLabel.hidden = YES;
            badGpsLabel2.hidden = YES;
            tooFastLabel.hidden = YES;

			[self setUserInteractionEnabled:YES];
						
			[self playAudioAlert:@"holdShortOfRunway" onRunway:rw];	
		} else if(t == 2) {
			maxBackgroundView.hidden = YES;
			holdShortLabel.hidden    = YES;
			noClearanceLabel.hidden  = YES;
			noTakeoffLabel.hidden    = YES;
			
			crossingBackgroundView.hidden = NO;
			crossingLabel.hidden          = NO;
            badGpsLabel.hidden = YES;
            badGpsLabel2.hidden = YES;
            tooFastLabel.hidden = YES;

			[self setUserInteractionEnabled:NO];
			[self playAudioAlert:@"crossingRunway" onRunway:rw];	
		} else if(t == 3) {
            maxBackgroundView.image = redBackground;
			maxBackgroundView.hidden = NO;
			holdShortLabel.hidden    = YES;
			noClearanceLabel.hidden  = NO;
			noTakeoffLabel.hidden    = YES;
			
			crossingBackgroundView.hidden = YES;
			crossingLabel.hidden          = YES;
            badGpsLabel.hidden = YES;
            badGpsLabel2.hidden = YES;
            tooFastLabel.hidden = YES;
			[self setUserInteractionEnabled:YES];
			[self playAudioAlert:@"holdShortNoClearanceForRunway" onRunway:rw];	

		} else if(t == 4) {
            maxBackgroundView.image = redBackground;
			maxBackgroundView.hidden = NO;
			holdShortLabel.hidden    = YES;
			noClearanceLabel.hidden  = YES;
			noTakeoffLabel.hidden    = NO;
			
			crossingBackgroundView.hidden = YES;
			crossingLabel.hidden          = YES;
            badGpsLabel.hidden = YES;
            badGpsLabel2.hidden = YES;
            tooFastLabel.hidden = YES;
			[self setUserInteractionEnabled:YES];
			[self playAudioAlert:@"noTakeoffClearance" onRunway:rw];	
            
		} else if(t == 5) {
            maxBackgroundView.image = orangeBackground;
			maxBackgroundView.hidden = NO;
			holdShortLabel.hidden    = YES;
			noClearanceLabel.hidden  = YES;
			noTakeoffLabel.hidden    = YES;
			
			crossingBackgroundView.hidden = YES;
			crossingLabel.hidden          = YES;
            badGpsLabel.hidden = NO;
            badGpsLabel2.hidden = NO;
            tooFastLabel.hidden = YES;
			[self setUserInteractionEnabled:YES];
			//[self playAudioAlert:@"noTakeoffClearance" onRunway:rw];	
		} else if(t == 6) {
            maxBackgroundView.image = orangeBackground;
			maxBackgroundView.hidden = NO;
			holdShortLabel.hidden    = YES;
			noClearanceLabel.hidden  = YES;
			noTakeoffLabel.hidden    = YES;
			
			crossingBackgroundView.hidden = YES;
			crossingLabel.hidden          = YES;
            badGpsLabel.hidden = YES;
            tooFastLabel.hidden = NO;
            badGpsLabel2.hidden = YES;
			[self setUserInteractionEnabled:YES];
			//[self playAudioAlert:@"noTakeoffClearance" onRunway:rw];	
            
		}
	}
	
	if(t != 100) {
		alertType = t;
		[self setNeedsDisplay];
	}
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[delegate showMiniAlert];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}

- (void) stopAndClearPlayer {
	[alertSequence removeAllObjects];
	alertIndex = 0;

	if(player != nil) {
		if([player isPlaying]) {
			[player stop];
		}
	}
	self.player = nil;
}

- (void) playAudioAlert:(NSString*) s onRunway:(NSString*)rw {
	[self stopAndClearPlayer];
	
	NSString* audioAlerts = [[NSUserDefaults standardUserDefaults] stringForKey:@"AudioAlerts"];
	NSString* runwayAlerts = [[NSUserDefaults standardUserDefaults] stringForKey:@"RunwayAlerts"];

	if([audioAlerts isEqualToString:@"NO"] && [runwayAlerts isEqualToString:@"NO"]) {
		return;
	}
	
	if(![audioAlerts isEqualToString:@"NO"])
		[alertSequence addObject:s];
	
	if(![runwayAlerts isEqualToString:@"NO"]) {
		int count = [rw length];
		for(int i=0; i < count; i++) {
			//NSLog(@"%c", [rw characterAtIndex:i]);
			if([rw characterAtIndex:i] == 'R') {
				[alertSequence addObject:@"right"];
			} else if([rw characterAtIndex:i] == 'L') {
				[alertSequence addObject:@"left"];
			} else if([rw characterAtIndex:i] == 'C') {
				[alertSequence addObject:@"center"];
			} else if([rw characterAtIndex:i] == '-') {
				//skip
			} else {		
				[alertSequence addObject:[NSString stringWithFormat:@"%c", [rw characterAtIndex:i]]];
			}
		}
	}

	alertIndex = 0;
	NSString* path = [[NSBundle mainBundle] pathForResource:[alertSequence objectAtIndex:alertIndex] ofType:@"mp3"];
	NSURL* url = [NSURL fileURLWithPath:path];	
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
	[self.player setDelegate:self];
	alertIndex++;
	[self.player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag {
	self.player = nil;
	
	if(alertIndex < [alertSequence count]) {
		NSString* path = [[NSBundle mainBundle] pathForResource:[alertSequence objectAtIndex:alertIndex] ofType:@"mp3"];
		NSURL* url = [NSURL fileURLWithPath:path];	
		self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
		[self.player setDelegate:self];
		alertIndex++;
		[self.player play];
	} 
}

@end
