//
//  DominionCard.h
//  Dominionator
//
//  Created by Nur Monson on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DominionCard : NSObject {
@private
    
}

@property (retain) NSString* name;
@property (retain) NSString* set;
@property (retain) NSString* type;
@property (retain) NSString* cost;
@property (retain) NSString* rules;

- (id)initWithDictionary:(NSDictionary*)theDict;
- (BOOL)isAlchemy;
@end
