//
//  SettingsViewController.m
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "ButtonCell.h"

NSString* g_setNames[] = {
	@"Base", @"Alchemy", @"Seaside", @"Intrigue", @"Prosperity", @"Promo",
};

@implementation SettingsViewController

+ (void)initialize
{
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	for(NSInteger i = 0; i < sizeof(g_setNames)/sizeof(g_setNames[0]); ++i)
	{
		[defaults setValue:[NSNumber numberWithBool:YES] forKey:g_setNames[i]];
	}
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:NSLocalizedString(@"Settings", @"Settings view title")];
	_preferences = [[NSArray alloc] initWithObjects:g_setNames count:sizeof(g_setNames)/sizeof(g_setNames[0])];

	// Disabled until "Run Script" actions work again. Environment variables are broken
	if(0)
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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Sets";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_preferences count];
}

- (void)switchWasToggled:(UISwitch*)theSwitch
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PreferenceCell";

    ButtonCell *cell = (ButtonCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
	NSString* aPref = [_preferences objectAtIndex:[indexPath row]];
	//[[cell textLabel] setText:[aCard objectForKey:@"card"]];
	cell.textLabel.text = aPref;
	cell.button.on = [[NSUserDefaults standardUserDefaults] boolForKey:aPref];
	cell.button.tag = [indexPath row];
	[cell.button addTarget:self action:@selector(switchWasToggled:) forControlEvents:UIControlEventValueChanged];

    return cell;
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
