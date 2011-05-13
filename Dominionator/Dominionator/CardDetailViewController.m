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
	[_card release];
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

- (void)setCard:(DominionCard*)newCard
{
	if(newCard == _card)
	{
		return;
	}
	[_card release];
	_card = [newCard retain];

	NSString* specificHTML = [_htmlString stringByReplacingOccurrencesOfString:@"@@" withString:_card.rules];
	[self.cardRulesLabel loadHTMLString:specificHTML baseURL:[[NSBundle mainBundle] bundleURL]];
	self.cardNameLabel.text = _card.name;
	self.cardTypeLabel.text = _card.type;
	self.cardSetIconView.image = [UIImage imageNamed:_card.set];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.cardNameLabel   = nil;
	self.cardTypeLabel   = nil;
	self.cardRulesLabel  = nil;
	self.cardSetIconView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
