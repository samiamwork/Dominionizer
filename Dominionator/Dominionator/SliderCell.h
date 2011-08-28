//
//  SliderCell.h
//  Dominionizer
//
//  Created by Nur Monson on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderCell : UITableViewCell
{
	UISlider* _slider;
}

@property (readonly) UISlider* slider;
@end
