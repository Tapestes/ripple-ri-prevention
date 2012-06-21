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



#import "TaxiView.h"

@implementation TaxiView

@synthesize airport;
@synthesize delegate;
@synthesize taxiDelegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) showView {
    NSLog(@"command count: %d", [commandList count]);
    NSLog(@"saved count: %d", [savedCommands count]);
    if([commandList count] > 0)
        [commandList removeAllObjects];
    if([savedCommands count] > 0) {
        [commandList addObjectsFromArray:savedCommands];
    }
    NSString* text = [self buildTextFromCommands];
    textArea.text = text;
    self.hidden = NO;
}

- (void) setupButtonCallBacks {
    lastCommand = @"";
    commandList = [[NSMutableArray alloc] initWithCapacity:0];
    savedCommands = [[NSMutableArray alloc] initWithCapacity:0];
    textArea.scrollEnabled = YES;
    
    
    lineUp.titleLabel.textAlignment = UITextAlignmentCenter;
    [lineUp setTitle: @"Line\nUp" forState: UIControlStateNormal];
    [lineUp setTitle: @"Line\nUp" forState: UIControlStateApplication];
    [lineUp setTitle: @"Line\nUp" forState: UIControlStateHighlighted];
    [lineUp setTitle: @"Line\nUp" forState: UIControlStateReserved];
    [lineUp setTitle: @"Line\nUp" forState: UIControlStateSelected];
    [lineUp setTitle: @"Line\nUp" forState: UIControlStateDisabled];
    
    holdShort.titleLabel.textAlignment = UITextAlignmentCenter;
    [holdShort setTitle: @"Hold\nShort" forState: UIControlStateNormal];
    [holdShort setTitle: @"Hold\nShort" forState: UIControlStateApplication];
    [holdShort setTitle: @"Hold\nShort" forState: UIControlStateHighlighted];
    [holdShort setTitle: @"Hold\nShort" forState: UIControlStateReserved];
    [holdShort setTitle: @"Hold\nShort" forState: UIControlStateSelected];
    [holdShort setTitle: @"Hold\nShort" forState: UIControlStateDisabled];
    
    
	[done addTarget:self action:@selector(doneHit) forControlEvents:UIControlEventTouchUpInside];
	[cancel addTarget:self action:@selector(cancelHit) forControlEvents:UIControlEventTouchUpInside];
	[runway addTarget:self action:@selector(runwayHit) forControlEvents:UIControlEventTouchUpInside];
	[holdShort addTarget:self action:@selector(holdShortHit) forControlEvents:UIControlEventTouchUpInside];
	[lineUp addTarget:self action:@selector(lineupHit) forControlEvents:UIControlEventTouchUpInside];
	[cross addTarget:self action:@selector(crossHit) forControlEvents:UIControlEventTouchUpInside];
	[taxi addTarget:self action:@selector(taxiHit) forControlEvents:UIControlEventTouchUpInside];
	[bksp addTarget:self action:@selector(bkspHit) forControlEvents:UIControlEventTouchUpInside];
	[space addTarget:self action:@selector(spaceHit) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *bkspLongpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bkspLongPressHandler:)];
    bkspLongpressGesture.minimumPressDuration = 1.0;
    [bkspLongpressGesture setDelegate:self];
    [bksp addGestureRecognizer:bkspLongpressGesture];

    UILongPressGestureRecognizer *spaceLongpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(spaceLongPressHandler:)];
    spaceLongpressGesture.minimumPressDuration = 1.0;
    [spaceLongpressGesture setDelegate:self];
    [space addGestureRecognizer:spaceLongpressGesture];
}

- (void)bkspLongPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Bksp Long press Began");
        [self showBkspAlert];
    }
    
}

- (void)spaceLongPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Space Long press Began");
        [commandList addObject:@"~"];
        NSString* text = [self buildTextFromCommands];
        textArea.text = text;

    }
    
}

- (void) showBkspAlert {
    UIAlertView* bkspView = [[UIAlertView alloc] initWithTitle:@"Backspace Actions" message:@"What would you like to do?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete Last Command", @"Remove All Commands", nil];
	[bkspView show];	
}

- (void)alertView : (UIAlertView *)alertView1 clickedButtonAtIndex : (NSInteger)buttonIndex
{
	if([alertView1.title isEqualToString:@"Backspace Actions"]) {        
        if(buttonIndex == 1) {
            [commandList removeLastObject];
            NSString* text = [self buildTextFromCommands];
            textArea.text = text;
        } else if(buttonIndex == 2) {
            [commandList removeAllObjects];
            NSString* text = [self buildTextFromCommands];
            textArea.text = text;
		}
    } 
}



- (void) setupRunways:(Airport*) ap departureRunway:(NSString *)rwy{
    [self setRunwayName:rwy];
    runwayButtonsView.delegate = self;
    fullRunwayButtonsView.delegate = self;
    self.airport = ap;
    runwayNames = [[NSMutableArray alloc] initWithCapacity:0];
    fullRunwayNames = [[NSMutableArray alloc] initWithCapacity:0];
    for(Runway* rwy in airport.runways) {
        //NSLog(@"runway: %@", rwy.name);
        [fullRunwayNames addObject:rwy.name];
        NSArray* array = [rwy.name componentsSeparatedByString:@"-"]; 
        [runwayNames addObject:[array objectAtIndex:0]];
        [runwayNames addObject:[array objectAtIndex:1]];
        
    }   
    
    [runwayButtonsView setupRunways:runwayNames];
    [fullRunwayButtonsView setupRunways:fullRunwayNames];
        
}


