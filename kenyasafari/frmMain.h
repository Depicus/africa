//
//  frmMain.h
//  Kenya Diaries
//
//  Created by Brian Slack on 29/12/2010.
//  Copyright 2010 Depicus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface frmMain : UIViewController <CLLocationManagerDelegate,UITableViewDelegate,UIPopoverControllerDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate> {
    IBOutlet UIImageView *imgMain;
    IBOutlet UIImageView *imgRight;
    IBOutlet UIImageView *imgLeft;
    
    IBOutlet UIImageView *imgLeftFold;
    IBOutlet UIPageControl *pcMain;
    IBOutlet UILabel *lblHowWork;
    
    IBOutlet UILabel *lbl1;
    IBOutlet UILabel *lbl2;
    
    IBOutlet UILabel *lbl3;
    IBOutlet UIView *vIntro;
    CLLocationManager *myGPS;
    IBOutlet MKMapView *mkIntro;
    IBOutlet MKMapView *mkMain;
    
    IBOutlet UIView *vMap;
    
    IBOutlet UILabel *lblTitle;
    UIButton *showIntroMap;
    IBOutlet UILabel *lblIntroMap;
    
    IBOutlet UILabel *lblntroInfo;
    IBOutlet UILabel *lblInfo;
    IBOutlet UIImageView *imgArrowRight;
    IBOutlet UIImageView *imgArrowUp;
    
    IBOutlet UIImageView *imgArrowDown;
    IBOutlet UITableView *tvInfo;
    IBOutlet UIButton *btnExplore;
    IBOutlet UIImageView *imgArrowLeft;
    NSTimer *tmArrowRight;
    NSTimer *tmArrowLeft;
    
    IBOutlet UITableView *tvMain;
    
    NSMutableArray *maGPSData;
    IBOutlet UIButton *btnDiary;
    IBOutlet UISegmentedControl *scMap;
    IBOutlet UIButton *btnWeb;
    IBOutlet UIButton *btnWallpaper;
    IBOutlet UIButton *btnVideo;
    UIPopoverController *pcWeb;
    UIPopoverController *pcDiary;
    UIPopoverController *pcVideo;
    UILabel *lblCredits;
    UIImageView *imgCreditMask;
}


@property (nonatomic, retain) NSMutableArray *maGPSData;
@property (nonatomic, retain) UIPopoverController *pcWeb;
@property (nonatomic, retain) UIPopoverController *pcDiary;
@property (nonatomic, retain) UIPopoverController *pcVideo;
@property (nonatomic, retain) IBOutlet UILabel *lblCredits;
@property (nonatomic, retain) IBOutlet UIImageView *imgCreditMask;


- (IBAction)hideIntro;
- (IBAction)showIntroMap:(id)sender;
- (void) showInfo;
- (void) showMap;
- (void)moveImage:(UIImageView *)image duration:(NSTimeInterval)duration curve:(int)curve x:(CGFloat)x y:(CGFloat)y;
- (IBAction)showIntroInfo:(id)sender;
- (NSString *) getHumanReadableDay:(int)day;
- (NSString *) getHumanReadableMonth:(int)month;
- (IBAction)getWeb:(id)sender;
- (IBAction)btnHideMap:(id)sender;
- (void) setMapPin:(NSString *)title subtitle:(NSString *)subtitle pin:(NSString *)pin lat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon;
- (IBAction) mapTypeChanged;
- (IBAction)setWallpaper:(id)sender;
- (void) setCurrentPicture:(int)pic;
- (void) doSwipeRightToLeft;
- (void) doSwipeLeft;
- (IBAction)getDiary:(id)sender;
- (IBAction)setAsWallpaper:(id)sender;
- (void) animCredits;
- (void) hideCredits;
- (void) stopCredits;

//- (IBAction) playIntroMusic;

@end
