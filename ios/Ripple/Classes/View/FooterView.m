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

#import "FooterView.h"


@implementation FooterView

@synthesize taxiButton;
@synthesize infoButton;
@synthesize delegate;

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		NSString* imagePath = [ [ NSBundle mainBundle ] pathForResource: @"gradiant-glass-footer-32" ofType: @"png" ];
		self.image = [UIImage imageWithContentsOfFile:imagePath];		
		
		NSString* taxiImagePath = [ [ NSBundle mainBundle ] pathForResource: @"taxi-keyboard-button-32" ofType: @"png" ];
		UIImage* taxiImage = [UIImage imageWithContentsOfFile:taxiImagePath];		
		
		taxiButton	= [[UIButton alloc] initWithFrame:CGRectMake(10, 1, 72, 38)];
		[taxiButton setBackgroundImage:taxiImage forState:UIControlStateNormal];
		[self addSubview:taxiButton];
		
		NSString* infoImagePath = [ [ NSBundle mainBundle ] pathForResource: @"info-button-32" ofType: @"png" ];
		UIImage* infoImage = [UIImage imageWithContentsOfFile:infoImagePath];		
		
		infoButton	= [[UIButton alloc] initWithFrame:CGRectMake(270, 1, 40, 38)];
		[infoButton setBackgroundImage:infoImage forState:UIControlStateNormal];

		[self addSubview:infoButton];
				
	}
	return self;
}

- (void) setupInfoButtonCallBack {
	[infoButton addTarget:delegate action:@selector(infoButtonHit) forControlEvents:UIControlEventTouchUpInside];
	//[taxiButton addTarget:delegate action:@selector(taxiButtonHit) forControlEvents:UIControlEventTouchUpInside];
}



- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

@end
