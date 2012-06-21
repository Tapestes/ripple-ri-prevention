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
#import <QuartzCore/QuartzCore.h>
#import "AudioRecorder.h"
#import "Airport.h"


@interface HeaderView : UIImageView {
	UILabel* airportLabel;
	UIButton* headsetButton;
	UIButton* headsetButton2;
	UIButton* departureButton;
	id delegate;
	NSString* defaultButtonText;
	
	UIImage* unsetRunwayImage;
	UIImage* setRunwayImage;
    
    UIImage* headsetImage;
    UIImage* headsetImageOn;
    UIImage* headsetImageOn1;
    UIImage* headsetImageOn2;
    UIImage* headsetImageOn3;
    NSTimer *timer;
    AVAudioRecorder* recorder;

    Airport* airport;
    AudioRecorder* audioRecorder;
    BOOL talking, listening;
    NSString* path;
    NSTimer* talkingTimer;
    int talkingCounter;
}

@property (retain) UILabel* airportLabel;
@property (retain) UIButton* headsetButton;
@property (retain) UIButton* headsetButton2;
@property (retain) UIButton* departureButton;
@property (retain) id delegate;
@property (retain) UIImage* unsetRunwayImage;
@property (retain) UIImage* setRunwayImage;
@property (retain) UIImage* headsetImage;
@property (retain) UIImage* headsetImageOn;
@property (retain) UIImage* headsetImageOn1;
@property (retain) UIImage* headsetImageOn2;
@property (retain) UIImage* headsetImageOn3;
@property (retain) AudioRecorder* audioRecorder;
@property (retain) AVAudioRecorder* recorder;
@property (retain) NSTimer* timer;
@property (retain) NSTimer* talkingTimer;
@property (retain) Airport* airport;
@property (assign) BOOL talking;
@property (assign) BOOL listening;
@property (assign) int talkingCounter;
@property (retain) NSString* path;


- (void) configureAirport:(Airport*) a;
    
- (void)setDepartureRunwayName:(NSString*) runway;
- (void) showShadow;
- (void) hideShadow;
- (void) manageMics;
- (void) detectTalking;
@end
