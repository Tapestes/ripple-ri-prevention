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

#import "AlertRecord.h"

@implementation AlertRecord

const double MS_TO_KNOTS2 = 1.9438444924406;
const double M_TO_FEET2 = 3.2808399;

@synthesize startTime;
@synthesize startLatitude;
@synthesize startLongitude;
@synthesize startHeading;
@synthesize startSpeed;
@synthesize startAltitude;

@synthesize endTime;
@synthesize endLatitude;
@synthesize endLongitude;
@synthesize endHeading;
@synthesize endSpeed;
@synthesize endAltitude;

@synthesize alertType;
@synthesize userFeedback;
@synthesize airportCode;
@synthesize runwayName;

@synthesize activeAlert;

- (id) init {
	self = [ super init ];
	if (self != nil) {
		activeAlert = FALSE;
		alertType = -1;
		userFeedback = -1;
		
		UIDevice *myDevice = [UIDevice currentDevice];
		deviceId = [myDevice uniqueIdentifier];
		NSLog(@"deviceId: %@", deviceId);
		
		airportCode = @"LOG";
		
		//putController = [[PutController alloc] init];
		fileManager = [[NSFileManager alloc] init];
		logFileName = @"oldAlerts.dat";
		
	}
	return self;
	
}

-(void) reset {
	
	activeAlert = FALSE;

	startTime = 0;
	startLatitude = 0;
	startLongitude = 0;
	startHeading = 0;
	startSpeed = 0;
	startAltitude = 0;

	endTime = 0;
	endLatitude = 0;
	endLongitude = 0;
	endHeading = 0;
	endSpeed = 0;
	endAltitude = 0;
	
	alertType = -1;
	userFeedback = -1;

	airportCode = nil;
	runwayName = nil;
}


- (void) startAlertWithAlertType:(int)at airportCode:(NSString*)code runwayName:(NSString*)rw location:(CLLocation*)loc heading:(double)hdg {
	startTime = round(1000.0 * [[NSDate date] timeIntervalSince1970]);
		
	alertType = at;
		
	startLatitude = loc.coordinate.latitude;
	startLongitude = loc.coordinate.longitude;
	startHeading = hdg;
	startSpeed = loc.speed * MS_TO_KNOTS2;
	startAltitude = loc.altitude * M_TO_FEET2;
	
	airportCode = [NSString stringWithFormat:@"%@", code];
	runwayName = [NSString stringWithFormat:@"%@", rw];
	
	activeAlert = TRUE;
	
}

- (void) closeAlertWithLocation:(CLLocation*)loc heading:(double)hdg reason:(int) r {
	NSString* report = [self getFinalReport:loc heading:hdg reason:r];
	[self sendReport:report];
	
}

- (NSString*) getFinalReport:(CLLocation*)loc heading:(double)hdg reason:(int) r {
	endTime = round(1000.0 * [[NSDate date] timeIntervalSince1970]);
	
	endLatitude = loc.coordinate.latitude;
	endLongitude = loc.coordinate.longitude;
	endHeading = hdg;
	endSpeed = loc.speed * MS_TO_KNOTS2;
	endAltitude = loc.altitude * M_TO_FEET2;
	
	activeAlert = FALSE;	
	
	
	NSString* report = [NSString stringWithFormat:@"%@,%qi,%f,%f,%f,%f,%f,%qi,%f,%f,%f,%f,%f,%@,%@,%@,%@,%@\n", 
						deviceId, startTime, startLatitude, startLongitude,
						startHeading, startSpeed, startAltitude, endTime,
						endLatitude, endLongitude, endHeading, endSpeed, 
						endAltitude, [self getAlertString], 
						[self getUserFeedbackString], airportCode, runwayName, [self getEndType:r]];
	//NSLog(@"report: %@", report);
		
	return report;
	
}

- (void) logClosingAlertWithLocation:(CLLocation*)loc heading:(double)hdg reason:(int) r {
	NSString* report = [self getFinalReport:loc heading:hdg reason:r];
	[self appendToLogFile:report];
}

