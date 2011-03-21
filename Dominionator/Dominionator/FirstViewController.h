//
//  FirstViewController.h
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstViewController : UITableViewController {
	NSMutableArray* _cards;
	NSMutableDictionary* _cardPicks;
	NSMutableArray* _setNames;
	NSMutableSet* _setOfCardsPicked;
}

- (IBAction)pickNewCards:(id)sender;
@end
