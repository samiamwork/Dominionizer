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
	}
	return self;
}

- (void)drawBackgroundWithGradient:(CGGradientRef)gradient whiteGloss:(CGGradientRef)whiteGloss blackGloss:(CGGradientRef)blackGloss
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGRect workingRect = self.bounds;
	[_cell.background drawAtPoint:CGPointZero];
	CGContextSaveGState(ctx);
	{
		CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
		CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0.0, CGMaxY(workingRect)), CGPointMake(0.0, CGMinY(workingRect)), 0);
	}
	CGContextRestoreGState(ctx);
	CGContextDrawLinearGradient(ctx, whiteGloss, CGPointMake(0.0, CGMinY(workingRect)), CGPointMake(0.0, CGMinY(workingRect)+2.0), 0);
	CGContextDrawLinearGradient(ctx, blackGloss, CGPointMake(0.0, CGMaxY(workingRect)), CGPointMake(0.0, CGMaxY(workingRect)-2.0), 0);

}

- (void)drawRect:(CGRect)rect
{
	[[UIColor whiteColor] setFill];
	[[UIBezierPath bezierPathWithRect:rect] fill];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGRect workingRect = [self bounds];
	CGImageRef mask = _cell.tearMask;
	CGSize maskSize = CGSizeMake(CGImageGetWidth(mask), CGImageGetHeight(mask));
	workingRect.size.width -= maskSize.width;

	NSDictionary* properties = [_cell properties];
	NSString* type = [properties valueForKey:@"type"];

	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient;
	if([type isEqualToString:@"Action"] || [type isEqualToString:@"Action - Attack"])
	{
		CGFloat colors[] = {
			0.80, 0.78, 0.67, 1.0,
			0.91, 0.89, 0.78, 1.0, // Action
			0.96, 0.94, 0.83, 1.0,
		};
		CGFloat locations[] = {
			0.0,
			0.3,
			1.0
		};
		gradient = CGGradientCreateWithColorComponents(rgbColorSpace, colors, locations, 2);
	}
	else if([type isEqualToString:@"Treasure"])
	{
		CGFloat colors[] = {
			0.79, 0.61, 0.27, 1.0,
			0.90, 0.72, 0.38, 1.0, // Treasure
			0.95, 0.77, 0.43, 1.0,
		};
		CGFloat locations[] = {
			0.0,
			0.3,
			1.0
		};
		gradient = CGGradientCreateWithColorComponents(rgbColorSpace, colors, locations, 2);
	}
	else if([type isEqualToString:@"Victory"])
	{
		CGFloat colors[] = {
			0.44, 0.72, 0.28, 1.0,
			0.55, 0.83, 0.39, 1.0, // Victory
			0.60, 0.88, 0.44, 1.0,
		};
		CGFloat locations[] = {
			0.0,
			0.3,
			1.0
		};
		gradient = CGGradientCreateWithColorComponents(rgbColorSpace, colors, locations, 2);
	}
	else if([type isEqualToString:@"Action - Reaction"] || [type isEqualToString:@"Reaction"])
	{
		CGFloat colors[] = {
			0.33, 0.51, 0.71, 1.0,
			0.44, 0.62, 0.82, 1.0, // Action - Reaction
			0.49, 0.67, 0.87, 1.0,
		};
		CGFloat locations[] = {
			0.0,
			0.3,
			1.0
		};
		gradient = CGGradientCreateWithColorComponents(rgbColorSpace, colors, locations, 2);
	}
	else if([type isEqualToString:@"Action - Duration"])
	{
		CGFloat colors[] = {
			0.80, 0.41, 0.16, 1.0,
			0.91, 0.52, 0.27, 1.0, // Action - Duration
			0.96, 0.57, 0.32, 1.0,
		};
		CGFloat locations[] = {
			0.0,
			0.3,
			1.0
		};
		gradient = CGGradientCreateWithColorComponents(rgbColorSpace, colors, locations, 2);
	}
	else if([type isEqualToString:@"Treasure - Victory"])
	{
		CGFloat colors[] = {
			0.81, 0.78, 0.29, 1.0,
			0.90, 0.87, 0.38, 1.0, // Treasure
			0.55, 0.83, 0.39, 1.0, // Victory
			0.60, 0.88, 0.44, 1.0
		};
		CGFloat locations[] = {
			0.0,
			0.25,
			0.75,
			1.0
		};
		gradient = CGGradientCreateWithColorComponents(rgbColorSpace, colors, locations, 4);
	}
	else if([type isEqualToString:@"Action - Victory"])
	{
		CGFloat colors[] = {
			0.35, 0.57, 0.73, 1.0,
			0.44, 0.66, 0.82, 1.0, // Action
			0.55, 0.83, 0.39, 1.0, // Victory
			0.60, 0.88, 0.44, 1.0
		};
		CGFloat locations[] = {
			0.0,
			0.25,
			0.75,
			1.0
		};
		gradient = CGGradientCreateWithColorComponents(rgbColorSpace, colors, locations, 4);
	}
	else
	{
		UIBezierPath* outline = [UIBezierPath bezierPathWithRect:workingRect];
		[[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0] setFill];
		[outline fill];
	}

	// Gloss lines
	CGColorSpaceRef whiteColorSpace = CGColorSpaceCreateDeviceGray();
	CGFloat colorsWhite[] = {0.9, 0.6, 0.9, 0.0};
	CGFloat locationsWhite[] = {0.0, 1.0};
	CGGradientRef whiteGloss = CGGradientCreateWithColorComponents(whiteColorSpace, colorsWhite, locationsWhite, 2);

	CGFloat colorsBlack[] = {0.2, 0.6, 0.2, 0.0};
	CGFloat locationsBlack[] = {0.0, 1.0};
	CGGradientRef blackGloss = CGGradientCreateWithColorComponents(whiteColorSpace, colorsBlack, locationsBlack, 2);

	CGRect maskRect = CGRectMake(CGMaxX(workingRect), 0.0, maskSize.width, maskSize.height);
	CGContextSaveGState(ctx);
	{
		CGContextClipToRect(ctx, workingRect);
		[self drawBackgroundWithGradient:gradient whiteGloss:whiteGloss blackGloss:blackGloss];
	}
	CGContextRestoreGState(ctx);
	CGContextSaveGState(ctx);
	{
		CGContextClipToMask(ctx, maskRect, mask);
		[self drawBackgroundWithGradient:gradient whiteGloss:whiteGloss blackGloss:blackGloss];
	}
	CGContextRestoreGState(ctx);

	CFRelease(whiteGloss);
	CFRelease(blackGloss);
	CFRelease(gradient);
	CFRelease(rgbColorSpace);
	CFRelease(whiteColorSpace);

	// Now that we don't need the mask anymore lets extend our working rect to give us some more space
	workingRect.size.width += ceil(maskSize.width/2.0);
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

	// Draw Text
	CGContextSaveGState(ctx);
	{
		CGRect textRect;
		CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 1.0), 1.0, [[UIColor colorWithWhite:1.0 alpha:0.6] CGColor]);
		CGFloat labelXMargin = 10.0;
		CGFloat labelXMaxMargin = labelXMargin + coinDiameter + coinOffset + (potionCost == nil ? 0.0 : (coinDiameter+coinOffset));

		UIFont* typeFont = [UIFont boldSystemFontOfSize:11.0];
		CGSize stringSize = [type sizeWithFont:typeFont];
		[[UIColor colorWithWhite:0.1 alpha:0.8] setFill];
		textRect = CGRectMake(labelXMargin, CGMaxY(workingRect)-stringSize.height-5.0, workingRect.size.width - labelXMargin - labelXMaxMargin, stringSize.height);
		[type drawInRect:textRect withFont:typeFont lineBreakMode:UILineBreakModeTailTruncation];

		UIFont* nameFont = [UIFont boldSystemFontOfSize:19.0];
		NSString* cardName = [properties valueForKey:@"card"];
		stringSize = [cardName sizeWithFont:nameFont];
		textRect = CGRectMake(labelXMargin, CGMaxY(workingRect)-stringSize.height-20.0, workingRect.size.width - labelXMargin - labelXMaxMargin, stringSize.height);
		[cardName drawInRect:textRect withFont:nameFont lineBreakMode:UILineBreakModeTailTruncation];
	}
	CGContextRestoreGState(ctx);

	if(potionCost != nil)
	{
		CGRect coinRect = CGRectMake(CGMaxX(workingRect)-coinDiameter-coinOffset, 10.0, coinDiameter, coinDiameter);
		coinRect.origin.y -= 3.0;
		
		CGContextSaveGState(ctx);
		{
			CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 1.0), 1.0, [[UIColor colorWithWhite:1.0 alpha:0.6] CGColor]);
			[_cell.potion drawAtPoint:coinRect.origin];
		}
		CGContextRestoreGState(ctx);

		coinOffset += coinDiameter + 2.0;
	}
	if(coinCost != nil)
	{
		CGRect coinRect = CGRectMake(CGMaxX(workingRect)-coinDiameter-coinOffset, 10.0, coinDiameter, coinDiameter);
		coinRect.origin.y -= 1.0;
		coinRect.size = [_cell.coin size];
		CGContextSaveGState(ctx);
		{
			CGContextSetShadow(ctx, CGSizeMake(0.0, 2.0), 2.0);
			[_cell.coin drawAtPoint:coinRect.origin];
		}
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
		CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 1.0), 1.0, [[UIColor colorWithWhite:1.0 alpha:0.6] CGColor]);
		[[UIColor colorWithWhite:0.4 alpha:1.0] setFill];
		UIFont* font = [UIFont boldSystemFontOfSize:20.0];
		CGSize stringSize = [coinCost sizeWithFont:font];
		[coinCost drawAtPoint:CGPointMake(coinRect.origin.x+(coinRect.size.width-stringSize.width)/2.0,
										  coinRect.origin.y + (coinRect.size.height-stringSize.height)/2.0 - 2.0)
					 withFont:font];
		CGContextRestoreGState(ctx);
	}
}

