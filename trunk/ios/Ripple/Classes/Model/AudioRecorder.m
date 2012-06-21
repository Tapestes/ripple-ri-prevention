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



#import "AudioRecorder.h"
#import <CoreAudio/CoreAudioTypes.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
#define FILENAME @"recording.wav"
#define FILEPATH [DOCUMENTS_FOLDER stringByAppendingPathComponent:FILENAME]
#define MIMETYPE @"audio/x-wav"


@implementation AudioRecorder

@synthesize isRecording;
@synthesize recorder;
@synthesize session;
@synthesize responseData;
@synthesize connectionresponse ;
@synthesize webServiceURL;
@synthesize urlRequest;
@synthesize runways;
@synthesize delegate;
@synthesize delegate2;
@synthesize numbers;


-(id)init {
    self = [ super init ];
	if (self != nil) {
        isRecording = false;
        numbers = [NSArray arrayWithObjects:@"zero",@"one",@"two",@"three",@"four",
                   @"five",@"six",@"seven",@"eight",@"nine", nil];
	}
	return self;
}

- (BOOL)startRecording
{
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
	NSURL *url = [NSURL fileURLWithPath:FILEPATH];
    
    NSLog(@"File path: %@", FILEPATH);
	
	// Create recorder
	[self setRecorder:[[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error]];
	if (![self recorder])
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}
	
	// Initialize degate, metering, etc.
	self.recorder.delegate = self;
	self.recorder.meteringEnabled = YES;
	
	// Prepare the recording
	if (![self.recorder prepareToRecord])
	{
		NSLog(@"Error: Prepare to record failed");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
															message:@"Error preparing recording" 
														   delegate:nil 
												  cancelButtonTitle:@"Okay" 
												  otherButtonTitles:nil];
		[alertView show];
		return NO;
	}
	
	// Start recording
	if (![[self recorder] record])
	{
		NSLog(@"Error: Record failed");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
															message:@"Error recording audio" 
														   delegate:nil 
												  cancelButtonTitle:@"Okay" 
												  otherButtonTitles:nil];
		[alertView show];
		return NO;
	}
    isRecording = YES;

	return YES;
}

- (void) stopRecording {
	[[self recorder] stop];
    isRecording = NO;

}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    
	// Update the text label
	NSLog(@"Done recording");
    		
	// Let the user know the file was saved
    /*	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Saved" 
     message:@"File Saved"
     delegate:nil 
     cancelButtonTitle:@"Okay" 
     otherButtonTitles:nil];
     [alertView show];
     [alertView autorelease];
     */

	NSLog(@"%s", __func__);
	
	webServiceURL = [ NSURL URLWithString: @"http://YOUR_SPEECHREC_SERVER.com" ];
	urlRequest = [ NSMutableURLRequest requestWithURL: webServiceURL ];
	[ urlRequest setHTTPMethod: @"POST" ];
	[ urlRequest setValue: @"multipart/form-data; boundary=----FOO" forHTTPHeaderField: @"Content-Type" ];
	
	NSString *boundary = @"----FOO";
    
	NSData *recording = [ NSData dataWithContentsOfFile: 
						 [ [ NSHomeDirectory() stringByAppendingPathComponent:@"tmp" ] 
						  stringByAppendingPathComponent: @"recording.wav" ] ];
	
	/* Multipart/Form-Data Body */
	NSMutableData *postBody = [ NSMutableData data ];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"audio/x-wav\"; filename=\"%@\"\r\n", @"recording.wav"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: audio/x-wav\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData: recording ];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[urlRequest setHTTPBody:postBody];
    
	responseData = [ [ NSMutableData alloc ] init ];
	connectionresponse = [ [ NSURLConnection alloc ] initWithRequest: urlRequest delegate: self startImmediately : YES];	
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *httpResponseHeaderFields = [httpResponse
											  allHeaderFields];
    NSLog(@"Connection did receive response: %@",
		  httpResponseHeaderFields);
	
	[ responseData setLength: 0 ];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[ responseData appendData: data ];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	NSString *result = [ [ NSString alloc ] initWithData: responseData encoding: NSASCIIStringEncoding ];
	NSString *message = result;
	NSArray *components = [ result componentsSeparatedByString: @">" ];
	for(int i=0; i < [ components count ]; i++) {
		NSString *c = [ components objectAtIndex: i ];
		if ([ c hasPrefix: @"<result id" ]) {
			message = [ [ [ components objectAtIndex: i+1 ] componentsSeparatedByString: @"<" ] objectAtIndex: 0 ];
			break;
		}
	}
	
	
	NSLog(@"%s %@", __func__, result);
    
	[self parseCommand: message];
    	
	// Once this method is invoked, "responseData" contains the complete result
    
	// <recognition-results type="asr" lang="enu"><result id='0' conf='1836'>cross</result><result id='1' conf='1393'>cleared</result></recognition-results>
    
    NSURL *url = [NSURL fileURLWithPath:FILEPATH];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:url error:nil];

}

