//
//  kenyasafariAppDelegate.h
//  kenyasafari
//
//  Created by Brian Slack on 30/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class kenyasafariViewController;

@interface kenyasafariAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet kenyasafariViewController *viewController;

@end
