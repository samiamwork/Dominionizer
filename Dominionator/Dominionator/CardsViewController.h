//
//  CardsViewController.h
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardDetailViewController.h"


@interface CardsViewController : UITableViewController {
	NSMutableArray*           _cards;
	NSMutableDictionary*      _cardPicks;
	NSMutableArray*           _setNames;
	NSMutableSet*             _setOfCardsPicked;
	NSMutableSet*             _allowedSets;
	NSMutableArray*           _setHeaders;
	CardDetailViewController* _detailViewController;
	// The index of the next card to pick from the shuffled deck (monotonically increasing)
	unsigned                  _nextCardToPick;
}

- (IBAction)pickNewCards:(id)sender;
@end