@end

@implementation CardCell

@synthesize properties=_properties;
@synthesize background=_background;
@synthesize potion=_potion;
@synthesize coin=_coin;
@synthesize tearMask=_tearMask;

- (void)setProperties:(NSDictionary*)newProperties;
{
	static NSString* backgroundImages[] = {
		@"paperstrip_gray1",
		@"paperstrip_gray2",
		@"paperstrip_gray3"
	};
	static NSString* tearMaskImages[] = {
		@"tear_mask1",
		@"tear_mask2",
		@"tear_mask3",
		@"tear_mask4",
	};
	if(newProperties == _properties)
	{
		return;
	}
	[_properties release];
	_properties = [newProperties retain];
	[_cardView setNeedsDisplay];
	[self setBackground:[UIImage imageNamed:backgroundImages[random()%3]]];
	UIImage* tearImage = [UIImage imageNamed:tearMaskImages[random()%4]];
	CGImageRef tearCGImage = [tearImage CGImage];
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(tearCGImage),
										CGImageGetHeight(tearCGImage),
										CGImageGetBitsPerComponent(tearCGImage),
										CGImageGetBitsPerPixel(tearCGImage),
										CGImageGetBytesPerRow(tearCGImage),
										CGImageGetDataProvider(tearCGImage),
										NULL,
										true);
	CGImageRelease(_tearMask);
	_tearMask = mask;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_cardView = [[CardView alloc] initWithFrame:[[self contentView] bounds] cell:self];
		[_cardView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_cardView setContentMode:UIViewContentModeRedraw];
		self.opaque = YES;
		[self.contentView addSubview:_cardView];
		self.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.potion = [UIImage imageNamed:@"Potion"];
		self.coin = [UIImage imageNamed:@"Coin"];
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
	[_background release];
	[_potion release];
	[_coin release];
	CGImageRelease(_tearMask);
    [super dealloc];
}

@end
