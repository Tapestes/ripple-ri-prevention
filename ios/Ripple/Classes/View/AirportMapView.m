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



#import "AirportMapView.h"

@implementation AirportMapView

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		
		self.backgroundColor = [UIColor clearColor];
		self.hidden = YES;
		self.scalesPageToFit = YES;
		self.delegate = self;
	}
	return self;
}

- (void)showAirportMap:(NSString*)imagePath {
    
	//NSString* imagePath = [ [ NSBundle mainBundle ] pathForResource: @"airport_missing" ofType: @"png" ];
	//NSURL* imageURL = [ [ NSURL alloc ] initFileURLWithPath: imagePath ];
	
	//imageURL = [[NSURL alloc] initWithString:@"http://flightaware.com/resources/airport/IND/APD/AIRPORT+DIAGRAM/pdf"];
	imageURL = [[NSURL alloc] initWithString:imagePath];
	[self loadRequest: [ NSURLRequest requestWithURL: imageURL ] ];	
	self.hidden = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
	BOOL result = [request.URL isEqual:imageURL];
	
	if(!result) {
		UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 321)];
		NSString* imagePath = [ [ NSBundle mainBundle ] pathForResource: @"airport_missing" ofType: @"png" ];
		imageView.image          = [UIImage imageWithContentsOfFile:imagePath];	
		[self addSubview:imageView];
	}
	return result;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
}


@end