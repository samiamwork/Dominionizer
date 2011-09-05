//
//  CardsViewController.h
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardDetailViewController.h"
#import "CardPicker.h"


@interface CardsViewController : UITableViewController {
	CardPicker*               _cardPicker;
	NSMutableArray*           _setHeaders;
	CardDetailViewController* _detailViewController;
}

- (IBAction)pickNewCards:(id)sender;
@end
