//
//  ButtonCell.h
//  Dominionator
//
//  Created by Nur Monson on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ButtonCell : UITableViewCell {
    UISwitch* _button;
}

@property (readonly) UISwitch* button;
@end
