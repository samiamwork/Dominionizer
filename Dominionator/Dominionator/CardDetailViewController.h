//
//  CardDetailViewController.h
//  Dominionator
//
//  Created by Nur Monson on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CardDetailViewController : UIViewController {
    NSDictionary* _properties;
}

@property (nonatomic, retain) IBOutlet UILabel *cardNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *cardTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *cardRulesLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil properties:(NSDictionary*)properties;
@end
