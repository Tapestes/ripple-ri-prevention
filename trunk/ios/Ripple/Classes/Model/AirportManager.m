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

#import "AirportManager.h"


@implementation AirportManager

@synthesize initialLocation;
int fiveMiles = 8050;  

-(id)init {
    self = [ super init ];
	if (self != nil) {
		airports = [ [ NSMutableArray alloc ] init ];
		airportNames = [ [ NSMutableArray alloc ] init ];
		loaded = NO;
		myAirport = nil;
	}
	return self;
}

-(NSArray *)airports {
	if (loaded == NO)
		[ self reloadData ];
	return airports;
}

-(void)reloadData {
	//Quadrant Check
	double lat = initialLocation.coordinate.latitude;
	double lon = initialLocation.coordinate.longitude;
	NSString* filename = nil;
	
	if (lat >= 40 && lon < -100) {               //NW
		filename = @"ripple-runways_NW";
	} else if (lat >= 40 && lon >= -100) {     //NE
		filename = @"ripple-runways_NE";
	} else if (lat < 40 && lon < -100) {         //SW
		filename = @"ripple-runways_SW";
	} else {									//SE (lat < 40 && lon >= -100)
		filename = @"ripple-runways_SE";
	}
		
	
	NSXMLParser *parser;
	NSString *path = [ [ NSBundle mainBundle ] pathForResource:filename ofType: @"xml" ];
    NSLog(@"file: %@", filename);
    NSLog(@"path: %@", path);
	
	[ airports removeAllObjects ];
	[ airportNames removeAllObjects ];
	
	parser = [ [ NSXMLParser alloc ] initWithData: [ NSData dataWithContentsOfFile: path ] ];
	[ parser setDelegate: self ];
	[ parser setShouldProcessNamespaces: NO ];
	[ parser setShouldReportNamespacePrefixes: NO ];
	[ parser setShouldResolveExternalEntities: NO ];
	[ parser parse ];
		
	loaded = YES;
}

/* NSXMLParserDelegate methods */

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
attributes:(NSDictionary *)attributeDict {
	
	if ([ elementName isEqualToString: @"airport" ]) {
		currentAirportName = [ attributeDict objectForKey: @"id" ];
		currentLat = currentLon = 0.0;
		myAirport = nil;

	}
	else if ([ elementName isEqualToString: @"runway" ] && myAirport != nil) {
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
	
	
	if ([ currentElement isEqualToString: @"latitude" ] && currentLat == 0.0) {
		currentLat = [ string doubleValue ];

	} else if ([ currentElement isEqualToString: @"longitude" ] && currentLon == 0.0) {
		currentLon = [ string doubleValue ];
		CLLocation* loc = [ [ CLLocation alloc ] initWithLatitude: currentLat longitude: currentLon ];
		CLLocationDistance distanceMeters = [ loc distanceFromLocation: initialLocation ];
        //NSLog(@"Distance: %f", distanceMeters);
		if(distanceMeters < fiveMiles) {
			[airportNames addObject: currentAirportName ];
			myAirport = [ [ Airport alloc ] initWithName:currentAirportName withLocation:loc ];
			[airports addObject: myAirport ];
		}		
	}
	
	if (myAirport == nil) {
		return;
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
	
	/* Runway information */
	if ([ currentElement isEqualToString: @"runwayNumber" ]) {
		currentRunway.name = string;
	}
    if ([ currentElement isEqualToString: @"runwayName" ]) {
		currentRunway.fullName = string;
	}

	if ([ currentElement isEqualToString: @"runwayBaseOrientation" ]) {
		currentRunway.heading1 = [string intValue];
	}
	if ([ currentElement isEqualToString: @"runwayReciprocalOrientation" ]) {
		currentRunway.heading2 = [string intValue];
	}
	
	return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if (myAirport == nil)
		return;
	
	if ([ elementName isEqualToString: @"runway" ]) {
		[myAirport.runways addObject: currentRunway ];
		currentRunway = nil;
	}
	
	currentElement = nil;
	return;
}

- (Airport*)findClosestAirportToLocation:(CLLocation *)currentLocation
{
	if(airportNotFound)
		return nil;
	
	//NSLog(@"Finding closest airport");
	Airport *closestAirport = nil;
	double closestDistance = -1;
	
	
	if (currentLocation.coordinate.latitude != 0) {
		for (Airport *airport in self.airports)
		{
			CLLocationDistance distanceMeters = [ airport.location distanceFromLocation: currentLocation ];
			NSLog(@"%s airport %@ [%f,%f] distance %f kilometers", __func__, airport.airportCode, airport.location.coordinate.latitude, airport.location.coordinate.longitude, distanceMeters / 1000.0);
			
			if (closestDistance == -1) {
				closestDistance = distanceMeters;
				closestAirport = airport;
			} else if (distanceMeters < closestDistance) {
				closestDistance = distanceMeters;
				closestAirport = airport;
			}
		}
	}
	
	if(closestAirport == nil) {
		airportNotFound = TRUE;
		/*noAirportFoundView = [[UIAlertView alloc] initWithTitle:@"No Airport Found!" message:@"It appears that you are trying to use the Ripple App, but are not located at an airport. You must be within 5 miles of an airport in order for the application to work correctly.\n\nPlease continue by choosing an option below." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Upload Saved Data", @"Contact MITRE", @"Exit", nil];
		
		[noAirportFoundView show];			
         */
        
        return nil;
		
	} else {
		myAirport = closestAirport;
        return myAirport;
	}
}


@end