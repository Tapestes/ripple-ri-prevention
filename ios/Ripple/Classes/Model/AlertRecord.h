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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AlertRecord : NSObject {
	long long startTime;
	double startLatitude;
	double startLongitude;
	double startHeading;
	double startSpeed;
	double startAltitude;
	
	long long endTime;
	double endLatitude;
	double endLongitude;
	double endHeading;
	double endSpeed;
	double endAltitude;
	
	int alertType;
	int userFeedback;
	NSString* airportCode;
	NSString* runwayName;
	NSString* deviceId;
	NSString* logFileName;
	
	//Reachability* internetReachable;
    //Reachability* hostReachable;
	//PutController* putController;
	NSFileManager* fileManager;
	BOOL activeAlert;
}

@property(assign) long long startTime;
@property(assign) double startLatitude;
@property(assign) double startLongitude;
@property(assign) double startHeading;
@property(assign) double startSpeed;
@property(assign) double startAltitude;

@property(assign) long long endTime;
@property(assign) double endLatitude;
@property(assign) double endLongitude;
@property(assign) double endHeading;
@property(assign) double endSpeed;
@property(assign) double endAltitude;

@property(assign) int alertType;
@property(assign) int userFeedback;
@property(retain) NSString* airportCode;
@property(retain) NSString* runwayName;
@property(assign) BOOL activeAlert;

- (void) reset;
- (void) startAlertWithAlertType:(int)at airportCode:(NSString*)code runwayName:(NSString*)runway location:(CLLocation*)loc heading:(double)hdg;
- (void) closeAlertWithLocation:(CLLocation*)loc heading:(double)hdg reason:(int)r;
- (void) logClosingAlertWithLocation:(CLLocation*)loc heading:(double)hdg reason:(int)r;
- (NSString*) getFinalReport:(CLLocation*)loc heading:(double)hdg reason:(int) r;

- (NSString*) getAlertString;
- (NSString*) getUserFeedbackString;
- (NSString*) getEndType:(int)reason;
- (NSString*) sendReport:(NSString*) report;  
-(void) appendToLogFile:(NSString*) report;


@end
