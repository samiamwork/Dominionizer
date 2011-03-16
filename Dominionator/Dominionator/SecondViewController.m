//
//  SecondViewController.m
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "ButtonCell.h"

NSString* g_setNames[] = {
	@"Base", @"Alchemy", @"Seaside", @"Intrigue", @"Prosperity", nil
};

@implementation SecondViewController

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_setNames[0]];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_setNames[1]];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_setNames[2]];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_setNames[3]];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_setNames[4]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	_preferences = [[NSArray alloc] initWithObjects:g_setNames[0], g_setNames[1], g_setNames[2], g_setNames[3], g_setNames[4], nil];
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
