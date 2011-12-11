//
//  SettingsViewController.m
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "ButtonCell.h"
#import "SliderCell.h"

NSString* g_setNames[] = {
	@"Base", @"Alchemy", @"Seaside", @"Intrigue", @"Prosperity", @"Cornucopia", @"Hinterlands", @"Promo",
};

NSUInteger g_setCount = sizeof(g_setNames)/sizeof(g_setNames[0]);
NSString* kPreferenceNameSetPickingEnable = @"SetPickingEnable";
NSString* kPreferenceNameSetCount = @"SetPickingCount";

enum
{
	kSectionSets = 0,
	kSectionSetPicking = 1,
} SectionIndices;

@implementation SettingsViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Settings", @"Settings view title")];
	_preferences = [[NSArray alloc] initWithObjects:g_setNames count:sizeof(g_setNames)/sizeof(g_setNames[0])];

	{
		UILabel* versionFooter = [[UILabel alloc] init];
		versionFooter.font            = [UIFont systemFontOfSize:12.0];
		versionFooter.backgroundColor = [UIColor groupTableViewBackgroundColor];
		versionFooter.textAlignment   = UITextAlignmentCenter;
		versionFooter.textColor       = [UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1.0];
		versionFooter.shadowColor     = [UIColor whiteColor];
		versionFooter.shadowOffset    = CGSizeMake(0.0, 1.0);
		versionFooter.lineBreakMode   = UILineBreakModeWordWrap;
		versionFooter.numberOfLines   = 2;
		versionFooter.text            = NSLocalizedString(@"Version ID\n0000000000000000000000000000000000000000", @"Version string");
		[versionFooter sizeToFit];
		self.tableView.tableFooterView = versionFooter;
		[versionFooter release];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[_preferences release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == kSectionSets)
	{
		return @"Sets";
	}
	else
	{
		return @"Card Picking Method";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(section == kSectionSetPicking)
	{
		return @"Enabling this will cause random sets to be chosen first and then cards from those sets, rather than random cards from all enabled sets.";
	}

	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == kSectionSets)
	{
		// Return the number of rows in the section.
		return [_preferences count];
	}
	else if(section == kSectionSetPicking)
	{
		return 2;
	}
	return 0;
}

- (void)setSwitchWasToggled:(UISwitch*)theSwitch
{
	NSInteger row = [theSwitch tag];
	[[NSUserDefaults standardUserDefaults] setBool:[theSwitch isOn] forKey:[_preferences objectAtIndex:row]];
	BOOL anyEnabled = NO;
	for(NSString* aSet in _preferences)
	{
		if([[NSUserDefaults standardUserDefaults] boolForKey:aSet])
		{
			anyEnabled = YES;
			break;
		}
	}
	// If none are enabled set the base set enabled
	if(!anyEnabled)
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[_preferences objectAtIndex:0]];
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		NSArray* indexArray = [NSArray arrayWithObject:indexPath];
		ButtonCell* theCell = (ButtonCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		[theCell.button setOn:YES animated:YES];
		[self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void)updateSetPickingCountLabel:(SliderCell*)cell
{
	NSInteger setPickingCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"SetPickingCount"];
	if(setPickingCount == 0)
	{
		cell.textLabel.text = @"Pick Random Sets";
	}
	else
	{
		cell.textLabel.text = [NSString stringWithFormat:@"Pick %d Sets", setPickingCount];
	}
}

- (void)setPickingSwitchWasToggled:(UISwitch*)theSwitch
{
	[[NSUserDefaults standardUserDefaults] setBool:[theSwitch isOn] forKey:kPreferenceNameSetPickingEnable];
	SliderCell* setPickingCountCell = (SliderCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
	if([theSwitch isOn])
	{
		//Enable the count cell
		setPickingCountCell.textLabel.enabled = YES;
		setPickingCountCell.slider.enabled = YES;
	}
	else
	{
		setPickingCountCell.textLabel.enabled = NO;
		setPickingCountCell.slider.enabled = NO;
	}
}

- (void)setCountWasChanged:(UISlider*)theSlider
{
	[[NSUserDefaults standardUserDefaults] setFloat:theSlider.value forKey:kPreferenceNameSetCount];
	[self updateSetPickingCountLabel:(SliderCell*)theSlider.superview.superview];
}

- (ButtonCell*)getButtonCell:(UITableView*)tableView
{
	static NSString *buttonCellIdentifier = @"ButtonCell";
	ButtonCell *cell = (ButtonCell*)[tableView dequeueReusableCellWithIdentifier:buttonCellIdentifier];
	if (cell == nil) {
		cell = [[[ButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCellIdentifier] autorelease];
	}
	return cell;
}

- (SliderCell*)getSliderCell:(UITableView*)tableView
{
	static NSString *sliderCellIdentifier = @"SliderCell";
	SliderCell *cell = (SliderCell*)[tableView dequeueReusableCellWithIdentifier:sliderCellIdentifier];
	if (cell == nil) {
		cell = [[[SliderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sliderCellIdentifier] autorelease];
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([indexPath section] == kSectionSets)
	{
		ButtonCell *cell = [self getButtonCell:tableView];

		// Configure the cell...
		NSString* aPref = [_preferences objectAtIndex:[indexPath row]];
		//[[cell textLabel] setText:[aCard objectForKey:@"card"]];
		cell.textLabel.text = aPref;
		cell.button.on = [[NSUserDefaults standardUserDefaults] boolForKey:aPref];
		cell.button.tag = [indexPath row];
		[cell.button addTarget:self action:@selector(setSwitchWasToggled:) forControlEvents:UIControlEventValueChanged];

		return cell;
	}
	else if([indexPath section] == kSectionSetPicking)
	{
		if([indexPath row] == 0)
		{
			ButtonCell *cell = [self getButtonCell:tableView];

			// Configure the cell...
			cell.textLabel.text = @"Pick By Set";
			cell.button.on = [[NSUserDefaults standardUserDefaults] boolForKey:kPreferenceNameSetPickingEnable];
			[cell.button addTarget:self action:@selector(setPickingSwitchWasToggled:) forControlEvents:UIControlEventValueChanged];

			return cell;
		}
		else if([indexPath row] == 1)
		{
			SliderCell *cell = [self getSliderCell:tableView];

			// Configure the cell...
			cell.slider.minimumValue = 0;
			cell.slider.maximumValue = g_setCount;
			cell.slider.value = [[NSUserDefaults standardUserDefaults] floatForKey:kPreferenceNameSetCount];
			cell.slider.enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kPreferenceNameSetPickingEnable];
			cell.textLabel.enabled = cell.slider.enabled;
			[self updateSetPickingCountLabel:cell];

			[cell.slider addTarget:self action:@selector(setCountWasChanged:) forControlEvents:UIControlEventValueChanged];

			return cell;
		}
	}
	return nil;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"selected %@", [[_cardPicks objectAtIndex:[indexPath row]] valueForKey:@"card"]);
	NSDictionary* aCard = [_cardPicks objectAtIndex:[indexPath row]];
	CardDetailViewController* detailViewController = [[CardDetailViewController alloc] initWithNibName:@"CardDetailViewController" bundle:[NSBundle mainBundle] properties:aCard];
	[self.navigationController pushViewController:detailViewController animated:YES];
}
*/
@end
