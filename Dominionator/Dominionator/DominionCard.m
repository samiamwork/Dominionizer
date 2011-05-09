//
//  DominionCard.m
//  Dominionator
//
//  Created by Nur Monson on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DominionCard.h"


@implementation DominionCard

- (id)initWithDictionary:(NSDictionary*)theDict;
{
    self = [super init];
    if (self)
	{
		self.name  = [theDict valueForKey:@"card"];
		self.set   = [theDict valueForKey:@"set"];
		self.type  = [theDict valueForKey:@"type"];
		self.cost  = [theDict valueForKey:@"cost"];
		self.rules = [theDict valueForKey:@"rules"];
    }
    
    return self;
}

@synthesize name;
@synthesize set;
@synthesize type;
@synthesize cost;
@synthesize rules;

- (void)dealloc
{
	[self.name release];
	[self.set release];
	[self.type release];
	[self.cost release];
	[self.rules release];

    [super dealloc];
}

- (BOOL)isAlchemy
{
	return [self.set isEqualToString:@"Alchemy"];
}

@end
