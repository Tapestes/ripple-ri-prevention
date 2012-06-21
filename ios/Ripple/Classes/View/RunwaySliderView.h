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

@interface RunwaySliderView : UIView {
	Runway* runway;
	UIImageView* colorSlider;
	UIImageView* greySlider;
	UIImageView* buttonSlider;
	
	UILabel* crossLabel;
	UILabel* holdLabel;
	UILabel* runwayLabel;
	UILabel* clearedToCrossLabel;
	UILabel* holdShortLabel;
	
	UIImage* unselectedButtonImage;
	UIImage* selectedButtonImage;
	UIImage* blueSliderImage;
	UIImage* redSliderImage;
	
}

@property (retain) Runway* runway;
@property (retain) UIImageView* colorSlider;
@property (retain) UIImageView* greySlider;
@property (retain) UIImageView* buttonSlider;

@property (retain) UILabel* crossLabel;
@property (retain) UILabel* holdLabel;
@property (retain) UILabel* runwayLabel;
@property (retain) UILabel* clearedToCrossLabel;
@property (retain) UILabel* holdShortLabel;

@property (retain) UIImage* unselectedButtonImage;
@property (retain) UIImage* selectedButtonImage;
@property (retain) UIImage* blueSliderImage;
@property (retain) UIImage* redSliderImage;

- (id) initWithRunway:(Runway*)r index:(int)idx;
- (UIImage*) loadImage:(NSString*)name type:(NSString*)type;
- (void) buildSliders;
- (void) buildLabels;
- (void) buildSliderButton;
- (void) moveSlider:(float) delta;	
- (void) setSliderXPosition:(int) x;
- (void) setRunwaySliderStateWithXPos:(int) xPos;
- (void) setSliderForRunway:(NSString*)runwayName withState:(RunwayState)state;



@end
