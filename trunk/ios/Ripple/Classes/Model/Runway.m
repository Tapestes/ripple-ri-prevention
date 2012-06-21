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



#import "Runway.h"

@implementation Runway

@synthesize vertices;
@synthesize name;
@synthesize fullName;
@synthesize idx;
@synthesize state;
@synthesize heading1;
@synthesize heading2;
@synthesize stateHasChanged;

-(id)init {
    self = [ super init ];
	if (self != nil) {
		vertices = [ [ NSMutableArray alloc ] init ];
        state = RunwayNeutralState;
		stateHasChanged = FALSE;
	}
	return self;
}

- (void) setState:(RunwayState)s {
    state = s;
    stateHasChanged = TRUE;
}

@end
