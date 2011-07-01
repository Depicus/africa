//
//  mapAnnotation.h
//  MapLocation
//
//  Created by Depicus on 14/07/2010.
//  Copyright 2010 Digital Wired Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface mapAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
    NSString *subtitle;
	NSString *pinColor;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *pinColor;

@end