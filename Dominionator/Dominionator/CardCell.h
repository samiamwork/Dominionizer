//
//  CardCell.h
//  Dominionator
//
//  Created by Nur Monson on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CardCell : UITableViewCell {
    UIView* _cardView;
	NSDictionary* _properties;
}

@property (nonatomic, retain) NSDictionary* properties;
@end
