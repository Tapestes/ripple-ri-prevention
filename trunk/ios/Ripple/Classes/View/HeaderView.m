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

#import "HeaderView.h"


@implementation HeaderView

@synthesize airportLabel;
@synthesize headsetButton;
@synthesize headsetButton2;
@synthesize departureButton;
@synthesize delegate;
@synthesize unsetRunwayImage;
@synthesize setRunwayImage;
@synthesize audioRecorder;
@synthesize headsetImage;
@synthesize headsetImageOn;
@synthesize headsetImageOn1;
@synthesize headsetImageOn2;
@synthesize headsetImageOn3;
@synthesize timer;
@synthesize talkingTimer;
@synthesize airport;
@synthesize recorder;
@synthesize talking;
@synthesize listening;
@synthesize talkingCounter;
@synthesize path;

int imageCounter = 0;


- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
        talking = NO;
        listening = NO;
        
        NSString* folder = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        NSString* name= @"listening.wav";
        path = [folder stringByAppendingPathComponent:name];
        
		NSString* imagePath = [ [ NSBundle mainBundle ] pathForResource: @"header-32" ofType: @"png" ];
		self.image = [UIImage imageWithContentsOfFile:imagePath];		
		
		airportLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(245, 10, 60, 20)];
		airportLabel.backgroundColor  = [UIColor clearColor];
		airportLabel.font             = [UIFont boldSystemFontOfSize:18.0];
		airportLabel.textColor		  = [UIColor whiteColor];
		airportLabel.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		airportLabel.shadowOffset     = CGSizeMake(1, 2);
		airportLabel.textAlignment    = UITextAlignmentRight;
		[self addSubview:airportLabel];
		
		NSString* headsetImagePath = [ [ NSBundle mainBundle ] pathForResource: @"mic_off" ofType: @"png" ];
		NSString* headsetImageOnPath = [ [ NSBundle mainBundle ] pathForResource: @"mic_on" ofType: @"png" ];
		NSString* headsetImageOn1Path = [ [ NSBundle mainBundle ] pathForResource: @"mic_on1" ofType: @"png" ];
		NSString* headsetImageOn2Path = [ [ NSBundle mainBundle ] pathForResource: @"mic_on2" ofType: @"png" ];
		NSString* headsetImageOn3Path = [ [ NSBundle mainBundle ] pathForResource: @"mic_on3" ofType: @"png" ];
		headsetImage = [UIImage imageWithContentsOfFile:headsetImagePath];		
		headsetImageOn = [UIImage imageWithContentsOfFile:headsetImageOnPath];		
		headsetImageOn1 = [UIImage imageWithContentsOfFile:headsetImageOn1Path];		
		headsetImageOn2 = [UIImage imageWithContentsOfFile:headsetImageOn2Path];		
		headsetImageOn3 = [UIImage imageWithContentsOfFile:headsetImageOn3Path];		
		
		headsetButton	= [[UIButton alloc] initWithFrame:CGRectMake(143, 7, 40, 28)];
		[headsetButton setBackgroundImage:headsetImage forState:UIControlStateNormal];
		[self addSubview:headsetButton];
        //[headsetButton addTarget:self action:@selector(manageMics) forControlEvents:UIControlEventTouchUpInside];
		headsetButton2	= [[UIButton alloc] initWithFrame:CGRectMake(143, 7, 40, 28)];
		[headsetButton2 setBackgroundImage:headsetImageOn1 forState:UIControlStateNormal];
		[self addSubview:headsetButton2];
        headsetButton2.hidden = true;
        //[headsetButton2 addTarget:self action:@selector(manageMics) forControlEvents:UIControlEventTouchUpInside];


		NSString* unsetImagePath = [ [ NSBundle mainBundle ] pathForResource: @"departure-button-not-set-32" ofType: @"png" ];
		unsetRunwayImage = [UIImage imageWithContentsOfFile:unsetImagePath];		
		NSString* setImagePath = [ [ NSBundle mainBundle ] pathForResource: @"departure-button-set-32" ofType: @"png" ];
    
		setRunwayImage = [UIImage imageWithContentsOfFile:setImagePath];		
		
		defaultButtonText = @"Departure Rwy";
		
		departureButton	= [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 91, 27)];
		[departureButton setBackgroundImage:unsetRunwayImage forState:UIControlStateNormal];
		[departureButton setTitle: defaultButtonText forState:UIControlStateNormal];
		departureButton.titleLabel.font             = [UIFont boldSystemFontOfSize:11.0];
		departureButton.titleLabel.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
		departureButton.titleLabel.shadowOffset     = CGSizeMake(1, 2);
		[departureButton addTarget:delegate action:@selector(toggleSetDepartureView) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:departureButton];
		
		self.layer.borderColor = [UIColor blackColor].CGColor;
		self.layer.borderWidth = 0.3;
		
		self.layer.shadowOffset = CGSizeMake(2.0, 2.0);
		self.layer.shadowRadius = 2.0;
		self.layer.shadowOpacity = 0.8;
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.clipsToBounds = NO;
        
        audioRecorder = [[AudioRecorder alloc] init];
		
		
	}
	return self;
}

