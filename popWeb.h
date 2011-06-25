//
//  popWeb.h
//  Kenya Diaries
//
//  Created by Brian Slack on 09/05/2011.
//  Copyright 2011 Depicus. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface popWeb : UIViewController {
    id delegate;
    
}


@property (nonatomic, retain) id delgate;


- (IBAction)setNewPage:(id)sender;

@end
