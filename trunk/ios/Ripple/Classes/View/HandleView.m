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

#import "HandleView.h"


@implementation HandleView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		
		NSString* imagePath = [ [ NSBundle mainBundle ] pathForResource: @"footer-32" ofType: @"png" ];
		self.image          = [UIImage imageWithContentsOfFile:imagePath];		
		
		self.layer.borderColor = [UIColor blackColor].CGColor;
		self.layer.borderWidth = 0.3;
		
		self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
		self.layer.shadowRadius = 5.0;
		self.layer.shadowOpacity = 0.8;
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.clipsToBounds = NO;
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/


@end
