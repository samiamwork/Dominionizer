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
	NSMutableArray*           _setHeaders;
	CardDetailViewController* _detailViewController;
}

- (IBAction)pickNewCards:(id)sender;
@end
