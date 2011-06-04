//
//  CardsViewController.m
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardsViewController.h"
#import "CardCell.h"
#import "SettingsViewController.h"
#import "DominionCard.h"

// random value in range without modulus bias

unsigned randomValueInRange(unsigned range)
{
	unsigned thirtyTwoBits = (1U<<31)-1;
	unsigned maxRandomValue = (thirtyTwoBits / range) * range;
	NSUInteger randomValue = random();
	while(randomValue > maxRandomValue)
	{
		randomValue = random();
	}
	return randomValue % range;
}

@implementation CardsViewController

+ (void)initialize
{
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	for(NSInteger i = 0; i < g_setCount; ++i)
	{
		[defaults setValue:[NSNumber numberWithBool:YES] forKey:g_setNames[i]];
	}
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	[[self tableView] setRowHeight:55.0];
	[self tableView].backgroundColor = [UIColor darkGrayColor];
	NSURL* cardListURL = [[NSBundle mainBundle] URLForResource:@"cardlist" withExtension:@"plist"];
	NSArray* rawCards = [NSArray arrayWithContentsOfURL:cardListURL];
	_cards = [[NSMutableArray alloc] init];
	for(NSDictionary* aCardDict in rawCards)
	{
		DominionCard* newCard = [[DominionCard alloc] initWithDictionary:aCardDict];
		[_cards addObject:newCard];
		[newCard release];
	}

	_cardPicks = [[NSMutableDictionary alloc] init];
	_setOfCardsPicked = [[NSMutableSet alloc] init];
	_setHeaders = [[NSMutableArray alloc] init];
	srandomdev();
	[self pickNewCards:nil];

	[self setTitle:NSLocalizedString(@"Cards", @"Title of Random Cards Navigation bar")];
	UIBarButtonItem* shuffleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(pickNewCards:)];
	self.navigationItem.rightBarButtonItem = shuffleButton;
	[shuffleButton release];
	UIBarButtonItem* settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(changeSettings:)];
	self.navigationItem.leftBarButtonItem = settingsButton;
	[settingsButton release];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.545 green:0.366 blue:0.232 alpha:1.000];

	// Allocate cached settings controller
	_detailViewController = [[CardDetailViewController alloc] initWithNibName:@"CardDetailViewController" bundle:[NSBundle mainBundle]];
	[_detailViewController view];
}

- (NSSet*)allowedSets
{
	// Make a set containing allowed card sets that we're allowed to pull from
	NSMutableSet* usableSets = [NSMutableSet set];
	for(NSInteger i = 0; i < g_setCount; ++i)
	{
		NSString* setName = g_setNames[i];
		if([[NSUserDefaults standardUserDefaults] boolForKey:setName])
		{
			[usableSets addObject:setName];
		}
	}

	return usableSets;
}

- (UIView*)newHeaderForSetNamed:(NSString*)setName
{
	UITableViewCell* newHeaderView = [[UITableViewCell alloc] init];
	newHeaderView.opaque = YES;

	newHeaderView.textLabel.text = setName;
	newHeaderView.textLabel.opaque = NO;
	newHeaderView.textLabel.backgroundColor = [UIColor clearColor];

	newHeaderView.imageView.image = [UIImage imageNamed:setName];
	newHeaderView.imageView.alpha = 0.7;

	newHeaderView.textLabel.textColor = [UIColor whiteColor];
	newHeaderView.textLabel.shadowColor = [UIColor colorWithWhite:0.35 alpha:1.0];
	newHeaderView.textLabel.shadowOffset = CGSizeMake(0.0, -1.0);

	newHeaderView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_gradient"]] autorelease];
	newHeaderView.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_gradient"]] autorelease];

	return  [newHeaderView autorelease];
}

