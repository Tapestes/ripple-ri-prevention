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

#import "InfoTableViewController.h"


@implementation InfoTableViewController

@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

NSString* disclaimer = @"The MITRE Corporationís Center for Advanced Aviation System Development (CAASD) is soliciting the help of 30 pilots for a study to assess situation awareness and workload of flight crews during departure and arrival operations.\n\nThe data collected during this study, as in all our research, is	aggregated and de-identified prior to analysis and reporting. Individual pilots and their input are not identifiable in the results that are reported out.\n\nThe study is expected to require a half day of participation (0800-1200 or 1230-1630) and will include introductory briefings, warm-up flying in the CAASD flight deck simulator, a block of data collection trials, and exit briefings. Pilot opinion data will be collected after each trial and again at the completion of the study. Participants will be paid $180 for participating and completing the study. Any transportation and lodging costs will be the responsibility of the pilot volunteer.\n\nParticipants must have previous experience as a pilot in FAR Part 121 or Part 135 operations. Both Captains and First Officers are eligible. Pilots who have been furloughed within the past 12 months are eligible. A current medical certificate is not required, but participants must have flown as a crewmember in air carrier or on-demand charter operations within the last 12 months. Preference will be given to pilots who have not flown in a CAASD study within the previous 12 months.\n\nIf you would be interested in participating in this research please contact Suzette Porter at 703-983-2024 or porters@mitre.org. Expressing interest does not guarantee a spot in the study. If selected to participate, pilots will be scheduled for a morning or afternoon participant slot Monday through Friday of each week, beginning July 11th and continuing through July 29th. If you have availability on more than one day please indicate your scheduling preferences in order.\n\nThank you for your interest and support in the advancement of aviation!";

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle{
	if (self = [super initWithNibName:nibName bundle:nibBundle]) {
		self.title = @"Settings";
    }
    return self;
}



/*- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Settings";

}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch(section) {
		case 0:
			return 2;
			break;
		case 1:
			return 5;
			break;
		case 2:
			return 1;
			break;
		default:
			return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [ NSString stringWithFormat: @"%d/%d", indexPath.section, indexPath.row ];
    UITableViewCell* cell;
    NSString* audioAlerts;
    NSString* runwayAlerts;
    UISwitch* mySwitch;
    UISwitch* mySwitch2;
    
	//UIView *cellContentView = cell.contentView;
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
					}
					cell.textLabel.text = @"Provide Aural Alerts";
                    
                    audioAlerts = [[NSUserDefaults standardUserDefaults] stringForKey:@"AudioAlerts"];
					mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
					if([audioAlerts isEqualToString:@"YES"]) {
						[mySwitch setOn:YES];
					} else {
						[mySwitch setOn:NO];					
					}
					[cell addSubview:mySwitch];
					cell.accessoryView = mySwitch;
					[mySwitch addTarget:self action:@selector(audioAlertSwitchToggled) forControlEvents: UIControlEventTouchUpInside];
                     
					break;
				case 1:
					cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
					}
					cell.textLabel.text = @"Announce RWY";
					runwayAlerts = [[NSUserDefaults standardUserDefaults] stringForKey:@"RunwayAlerts"];
					mySwitch2 = [[UISwitch alloc] initWithFrame:CGRectZero];
					if([runwayAlerts isEqualToString:@"YES"]) {
						[mySwitch2 setOn:YES];
					} else {
						[mySwitch2 setOn:NO];					
					}
					[cell addSubview:mySwitch2];
					cell.accessoryView = mySwitch2;
					[mySwitch2 addTarget:self action:@selector(runwayAlertSwitchToggled) forControlEvents: UIControlEventTouchUpInside];
					break;
				default:
					break;

			}			
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
					}
					cell.textLabel.text = @"View Legal/Copyright Info";
					break;
				case 1:
					cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
					}
					cell.textLabel.text = @"Version";
					cell.detailTextLabel.text = @"1.0";
					break;
				case 2:
					cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
					}
					cell.textLabel.text = @"Developed by";
					cell.detailTextLabel.text = @"The MITRE Corp.";
					break;
				case 3:
					cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
					}
					cell.textLabel.text = @"Contact Us";
					break;
				case 4:
					cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
					}
					cell.textLabel.text = @"Debug Map";
					break;
				default:
					break;
			}			
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					if (cell == nil) {
						cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
					}
					cell.textLabel.text = @"Exit Settings";
					break;
                default:
                    break;
            }
            break;
	}	
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return @"Audio Settings";
    } else if (section==1) {
        return @"Information";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section) {
		case 1:
			switch (indexPath.row) {
				case 0:
					[self showLegal];
					break;
				case 3:
					[self emailRipple];
					break;
				case 4:
					[self showDebugMap];
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					[self exitSettings];
					break;
            }
            break;
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void) audioAlertSwitchToggled {
	//NSLog(@"Audio switch toggled");
	
	NSString* audioAlerts = [[NSUserDefaults standardUserDefaults] stringForKey:@"AudioAlerts"];
	if([audioAlerts isEqualToString:@"YES"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"AudioAlerts"];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"AudioAlerts"];
	}

}

- (void) runwayAlertSwitchToggled {
	//NSLog(@"Runway switch toggled");
	NSString* runwayAlerts = [[NSUserDefaults standardUserDefaults] stringForKey:@"RunwayAlerts"];
	if([runwayAlerts isEqualToString:@"YES"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"RunwayAlerts"];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"RunwayAlerts"];
	}
	
}

- (void) showLegal {
	UIAlertView* legalView = [[UIAlertView alloc] initWithTitle:@"Legal Disclaimer" message:disclaimer delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
	[legalView show];		
}

- (void) emailRipple {
	NSString *emailIDString = @"mailto:ripple@mitre.org";
	if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailIDString]]) {
		// there was an error trying to open the URL.
		//for the time b_view we'll ignore it.
	}	
}

- (void) showDebugMap {
    self.view.hidden = YES;
    [delegate showDebugMap];
}


- (void) exitSettings {
    self.view.hidden = YES;

    //[self dismissViewControllerAnimated:YES completion:NULL];
   
}


@end