-(NSString*) sendReport:(NSString*) report {
	//NSString* report = @"blah blah blah\n";
	//NSLog(@"report: %@", report);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:logFileName];
		
	BOOL oldFileExists = [[NSFileManager defaultManager] fileExistsAtPath:logFilePath];
	
	if(!oldFileExists && [report isEqualToString:@""]) {
		return @"No data to send.";
	}
	
	/*if(remoteHostStatus == NotReachable) { 
	//if(YES) { 
		//NSLog(@"ftp not reachable");
		[self appendToLogFile:report];
		
	} else if ((remoteHostStatus == ReachableViaWWAN) || (remoteHostStatus == ReachableViaWiFi)) { 
		//NSLog(@"ftp reachable");
		long long filetime = round(1000.0 * [[NSDate date] timeIntervalSince1970]);
		if(airportCode == nil)
			airportCode = @"LOG";

		NSString* filename = [NSString stringWithFormat:@"%@_%qi.dat", airportCode, filetime];
		//NSLog(@"filename: %@", filename);
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
		
		BOOL success = [report writeToFile:filePath atomically:YES encoding:NSASCIIStringEncoding error:NULL];
		//BOOL success = [report writeToFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename] atomically:YES encoding:NSASCIIStringEncoding error:NULL];
		//NSLog(@"filepath_write: %@", filePath);
		if(success) {
			if(oldFileExists) {
				NSString* oldData = [NSString stringWithContentsOfFile:logFilePath encoding:NSASCIIStringEncoding error:NULL];
				NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:filePath];
				[output seekToEndOfFile];
				[output writeData:[oldData dataUsingEncoding:NSASCIIStringEncoding]];
				[output closeFile];
				//NSLog(@"Old file added to new file");				
				
				[[NSFileManager defaultManager] removeItemAtPath:logFilePath error:NULL];
				//NSLog(@"Old log file deleted");				
			}
			[putController sendFile:filePath];
		} else {
			NSLog(@"Error creating report file.");
			[self appendToLogFile:report];
		}
	}
	*/
	return @"Alert Discarded. No FTP mechanism.";
}

-(void) appendToLogFile:(NSString*) report {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:logFileName];
	
	//NSString *logFilePath = [[NSBundle mainBundle] pathForResource:logFileName ofType:nil];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:logFilePath];
	
	if(fileExists) {
		NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
		[output seekToEndOfFile];
		[output writeData:[report dataUsingEncoding:NSASCIIStringEncoding]];
		[output closeFile];
		//NSLog(@"Old file appended");
	} else {
		[report writeToFile:logFilePath atomically:YES encoding:NSASCIIStringEncoding error:NULL];
		//BOOL success = [report writeToFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], logFileName] atomically:YES encoding:NSASCIIStringEncoding error:NULL];
		//NSLog(@"Old file written: %d", success);
	}
}

//alertType == 1   ->   HOLD SHORT
//alertType == 2   ->   CROSSING
//alertType == 3   ->   APPROACHING
//alertType == 4   ->   WRONG RUNWAY

- (NSString*) getAlertString {
	
	if(alertType == 1) {
		return @"HOLD_SHORT";
	} else if(alertType == 2) {
		return @"CROSSING";
	} else if(alertType == 3) {
		return @"NO_CLEARANCE";
	} else if(alertType == 4) {
		return @"WRONG_RUNWAY";
	} else {
		return @"INVALID_ALERT";		
	}
	
}

- (NSString*) getUserFeedbackString {
	
	if(userFeedback == -1) {
		return @"NO_RESPONSE";
	} else if(userFeedback == 0) {
		return @"EARLY_ALERT";
	} else if(userFeedback == 1) {
		return @"GOOD_ALERT";
	} else if(userFeedback == 2) {
		return @"LATE_ALERT";
	} else if(userFeedback == 3) {
		return @"FALSE_ALERT";
	} else {
		return @"NO_RESPONSE";		
	}
	
}

- (NSString*) getEndType:(int)reason {
	if(reason == 0) {
		return @"NEW_ALERT";
	} else if(reason == 1) {
		return @"CLEARED_ALERT";
	} else { //(reason == 2)
		return @"SYSTEM_EXIT";
	}
		
}

@end
