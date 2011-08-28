//
//  SliderCell.m
//  Dominionizer
//
//  Created by Nur Monson on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SliderCell.h"

@implementation SliderCell

@synthesize slider=_slider;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// The switch won't be placed properly without text first
		self.textLabel.text = @"blah";
		_slider = [[UISlider alloc] initWithFrame:CGRectMake(194, 8, 94, 27)];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		[self.contentView addSubview:_slider];
    }
    return self;
}

@end
