//
//  FirstViewController.m
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "CardCell.h"
#import "CardDetailViewController.h"
#import "SecondViewController.h"

@implementation FirstViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	[[self tableView] setRowHeight:55.0];
	NSURL* cardListURL = [[NSBundle mainBundle] URLForResource:@"cardlist" withExtension:@"plist"];
	_cards = [[NSMutableArray alloc] initWithContentsOfURL:cardListURL];
	_cardPicks = [[NSMutableDictionary alloc] init];
	_setOfCardsPicked = [[NSMutableSet alloc] init];
	srandomdev();
	[self pickNewCards:nil];

	[self setTitle:NSLocalizedString(@"Cards", @"Title of Random Cards Navigation bar")];
	UIBarButtonItem* shuffleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pickNewCards:)];
	self.navigationItem.rightBarButtonItem = shuffleButton;
	[shuffleButton release];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.545 green:0.366 blue:0.232 alpha:1.000];
}

- (NSSet*)allowedSets
{
	// Make a set containing allowed card sets that we're allowed to pull from
	NSMutableSet* usableSets = [NSMutableSet set];
	for(NSInteger i = 0; i < 7; ++i)
	{
		NSString* setName = g_setNames[i];
		if([[NSUserDefaults standardUserDefaults] boolForKey:setName])
		{
			[usableSets addObject:setName];
		}
	}

	return usableSets;
}

- (IBAction)pickNewCards:(id)sender
{
	// Shuffle
	for(NSInteger i = 0; i < [_cards count]; ++i)
	{
		// TODO: fix modulous bias
		NSUInteger j = random() % [_cards count];
		[_cards exchangeObjectAtIndex:i withObjectAtIndex:j];
	}
	// Pick Ten

	NSSet* usableSets = [self allowedSets];

	BOOL hasAlchemy = NO;
	NSUInteger alchemyCount = 0;
	[_setOfCardsPicked removeAllObjects];
	for(NSDictionary* aCard in _cards)
	{
		NSString* set = [aCard valueForKey:@"set"];
		// Skip this card if it's not an allowed set
		// or if it's from the Alchemy set and we don't have enough slots to pick enough Alchemy cards
		if(![usableSets containsObject:set] || (!hasAlchemy && [set isEqualToString:@"Alchemy"] && (10-[_cardPicks count]) < 4))
		{
			continue;
		}
		// TODO: I think this should check for potion cost
		if([set isEqualToString:@"Alchemy"])
		{
			alchemyCount++;
			hasAlchemy = YES;
		}
		// Make sure that we pick the alchemy cards we need
		else if(hasAlchemy && alchemyCount < 4 && (10-[_cardPicks count]) <= (4-alchemyCount))
		{
			continue;
		}
		[_setOfCardsPicked addObject:aCard];
		if([_setOfCardsPicked count] == 10)
		{
			break;
		}
	}

	// Put cards into arrays by set
	NSMutableDictionary* pickedCardsBySet = [[NSMutableDictionary alloc] init];
	NSMutableArray* newSetNames = [[NSMutableArray alloc] init];
	for(NSMutableDictionary* aCard in _setOfCardsPicked)
	{
		NSString* setName = [aCard valueForKey:@"set"];
		NSMutableArray* setArray = [pickedCardsBySet valueForKey:setName];
		if(setArray == nil)
		{
			setArray = [NSMutableArray array];
			[pickedCardsBySet setValue:setArray forKey:setName];
			[newSetNames addObject:setName];
		}
		[setArray addObject:aCard];
	}

	NSUInteger oldSetCount = [_setNames count];
	NSUInteger newSetCount = [newSetNames count];
	[_setNames release];
	_setNames = newSetNames;
	[_cardPicks release];
	_cardPicks = pickedCardsBySet;

	[[self tableView] beginUpdates];
	if(oldSetCount == newSetCount)
	{
		[[self tableView] reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldSetCount)]
						withRowAnimation:UITableViewRowAnimationMiddle];
	}
	else if(oldSetCount > newSetCount)
	{
		[[self tableView] reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newSetCount)]
						withRowAnimation:UITableViewRowAnimationMiddle];
		[[self tableView] deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newSetCount, oldSetCount-newSetCount)]
						withRowAnimation:UITableViewRowAnimationMiddle];
	}
	else if(oldSetCount < newSetCount)
	{
		[[self tableView] reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldSetCount)]
						withRowAnimation:UITableViewRowAnimationMiddle];
		[[self tableView] insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(oldSetCount, newSetCount-oldSetCount)]
						withRowAnimation:UITableViewRowAnimationMiddle];
	}
	[[self tableView] endUpdates];
}

- (void)replaceCardAtIndex:(NSIndexPath*)indexPath
{
	NSString* setName = [_setNames objectAtIndex:[indexPath section]];
	NSMutableArray* oldSetArray = [_cardPicks valueForKey:setName];
	NSDictionary* theCardToReplace = [oldSetArray objectAtIndex:[indexPath row]];
	NSDictionary* newCard = nil;
	NSSet* allowedSets = [self allowedSets];
	NSString* newCardSet = nil;
	BOOL cardMustBeAlchemy = [[theCardToReplace valueForKey:@"set"] isEqualToString:@"Alchemy"];
	do
	{
		NSUInteger newIndex = random() % [_cards count];
		newCard = [_cards objectAtIndex:newIndex];
		newCardSet = [newCard valueForKey:@"set"];
	} while(newCard == theCardToReplace
			|| [_setOfCardsPicked containsObject:newCard]
			|| ![allowedSets containsObject:newCardSet]
			|| (cardMustBeAlchemy && ![newCardSet isEqualToString:@"Alchemy"]));

	[[self tableView] beginUpdates];
	// Delete old card
	[oldSetArray removeObjectAtIndex:[indexPath row]];
	[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];

	// Add new card
	[_setOfCardsPicked removeObject:theCardToReplace];
	[_setOfCardsPicked addObject:newCard];
	NSString* newSetName = [newCard valueForKey:@"set"];
	NSMutableArray* newSetArray = [_cardPicks valueForKey:newSetName];
	[newSetArray addObject:newCard];
	NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:[newSetArray count]-1 inSection:[_setNames indexOfObject:newSetName]];
	[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];

	[[self tableView] endUpdates];
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
	[_cards release];
	[_cardPicks release];
	[_setNames release];
	[_setOfCardsPicked release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_setNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSString* setName = [_setNames objectAtIndex:section];
	NSArray* setArray = [_cardPicks valueForKey:setName];
    // Return the number of rows in the section.
    return [setArray count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [_setNames objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CardCell";
    
    CardCell *cell = (CardCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSString* setName = [_setNames objectAtIndex:[indexPath section]];
	NSArray* setArray = [_cardPicks valueForKey:setName];
	NSDictionary* aCard = [setArray objectAtIndex:[indexPath row]];
	//[[cell textLabel] setText:[aCard objectForKey:@"card"]];
	[cell setProperties:aCard];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* setName = [_setNames objectAtIndex:[indexPath section]];
	NSArray* setArray = [_cardPicks valueForKey:setName];
	NSDictionary* aCard = [setArray objectAtIndex:[indexPath row]];
	CardDetailViewController* detailViewController = [[CardDetailViewController alloc] initWithNibName:@"CardDetailViewController" bundle:[NSBundle mainBundle] properties:aCard];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark Table view delegate

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self replaceCardAtIndex:indexPath];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NSLocalizedString(@"Replace", @"Text for button to replace a card in the card list when swiping (instead of \"Delete\"");
}

@end
