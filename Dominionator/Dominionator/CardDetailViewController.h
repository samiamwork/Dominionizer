//
//  CardDetailViewController.h
//  Dominionator
//
//  Created by Nur Monson on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DominionCard.h"

@interface CardDetailViewController : UIViewController {
    DominionCard* _card;
	NSString* _htmlString;
}

@property (nonatomic, retain) IBOutlet UILabel *cardNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *cardTypeLabel;
@property (nonatomic, retain) IBOutlet UIWebView *cardRulesLabel;
@property (nonatomic, retain) IBOutlet UIImageView *cardSetIconView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)setCard:(DominionCard*)newCard;
@end
