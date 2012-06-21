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

#import "RunwaySliderView.h"


@implementation RunwaySliderView

@synthesize runway;
@synthesize greySlider;
@synthesize colorSlider;
@synthesize buttonSlider;
@synthesize crossLabel;
@synthesize holdLabel;
@synthesize runwayLabel;
@synthesize clearedToCrossLabel;
@synthesize holdShortLabel;
@synthesize unselectedButtonImage;
@synthesize selectedButtonImage;
@synthesize redSliderImage;
@synthesize blueSliderImage;

int sliderLeft = 5;
int sliderCenter = 104;
int sliderRight = 203;

- (id)initWithRunway:(Runway*)r index:(int)idx {
    self = [super initWithFrame:CGRectMake(5, 270-(50*idx), 310, 50)];
    if (self) {
        // Initialization code.
		runway = r;
		self.backgroundColor = [UIColor lightGrayColor];

		[self buildSliders];
		[self buildLabels];
		[self buildSliderButton];
        
        [self setRunwaySliderStateWithXPos:155];
				
    }
    return self;
	

}

- (UIImage*) loadImage:(NSString*)name type:(NSString*)type {
	NSString* imagePath = [ [ NSBundle mainBundle ] pathForResource: name ofType: type ];
	UIImage* image = [UIImage imageWithContentsOfFile:imagePath];		
	return image;
}

- (void) buildSliders {
	colorSlider = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 301, 37)];
	greySlider  = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 301, 37)];
	
    blueSliderImage = [self loadImage:@"Rwy-Slider-Two-State-Blue-Background-32" type:@"png"];
	redSliderImage = [self loadImage:@"Rwy-Slider-Two-State-Red-Background-32" type:@"png"];
	
    //blueSliderImage = [self loadImage:@"Rwy-Slider-Blue-Background-32" type:@"png"];
	//redSliderImage = [self loadImage:@"Rwy-Slider-Red-Background-32" type:@"png"];
	
	greySlider.image = [self loadImage:@"Rwy-Slider-Grey-Hatch-Background-32" type: @"png" ];
	
	[self addSubview:colorSlider];
	[self addSubview:greySlider];	
}

- (void) buildSliderButton {
	unselectedButtonImage = [self loadImage:@"Rwy-Slider-Slider-Deep-Red-32" type: @"png" ];
	selectedButtonImage = [self loadImage:@"Rwy-Slider-Slider-Bright-Red-for-Hold-Short-32" type: @"png"];
	
	buttonSlider = [[UIImageView alloc] initWithFrame:CGRectMake(sliderCenter, 5, 103, 37)];
	buttonSlider.image = unselectedButtonImage;	

	[self addSubview:buttonSlider];

	//NSLog(@"Runway name: %@", runway.name);
	runwayLabel = [[UILabel alloc] initWithFrame:CGRectMake(106, 4, 100, 37)];
	runwayLabel.text              = runway.name;
	runwayLabel.backgroundColor   = [UIColor clearColor];
	runwayLabel.font              = [UIFont boldSystemFontOfSize:22.0];
	runwayLabel.textColor		  = [UIColor whiteColor];
	runwayLabel.textAlignment     = UITextAlignmentCenter;
	[self addSubview:runwayLabel];			
	
}

- (void) buildLabels {
	crossLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 8, 80, 30)];
	crossLabel.text               = @"Cross";	
	crossLabel.backgroundColor    = [UIColor clearColor];
	crossLabel.font               = [UIFont boldSystemFontOfSize:20.0];
	crossLabel.textColor		  = [UIColor lightGrayColor];
	[self addSubview:crossLabel];
	
	holdLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 8, 80, 30)];
	holdLabel.text             = @"Hold";	
	holdLabel.backgroundColor  = [UIColor clearColor];
	holdLabel.font             = [UIFont boldSystemFontOfSize:20.0];
	holdLabel.textColor		   = [UIColor lightGrayColor];
	[self addSubview:holdLabel];
	
	clearedToCrossLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 8, 180, 30)];
	clearedToCrossLabel.text               = @"Cleared to Cross";	
	clearedToCrossLabel.backgroundColor    = [UIColor clearColor];
	clearedToCrossLabel.font               = [UIFont boldSystemFontOfSize:22.0];
	clearedToCrossLabel.textColor	 	   = [UIColor whiteColor];
	clearedToCrossLabel.textAlignment      = UITextAlignmentCenter;
	clearedToCrossLabel.hidden			   = YES;
	[self addSubview:clearedToCrossLabel];
	
	holdShortLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 180, 30)];
	holdShortLabel.text             = @"Hold Short of";	
	holdShortLabel.backgroundColor  = [UIColor clearColor];
	holdShortLabel.font             = [UIFont boldSystemFontOfSize:24.0];
	holdShortLabel.textColor		= [UIColor whiteColor];
	holdShortLabel.textAlignment    = UITextAlignmentCenter;
	holdShortLabel.hidden		    = YES;
	[self addSubview:holdShortLabel];
	
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
CGPoint lastPoint;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	lastPoint = [touch locationInView:self];
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	float delta = point.x - lastPoint.x;
	CGRect rect = runwayLabel.frame;
	float xPos = rect.origin.x;
	float newAlpha = 1.0 - (fabs(104.0 - xPos) / 100.0);
	
	if(xPos == 104) {
		clearedToCrossLabel.hidden = YES;
		holdShortLabel.hidden = YES;
		crossLabel.hidden = NO;
		holdLabel.hidden = NO;
	} else if (xPos < 104) {
		clearedToCrossLabel.hidden = NO;
		holdShortLabel.hidden = YES;
		crossLabel.hidden = NO;
		holdLabel.hidden = YES;
		colorSlider.image = blueSliderImage;
	} else if (xPos > 104) {
		clearedToCrossLabel.hidden = YES;
		holdShortLabel.hidden = NO;
		crossLabel.hidden = YES;
		holdLabel.hidden = NO;
		colorSlider.image = redSliderImage;
	}
	
	if((xPos > 6) && (xPos < 203)) {
		greySlider.alpha = newAlpha;
		[self moveSlider:delta];
	} else if(xPos <= 6) {
		if (delta < 0) {
			greySlider.alpha = 0.0;
			[self setSliderXPosition:sliderLeft];		
		} else {
			greySlider.alpha = newAlpha;
			[self moveSlider:delta];		
		}
	} else if(xPos >= 203) {
		if (delta > 0) {
			greySlider.alpha = 0.0;
			[self setSliderXPosition:sliderRight];		
		} else {
			greySlider.alpha = newAlpha;
			[self moveSlider:delta];		
		}
	}
	
	lastPoint = point;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGRect rect = runwayLabel.frame;
	float xPos = rect.origin.x;
	
    [self setRunwaySliderStateWithXPos:xPos];

}

