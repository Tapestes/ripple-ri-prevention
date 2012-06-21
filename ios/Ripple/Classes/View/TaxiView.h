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
#import "RunwayButtonsView.h"
#import "Airport.h"
#import "SetRunwaySliderView.h"
#import "FullRunwayButtonsView.h"

@protocol TaxiViewDelegate<NSObject>

- (void) taxiPathChanged:(NSString*) text;
@optional
- (void) updateSliderForRunway:(NSString*) runwayName withState:(RunwayState) state;


@end

@interface TaxiView : UIView <SetRunwayDelegate, AircraftCommandDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate> {
    
    IBOutlet UIButton *holdShort, *taxi, *lineUp, *cross;
    IBOutlet UIButton *one, *two, *three, *four, *five, *six, *seven, *eight, *nine, *zero;
    IBOutlet UIButton *q, *w, *e, *r, *t, *y, *u, *i, *o, *p;
    IBOutlet UIButton *a, *s, *d, *f, *g, *h, *j, *k, *l;
    IBOutlet UIButton *comma, *z, *x, *c, *v, *b, *n, *m, *period;
    IBOutlet UIButton *bksp, *space, *done;
    IBOutlet UIButton *runway, *cancel;
    
    IBOutlet RunwayButtonsView *runwayButtonsView;
    IBOutlet FullRunwayButtonsView *fullRunwayButtonsView;
    Airport* airport;
    NSMutableArray *runwayNames, *fullRunwayNames, *commandList, *savedCommands;
    
    NSString* departureRunway, *lastCommand;
    id<SetDepartureRunwayDelegate> delegate;
    id<TaxiViewDelegate> taxiDelegate;
    
    IBOutlet UITextView* textArea;
    
    
}

@property (retain) Airport* airport;
@property (retain) id<SetDepartureRunwayDelegate> delegate;
@property (retain) id<TaxiViewDelegate> taxiDelegate;


- (void) setupButtonCallBacks;
- (void) setupRunways:(Airport*)ap departureRunway:(NSString*)rwy;
- (NSString*) buildTextFromCommands;
- (IBAction) keyHit:(id)sender;
- (void) showView;
- (void) showBkspAlert;
- (void) checkForSliderCommands;


@end
