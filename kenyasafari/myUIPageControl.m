//
//  myUIPageControl.m
//  kenyasafari
//
//  Created by Depicus on 01/06/2011.
//  Copyright 2011 Depicus. All rights reserved.
//

#import "myUIPageControl.h"

@implementation myUIPageControl

- (void) setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    
    NSString* imgActive = [[NSBundle mainBundle] pathForResource:@"sunnyday" ofType:@"png"];
    NSString* imgInactive = [[NSBundle mainBundle] pathForResource:@"night" ofType:@"png"];
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y,10,10);
        if (subviewIndex == page) [subview setImage:[UIImage imageWithContentsOfFile:imgActive]];
        else [subview setImage:[UIImage imageWithContentsOfFile:imgInactive]];
    }
}

- (void) setNumberOfPages:(NSInteger)pages {
    [super setNumberOfPages:pages];
    
    NSString* img = [[NSBundle mainBundle] pathForResource:@"night" ofType:@"png"];
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        [subview setImage:[UIImage imageWithContentsOfFile:img]];
    }
}

/*- (void)updateDots {
    if (imgCurrent || imgNormal) {
        NSArray *dotViews = self.subviews;
        for (int i = 0; i < dotViews.count; ++i) {
            UIImageView *dot = [dotViews objectAtIndex:i];
            dot.image = (i == self.currentPage) ? imgCurrent : imgNormal;
            dot.frame = CGRectMake(0, 0, imgNormal.size.width, imgNormal.size.height);
        }
    }
}*/

@end