- (void) setRunwaySliderStateWithXPos:(int) xPos {
    
 	if(xPos > 105) { 
        clearedToCrossLabel.hidden = YES;
		holdShortLabel.hidden = NO;
		crossLabel.hidden = YES;
		holdLabel.hidden = NO;
		colorSlider.image = redSliderImage;
        
		greySlider.alpha = 0.0;
		runway.state = RunwayWatchedState;
		buttonSlider.image = selectedButtonImage;
		colorSlider.image = redSliderImage;
		[self setSliderXPosition:sliderRight];
	} else {
		clearedToCrossLabel.hidden = NO;
		holdShortLabel.hidden = YES;
		crossLabel.hidden = NO;
		holdLabel.hidden = YES;
		colorSlider.image = blueSliderImage;
        
		greySlider.alpha = 0.0;
		runway.state = RunwayClearState;
		buttonSlider.image = unselectedButtonImage;
		colorSlider.image = blueSliderImage;
		[self setSliderXPosition:sliderLeft];
	}
	
	[self setNeedsDisplay];   
    
    
}

/*
 * 3 State Slider mode
- (void) setRunwaySliderStateWithXPos:(int) xPos {
    
 	if(xPos > 154) { 
        clearedToCrossLabel.hidden = YES;
		holdShortLabel.hidden = NO;
		crossLabel.hidden = YES;
		holdLabel.hidden = NO;
		colorSlider.image = redSliderImage;
        
		greySlider.alpha = 0.0;
		runway.state = RunwayWatchedState;
		buttonSlider.image = selectedButtonImage;
		colorSlider.image = redSliderImage;
		[self setSliderXPosition:sliderRight];
	} else if(xPos < 55) {
		clearedToCrossLabel.hidden = NO;
		holdShortLabel.hidden = YES;
		crossLabel.hidden = NO;
		holdLabel.hidden = YES;
		colorSlider.image = blueSliderImage;
        
		greySlider.alpha = 0.0;
		runway.state = RunwayClearState;
		buttonSlider.image = unselectedButtonImage;
		colorSlider.image = blueSliderImage;
		[self setSliderXPosition:sliderLeft];
	} else {
		runway.state = RunwayNeutralState;
		clearedToCrossLabel.hidden = YES;
		holdShortLabel.hidden = YES;
		crossLabel.hidden = NO;
		holdLabel.hidden = NO;
		greySlider.alpha = 1.0;
		buttonSlider.image = unselectedButtonImage;
		[self setSliderXPosition:sliderCenter];
	}
	
	[self setNeedsDisplay];   
    
    
}
*/

- (void) moveSlider:(float) delta {	
	CGRect rect = runwayLabel.frame;
	rect.origin.x += delta;
	runwayLabel.frame = rect;
	
	rect = buttonSlider.frame;
	rect.origin.x += delta;
	buttonSlider.frame = rect;
	[self setNeedsDisplay];
	
}

- (void) setSliderXPosition:(int) x {	
	CGRect rect = runwayLabel.frame;
	rect.origin.x = x;
	runwayLabel.frame = rect;
	
	rect = buttonSlider.frame;
	rect.origin.x = x;
	buttonSlider.frame = rect;
	
	[self setNeedsDisplay];
	
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}

- (void) setSliderForRunway:(NSString*)runwayName withState:(RunwayState)state {
    if([runway.name isEqualToString:runwayName]) {
        if(state == RunwayClearState) {
            [self setRunwaySliderStateWithXPos:0];
        } else if(state == RunwayWatchedState) {
            [self setRunwaySliderStateWithXPos:155];
        }
    }
}

@end
