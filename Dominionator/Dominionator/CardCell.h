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
	UIImage* _background;
	UIImage* _potion;
	UIImage* _coin;
	CGImageRef _tearMask;
}

@property (nonatomic, retain) NSDictionary* properties;
@property (nonatomic, retain) UIImage* background;
@property (nonatomic, retain) UIImage* potion;
@property (nonatomic, retain) UIImage* coin;
@property (nonatomic) CGImageRef tearMask;
@end