- (IBAction)pickNewCards:(id)sender
{
	// Shuffle
	for(NSInteger i = 0; i < [_cards count]; ++i)
	{
		NSUInteger j = randomValueInRange([_cards count]);
		[_cards exchangeObjectAtIndex:i withObjectAtIndex:j];
	}
	// Pick Ten

	NSSet* usableSets = [self allowedSets];

	BOOL hasAlchemy = NO;
	NSUInteger alchemyCount = 0;
	[_setOfCardsPicked removeAllObjects];
	_nextCardToPick = 0;
	for(DominionCard* aCard in _cards)
	{
		_nextCardToPick++;
		NSString* set = aCard.set;
		NSInteger cardsLeft = 10 - [_setOfCardsPicked count];
		// Skip this card if it's not an allowed set
		// or if it's from Alchemy and there aren't enough slots left to fill the quota
		if(![usableSets containsObject:set] || (!hasAlchemy && [aCard isAlchemy] && cardsLeft < 4))
		{
			continue;
		}
		// TODO: I think this should check for potion cost
		if([aCard isAlchemy])
		{
			alchemyCount++;
			hasAlchemy = YES;
		}
		// Make sure that we pick the alchemy cards we need
		else if(hasAlchemy && alchemyCount < 4 && cardsLeft <= (4-alchemyCount))
		{
			continue;
		}
		[_setOfCardsPicked addObject:aCard];
		if([_setOfCardsPicked count] == 10)
		{
			break;
		}
	}

	[_setHeaders removeAllObjects];
	// Put cards into arrays by set
	NSMutableDictionary* pickedCardsBySet = [[NSMutableDictionary alloc] init];
	NSMutableArray* newSetNames = [[NSMutableArray alloc] init];
	for(DominionCard* aCard in _setOfCardsPicked)
	{
		NSString* setName = aCard.set;
		NSMutableArray* setArray = [pickedCardsBySet valueForKey:setName];
		if(setArray == nil)
		{
			setArray = [NSMutableArray array];
			[pickedCardsBySet setValue:setArray forKey:setName];
			[newSetNames addObject:setName];
			[_setHeaders addObject:[self newHeaderForSetNamed:setName]];
		}
		[setArray addObject:aCard];
	}
	for(NSString* aSet in pickedCardsBySet)
	{
		[(NSMutableArray*)[pickedCardsBySet valueForKey:aSet] sortUsingComparator:(NSComparator)^(DominionCard* cardOne, DominionCard* cardTwo) {
			return [cardOne.name caseInsensitiveCompare:cardTwo.name];
		}];
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

- (void)changeSettings:(id)sender
{
	SettingsViewController* settingsView = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:[NSBundle mainBundle]];
	UINavigationController* newNav = [[UINavigationController alloc] initWithRootViewController:settingsView];
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings:)];
	newNav.visibleViewController.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	newNav.navigationBar.tintColor = [UIColor colorWithRed:0.545 green:0.366 blue:0.232 alpha:1.000];
	self.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:newNav animated:YES];
	[newNav release];
	[settingsView release];
}

- (void)dismissSettings:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)replaceCardAtIndex:(NSIndexPath*)indexPath
{
	NSString* setName = [_setNames objectAtIndex:[indexPath section]];
	NSMutableArray* oldSetArray = [_cardPicks valueForKey:setName];
	DominionCard* theCardToReplace = [oldSetArray objectAtIndex:[indexPath row]];
	DominionCard* newCard = nil;
	NSSet* allowedSets = [self allowedSets];
	NSString* newCardSet = nil;
	BOOL cardMustBeAlchemy = [theCardToReplace isAlchemy];
	do
	{
		newCard = [_cards objectAtIndex:_nextCardToPick++];
		newCardSet = newCard.set;
		if(_nextCardToPick >= [_cards count])
		{
			_nextCardToPick = 0;
		}
	} while(newCard == theCardToReplace
			|| [_setOfCardsPicked containsObject:newCard]
			|| ![allowedSets containsObject:newCardSet]
			|| (cardMustBeAlchemy && ![newCard isAlchemy]));

	NSString* newSetName = newCard.set;
	if([setName isEqualToString:newSetName])
	{
		[oldSetArray replaceObjectAtIndex:[indexPath row] withObject:newCard];
		[[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
	}
	else
	{
		[[self tableView] beginUpdates];
		// Delete old card
		if([oldSetArray count] == 1)
		{
			[_cardPicks removeObjectForKey:setName];
			[_setNames removeObjectAtIndex:[indexPath section]];
			[_setHeaders removeObjectAtIndex:[indexPath section]];
			[[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationMiddle];
		}
		else
		{
			[oldSetArray removeObjectAtIndex:[indexPath row]];
			[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		}

		// Add new card
		[_setOfCardsPicked removeObject:theCardToReplace];
		[_setOfCardsPicked addObject:newCard];
		NSMutableArray* newSetArray = [_cardPicks valueForKey:newSetName];
		if(newSetArray == nil)
		{
			// This is a new set
			[_setNames addObject:newSetName];
			[_setHeaders addObject:[self newHeaderForSetNamed:newSetName]];
			NSMutableArray* newSetArray = [NSMutableArray arrayWithObject:newCard];
			[_cardPicks setValue:newSetArray forKey:newSetName];
			[[self tableView] insertSections:[NSIndexSet indexSetWithIndex:[_setNames count]-1] withRowAnimation:UITableViewRowAnimationMiddle];
		}
		else
		{
			[newSetArray addObject:newCard];
			NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:[newSetArray count]-1 inSection:[_setNames indexOfObject:newSetName]];
			[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
		}

		[[self tableView] endUpdates];
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

	[_cards release];
	[_cardPicks release];
}


- (void)dealloc
{
	[_cards release];
	[_cardPicks release];
	[_setNames release];
	[_setOfCardsPicked release];
	[_setHeaders release];
	[_detailViewController release];
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
	DominionCard* aCard = [setArray objectAtIndex:[indexPath row]];
	[cell setCard:aCard];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* setName = [_setNames objectAtIndex:[indexPath section]];
	NSArray* setArray = [_cardPicks valueForKey:setName];
	DominionCard* aCard = [setArray objectAtIndex:[indexPath row]];
	[_detailViewController setCard:aCard];
	[self.navigationController pushViewController:_detailViewController animated:YES];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return [_setHeaders objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 32.0;
}

@end
