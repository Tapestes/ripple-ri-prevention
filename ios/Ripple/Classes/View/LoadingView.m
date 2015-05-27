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

#import "LoadingView.h"


@implementation LoadingView

@synthesize spinner;
@synthesize label;

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
				
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		spinner.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
		spinner.center = self.center;
		[self addSubview:spinner];
		
		label                  = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 20)];
		label.text			   = @"Locating airport...";
		label.backgroundColor  = [UIColor clearColor];
		label.font             = [UIFont boldSystemFontOfSize:18.0];
		label.textColor		   = [UIColor whiteColor];
		label.shadowColor      = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
        label.hidden = YES;
		label.shadowOffset     = CGSizeMake(1, 2);
		label.textAlignment    = UITextAlignmentCenter;
		[self addSubview:label];
		
		
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
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