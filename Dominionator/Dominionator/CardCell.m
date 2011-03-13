//
//  CardCell.m
//  Dominionator
//
//  Created by Nur Monson on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardCell.h"

#define CGMinX(a) ((a).origin.x)
#define CGMaxX(a) ((a).origin.x + (a).size.width)
#define CGMinY(a) ((a).origin.y)
#define CGMaxY(a) ((a).origin.y + (a).size.height)

@interface CardView : UIView {
@private
    CardCell* _cell;
}
@end

@implementation CardView
- (id)initWithFrame:(CGRect)frame cell:(CardCell*)cell
{
	if((self = [super initWithFrame:frame]))
	{
		_cell = cell;
		self.opaque = YES;
        self.backgroundColor = _cell.backgroundColor;
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	[[UIColor whiteColor] setFill];
	[[UIBezierPath bezierPathWithRect:rect] fill];
	CGRect workingRect = CGRectInset([self bounds], 1.0, 1.0);

	NSDictionary* properties = [_cell properties];
	NSString* type = [properties valueForKey:@"type"];
	
	UIBezierPath* outline = [UIBezierPath bezierPathWithRoundedRect:workingRect cornerRadius:10.0];
	if([type isEqualToString:@"Action"] || [type isEqualToString:@"Action - Attack"])
	{
		[[UIColor colorWithRed:0.91 green:0.89 blue:0.78 alpha:1.0] setFill];
		[outline fill];
	}
	else if([type isEqualToString:@"Treasure"])
	{
		//90 72 38 = Treasure
		[[UIColor colorWithRed:0.90 green:0.87 blue:0.38 alpha:1.0] setFill];
		[outline fill];
	}
	else if([type isEqualToString:@"Victory"])
	{
		//55 83 39 = victory
		[[UIColor colorWithRed:0.55 green:0.83 blue:0.39 alpha:1.0] setFill];
		[outline fill];
	}
	else if([type isEqualToString:@"Action - Reaction"] || [type isEqualToString:@"Reaction"])
	{
		//44 62 82 = Action - Reaction
		[[UIColor colorWithRed:0.44 green:0.66 blue:0.82 alpha:1.0] setFill];
		[outline fill];
	}
	else if([type isEqualToString:@"Action - Duration"])
	{
		//91 52 27 = Action - Duration
		[[UIColor colorWithRed:0.91 green:0.52 blue:0.27 alpha:1.0] setFill];
		[outline fill];
	}
	else if([type isEqualToString:@"Treasure - Victory"])
	{
		CGRect topRect;
		CGRect bottomRect;
		CGRectDivide(workingRect, &topRect, &bottomRect, workingRect.size.height/2.0, CGRectMaxYEdge);
		topRect.origin.y -= 1.0;
		topRect.size.height += 1.0;
		bottomRect.size.height += 1.0;
		// Treasure
		[[UIColor colorWithRed:0.90 green:0.87 blue:0.38 alpha:1.0] setFill];
		UIBezierPath* topPath = [UIBezierPath bezierPath];
		[topPath moveToPoint:CGPointMake(CGMinX(topRect), CGMinY(topRect))];
		[topPath addLineToPoint:CGPointMake(CGMaxX(topRect), CGMinY(topRect))];
		[topPath addLineToPoint:CGPointMake(CGMaxX(topRect), CGMaxY(topRect)-10.0)];
		[topPath addArcWithCenter:CGPointMake(CGMaxX(topRect)-10.0, CGMaxY(topRect)-10.0) radius:10.0 startAngle:0.0 endAngle:M_PI/2.0 clockwise:YES];
		[topPath addLineToPoint:CGPointMake(CGMinX(topRect)+10.0, CGMaxY(topRect))];
		[topPath addArcWithCenter:CGPointMake(CGMinX(topRect)+10.0, CGMaxY(topRect)-10.0) radius:10.0 startAngle:M_PI/2.0 endAngle:M_PI clockwise:YES];
		[topPath closePath];
		[topPath fill];
		// Victory
		[[UIColor colorWithRed:0.55 green:0.83 blue:0.39 alpha:1.0] setFill];
		UIBezierPath* bottomPath = [UIBezierPath bezierPath];
		[bottomPath moveToPoint:CGPointMake(CGMinX(bottomRect), CGMaxY(bottomRect))];
		[bottomPath addLineToPoint:CGPointMake(CGMinX(bottomRect), CGMinY(bottomRect)-10.0)];
		[bottomPath addArcWithCenter:CGPointMake(CGMinX(bottomRect)+10.0, CGMinY(bottomRect)+10.0)
							  radius:10.0 startAngle:M_PI endAngle:3.0*M_PI/2.0 clockwise:YES];
		[bottomPath addLineToPoint:CGPointMake(CGMaxX(bottomRect)-10.0, CGMinY(bottomRect))];
		[bottomPath addArcWithCenter:CGPointMake(CGMaxX(bottomRect)-10.0, CGMinY(bottomRect)+10.0)
							  radius:10.0 startAngle:3.0*M_PI/2.0 endAngle:2.0*M_PI clockwise:YES];
		[bottomPath addLineToPoint:CGPointMake(CGMaxX(bottomRect), CGMaxY(bottomRect))];
		[bottomPath closePath];
		[bottomPath fill];
	}
	else if([type isEqualToString:@"Action - Victory"])
	{
		CGRect topRect;
		CGRect bottomRect;
		CGRectDivide(workingRect, &topRect, &bottomRect, workingRect.size.height/2.0, CGRectMaxYEdge);
		topRect.origin.y -= 1.0;
		topRect.size.height += 1.0;
		bottomRect.size.height += 1.0;
		// Action
		[[UIColor colorWithRed:0.44 green:0.66 blue:0.82 alpha:1.0] setFill];
		UIBezierPath* topPath = [UIBezierPath bezierPath];
		[topPath moveToPoint:CGPointMake(CGMinX(topRect), CGMinY(topRect))];
		[topPath addLineToPoint:CGPointMake(CGMaxX(topRect), CGMinY(topRect))];
		[topPath addLineToPoint:CGPointMake(CGMaxX(topRect), CGMaxY(topRect)-10.0)];
		[topPath addArcWithCenter:CGPointMake(CGMaxX(topRect)-10.0, CGMaxY(topRect)-10.0) radius:10.0 startAngle:0.0 endAngle:M_PI/2.0 clockwise:YES];
		[topPath addLineToPoint:CGPointMake(CGMinX(topRect)+10.0, CGMaxY(topRect))];
		[topPath addArcWithCenter:CGPointMake(CGMinX(topRect)+10.0, CGMaxY(topRect)-10.0) radius:10.0 startAngle:M_PI/2.0 endAngle:M_PI clockwise:YES];
		[topPath closePath];
		[topPath fill];
		// Victory
		[[UIColor colorWithRed:0.55 green:0.83 blue:0.39 alpha:1.0] setFill];
		UIBezierPath* bottomPath = [UIBezierPath bezierPath];
		[bottomPath moveToPoint:CGPointMake(CGMinX(bottomRect), CGMaxY(bottomRect))];
		[bottomPath addLineToPoint:CGPointMake(CGMinX(bottomRect), CGMinY(bottomRect)-10.0)];
		[bottomPath addArcWithCenter:CGPointMake(CGMinX(bottomRect)+10.0, CGMinY(bottomRect)+10.0)
							  radius:10.0 startAngle:M_PI endAngle:3.0*M_PI/2.0 clockwise:YES];
		[bottomPath addLineToPoint:CGPointMake(CGMaxX(bottomRect)-10.0, CGMinY(bottomRect))];
		[bottomPath addArcWithCenter:CGPointMake(CGMaxX(bottomRect)-10.0, CGMinY(bottomRect)+10.0)
							  radius:10.0 startAngle:3.0*M_PI/2.0 endAngle:2.0*M_PI clockwise:YES];
		[bottomPath addLineToPoint:CGPointMake(CGMaxX(bottomRect), CGMaxY(bottomRect))];
		[bottomPath closePath];
		[bottomPath fill];
	}
	else
	{
		[[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0] setFill];
		[outline fill];
	}
	
	CGFloat labelXMargin = 20.0;
	CGSize stringSize = [type sizeWithFont:[UIFont boldSystemFontOfSize:11.0]];
	[[UIColor blackColor] setFill];
	[type drawAtPoint:CGPointMake(labelXMargin, CGMaxY(workingRect)-stringSize.height-5.0) withFont:[UIFont boldSystemFontOfSize:11.0]];

	NSString* cardName = [properties valueForKey:@"card"];
	stringSize = [cardName sizeWithFont:[UIFont boldSystemFontOfSize:20.0]];
	[cardName drawAtPoint:CGPointMake(labelXMargin, CGMaxY(workingRect)-stringSize.height-20.0) withFont:[UIFont boldSystemFontOfSize:20.0]];

	NSString* cost = [properties valueForKey:@"cost"];
	NSArray* costList = [cost componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString* coinCost = nil;
	NSString* potionCost = nil;
	for(NSString* aCost in costList)
	{
		if([aCost hasPrefix:@"$"])
		{
			coinCost = [aCost stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$"]];
		}
		else if([aCost hasSuffix:@"P"])
		{
			potionCost = [aCost stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"P"]];
		}
	}

	CGFloat coinOffset = 5.0;
	CGFloat coinDiameter = 30.0;
	if(potionCost != nil)
	{
		CGRect coinRect = CGRectMake(CGMaxX(workingRect)-coinDiameter-coinOffset, 10.0, coinDiameter, coinDiameter);
		coinRect.origin.y -= 3.0;
		
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		CGContextBeginTransparencyLayer(ctx, NULL);
		CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 1.0), 1.0, [[UIColor colorWithWhite:1.0 alpha:0.6] CGColor]);
		CGFloat bottomHeight = coinRect.size.height/2.0;
		CGRect potionBottomRect = CGRectMake(coinRect.origin.x + (coinRect.size.width - bottomHeight)/2.0, CGMaxY(coinRect)-bottomHeight, bottomHeight, bottomHeight);
		CGFloat topWidth = bottomHeight/2.0;
		CGRect potionTopRect = CGRectMake(coinRect.origin.x + bottomHeight-topWidth/2.0, CGMinY(coinRect)+5.0, topWidth, bottomHeight);
		[[UIColor colorWithRed:0.23 green:0.22 blue:0.93 alpha:1.0] setFill];
		[[UIBezierPath bezierPathWithRoundedRect:potionTopRect cornerRadius:2.0] fill];
		[[UIBezierPath bezierPathWithOvalInRect:potionBottomRect] fill];
		CGContextEndTransparencyLayer(ctx);
		CGContextRestoreGState(ctx);

		coinOffset += coinDiameter + 2.0;
	}
	if(coinCost != nil)
	{
		CGRect coinRect = CGRectMake(CGMaxX(workingRect)-coinDiameter-coinOffset, 10.0, coinDiameter, coinDiameter);
		UIBezierPath* circle = [UIBezierPath bezierPathWithOvalInRect:coinRect];
		[[UIColor colorWithRed:0.7 green:0.7 blue:0.2 alpha:1.0] setFill];
		[circle fill];
		coinRect.origin.y -= 1.0;
		circle = [UIBezierPath bezierPathWithOvalInRect:coinRect];
		[[UIColor colorWithRed:0.9 green:0.9 blue:0.23 alpha:1.0] setFill];
		[circle fill];
		
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 1.0), 1.0, [[UIColor colorWithWhite:1.0 alpha:0.6] CGColor]);
		[[UIColor colorWithWhite:0.4 alpha:1.0] setFill];
		UIFont* font = [UIFont boldSystemFontOfSize:25.0];
		stringSize = [coinCost sizeWithFont:font];
		[coinCost drawAtPoint:CGPointMake(coinRect.origin.x+(coinRect.size.width-stringSize.width)/2.0,
										  coinRect.origin.y + (coinRect.size.height-stringSize.height)/2.0)
					 withFont:font];
		CGContextRestoreGState(ctx);
	}
}

@end

@implementation CardCell

@synthesize properties=_properties;

- (void)setProperties:(NSDictionary*)newProperties;
{
	if(newProperties == _properties)
	{
		return;
	}
	[_properties release];
	_properties = [newProperties retain];
	[_cardView setNeedsDisplay];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_cardView = [[CardView alloc] initWithFrame:CGRectInset([[self contentView] bounds], 0.0, 1.0) cell:self];
		[_cardView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_cardView setContentMode:UIViewContentModeRedraw];
		[self.contentView addSubview:_cardView];
    }
    return self;
}
/*
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	
    [UIView setAnimationsEnabled:NO];
    CGSize contentSize = _cardView.bounds.size;
    _cardView.contentStretch = CGRectMake(225.0 / contentSize.width, 0.0, (contentSize.width - 260.0) / contentSize.width, 1.0);
    [UIView setAnimationsEnabled:YES];
}
*/
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
	[_properties release];
	[_cardView release];
    [super dealloc];
}

@end
