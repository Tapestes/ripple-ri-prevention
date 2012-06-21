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

#import "SetRunwaySliderView.h"


@implementation SetRunwaySliderView

@synthesize runway;
@synthesize greySlider;
@synthesize blueSlider;
@synthesize buttonSlider;
@synthesize runwayLabel1;
@synthesize runwayLabel2;
@synthesize departLabel1;
@synthesize departLabel2;
@synthesize greySliderImage;
@synthesize blueSliderImage;
@synthesize unselectedButtonImage;
@synthesize selectedButtonImage;
@synthesize sliderLeft;
@synthesize sliderCenter;
@synthesize sliderRight;
@synthesize delegate;
@synthesize lastDepartureRunway;


- (id)initWithRunway:(Runway*)r index:(int)idx {
    self = [super initWithFrame:CGRectMake(0, 20+(50*idx), 250, 50)];
    if (self) {
        // Initialization code.
		sliderLeft = 25;
		sliderCenter = 92;
		sliderRight = 156;
		
		runway = r;
		self.backgroundColor = [UIColor lightGrayColor];
		
		lastDepartureRunway = @"";
		
		[self buildSliders];
		[self buildSliderButton];
		[self buildLabels];
    }
    return self;
	
	
}

- (UIImage*) loadImage:(NSString*)name type:(NSString*)type {
	NSString* imagePath = [ [ NSBundle mainBundle ] pathForResource: name ofType: type ];
	UIImage* image = [UIImage imageWithContentsOfFile:imagePath];		
	return image;
}

- (void) buildSliders {
	blueSlider = [[UIImageView alloc] initWithFrame:CGRectMake(25, 5, 201, 36)];
	greySlider = [[UIImageView alloc] initWithFrame:CGRectMake(25, 5, 201, 36)];
	
	blueSliderImage = [self loadImage:@"Departure-Slider-Blue-Background-32" type:@"png"];
	greySliderImage = [self loadImage:@"Depature-Slider-Grey-Hatch-Background-32" type:@"png"];
	
	greySlider.image = greySliderImage;
	blueSlider.image = blueSliderImage;
	
	[self addSubview:blueSlider];
	[self addSubview:greySlider];	
}

- (void) buildSliderButton {
	unselectedButtonImage = [self loadImage:@"Departure-Slider-Button-Grey-32" type: @"png" ];
	selectedButtonImage = [self loadImage:@"Departure-Slider-Button-Red-32" type: @"png"];
	
	buttonSlider = [[UIImageView alloc] initWithFrame:CGRectMake(sliderCenter, 5, 69, 36)];
	buttonSlider.image = unselectedButtonImage;	
	
	[self addSubview:buttonSlider];
}


