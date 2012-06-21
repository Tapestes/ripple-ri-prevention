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
#import <AVFoundation/AVFoundation.h>
#import "Runway.h"
#import "TaxiView.h"

@interface AudioRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate, NSURLConnectionDelegate> {
    
    AVAudioRecorder *recorder;
	AVAudioSession *session;
    BOOL isRecording;
    
    NSMutableData *responseData;
	NSURLConnection *connectionresponse ;
	NSURL *webServiceURL;
	NSMutableURLRequest *urlRequest;
    NSMutableArray *runways;
    
    id<TaxiViewDelegate> delegate;
    id<SetDepartureRunwayDelegate> delegate2;
    NSArray* numbers;

}

@property (assign) BOOL isRecording;
@property (retain) AVAudioSession *session;
@property (retain) AVAudioRecorder *recorder;
@property (retain) NSMutableData *responseData;
@property (retain) NSURLConnection *connectionresponse;
@property (retain) NSURL *webServiceURL;
@property (retain) NSMutableURLRequest *urlRequest;
@property (retain) NSMutableArray* runways;
@property (retain) id<TaxiViewDelegate> delegate;
@property (retain) id<SetDepartureRunwayDelegate> delegate2;
@property (retain) NSArray* numbers;


-(BOOL) startRecording;
-(void) stopRecording;
-(void)parseCommand:(NSString *)message;
-(void) processCommand:(NSString*)command forRunway:(NSString*) runwayName;
-(NSString*) findNextCommand:(NSString*)msg;
-(NSString*) findNextRunway:(NSString*)msg;
@end
