//
//  popWeb.m
//  Kenya Diaries
//
//  Created by Brian Slack on 09/05/2011.
//  Copyright 2011 Depicus. All rights reserved.
//

#import "popWeb.h"
#import "frmMain.h"


@implementation popWeb

@synthesize delgate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
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
}

- (void)viewWillAppear:(BOOL)animated {
    
    CGSize size = {320, 480}; // size of view in popover
    self.contentSizeForViewInPopover = size;
    
    [super viewWillAppear:animated];
    
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
	return YES;
}

- (IBAction)setNewPage:(id)sender {
    frmMain * callfrmMain = [[frmMain alloc] init];
    [callfrmMain setCurrentPicture:[sender tag]]; 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"killPop" object:nil];
}

@end
