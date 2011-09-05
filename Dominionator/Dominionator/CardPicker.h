//
//  CardPicker.h
//  Dominionizer
//
//  Created by Nur Monson on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DominionCard.h"

@interface CardPicker : NSObject
{
	NSMutableArray*      _cards;
	NSMutableDictionary* _cardPicks;
	NSMutableArray*      _setNames;
	NSMutableSet*        _setOfCardsPicked;
	NSMutableSet*        _allowedSets;
	// The index of the next card to pick from the shuffled deck (monotonically increasing)
	unsigned             _nextCardToPick;
}

- (void)          pickNewCards;
- (NSIndexPath*)  replaceCardAt:(NSIndexPath*)indexPath;
- (BOOL)          setPicked:(NSString*)setName;
- (NSArray*)      pickedSets;
- (NSUInteger)    pickedSetCount;
- (DominionCard*) cardAtIndexPath:(NSIndexPath*)indexPath;
- (NSUInteger)    countOfPickedCardsFromSet:(NSUInteger)setIndex;
@end