- (void) cancelHit { self.hidden = YES; }
- (void) runwayHit { runwayButtonsView.hidden = NO; }
- (void) holdShortHit { 
    fullRunwayButtonsView.titleLabel.text = @"Hold Short of:";
    fullRunwayButtonsView.hidden = NO; 
    lastCommand = @"Hold Short of RWY ";
}
- (void) crossHit { 
    fullRunwayButtonsView.titleLabel.text = @"Cross:";
    fullRunwayButtonsView.hidden = NO; 
    lastCommand = @"Cross RWY ";
}
- (void) lineupHit { 
    fullRunwayButtonsView.titleLabel.text = @"Line Up and Wait On:";
    fullRunwayButtonsView.hidden = NO; 
    lastCommand = @"Line Up and Wait - RWY ";

}
- (void) taxiHit { 
    lastCommand = @"Taxi via: "; 
    [self commandForRunway:@""];
}

- (void) spaceHit { 
    NSString* text = @" ";
    NSLog(@"key hit: '%@'", text);
    if([commandList count] == 0) {
        [commandList addObject:text];
    } else  {
        NSString* command = [commandList lastObject];
        command = [NSString stringWithFormat:@"%@%@", command, text];
        int idx = [commandList count] - 1;
        [commandList replaceObjectAtIndex:idx withObject:command];
    }
    text = [self buildTextFromCommands];
    textArea.text = text;
}

- (void) bkspHit { 
    NSLog(@"bksp hit");
    if([commandList count] != 0) {
        NSString* text = [commandList lastObject];
        if(!([text isEqualToString:@""])) {
            text = [text substringToIndex:([text length]-1)];
            [commandList removeLastObject];
            if(![text isEqualToString:@""]) {
                [commandList addObject:text];
            }
            
            text = [self buildTextFromCommands];
            textArea.text = text;
        }
    }
}

- (void) doneHit { 
    self.hidden = YES; 
    if(![departureRunway isEqualToString:@""]) {
        [delegate setDepartureRunway:departureRunway];
    }
    
    [savedCommands removeAllObjects];
    [savedCommands addObjectsFromArray:commandList];
    
    [taxiDelegate taxiPathChanged:textArea.text];
    [self checkForSliderCommands];
    
}

- (void) checkForSliderCommands {
    for(NSString* command in commandList) {
        NSRange rangeHS = [command rangeOfString:@"Hold Short"];
        NSRange rangeCC = [command rangeOfString:@"Cross RWY"];
        NSRange rangeLW = [command rangeOfString:@"Line Up"];
        
        NSString* runwayName = [[command componentsSeparatedByString:@" "] lastObject];
        
        NSLog(@"checking: %@ for commands: %d, %d, %d", command, rangeHS.location, rangeCC.location, rangeLW.location);
        
        if(rangeHS.location != NSNotFound) { [taxiDelegate updateSliderForRunway:runwayName withState:RunwayWatchedState]; }
        else if(rangeCC.location != NSNotFound) { [taxiDelegate updateSliderForRunway:runwayName withState:RunwayClearState]; }
        else if(rangeLW.location != NSNotFound) { [taxiDelegate updateSliderForRunway:runwayName withState:RunwayWatchedState]; }
        
        
    }
}

- (void) setRunwayName:(NSString *)runwayName {
    if([runwayName isEqualToString:@""])
        [runway setTitle:@"UNK" forState:UIControlStateNormal];
    else
        [runway setTitle:runwayName forState:UIControlStateNormal];
    departureRunway = runwayName;
}

- (void) commandForRunway:(NSString *)runwayName {
    if([commandList count] == 0) {
        [commandList addObject:[NSString stringWithFormat:@"%@%@", lastCommand, runwayName]];
        lastCommand = @"";
    } else {
        NSString* text = [commandList lastObject];
        if([text isEqualToString:@"~"]) {
            [commandList removeLastObject];
        }
        [commandList addObject:[NSString stringWithFormat:@"%@%@", lastCommand, runwayName]];
        lastCommand = @"";
    }
    NSString* text = [self buildTextFromCommands];
    textArea.text = text;
}

- (NSString*) buildTextFromCommands {
    int counter = 1;
    NSString* text = @"";
    for (NSString* command in commandList) {
        if([command isEqualToString:@"~"])
            text = [NSString stringWithFormat:@"%@%d: %@\n", text, counter, @""];
        else
            text = [NSString stringWithFormat:@"%@%d: %@\n", text, counter, command];
        counter++;
        NSLog(@"building: %@", text);
    }
    
    if(![text isEqualToString:@""])
        text = [text substringToIndex:([text length]-1)];
    
    
    return text;
}

- (void) keyHit:(UIButton*) keybutton {
    NSString* text = keybutton.titleLabel.text;
    NSLog(@"key hit: '%@'", text);
    if([commandList count] == 0) {
        [commandList addObject:text];
    } else  {
        NSString* command = [commandList lastObject];
        [commandList removeLastObject];
        
        if([command isEqualToString:@"~"]) {
            [commandList addObject:text];
        } else {
            command = [NSString stringWithFormat:@"%@%@", command, text];
            [commandList addObject:command];
        }
    }
    text = [self buildTextFromCommands];
    textArea.text = text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
