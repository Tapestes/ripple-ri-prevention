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
#import "Runway.h"

@protocol SetDepartureRunwayDelegate <NSObject>

- (void)setDepartureRunway:(NSString*)runwayName;

@end


@interface SetRunwaySliderView : UIView <SetDepartureRunwayDelegate> {
	Runway* runway;
	UIImageView* blueSlider;
	UIImageView* greySlider;
	UIImageView* buttonSlider;
			
	UILabel* runwayLabel1;
	UILabel* runwayLabel2;
	UILabel* departLabel1;
	UILabel* departLabel2;

	UIImage* blueSliderImage;
	UIImage* greySliderImage;	
	UIImage* unselectedButtonImage;
	UIImage* selectedButtonImage;
	
	int sliderLeft;
	int sliderCenter;
	int sliderRight;
	
	id <SetDepartureRunwayDelegate> delegate;
	NSString* lastDepartureRunway;
}

@property (retain) Runway* runway;
@property (retain) UIImageView* blueSlider;
@property (retain) UIImageView* greySlider;
@property (retain) UIImageView* buttonSlider;

@property (retain) UILabel* runwayLabel1;
@property (retain) UILabel* runwayLabel2;
@property (retain) UILabel* departLabel1;
@property (retain) UILabel* departLabel2;

@property (retain) UIImage* blueSliderImage;
@property (retain) UIImage* greySliderImage;
@property (retain) UIImage* unselectedButtonImage;
@property (retain) UIImage* selectedButtonImage;

@property (assign) int sliderLeft;
@property (assign) int sliderCenter;
@property (assign) int sliderRight;

@property (retain) id <SetDepartureRunwayDelegate> delegate;
@property (retain) NSString* lastDepartureRunway;

- (id) initWithRunway:(Runway*)r index:(int)idx;
- (UIImage*) loadImage:(NSString*)name type:(NSString*)type;
- (void) buildSliders;
- (void) buildLabels;
- (void) buildSliderButton;
- (void) moveSlider:(float) delta;	
- (void) setSliderXPosition:(int) x;
- (void) clearSlider:(NSString*) s;
- (BOOL) hasRunway:(NSString*) s;
@end
