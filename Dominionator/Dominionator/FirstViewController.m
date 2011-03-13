//
//  FirstViewController.m
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "CardCell.h"

@implementation FirstViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	[[self tableView] setRowHeight:55.0];
	NSURL* cardListURL = [[NSBundle mainBundle] URLForResource:@"cardlist" withExtension:@"plist"];
	_cards = [[NSMutableArray alloc] initWithContentsOfURL:cardListURL];
	_cardPicks = [[NSMutableArray alloc] init];
	srandomdev();
	[self pickNewCards:nil];

	[self setTitle:NSLocalizedString(@"Random Cards", @"Title of Random Cards Navigation bar")];
	UIBarButtonItem* shuffleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pickNewCards:)];
	self.navigationItem.rightBarButtonItem = shuffleButton;
	[shuffleButton release];
}

- (IBAction)pickNewCards:(id)sender
{
	// Shuffle
	for(NSInteger i = 0; i < [_cards count]; ++i)
	{
		NSUInteger j = random() % [_cards count];
		[_cards exchangeObjectAtIndex:i withObjectAtIndex:j];
	}
	// Pick Ten
	[_cardPicks removeAllObjects];
	BOOL hasAlchemy = NO;
	NSUInteger alchemyCount = 0;
	for(NSDictionary* aCard in _cards)
	{
		NSString* set = [aCard valueForKey:@"set"];
		// TODO: I think this should check for potion cost
		if([set isEqualToString:@"Alchemy"])
		{
			alchemyCount++;
			hasAlchemy = YES;
		}
		else if(hasAlchemy && alchemyCount < 4 && (10-[_cardPicks count]) <= (4-alchemyCount))
		{
			continue;
		}
		[_cardPicks addObject:aCard];
		if([_cardPicks count] == 10)
		{
			break;
		}
	}
	
	[[self tableView] reloadData];
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

	[_cards release];
	[_cardPicks release];
}


- (void)dealloc
{
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_cardPicks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CardCell";
    
    CardCell *cell = (CardCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSDictionary* aCard = [_cardPicks objectAtIndex:[indexPath row]];
	//[[cell textLabel] setText:[aCard objectForKey:@"card"]];
	[cell setProperties:aCard];
    
    return cell;
}

@end