-(void)parseCommand:(NSString *)message {
    NSLog(@"checking for commands in voice message: %@", message);
    [delegate taxiPathChanged:message];
    
    NSString* msg = [message lowercaseString];
    
    NSString* command = [self findNextCommand:msg];
    while(command != nil) {
        NSRange cmdRange = [msg rangeOfString:command];
        msg = [msg substringFromIndex:(cmdRange.location + cmdRange.length)];
        NSString* runwayName = [self findNextRunway:msg];
        
        if(runwayName != nil) {
            NSString* nextCommand = [self findNextCommand:msg];
            NSRange runwayRange = [msg rangeOfString:runwayName];
            
            if(nextCommand == nil) {
                //Do stuff for command + runwayName
                //And return
                NSLog(@"voice command: %@ %@", command, runwayName);
                [self processCommand:command forRunway:runwayName];
            } else {
                NSRange nextCmdRange = [msg rangeOfString:nextCommand];
        
                if(runwayRange.location < nextCmdRange.location) {
                    //Do stuff for command + runwayName
                    NSLog(@"voice command: %@ %@", command, runwayName);
                }
            }
        }
        
        command = [self findNextCommand:msg];
    }
    
    NSLog(@"Voice command check complete!");
    
    
    
}

-(void) processCommand:(NSString*)command forRunway:(NSString*) runwayName {
    //NSArray* words = [runwayName componentsSeparatedByString:@"_"];
    //NSString* name = [NSString stringWithFormat:@"%d%d", 
    //                  [numbers indexOfObject:[words objectAtIndex:0]],
    //                  [numbers indexOfObject:[words objectAtIndex:1]]];
    //NSLog(@"number name: %@", name);

    
    
    if([command isEqualToString:@"cross"]) {
        for(Runway* rwy in runways) {
            //NSLog(@"name: %@", rwy.name);
            //NSLog(@"name: %@", rwy.fullName);
            NSRange runwayRange = [rwy.fullName rangeOfString:runwayName];
            if(runwayRange.location != NSNotFound) {
                //Set Runway / Cross
                [delegate updateSliderForRunway:rwy.name withState:RunwayClearState];
     
            }
        }
    } else if([command isEqualToString:@"hold"]) {
        for(Runway* rwy in runways) {
            NSRange runwayRange = [rwy.fullName rangeOfString:runwayName];
            if(runwayRange.location != NSNotFound) {
                //Set Runway / Hold
                [delegate updateSliderForRunway:rwy.name withState:RunwayWatchedState];                
            }
        }     
    } else if([command isEqualToString:@"takeoff"]) {
        for(Runway* rwy in runways) {
            NSRange runwayRange = [rwy.fullName rangeOfString:runwayName];
            if(runwayRange.location != NSNotFound) {
                //Set Runway / Departure
                //[delegate2 setDepartureRunway:rwy.name];
                NSArray* words = [runwayName componentsSeparatedByString:@"_"];
                NSString* name = [NSString stringWithFormat:@"%d%d", 
                                  [numbers indexOfObject:[words objectAtIndex:0]],
                                  [numbers indexOfObject:[words objectAtIndex:1]]];
                NSArray* parts = [rwy.name componentsSeparatedByString:@"-"];
                NSRange partRange = [[parts objectAtIndex:0] rangeOfString:name];
                if(partRange.location != NSNotFound) {
                    [delegate2 setDepartureRunway:[parts objectAtIndex:0]];                       
                } else {
                    partRange = [[parts objectAtIndex:1] rangeOfString:name];
                    if(partRange.location != NSNotFound) {
                        [delegate2 setDepartureRunway:[parts objectAtIndex:1]];   
                    }                    
                }
            }
        }     
     }
}

-(NSString*) findNextCommand:(NSString*)msg {
    NSRange crossRange = [msg rangeOfString:@"cross"];
    NSRange holdShortRange = [msg rangeOfString:@"hold"];
    NSRange taxiRange = [msg rangeOfString:@"takeoff"];

    NSString* command = nil;
    int index = NSUIntegerMax;
    
    if(crossRange.location != NSNotFound) {
        if(crossRange.location < index) {
            index = crossRange.location;
            command = @"cross";
        }
    } else if(holdShortRange.location != NSNotFound) {
        if(holdShortRange.location < index) {
            index = holdShortRange.location;
            command = @"hold";
        }
    } else if(taxiRange.location != NSNotFound) {
        if(taxiRange.location < index) {
            index = taxiRange.location;
            command = @"takeoff";
        }
    }
    
    return command;
}

-(NSString*) findNextRunway:(NSString*)msg {

    int index = NSUIntegerMax;
    NSString* runwayName = nil;
    
    for(NSString* number1 in numbers) {
        for(NSString* number2 in numbers) {
            NSString* name = [NSString stringWithFormat:@"%@ %@", number1, number2];
            NSRange nameRange = [msg rangeOfString:name];
            if(nameRange.location != NSNotFound) {
                if(nameRange.location < index) {
                    index = nameRange.location;
                    runwayName = [NSString stringWithFormat:@"%@_%@", number1, number2];;
                }
            }
        }
    }
    
    return runwayName;
}



@end
