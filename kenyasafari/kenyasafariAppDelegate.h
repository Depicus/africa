//
//  kenyasafariAppDelegate.h
//  kenyasafari
//
//  Created by Depicus on 30/05/2011.
//  Copyright 2011 Depicus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class frmMain;

@interface kenyasafariAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	frmMain *myMain;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) frmMain *myMain;

@end
