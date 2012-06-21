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
#import "Airport.h"

@interface AirportManager : NSObject <NSXMLParserDelegate> {
	NSMutableArray *airportNames;
	NSMutableArray *airports;
	BOOL loaded;
    BOOL airportNotFound;
	
	/* NSXMLParser */
	NSString *currentElement;	
	NSString *currentAirportName;	
	double currentLon, currentLat;
	CLLocation* initialLocation;
	Runway *currentRunway;
	Airport* myAirport;
}

@property (nonatomic, retain) CLLocation* initialLocation;

-(NSArray *)airports;
-(void)reloadData;
- (Airport*)findClosestAirportToLocation:(CLLocation *)currentLocation;

@end
