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



#import "Airport.h"

@implementation Airport
@synthesize runways;
@synthesize airportCode;
@synthesize imagePath;
@synthesize location;

-(id)init {
    self = [ super init ];
	if (self != nil) {
		runways = [ [ NSMutableArray alloc ] init ];
		location = nil;
	}
	return self;
}


-(id)initWithName:(NSString *)name withLocation:(CLLocation*) loc {
	self = [ super init ];
	if (self != nil) {		
		//NSLog(@"%s creating airport: %@", __func__, name);
		
		runways = [ [ NSMutableArray alloc ] init ];
		self.airportCode = name;
		self.imagePath = [NSString stringWithFormat:@"http://flightaware.com/resources/airport/%@/APD/AIRPORT+DIAGRAM/pdf", name];
		self.location = loc;
	}
	return self;
}

-(id)initWithContentsOfFile:(NSString *)path withAirportCode:(NSString *)_airportCode {
	self = [ super init ];
	if (self != nil) {
		NSXMLParser *parser;
		
		//NSLog(@"%s creating airport: %@", __func__, _airportCode);
		
		runways = [ [ NSMutableArray alloc ] init ];
		self.airportCode = [NSString stringWithFormat:@"%@", _airportCode];
		self.imagePath = [NSString stringWithFormat:@"http://flightaware.com/resources/airport/%@/APD/AIRPORT+DIAGRAM/pdf", _airportCode];
		
		parser = [ [ NSXMLParser alloc ] initWithData: [ NSData dataWithContentsOfFile: path ] ];
		[ parser setDelegate: self ];
        [ parser setShouldProcessNamespaces: NO ];
        [ parser setShouldReportNamespacePrefixes: NO ];
        [ parser setShouldResolveExternalEntities: NO ];
        [ parser parse ];
    }
	return self;
}


/* NSXMLParserDelegate methods */

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
		
	if ([ elementName isEqualToString: @"airport" ]) {
		if ([ [ attributeDict objectForKey: @"id" ] isEqualToString: airportCode ]) {
			myAirport = YES;
		} else {
			myAirport = NO;
		}
		currentLon = currentLat = 0.0;
	}
	
	else if ([ elementName isEqualToString: @"runway" ] && myAirport == YES) {
		currentRunway = [ [ Runway alloc ] init ];
		currentLon = currentLat = 0.0;
	}
	
	currentElement = [ elementName copy ];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	/* Clean up */
	string = [ string stringByReplacingOccurrencesOfString: @"\n" withString: @"" ];
	if ([ string isEqualToString: @" " ])
		string = @"";
	if (string == nil || [ string isEqualToString: @"" ] )
		return;
		
	if (myAirport != YES) {
		return;
	}
    
	if ([ currentElement isEqualToString: @"latitude" ] && currentLat == 0.0) {
		currentLat = [ string doubleValue ];
		if (currentLat != 0.0 && currentLon != 0.0)
			self.location = [ [ CLLocation alloc ] initWithLatitude: currentLat longitude: currentLon ];
	} else if ([ currentElement isEqualToString: @"longitude" ] && currentLon == 0.0) {
		currentLon = [ string doubleValue ];
		if (currentLat != 0.0 && currentLon != 0.0)
			self.location = [ [ CLLocation alloc ] initWithLatitude: currentLat longitude: currentLon ];
	}
	
	/* Runway vertices */
	if ([ currentElement isEqualToString: @"coordinates" ]) {
		NSArray* points = [string componentsSeparatedByString:@" "];
		for(NSString* point in points) {
			if(![point isEqualToString:@""]) {
				NSArray* pointParts = [point componentsSeparatedByString:@","];	
				currentLon = [[pointParts objectAtIndex:0] floatValue];	
				currentLat = [[pointParts objectAtIndex:1] floatValue];	
				CLLocation *vertex = [ [ CLLocation alloc ] initWithLatitude: currentLat longitude: currentLon ];
				[currentRunway.vertices addObject: vertex ];
                
			}
		}
		
	}	

    NSLog(@"current element: %@", currentElement);
    
	/* Runway information */
	if ([ currentElement isEqualToString: @"runwayNumber" ]) {
		NSLog(@"%s setting runway number: %@", __func__, string);
		currentRunway.name = string;
	}
	if ([ currentElement isEqualToString: @"runwayName" ]) {
		NSLog(@"%s setting runway fullname: %@", __func__, string);
		currentRunway.fullName = string;
	}
	if ([ currentElement isEqualToString: @"runwayBaseOrientation" ]) {
		NSLog(@"%s setting runway heading1: %@", __func__, string);
		currentRunway.heading1 = [string intValue];
	}
	if ([ currentElement isEqualToString: @"runwayReciprocalOrientation" ]) {
		NSLog(@"%s setting runway heading2: %@", __func__, string);
		currentRunway.heading2 = [string intValue];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
		
	if (myAirport != YES)
		return;
    
	if ([ elementName isEqualToString: @"runway" ]) {
		[ runways addObject: currentRunway ];
		currentRunway = nil;
	}
	
	currentElement = nil;
}

@end