- (void) buildLabels {
	NSArray* array = [runway.name componentsSeparatedByString:@"-"];
	
	runwayLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(40, 8, 40, 30)];
	runwayLabel1.text               = [array objectAtIndex:0];	
	runwayLabel1.backgroundColor    = [UIColor clearColor];
	runwayLabel1.font               = [UIFont boldSystemFontOfSize:20.0];
	runwayLabel1.textColor		    = [UIColor lightGrayColor];
	runwayLabel1.textAlignment      = UITextAlignmentCenter;
	[self addSubview:runwayLabel1];
	
	runwayLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(170, 8, 40, 30)];
	runwayLabel2.text               = [array objectAtIndex:1];	
	runwayLabel2.backgroundColor    = [UIColor clearColor];
	runwayLabel2.font               = [UIFont boldSystemFontOfSize:20.0];
	runwayLabel2.textColor		    = [UIColor lightGrayColor];
	runwayLabel2.textAlignment      = UITextAlignmentCenter;
	[self addSubview:runwayLabel2];

	departLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(58, 8, 100, 30)];
	departLabel1.text               = @"Depart";
	departLabel1.backgroundColor    = [UIColor clearColor];
	departLabel1.font               = [UIFont boldSystemFontOfSize:20.0];
	departLabel1.textColor		    = [UIColor whiteColor];
	departLabel1.hidden = YES;
	[self addSubview:departLabel1];
	
	departLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(130, 8, 100, 30)];
	departLabel2.text               = @"Depart";	
	departLabel2.backgroundColor    = [UIColor clearColor];
	departLabel2.font               = [UIFont boldSystemFontOfSize:20.0];
	departLabel2.textColor		    = [UIColor whiteColor];
	departLabel2.hidden = YES;
	[self addSubview:departLabel2];
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
	CGRect rect = buttonSlider.frame;
	float xPos = rect.origin.x;
	float newAlpha = 1.0 - (fabs(sliderCenter - xPos) / 100.0);

	buttonSlider.image = unselectedButtonImage;
	runwayLabel1.textColor = [UIColor lightGrayColor];
	runwayLabel2.textColor = [UIColor lightGrayColor];
	departLabel1.hidden = YES;
	departLabel2.hidden = YES;
	runwayLabel1.hidden = NO;
	runwayLabel2.hidden = NO;

	
	if(xPos == sliderCenter) {
	} else if (xPos < sliderCenter) {
	} else if (xPos > sliderCenter) {
	}
	
	if((xPos > sliderLeft) && (xPos < sliderRight)) {
		greySlider.alpha = newAlpha;
		[self moveSlider:delta];
	} else if(xPos <= sliderLeft) {
		if (delta < 0) {
			greySlider.alpha = 0.0;
			[self setSliderXPosition:sliderLeft];		
		} else {
			greySlider.alpha = newAlpha;
			[self moveSlider:delta];		
		}
	} else if(xPos >= sliderRight) {
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

	CGRect rect = buttonSlider.frame;
	float xPos = rect.origin.x;
	
	if(xPos > 124) { 
		greySlider.alpha = 0.0;
		lastDepartureRunway = runwayLabel2.text;
		[delegate setDepartureRunway:runwayLabel2.text];	
		runwayLabel2.textColor = [UIColor whiteColor];
		buttonSlider.image = selectedButtonImage;
		departLabel1.hidden = NO;
		departLabel2.hidden = YES;
		runwayLabel1.hidden = YES;
		runwayLabel2.hidden = NO;
		[self setSliderXPosition:sliderRight];
	} else if(xPos < 59) {
		greySlider.alpha = 0.0;
		lastDepartureRunway = runwayLabel1.text;
		[delegate setDepartureRunway:runwayLabel1.text];	
		runwayLabel1.textColor = [UIColor whiteColor];
		buttonSlider.image = selectedButtonImage;
		departLabel1.hidden = YES;
		departLabel2.hidden = NO;
		runwayLabel1.hidden = NO;
		runwayLabel2.hidden = YES;
		[self setSliderXPosition:sliderLeft];
	} else {
		if(![lastDepartureRunway isEqualToString:@""]) {
			lastDepartureRunway = @"";
			[delegate setDepartureRunway:@""];	
		}
		greySlider.alpha = 1.0;
		departLabel1.hidden = YES;
		departLabel2.hidden = YES;
		runwayLabel1.hidden = NO;
		runwayLabel2.hidden = NO;
		buttonSlider.image = unselectedButtonImage;
		[self setSliderXPosition:sliderCenter];
	}
	
	[self setNeedsDisplay];
}

- (void) moveSlider:(float) delta {	
	CGRect rect = buttonSlider.frame;
	rect.origin.x += delta;
	buttonSlider.frame = rect;
	
	[self setNeedsDisplay];
	
}

- (void) setSliderXPosition:(int) x {	
	CGRect rect = buttonSlider.frame;
	rect.origin.x = x;
	buttonSlider.frame = rect;
	
	[self setNeedsDisplay];
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}

- (void) clearSlider:(NSString*) s {
    
	if(!([runwayLabel1.text isEqualToString:s] ||  [runwayLabel2.text isEqualToString:s])) {
		if(![s isEqualToString:@""]) {
			greySlider.alpha = 1.0;
			departLabel1.hidden = YES;
			departLabel2.hidden = YES;
			runwayLabel1.hidden = NO;
			runwayLabel2.hidden = NO;
			buttonSlider.image = unselectedButtonImage;
			runwayLabel1.textColor = [UIColor lightGrayColor];
			runwayLabel2.textColor = [UIColor lightGrayColor];
			[self setSliderXPosition:sliderCenter];
			[self setNeedsDisplay];
		}
	}
}

- (BOOL) hasRunway:(NSString *)rwy {
    
    if([runwayLabel1.text isEqualToString:rwy] || [runwayLabel2.text isEqualToString:rwy]) {
        return true;
    }
    return false;
}

- (void) setDepartureRunway:(NSString *)rwy {
    if([rwy isEqualToString:runwayLabel1.text]) {
		greySlider.alpha = 0.0;
		lastDepartureRunway = runwayLabel1.text;
		runwayLabel1.textColor = [UIColor whiteColor];
		buttonSlider.image = selectedButtonImage;
		departLabel1.hidden = YES;
		departLabel2.hidden = NO;
		runwayLabel1.hidden = NO;
		runwayLabel2.hidden = YES;
		[self setSliderXPosition:sliderLeft];
    } else if([rwy isEqualToString:runwayLabel2.text]) {
		greySlider.alpha = 0.0;
		lastDepartureRunway = runwayLabel2.text;
		runwayLabel2.textColor = [UIColor whiteColor];
		buttonSlider.image = selectedButtonImage;
		departLabel1.hidden = NO;
		departLabel2.hidden = YES;
		runwayLabel1.hidden = YES;
		runwayLabel2.hidden = NO;
		[self setSliderXPosition:sliderRight];
    }
    
}


@end
