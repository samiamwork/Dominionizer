//
//  CardDetailViewController.m
//  Dominionator
//
//  Created by Nur Monson on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardDetailViewController.h"


@implementation CardDetailViewController

@synthesize cardNameLabel=_cardNameLabel;
@synthesize cardTypeLabel=_cardTypeLabel;
@synthesize cardRulesLabel=_cardRulesLabel;
@synthesize cardSetIconView=_cardSetIconView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
    }
    return self;
}

- (void)dealloc
{
	[_htmlString release];
	[_properties release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	_htmlString = [[NSString alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"cardrules" withExtension:@"html"] encoding:NSUTF8StringEncoding error:NULL];
	self.cardRulesLabel.opaque = NO;
	self.cardRulesLabel.backgroundColor = [UIColor clearColor];
	[self.cardRulesLabel setUserInteractionEnabled:NO];
}

- (void)setProperties:(NSDictionary*)newProperties;
{
	if(newProperties == _properties)
	{
		return;
	}
	[_properties release];
	_properties = [newProperties retain];

	NSString* specificHTML = [_htmlString stringByReplacingOccurrencesOfString:@"@@" withString:[_properties valueForKey:@"rules"]];
	[self.cardRulesLabel loadHTMLString:specificHTML baseURL:[[NSBundle mainBundle] bundleURL]];
	self.cardNameLabel.text = [_properties valueForKey:@"card"];
	self.cardTypeLabel.text = [_properties valueForKey:@"type"];
	self.cardSetIconView.image = [UIImage imageNamed:[_properties valueForKey:@"set"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
