//
//  CardPicker.m
//  Dominionizer
//
//  Created by Nur Monson on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardPicker.h"
#import "DominionCard.h"
#import "SettingsViewController.h"


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

@implementation CardPicker

- (id)init
{
    self = [super init];
    if (self)
	{
		_allowedSets      = [[NSMutableSet alloc] init];
		_cards            = [[NSMutableArray alloc] init];
		_cardPicks        = [[NSMutableDictionary alloc] init];
		_setOfCardsPicked = [[NSMutableSet alloc] init];
		_setNames         = [[NSMutableArray alloc] init];

		NSURL* cardListURL = [[NSBundle mainBundle] URLForResource:@"cardlist" withExtension:@"plist"];
		NSArray* rawCards  = [NSArray arrayWithContentsOfURL:cardListURL];
		for(NSDictionary* aCardDict in rawCards)
		{
			DominionCard* newCard = [[DominionCard alloc] initWithDictionary:aCardDict];
			[_cards addObject:newCard];
			[newCard release];
		}

		srandomdev();
		[self pickNewCards];
    }
    
    return self;
}

- (void)dealloc
{
	[_cards release];
	[_cardPicks release];
	[_cards release];
	[_setNames release];
	[_setOfCardsPicked release];

	[super dealloc];
}

- (NSUInteger)pickedSetCount
{
	return [_setNames count];
}

- (void)pickAllowedSets
{
	// Make a set containing allowed card sets that we're allowed to pull from
	[_allowedSets removeAllObjects];
	NSMutableSet* usableSets = _allowedSets;
	if([[NSUserDefaults standardUserDefaults] boolForKey:kPreferenceNameSetPickingEnable])
	{
		NSMutableArray* sets = [NSMutableArray array];
		for(NSInteger i = 0; i < g_setCount; i++)
		{
			[sets addObject:g_setNames[i]];
		}
		// Shuffle sets
		for(NSInteger i = 0; i < [sets count]; i++)
		{
			[sets exchangeObjectAtIndex:i withObjectAtIndex:randomValueInRange([sets count])];
		}
		// pick sets
		NSInteger pickingSetCount = [[NSUserDefaults standardUserDefaults] integerForKey:kPreferenceNameSetCount];
		while(pickingSetCount == 0)
		{
			// Pick a random number of sets
			pickingSetCount = randomValueInRange(g_setCount);
		}
		NSInteger setIndex = 0;
		while([usableSets count] < pickingSetCount && setIndex < g_setCount)
		{
			NSString* aSet = [sets objectAtIndex:setIndex];
			if([[NSUserDefaults standardUserDefaults] boolForKey:aSet])
			{
				[usableSets addObject:aSet];
			}
			setIndex++;
		}
	}
	else
	{
		for(NSInteger i = 0; i < g_setCount; ++i)
		{
			NSString* setName = g_setNames[i];
			if([[NSUserDefaults standardUserDefaults] boolForKey:setName])
			{
				[usableSets addObject:setName];
			}
		}
	}
}

- (void)pickNewCards
{
	// Shuffle
	for(NSInteger i = 0; i < [_cards count]; ++i)
	{
		NSUInteger j = randomValueInRange([_cards count]);
		[_cards exchangeObjectAtIndex:i withObjectAtIndex:j];
	}
	// Pick Ten
	
	[self pickAllowedSets];
	NSSet* usableSets = _allowedSets;
	
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
	
	// Put cards into arrays by set
	[_cardPicks removeAllObjects];
	[_setNames removeAllObjects];
	for(DominionCard* aCard in _setOfCardsPicked)
	{
		NSString* setName = aCard.set;
		NSMutableArray* setArray = [_cardPicks valueForKey:setName];
		if(setArray == nil)
		{
			setArray = [NSMutableArray array];
			[_cardPicks setValue:setArray forKey:setName];
			[_setNames addObject:setName];
		}
		[setArray addObject:aCard];
	}
	for(NSString* aSet in _cardPicks)
	{
		[(NSMutableArray*)[_cardPicks valueForKey:aSet] sortUsingComparator:(NSComparator)^(DominionCard* cardOne, DominionCard* cardTwo) {
			return [cardOne.name caseInsensitiveCompare:cardTwo.name];
		}];
	}
}

- (NSIndexPath*)replaceCardAt:(NSIndexPath*)indexPath
{
	NSString*       setName           = [_setNames objectAtIndex:[indexPath section]];
	NSMutableArray* oldSetArray       = [_cardPicks valueForKey:setName];
	DominionCard*   theCardToReplace  = [oldSetArray objectAtIndex:[indexPath row]];
	DominionCard*   newCard           = nil;
	NSSet*          allowedSets       = _allowedSets;
	NSString*       newCardSet        = nil;
	BOOL            cardMustBeAlchemy = [theCardToReplace isAlchemy];

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
		// new card is in same set as the old card
		
		[oldSetArray replaceObjectAtIndex:[indexPath row] withObject:newCard];
		return [indexPath copy];
	}
	else
	{
		// new card is in different set than old card
		
		// Delete old card
		if([oldSetArray count] == 1)
		{
			// Old card was last of its set
			
			[_cardPicks removeObjectForKey:setName];
			[_setNames removeObjectAtIndex:[indexPath section]];
		}
		else
		{
			[oldSetArray removeObjectAtIndex:[indexPath row]];
		}
		
		// Add new card
		[_setOfCardsPicked removeObject:theCardToReplace];
		[_setOfCardsPicked addObject:newCard];
		NSMutableArray* newSetArray = [_cardPicks valueForKey:newSetName];
		if(newSetArray == nil)
		{
			// This is a new set
			[_setNames addObject:newSetName];
			NSMutableArray* newSetArray = [NSMutableArray arrayWithObject:newCard];
			[_cardPicks setValue:newSetArray forKey:newSetName];
			return [NSIndexPath indexPathForRow:0 inSection:[_setNames count]-1];
		}
		else
		{
			[newSetArray addObject:newCard];
			return [NSIndexPath indexPathForRow:[newSetArray count]-1 inSection:[_setNames indexOfObject:newSetName]];
		}
	}
}

- (BOOL)setPicked:(NSString*)setName
{
	return [_setNames containsObject:setName];
}

- (NSUInteger)countOfPickedCardsFromSet:(NSUInteger)setIndex
{
	NSArray* setCardArray = [_cardPicks valueForKey:[_setNames objectAtIndex:setIndex]];
	return [setCardArray count];
}

- (NSArray*)pickedSets
{
	return _setNames;
}

- (DominionCard*)cardAtIndexPath:(NSIndexPath*)indexPath
{
	return [[_cardPicks valueForKey:[_setNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
}

@end
