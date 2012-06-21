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
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVPlayer.h>

@protocol AlertViewDelegate <NSObject>

- (void)showMiniAlert;

@end

@interface AlertView : UIView <AVAudioPlayerDelegate> {
	UIImageView* maxBackgroundView;
	UIImageView* crossingBackgroundView;
	UILabel* holdShortLabel;
	UILabel* noClearanceLabel;
	UILabel* noTakeoffLabel;
	UILabel* crossingLabel;
	UILabel* tooFastLabel;
	UILabel* badGpsLabel;
	UILabel* badGpsLabel2;
	int alertType;
	AVAudioPlayer* player;	
	NSMutableArray* alertSequence;
	int alertIndex;
	id<AlertViewDelegate> delegate;
    
    UIImage* redBackground;
    UIImage* orangeBackground;
}

@property (retain) UIImageView* maxBackgroundView;
@property (retain) UIImageView* crossingBackgroundView;
@property (retain) UILabel* holdShortLabel;
@property (retain) UILabel* noClearanceLabel;
@property (retain) UILabel* noTakeoffLabel;
@property (retain) UILabel* crossingLabel;
@property (assign) int alertType;
@property (retain) id delegate;
@property (assign) int alertIndex;
@property (retain) AVAudioPlayer* player;
@property (retain) NSMutableArray* alertSequence;


- (void) setAlert:(int)t onRunway:(NSString*)rw;
- (void) playAudioAlert:(NSString*) s onRunway:(NSString*)rw;
- (void) stopAndClearPlayer;

@end
