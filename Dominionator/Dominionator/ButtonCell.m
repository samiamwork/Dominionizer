//
//  ButtonCell.m
//  Dominionator
//
//  Created by Nur Monson on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ButtonCell.h"


@implementation ButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// The switch won't be placed properly without text first
		self.textLabel.text = @"blah";
		_button = [[UISwitch alloc] initWithFrame:CGRectMake(194, 8, 94, 27)];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		[self.contentView addSubview:_button];
    }
    return self;
}

@synthesize button=_button;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
	[_button release];
    [super dealloc];
}

@end