- (void) configureAirport:(Airport*) a {
    self.airport = a;
    airportLabel.text = [NSString stringWithFormat:@"%@", airport.airportCode];	
    audioRecorder.runways = airport.runways;
    audioRecorder.delegate = self.delegate;
    audioRecorder.delegate2 = self.delegate;

}

- (void)setDepartureRunwayName:(NSString*) runway {
	if([runway isEqualToString:@""]) {
		[departureButton setTitle: defaultButtonText forState:UIControlStateNormal];
		[departureButton setBackgroundImage:unsetRunwayImage forState:UIControlStateNormal];
		departureButton.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
	} else {
		[departureButton setTitle: [NSString stringWithFormat:@"Depart %@", runway] forState:UIControlStateNormal];	
		[departureButton setBackgroundImage:setRunwayImage forState:UIControlStateNormal];
		departureButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	}
	[departureButton setNeedsDisplay];
}

- (void) showShadow {
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	[self setNeedsDisplay];
}

- (void) hideShadow {
	self.layer.shadowColor = [UIColor clearColor].CGColor;
	[self setNeedsDisplay];
}

- (void) handleRecording {    
    if(audioRecorder.isRecording == YES) {
        NSLog(@"stopping recording");
        [audioRecorder stopRecording];
        [timer invalidate];
        [headsetButton2 setBackgroundImage:headsetImageOn forState:UIControlStateNormal];
        
    } else {
        NSLog(@"starting recording");
        [audioRecorder startRecording];
        imageCounter = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(updateImage) userInfo:nil repeats:YES];

    }
}

- (void) updateImage {    
    if(imageCounter == 0) {        
		headsetButton.hidden = YES;
		headsetButton2.hidden = NO;
    } else if(imageCounter == 1) {
		[headsetButton2 setBackgroundImage:headsetImageOn2 forState:UIControlStateNormal];
    } else if(imageCounter == 2) {
		[headsetButton2 setBackgroundImage:headsetImageOn3 forState:UIControlStateNormal];
    } else if(imageCounter == 3) {
		[headsetButton2 setBackgroundImage:headsetImageOn2 forState:UIControlStateNormal];
    } else if(imageCounter == 4) {
		[headsetButton2 setBackgroundImage:headsetImageOn1 forState:UIControlStateNormal];
    } else {
		headsetButton.hidden = NO;
		headsetButton2.hidden = YES;
        imageCounter = -1;
    }
    imageCounter++;

}

- (void) manageMics {
    if(listening) {
        if(audioRecorder.isRecording == YES) {
            NSLog(@"stopping recording");
            [audioRecorder stopRecording];
            [timer invalidate];
        }
        
        [recorder stop];
        [talkingTimer invalidate];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:url error:nil];

        [headsetButton setBackgroundImage:headsetImage forState:UIControlStateNormal];
        headsetButton.hidden = NO;
        headsetButton2.hidden = YES;
        
        talking = NO;

    } else {
     
        NSError *error;
            
        // Recording settings
        NSMutableDictionary *settings = [NSMutableDictionary dictionary];
        //[settings setValue: [NSNumber numberWithInt:kAudioFormatULaw] forKey:AVFormatIDKey];
        [settings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [settings setValue: [NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
        [settings setValue: [NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
            
        
        // File URL
        NSURL *url = [NSURL fileURLWithPath:path];
            
        NSLog(@"File path: %@", path);
            
        // Create recorder
        [self setRecorder:[[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error]];
        if (![self recorder]) {
            NSLog(@"Error: %@", [error localizedDescription]);
            return;
        }
            
        // Initialize degate, metering, etc.
        //self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
            
        // Prepare the recording
        if (![self.recorder prepareToRecord]) {
            NSLog(@"Error: Prepare to record failed");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                    message:@"Error preparing recording" 
                                                                   delegate:nil 
                                                          cancelButtonTitle:@"Okay" 
                                                          otherButtonTitles:nil];
            [alertView show];
            return;
        }
            
        // Start recording
        if (![[self recorder] record]) {
            NSLog(@"Error: Record failed");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                    message:@"Error recording audio" 
                                                                   delegate:nil 
                                                          cancelButtonTitle:@"Okay" 
                                                          otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        [headsetButton setBackgroundImage:headsetImageOn forState:UIControlStateNormal];
        talkingTimer = [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(detectTalking) userInfo:nil repeats:YES];
        talking = NO;


    }
    
    listening = !listening;
    
}

- (void) detectTalking {
    [recorder updateMeters];
    
    //const double alpha = .05;
    //double peakPowerForChannel = pow(10, (.05 * [recorder peakPowerForChannel:0]));
    //double lowPassResults = (alpha * peakPowerForChannel) + (.95 * lowPassResults);
    
    //NSLog(@"audio: %f, %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0]);
    
    double power = [recorder peakPowerForChannel:0];
    if(!talking) {
        //if(power > -20) {
        if(power > -10) {
            NSLog(@"Someone has STARTED talking!!!");
            talkingCounter = 0;
            talking = !talking;
            [self handleRecording];
        }
    } else {
        //if (power < -40) {
        if (power < -18) {
            talkingCounter++;
            if(talkingCounter > 10) {
                NSLog(@"Someone has STOPPED talking!!!");
                talking = !talking;
                [self handleRecording];

            }
        }
    }    
}

@end
