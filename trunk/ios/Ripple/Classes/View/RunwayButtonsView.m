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



#import "RunwayButtonsView.h"

@implementation RunwayButtonsView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setupRunways:(NSMutableArray*) runwayNames {
    int size = [runwayNames count];
    int x, y;
    UIImage* selImage  = [UIImage imageNamed:@"Rwy-Slider-Slider-Bright-Red-for-Hold-Short-32.png"];

    int height = 50 + ((size / 3) * 70);
    if((size % 3) != 0) {
        height += 70;
    }
    
    self.frame = CGRectMake(10, 65, 300, height);
    
    for(int idx=0; idx < size; idx++) {
        NSLog(@"runway: %@", [runwayNames objectAtIndex:idx]);
        
        x = 15 + ((idx % 3) * 90);
        y = 50 + ((idx / 3) * 70);
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom]; 
        button.frame = CGRectMake(x, y, 80, 50);        
        
        [button setBackgroundImage:selImage forState:UIControlStateNormal];
        [button setTitle:[runwayNames objectAtIndex:idx] forState:UIControlStateNormal];

        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
    }
    
    UIImage* greyImage = [UIImage imageNamed:@"Grey-Banner-Background-32.png"];

    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom]; 
    button.frame = CGRectMake(265, 10, 25, 25);        
    
    [button setBackgroundImage:greyImage forState:UIControlStateNormal];
    [button setTitle:@"x" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];

}

- (void) click:(UIButton*) button {
    NSLog(@"runway: %@", button.titleLabel.text);
    [delegate setRunwayName:button.titleLabel.text];
    self.hidden = YES;
}

- (void) cancel {
    self.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
