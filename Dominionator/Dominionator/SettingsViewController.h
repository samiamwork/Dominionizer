//
//  SettingsViewController.h
//  Dominionator
//
//  Created by Nur Monson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* g_setNames[];
extern NSUInteger g_setCount;

@interface SettingsViewController : UITableViewController {
    NSArray* _preferences;
}

@end
