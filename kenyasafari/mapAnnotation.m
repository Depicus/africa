//
//  mapAnnotation.m
//  MapLocation
//
//  Created by Brian Slack on 14/07/2010.
//  Copyright 2010 Digital Wired Limited. All rights reserved.
//

#import "mapAnnotation.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation mapAnnotation

@synthesize coordinate, title, subtitle, pinColor;

-(void)dealloc
{
    [title release];
    [subtitle release];
	[pinColor release];
    [super dealloc];
}
@end
