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


@implementation CardsViewController

+ (void)initialize
{
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	for(NSInteger i = 0; i < g_setCount; ++i)
	{
		[defaults setValue:[NSNumber numberWithBool:YES] forKey:g_setNames[i]];
	}
	[defaults setValue:[NSNumber numberWithInt:3] forKey:kPreferenceNameSetCount];
	[defaults setValue:[NSNumber numberWithBool:NO] forKey:kPreferenceNameSetPickingEnable];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];

	[[self tableView] setRowHeight:55.0];
	[self tableView].backgroundColor = [UIColor darkGrayColor];

	_setHeaders = [[NSMutableArray alloc] init];
	_cardPicker = [[CardPicker alloc] init];

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

	[self pickNewCards:nil];
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
	// Workaround for tableview bug where section headers stay around after
	// reloading sections with animation
	if(kCFCoreFoundationVersionNumber == kCFCoreFoundationVersionNumber_iOS_4_2)
	{
		for(UIView* aView in _setHeaders)
		{
			[aView removeFromSuperview];
		}
	}

	[_setHeaders removeAllObjects];

	NSUInteger oldSetCount = [_cardPicker pickedSetCount];
	[_cardPicker pickNewCards];
	NSUInteger newSetCount = [_cardPicker pickedSetCount];

	NSArray* pickedSets = [_cardPicker pickedSets];
	for(NSString* setName in pickedSets)
	{
		[_setHeaders addObject:[self newHeaderForSetNamed:setName]];
	}

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
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
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
	DominionCard* oldCard = [[_cardPicker cardAtIndexPath:indexPath] retain];
	NSIndexPath* newCardIndexPath = [_cardPicker replaceCardAt:indexPath];
	DominionCard* newCard = [[_cardPicker cardAtIndexPath:newCardIndexPath] retain];

	if([oldCard.set isEqualToString:newCard.set])
	{
		// new card is in same set as the old card

		[[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
	}
	else
	{
		// new card is in different set than old card

		[[self tableView] beginUpdates];
		// Delete old card
		if(![_cardPicker setPicked:oldCard.set])
		{
			// Old card was last of its set

			[_setHeaders removeObjectAtIndex:[indexPath section]];
			[[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationMiddle];
		}
		else
		{
			[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		}

		// Add new card
		if([_cardPicker countOfPickedCardsFromSet:[newCardIndexPath section]] == 1)
		{
			// This is a new set

			[_setHeaders addObject:[self newHeaderForSetNamed:newCard.set]];
			[[self tableView] insertSections:[NSIndexSet indexSetWithIndex:[newCardIndexPath section]] withRowAnimation:UITableViewRowAnimationMiddle];
		}
		else
		{
			[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newCardIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
		}

		[[self tableView] endUpdates];
	}

	[oldCard release];
	[newCard release];
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
	[_cardPicker release];
	[_setHeaders release];
	[_detailViewController release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_cardPicker pickedSetCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_cardPicker countOfPickedCardsFromSet:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CardCell";
    
    CardCell *cell = (CardCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	DominionCard* aCard = [_cardPicker cardAtIndexPath:indexPath];
	[cell setCard:aCard];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_detailViewController setCard:[_cardPicker cardAtIndexPath:indexPath]];
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
