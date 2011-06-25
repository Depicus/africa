    //
//  frmMain.m
//  Kenya Diaries
//
//  Created by Brian Slack on 29/12/2010.
//  Copyright 2010 Depicus. All rights reserved.
//

#import "frmMain.h"
#import "mapAnnotation.h"
#import "ImageIO/CGImageSource.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import "popWeb.h"
#import "popWebSite.h"

@implementation frmMain
@synthesize lblCredits;
@synthesize imgCreditMask;

@synthesize maGPSData,pcWeb,pcDiary,pcVideo;

NSInteger swipeLength;
CGPoint gestureStartPoint;
int currentPicture = 1;
UIImageView *splashView;
int tapCount;
CGPoint tapLocation;
bool animOne = TRUE;
bool animTwo = TRUE;
float pageSwipeSpeed = 0.29f;
BOOL canShowMap = TRUE;
BOOL canShowInfo = FALSE;
BOOL isShowingIntro = TRUE;
BOOL isFlipping = FALSE;

- (void)viewDidLoad {

    splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 1024, 768)];
	splashView.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
	[self.view addSubview:splashView];
	[self.view bringSubviewToFront:splashView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(killPop:) name:@"killPop" object:nil];
    
    canShowInfo = FALSE;
    [self showInfo];
    vMap.alpha=0.0f;
    vIntro.layer.cornerRadius = 8;
    vMap.layer.cornerRadius = 8;
    mkMain.layer.cornerRadius = 8;
    mkIntro.layer.cornerRadius = 8;
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"SeenIntro"])
    {
        //Load the introduction screen
        lblTitle.alpha=0.0f;
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"frmIntro" owner:self options:nil];
        vIntro = [nibObjects objectAtIndex:0];
        vIntro.frame =  CGRectMake(0,44,1024,690);
        [self.view addSubview:vIntro];
        [self.view bringSubviewToFront:splashView];

        
        
        lblHowWork.layer.cornerRadius = 4;
        lblIntroMap.layer.cornerRadius = 4;
        lbl1.layer.cornerRadius = 4;
        lbl2.layer.cornerRadius = 4;
        lbl3.layer.cornerRadius = 4;
        
        
        pcMain.hidden = TRUE;
        btnWeb.hidden = TRUE;
        btnDiary.hidden=TRUE;
        btnVideo.hidden=TRUE;
        btnWallpaper.hidden = TRUE;
        
        // shake arrows
        tmArrowRight = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animArrow) userInfo:nil repeats:YES];
    }
    else
    {
        canShowInfo = FALSE;
        isShowingIntro = FALSE;
        canShowMap = FALSE;
        [self showInfo];
    }

    
    NSMutableArray *tempDataArray = [[NSMutableArray alloc] init];  
	self.maGPSData = tempDataArray;
	[tempDataArray release];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
	[UIView setAnimationDelegate:self]; 
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
	splashView.alpha = 0.0f;
	[UIView commitAnimations];
    
    //pinch
    imgMain.userInteractionEnabled = YES;
    UIPinchGestureRecognizer *pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pgr.delegate = self;
    [imgMain addGestureRecognizer:pgr];
    [pgr release];
    
    [super viewDidLoad];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
	[splashView removeFromSuperview];
	[splashView release];
}

- (void)hideIntro;
{
    //pcMain.numberOfPages = 43;
    pcMain.alpha=0.0f;
    pcMain.hidden = FALSE;
    lblTitle.alpha=0.0f;
    lblTitle.hidden = FALSE;
    btnWeb.alpha=0.0f;
    //btnWeb.hidden= FALSE;
    btnDiary.alpha=0.0f;
    btnDiary.hidden= FALSE;
    btnVideo.alpha=0.0f;
    btnVideo.hidden= FALSE;
    
    btnWallpaper.alpha=0.0f;
    btnWallpaper.hidden= FALSE;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.5];
    vIntro.alpha=0.0f;
    lblTitle.alpha=1.0f;
    //btnWeb.alpha=1.0f;
    btnDiary.alpha=1.0f;
    btnWallpaper.alpha=1.0f;
    pcMain.alpha=1.0f;
    [UIView commitAnimations];
	[self performSelector:@selector(removeInto) withObject:NULL afterDelay:3];
	//[vIntro release];
    lblInfo.layer.cornerRadius = 6;
    canShowInfo = FALSE;
    isShowingIntro = FALSE;
    canShowMap = FALSE;
    [self showInfo];
    [self showMap];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"SeenIntro"];
}

#pragma mark -
#pragma mark Map Stuff

- (IBAction)showIntroMap:(id)sender {
    lblIntroMap.alpha=0.0f;
    lblIntroMap.hidden = FALSE;
    mkIntro.alpha=0.0f;
    mkIntro.hidden=FALSE;
    imgArrowLeft.alpha=0.0f;
    lbl2.alpha=0.0f;
    imgArrowLeft.hidden=FALSE;
    lbl2.hidden=FALSE;
    [tmArrowRight invalidate];
    tmArrowRight = nil; 
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    mkIntro.alpha=1.0f;
    lblIntroMap.alpha=1.0f;
    imgArrowRight.alpha=0.0f;
    imgArrowUp.alpha=0.0f;
    lblHowWork.alpha=0.0f;
    lbl1.alpha=0.0f;
    // 2
    imgArrowLeft.alpha=1.0f;
    lbl2.alpha=1.0f;
    //btnExplore.alpha=1.0f;
    [UIView commitAnimations];
    tmArrowLeft = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animArrow2) userInfo:nil repeats:YES];
    
    
    CLLocationCoordinate2D coord = {.latitude =  -1.275, .longitude =  36.812};
    MKCoordinateSpan span = {.latitudeDelta =  5, .longitudeDelta =  5};
    MKCoordinateRegion region = {coord, span};
    
	[mkIntro setRegion:region];
	[mkIntro setZoomEnabled:YES];
    [mkIntro setScrollEnabled:YES];
	//[iMap setShowsUserLocation:YES];
	
	//lblFound.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
	//lblFound.layer.cornerRadius = 3.0;
	
	mapAnnotation *ann = [[mapAnnotation alloc] init];
	ann.title = @"Hoiday Inn, Nairobi";
	ann.subtitle = @"on 24/4/2010";
	ann.pinColor = @"red";
	ann.coordinate = region.center;
	[mkIntro addAnnotation:ann];
    [ann release];
	
    canShowInfo = TRUE;
    canShowMap = FALSE;
    
    
    //Masi Marra
    
    //Lake Nakuru
    
    // /  Tsavo West
    
    [self setMapPin:@"Tsavo West" subtitle:@"21st/22nd December" pin:@"green" lat:-2.907 lon:38.0604];
    [self setMapPin:@"Amboseli" subtitle:@"22nd/24th December" pin:@"green" lat:-2.6943 lon:37.2750];
    //[self setMapPin:@"Outspan" subtitle:@"24th/25th December" pin:@"green" lat:-x lon:x];
    [self setMapPin:@"Samburu" subtitle:@"25th/27th December" pin:@"green" lat:0.5720 lon:37.5375];
    [self setMapPin:@"Aberdares" subtitle:@"27th/28th December" pin:@"green" lat:-0.3685 lon:36.8421];
    [self setMapPin:@"Lake Nakuru" subtitle:@"28th/29th December" pin:@"green" lat:-0.4030 lon:36.1032];
    [self setMapPin:@"Lake Naivasha" subtitle:@"29th/30th December" pin:@"green" lat:-0.7633 lon:36.4239];
    [self setMapPin:@"Maasai Mara" subtitle:@"30th December to 2nd January" pin:@"green" lat:-1.518 lon:35.0809];
    
    /*
     tsavo west
     amboseli
     outspan
     samburu
     aberdares
     lake nakuru
     lake naivasha
     masai mara
     
     
     
     */
    
}

- (void) setMapPin:(NSString *)title subtitle:(NSString *)subtitle pin:(NSString *)pin lat:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon
{
    CLLocationCoordinate2D coord = {.latitude =  lat, .longitude =  lon};
	mapAnnotation *ann = [[mapAnnotation alloc] init];
	ann.title = title;
	ann.subtitle = subtitle;
	ann.pinColor = pin;
	ann.coordinate = coord;
	[mkIntro addAnnotation:ann];
    [ann release];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation
{
	//NSLog(@"viewForAnnotation called");
    
    if( annotation == mapView.userLocation ){ return nil; }
    mapAnnotation *mdelegate = annotation;  
    MKPinAnnotationView *pinView = nil;
    if(annotation != mapView.userLocation)
    {
		static NSString *defaultPinID = @"com.depicus.pin";
		pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if ( pinView == nil )
            pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
		
		if ([mdelegate.pinColor localizedCaseInsensitiveCompare:@"green"] == NSOrderedSame)
		{
			pinView.pinColor = MKPinAnnotationColorGreen;
			pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            
            
            
            UIButton *discloseButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
            discloseButton.tag = 1;
            [discloseButton addTarget:self action: @selector(pushPinInfo:) forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = discloseButton;
            
            
            
		}
		else if ([mdelegate.pinColor localizedCaseInsensitiveCompare:@"orange"] == NSOrderedSame)
		{
			UIImage * image = [UIImage imageNamed:@"pinOrange.png"];
			UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
			[pinView addSubview:imageView];
		}
		else
		{
			pinView.pinColor = MKPinAnnotationColorRed;
		}
		
		//pinView.Url
        
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
    }
    else
        [mapView.userLocation setTitle:@"I am here"];
    return pinView;
}

- (void) pushPinInfo:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection" 
                                                    message:@"You must be connected to the internet to use this app." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}



- (IBAction)showIntroInfo:(id)sender {
    lblntroInfo.alpha=0.0f;
    lblntroInfo.hidden=FALSE;
    lblntroInfo.layer.cornerRadius = 6;
    btnExplore.alpha=0.0f;
    btnExplore.hidden=FALSE;
    lbl3.alpha=0.0f;
    lbl3.hidden=FALSE;
    
    imgArrowDown.alpha=0.0f;
    imgArrowDown.hidden=FALSE;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    btnExplore.alpha=1.0f;
    imgArrowLeft.alpha=0.0f;
    lblntroInfo.alpha=0.43f;
    lblIntroMap.alpha=0.0f;
    mkIntro.alpha=0.0f;
    lbl2.alpha=0.0f;
    lbl3.alpha=1.0f;
    tvInfo.alpha=1.0f;
    
    imgArrowDown.alpha=1.0f;
    
    [UIView commitAnimations];
    animOne = TRUE;
    tmArrowRight = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animArrow3) userInfo:nil repeats:YES];
}

-(void) showInfo
{
    NSArray  * blankPage = [NSArray arrayWithObjects:[NSNumber numberWithInteger:100],[NSNumber numberWithInteger:200],[NSNumber numberWithInteger:300],[NSNumber numberWithInteger:400],
                            [NSNumber numberWithInteger:500],[NSNumber numberWithInteger:600],[NSNumber numberWithInteger:700],[NSNumber numberWithInteger:800],
                            [NSNumber numberWithInteger:900],[NSNumber numberWithInteger:1000],[NSNumber numberWithInteger:2000],nil];
    
    tvMain.hidden = FALSE;
    BOOL prevView = canShowInfo;
    if ([blankPage containsObject:[NSNumber numberWithInt:currentPicture]])
    {
        canShowInfo = FALSE;
        //NSLog(@"isEmpty count = %i",currentPicture);
    }
    if (canShowInfo) 
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        lblInfo.alpha=0.7f;
        tvMain.alpha=1.0f;
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        lblInfo.alpha=0.0f;
        tvMain.alpha=0.0f;
        [UIView commitAnimations];
    }
    canShowInfo = prevView;
}

- (void) showMap
{
    if (canShowMap)
    {
        //NSLog(@"canShowMap  = t");
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        vMap.alpha=1.0f;
        [UIView commitAnimations];

    }
    else
    {
        //NSLog(@"canShowMap  = f");
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        vMap.alpha=0.0f;
        [UIView commitAnimations];
    }
}

- (IBAction)btnHideMap:(id)sender {
    canShowMap = FALSE;
    [self showMap];
}

-(IBAction) mapTypeChanged{
    NSLog(@"mapTypeChanged");
    switch (scMap.selectedSegmentIndex) {
        case 0:
            mkMain.mapType = MKMapTypeStandard;
            break;
        case 1:
            mkMain.mapType = MKMapTypeSatellite;
            break;
        case 2:
            mkMain.mapType = MKMapTypeHybrid;
            break;
        default:
            mkMain.mapType = MKMapTypeStandard;
            break;
    }
    
    
    
}

- (IBAction)setWallpaper:(id)sender {
}

-(void) removeInto;
{
    isShowingIntro = FALSE;
    [vIntro removeFromSuperview];
}

#pragma mark -
#pragma mark Date Stuff

- (NSString *) getHumanReadableDay:(int)day
{
    if ((day == 1) || (day == 21) || (day == 31))
    {
        return [NSString stringWithFormat:@"%ist", day];
    }
    else if ((day == 2) || (day == 22))
    {
        return [NSString stringWithFormat:@"%ind", day];
    }
    else if ((day == 3) || (day == 23))
    {
        return [NSString stringWithFormat:@"%ird", day];
    }
    else
    {
        return [NSString stringWithFormat:@"%ith", day];
    }
}

- (NSString *) getHumanReadableMonth:(int)month
{
    switch (month) {
        case 1:
            return @"Jan";
            break;
        case 2:
            return @"Feb";
            break;
        case 3:
            return @"Mar";
            break;
        case 4:
            return @"Apr";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"June";
            break;
        case 7:
            return @"July";
            break;
        case 8:
            return @"Aug";
            break;
        case 9:
            return @"Sept";
            break;
        case 10:
            return @"Oct";
            break;
        case 11:
            return @"Nov";
            break;
        case 12:
            return @"Dec";
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *) getHumanReadableDate:(NSDictionary *)exifDic
{
    int iday = [[[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(8, 2)] intValue];
    int imonth = [[[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(5, 2)] intValue];
    
    int hour = [[[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(11, 2)] intValue] + 3;
    int mini = [[[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(14, 2)] intValue];
    
    //NSLog(@"Hour %@", [[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(11, 5)]);
    //NSLog(@"Min %@", [[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(14, 2)]);
    
    NSString *takenDate = [NSString stringWithFormat:@"%@ on %@ %@ %@",[NSString stringWithFormat:@"%02d:%02d",hour,mini], [self getHumanReadableDay:iday],[self getHumanReadableMonth:imonth],[[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(0, 4)] ];
    return takenDate;
}

#pragma mark -
#pragma mark Play Sounds

/*- (IBAction) playIntroMusic {
    NSLog(@"play sound");
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/KenyaSongs.mp3", [[NSBundle mainBundle] resourcePath]]];
    
	NSError *error;
	AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	audioPlayer.numberOfLoops = -1;
    
	if (audioPlayer == nil)
		NSLog(@"Error = %@",[error description]);
	else
		[audioPlayer play];
}*/

#pragma mark -
#pragma mark Pinch/Zoom

float lastScaleFactor = 1.0f;

- (void)handlePinch:(UIPinchGestureRecognizer *)sender
{
    //handle pinch...
     NSLog(@"handle pinch...");
    CGFloat factor = [(UIPinchGestureRecognizer *) sender scale];
    if (factor > 1) { 
        //---zooming in--- 
        sender.view.transform = CGAffineTransformMakeScale(lastScaleFactor + (factor-1),lastScaleFactor + (factor-1)); 
    } 
    else {
        //---zooming out--- 
        sender.view.transform = CGAffineTransformMakeScale(lastScaleFactor * factor, lastScaleFactor * factor);
    }
    if (sender.state == UIGestureRecognizerStateEnded) { 
        if (factor > 1) {
            lastScaleFactor += (factor-1); 
        } else {
            lastScaleFactor *= factor;
        }
    }
}

#pragma mark -
#pragma mark Popups

- (IBAction)getWeb:(id)sender {
    
    if (self.pcWeb == nil) {
        popWebSite *bookMarksViewController = [[popWebSite alloc] initWithNibName:@"popWebSite" bundle:[NSBundle mainBundle]]; 
        //pcWeb.popoverContentSize = CGSizeMake(400.0, 500.0);
        bookMarksViewController.navigationItem.title = @"Interweb";
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:bookMarksViewController];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];// navController]; 
        [pcWeb setDelegate:self];
        popover.delegate = self;
        [bookMarksViewController release];
        [navController release];
        
        self.pcWeb = popover;
        [popover release];
    }

    pcWeb.popoverContentSize = CGSizeMake(1014.0, 700.0);
    CGRect popoverRect = [self.view convertRect:[btnWeb frame] fromView:[btnWeb superview]];
    popoverRect.size.width = MIN(popoverRect.size.width, 100); 
    [self.pcWeb presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)getDiary:(id)sender {
    if (self.pcDiary == nil) {
        popWeb *bookMarksViewController = [[popWeb alloc] initWithNibName:@"popWeb" bundle:[NSBundle mainBundle]]; 
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:bookMarksViewController];
        [pcDiary setDelegate:self];
        popover.delegate = self;
        [bookMarksViewController release];
        self.pcDiary = popover;
        [popover release];
    }
    pcDiary.popoverContentSize = CGSizeMake(740.0, 700.0);
    CGRect popoverRect = [self.view convertRect:[btnDiary frame] fromView:[btnDiary superview]];
    popoverRect.size.width = MIN(popoverRect.size.width, 100); 
    [self.pcDiary presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)setAsWallpaper:(id)sender {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Save Picture" message:@"Save this picture to Photos, you can then use it as a background picture." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
    [alert setTag:1];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSLog(@"didDismissWithButtonIndex %i  %i", [alertView tag], buttonIndex);
    if ([alertView tag] == 1) { 
        if (buttonIndex == 1) {     // clicked OK.
            // do stuff
            NSLog(@"UIImageWriteToSavedPhotosAlbum");
            UIImageWriteToSavedPhotosAlbum(imgMain.image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    //NSLog(@"SAVE IMAGE COMPLETE");
    if(error != nil) {
        NSLog(@"ERROR SAVING:%@",[error localizedDescription]);
    }
}

-(void) killPop:(NSNotification *)notif {
    
    //NSLog(@"popover about to be dismissed %@", notif);
    [self.pcDiary dismissPopoverAnimated:YES];
    [self doSwipeRightToLeft];
    pcMain.currentPage = 0;
    
}


//---called when the user clicks outside the popover view---
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    
    NSLog(@"popover about to be dismissed");
    return YES;
}

//---called when the popover view is dismissed---
- (void)popoverControllerDidDismissPopover: (UIPopoverController *)popoverController {
    NSLog(@"popover dismissed");    
}

- (void) setCurrentPicture:(int)pic
{
    currentPicture = pic;
    [mkMain removeAnnotations:mkMain.annotations];
}


#pragma mark -
#pragma mark Info Bubble

- (NSInteger)tableView:(UITableView *)foodView numberOfRowsInSection:(NSInteger)section {
	return 9; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    
    UITableViewCell *cell; // = [tableView dequeueReusableCellWithIdentifier:@"bob"];
    UILabel *lblLabel = nil;
	UILabel *lblText = nil;
    
    //NSLog(@"cellForRowAtIndexPath ");
    
    NSString *myCurrentPic = [NSString stringWithFormat:@"%d", currentPicture];
    NSString *myPath = [[NSBundle mainBundle] pathForResource:myCurrentPic ofType:@"jpg"];
    NSURL *myURL = [NSURL fileURLWithPath:myPath];
    CGImageSourceRef mySourceRef = CGImageSourceCreateWithURL((CFURLRef)myURL, NULL);
    NSDictionary *metaDic = (NSDictionary *) CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
    CFRelease(mySourceRef);
    NSDictionary *exifDic = [metaDic objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    NSDictionary *tiffDic = [metaDic objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    NSDictionary *gpsDic = [metaDic objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
    NSDictionary *iptcDic = [metaDic objectForKey:(NSString *)kCGImagePropertyIPTCDictionary];
    
    //[metaDic release];
    NSString *headerText = [iptcDic objectForKey:(NSString *)kCGImagePropertyIPTCHeadline];
    if (headerText.length == 0)
    {
        headerText = @"a journey into the wild luxury of Africa";
    }
    lblTitle.text = [NSString stringWithFormat:@"Kenya - %@",headerText ];
    
    
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bob"] autorelease];
    cell.tag = indexPath.row;
    
    lblLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8, -12, 100, 50)] autorelease];
    lblLabel.tag = 1;
    lblLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:14.0f];
    lblLabel.textColor = [UIColor whiteColor];  ///colorWithRed:0/255 green: 0/255 blue:0/255 alpha:1];
    lblLabel.backgroundColor = [UIColor clearColor];
    lblLabel.opaque = NO;
    lblLabel.numberOfLines = 1;
    lblLabel.adjustsFontSizeToFitWidth = TRUE;
    lblLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [cell.contentView addSubview:lblLabel];
    
    CGRect txtRect;
    switch (indexPath.row) {
        case 0: {
            UIFont *cellFont = [UIFont fontWithName:@"Georgia" size:14.0];
            CGSize constraintSize = CGSizeMake(290.0f, MAXFLOAT);
            CGSize labelSize = [[iptcDic objectForKey:(NSString *)kCGImagePropertyIPTCCaptionAbstract] sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
            txtRect = CGRectMake(8, 6, 290, labelSize.height);
            break;
        }
        default:
        {
            txtRect = CGRectMake(118, 6, 180, 16); 
        }
    }
    
    lblText = [[[UILabel alloc] initWithFrame:txtRect] autorelease];
    lblText.tag = 2;
    lblText.numberOfLines = 0;
    lblText.font = [UIFont fontWithName:@"Georgia" size:14.0f];
    lblText.textColor = [UIColor whiteColor];
    lblText.backgroundColor = [UIColor clearColor];
    lblText.opaque = NO;
    lblText.adjustsFontSizeToFitWidth = TRUE;
    lblText.lineBreakMode = UILineBreakModeWordWrap;
    [cell.contentView addSubview:lblText];
    NSString *lat = @"";
    NSString *lon = @"";
    switch (indexPath.row) {
        case 0: {
            lblText.text = [iptcDic objectForKey:(NSString *)kCGImagePropertyIPTCCaptionAbstract];
            //NSLog(@"exifDic properties: %@", myMetadata); //all data
            //set map
            
            if ([[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLatitudeRef] isEqualToString:@"S"])
            {
                lat = [NSString stringWithFormat:@"-%@",[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLatitude]];
            }
            else
            {
                lat = [NSString stringWithFormat:@"%@",[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLatitude]];
            }
            
            
            if ([[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLongitudeRef] isEqualToString:@"W"])
            {
                lon = [NSString stringWithFormat:@"-%@",[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLongitude]];
            }
            else
            {
                lon = [NSString stringWithFormat:@"%@",[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLongitude]];
            }
            if (![lat isEqualToString:@"(null)"])
            {
                //ToDO check going forward
                [self.maGPSData addObject:[NSString stringWithFormat:@"%@,%@",lat,lon]];
                
                //[self.fDatabaseArray count]
                //[fDatabaseArray objectAtIndex:indexPath.row];
                
                CLLocationCoordinate2D coord = {.latitude =  [lat floatValue], .longitude =  [lon floatValue]};
                
                float largestGap = 500.0f;
                for (NSString* gpsData in maGPSData) {
                    //NSLog(@"maGPSData = %@", gpsData);
                    
                    NSArray *gpsChunks = [gpsData componentsSeparatedByString: @","];
                    //NSLog(@"maGPSData      a  = %@", [gpsChunks objectAtIndex:0]);
                    //NSLog(@"maGPSData      b  = %@", [gpsChunks objectAtIndex:1]);
                    
                    CLLocationCoordinate2D cGPS = {.latitude =  [[gpsChunks objectAtIndex:0] floatValue], .longitude =  [[gpsChunks objectAtIndex:1] floatValue]};
                    
                    CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
                    CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:cGPS.latitude longitude:cGPS.longitude];
                    CLLocationDistance d = [pointALocation distanceFromLocation:pointBLocation];
                    
                    if (d > largestGap)
                    {
                        largestGap = d;
                    }
                    
                    [pointALocation release];
                    [pointBLocation release];
                    
                }
                
                MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(coord, 2*largestGap, 2*largestGap);
                [mkMain setZoomEnabled:YES];
                [mkMain setScrollEnabled:YES];
                mapAnnotation *ann = [[mapAnnotation alloc] init];
                ann.title = [NSString stringWithFormat:@"%@", [iptcDic objectForKey:(NSString *)kCGImagePropertyIPTCHeadline]];
                ann.subtitle = [self getHumanReadableDate:exifDic];
                ann.pinColor = @"red";
                ann.coordinate = r.center;
                [mkMain addAnnotation:ann];
                [ann release];
                [mkMain setRegion:r animated:YES];
            }
            //NSLog(@" long %@  lat %@ ***%@***", lon, lat, [gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLatitudeRef]);
            break;
        }
        case 1: {
            lblLabel.text = @"Camera:";
            lblText.text = [tiffDic objectForKey:(NSString *)kCGImagePropertyTIFFModel];
            break;
        }
        case 2: {
            lblLabel.text = @"Focal Length:";
            lblText.text = [NSString stringWithFormat:@"%@mm",[exifDic objectForKey:(NSString *)kCGImagePropertyExifFocalLength]];
            break;
        }
        case 3: {
            lblLabel.text = @"Shutter Speed:";
            float rawShutterSpeed = [[exifDic objectForKey:(NSString *)kCGImagePropertyExifExposureTime] floatValue];
            int decShutterSpeed = round(1 / rawShutterSpeed);
            //NSLog(@"Shutter speed = %i %f %f",decShutterSpeed, rawShutterSpeed,round(1 / rawShutterSpeed));
            lblText.text = [NSString stringWithFormat:@"1/%d", decShutterSpeed];
            break;
        }
        case 4: {
            lblLabel.text = @"Aperture:";
            lblText.text = [NSString stringWithFormat:@"f/%@", [exifDic objectForKey:(NSString *)kCGImagePropertyExifFNumber]];
            break;
        }
        case 5: {
            lblLabel.text = @"ISO:";
            NSNumber *ExifISOSpeed  = [[exifDic objectForKey:(NSString*)kCGImagePropertyExifISOSpeedRatings] objectAtIndex:0];
            lblText.text = [NSString stringWithFormat:@"%i", [ExifISOSpeed integerValue]];
            break;
        }
        case 6: {
            lblLabel.text = @"Taken:"; //2011:05:07 16:25:59
            
            //NSLog(@"Year %@", [[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(0, 4)]);
            //NSLog(@"Month %@", [[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(5, 2)]);
            //NSLog(@"Day %@", [[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(8, 2)]);
            //NSLog(@"Hour %@", [[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(11, 5)]);
            //NSLog(@"Min %@", [[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized] substringWithRange:NSMakeRange(14, 2)]);
            
            
            
            //NSLog(@" taken = %@", takenDate);
            
            lblText.text = [self getHumanReadableDate:exifDic];// takenDate;//[NSString stringWithFormat:@"%@",[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized]];
            break;
        }
        case 7: {
            lblLabel.text = @"Latitude:";
            lat = [NSString stringWithFormat:@"%@",[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLatitude]];
            if ([lat isEqualToString:@"(null)"])
            {
                lblText.text = @"None";
            }
            else
            {
                lblText.text = [NSString stringWithFormat:@"%.4f %@",[[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLatitude] floatValue],[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLatitudeRef]];
            }
            
            break;
        }
        case 8: {
            lblLabel.text = @"Longitude:";
            lat = [NSString stringWithFormat:@"%@",[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLatitude]];
            if ([lat isEqualToString:@"(null)"])
            {
                lblText.text = @"None";
            }
            else
            {
            lblText.text = [NSString stringWithFormat:@"%.4f %@",[[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLongitude] floatValue],[gpsDic objectForKey:(NSString*)kCGImagePropertyGPSLongitudeRef]];
            }
            break;
        }
        default:
        {
            lblLabel.text = @"Camera:";
            lblText.text = @"Canon EOS 7D";
        }
    }
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowHeight = 28;
    if (indexPath.row == 0)
    {
        NSString *myCurrentPic = [NSString stringWithFormat:@"%d", currentPicture];
        NSString *myPath = [[NSBundle mainBundle] pathForResource:myCurrentPic ofType:@"jpg"];
        //NSLog(@"path = %@     %@",myPath ,myCurrentPic);
        NSURL *myURL = [NSURL fileURLWithPath:myPath];
        CGImageSourceRef mySourceRef = CGImageSourceCreateWithURL((CFURLRef)myURL, NULL);
        NSDictionary *myMetadata = (NSDictionary *) CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
        CFRelease(mySourceRef);
        NSDictionary *iptcDic = [myMetadata objectForKey:(NSString *)kCGImagePropertyIPTCDictionary];
        NSString *captionInfo = [iptcDic objectForKey:(NSString *)kCGImagePropertyIPTCCaptionAbstract];
        UIFont *cellFont = [UIFont fontWithName:@"Georgia" size:14.0];
        CGSize constraintSize = CGSizeMake(290.0f, MAXFLOAT);
        CGSize labelSize = [captionInfo sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        rowHeight = labelSize.height + 12;
    }
    //NSLog(@"in heightForRowAtIndexPath %i = %i",indexPath.row,rowHeight);
    return rowHeight;
}


/*CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
 fadeAnimation.removedOnCompletion = YES;
 fadeAnimation.duration = duration;
 fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
 
 [fadeAnimation setToValue:[NSNumber numberWithFloat:0.0]];
 fadeAnimation.fillMode = kCAFillModeForwards;
 fadeAnimation.removedOnCompletion = NO;*/


#pragma mark -
#pragma mark Swipe Left

- (void) swipeRight:(UIImageView *)viewToOpen duration:(NSTimeInterval)duration isLeft:(BOOL)isLeft {

    [viewToOpen.layer removeAllAnimations];
    viewToOpen.hidden = NO;
    viewToOpen.userInteractionEnabled = NO;
    if (isLeft)
    {
        viewToOpen.layer.anchorPoint = CGPointMake(1.0f, 0.5f); 
        [self.view bringSubviewToFront:imgLeft]; 
        [self.view bringSubviewToFront:imgLeftFold];
        imgMain.layer.zPosition = -2024;
        imgLeft.layer.zPosition = 2024;
    }
    else
    {
        viewToOpen.layer.anchorPoint = CGPointMake(0.0f, 0.5f); 
        [self.view bringSubviewToFront:imgRight];
    }
    
    viewToOpen.center = CGPointMake(512, viewToOpen.center.y);
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CATransform3D endTransform = CATransform3DMakeRotation(M_PI /2.0f,0.0f,-1.0f,0.0f);
    endTransform.m34 = 0.001f;
    endTransform.m14 = -0.0015f;
    
    CATransform3D startTransform = CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
    startTransform.m34 = -0.001f;
    startTransform.m14 = 0.0015f;
    
    if (isLeft)
    {
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:startTransform];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity]; 
    }
    else
    {
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:endTransform]; 
    }
    
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.fillMode = kCAFillModeForwards;

    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.delegate = self;
    animGroup.duration = duration;
    if (isLeft)
    {
        [animGroup setValue:@"middleToLeft" forKey:@"viewToOpenTag"]; 
    }
    else
    {
        [animGroup setValue:@"rightToMiddle" forKey:@"viewToOpenTag"]; 
    }
	
    animGroup.animations = [NSArray arrayWithObjects:transformAnimation,nil];
    animGroup.removedOnCompletion = NO;
    animGroup.fillMode = kCAFillModeForwards;
    [viewToOpen.layer addAnimation:animGroup forKey:@"flipViewOpen"];
    //NSLog(@"r2m %f %f", imgMain.center.x,imgMain.center.y);
    tvInfo.hidden = FALSE;
    tvInfo.layer.zPosition = 2025;
    vMap.layer.zPosition = 2026;
}

#pragma mark Swipe Right

- (void) leftToMiddle:(UIView *)viewToOpen duration:(NSTimeInterval)duration {
    [viewToOpen.layer removeAllAnimations];
    viewToOpen.hidden = NO;
    viewToOpen.userInteractionEnabled = NO;
    
    [self.view bringSubviewToFront:viewToOpen];
    
    viewToOpen.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
    viewToOpen.center = CGPointMake(512, viewToOpen.center.y);
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CATransform3D endTransform = CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
    endTransform.m34 = -0.001f;
    endTransform.m14 = 0.0015f;
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:endTransform];
    
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    theGroup.delegate = self;
    theGroup.duration = duration;
    //[theGroup setValue:[NSNumber numberWithInt:viewToOpen.tag] forKey:@"viewToOpenTag"];
	[theGroup setValue:@"leftToMiddle" forKey:@"viewToOpenTag"];
    theGroup.animations = [NSArray arrayWithObjects:transformAnimation, nil];
    theGroup.removedOnCompletion = NO;
    theGroup.fillMode = kCAFillModeForwards;
    [viewToOpen.layer addAnimation:theGroup forKey:@"flipViewOpen"];
    //NSLog(@"l2m %f %f", imgMain.center.x,imgMain.center.y);
}

- (void) middleToRight:(UIView *)viewToOpen duration:(NSTimeInterval)duration {
    //NSLog(@"middleToRight");
    [self.view bringSubviewToFront:viewToOpen];
    [viewToOpen.layer removeAllAnimations];
    viewToOpen.hidden = NO;
    viewToOpen.userInteractionEnabled = NO;
    if (viewToOpen.layer.anchorPoint.x != 0.0f) 
    {
        viewToOpen.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToOpen.center = CGPointMake(512, viewToOpen.center.y);
    }
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CATransform3D endTransform = CATransform3DMakeRotation(3.141f/2.0f,0.0f,-1.0f,0.0f);
    endTransform.m34 = 0.001f;
    endTransform.m14 = -0.0015f;
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:endTransform];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    theGroup.delegate = self;
    theGroup.duration = duration;
    [theGroup setValue:[NSNumber numberWithInt:viewToOpen.tag] forKey:@"viewToOpenTag"];
	[theGroup setValue:@"middleToRight" forKey:@"viewToOpenTag"];
    theGroup.animations = [NSArray arrayWithObjects:transformAnimation, nil];
    theGroup.removedOnCompletion = NO;
    [viewToOpen.layer addAnimation:theGroup forKey:@"flipViewOpen"];
    //NSLog(@"m2r %f %f %f %f", imgLeft.center.x,imgLeft.center.y,imgMain.center.x,imgMain.center.y);
}
///////////////////

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	NSString* value = [theAnimation valueForKey:@"viewToOpenTag"];
    if ([value isEqualToString:@"rightToMiddle"])
    {
        [self swipeRight:imgLeft duration:pageSwipeSpeed isLeft:TRUE];
        UIImage *imgCaptured = imgMain.image;
        CGImageRef imageRef = CGImageCreateWithImageInRect(imgCaptured.CGImage, CGRectMake(0, 0, 512, 683));
        [imgLeft setImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
        [self showMap];
		return;
    }
    if ([value isEqualToString:@"middleToLeft"])
    {
        [self.view sendSubviewToBack:imgLeft];
        [self.view sendSubviewToBack:imgLeftFold];
        [self.view sendSubviewToBack:imgRight];
        [self.view bringSubviewToFront:imgMain];
        [self.view bringSubviewToFront:tvMain];
        [self.view bringSubviewToFront:vMap];
        imgLeftFold.alpha=0.0f;
        imgLeft.alpha=0.0f;
        [self showInfo];
        isFlipping = FALSE;
        //NSLog(@"currentPicture  = %i", currentPicture);
        if (currentPicture == 2000) 
        {
            [self animCredits];
        }
		return;
    }
    
    ////////////////////////////
    /// Swiping left to right
    ////////////////////////////
    
    if ([value isEqualToString:@"leftToMiddle"])
    {
        [imgLeft setImage:imgLeftFold.image];
        UIImageWriteToSavedPhotosAlbum(imgLeftFold.image, nil, nil, nil);
        imgRight.alpha=1.0f;
        imgLeft.alpha=0.0f;
		[self middleToRight:imgRight duration:pageSwipeSpeed];
		return;
    }
    if ([value isEqualToString:@"middleToRight"])
    {
        [self.view sendSubviewToBack:imgLeft];
        [self.view sendSubviewToBack:imgLeftFold];
        [self.view sendSubviewToBack:imgRight];
        [self.view bringSubviewToFront:imgMain];
        [self.view bringSubviewToFront:tvMain];
        [self.view bringSubviewToFront:vMap];
        
        NSString *mypic = [NSString stringWithFormat:@"%d", currentPicture];
        CGRect screenRectLeft = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        UIGraphicsBeginImageContext(screenRectLeft.size);
        CGContextRef ctxLeft = UIGraphicsGetCurrentContext();
        [[UIColor blackColor] set];
        CGContextFillRect(ctxLeft, screenRectLeft);
        [self.view.layer renderInContext:ctxLeft];
        
        UIImage *img = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:mypic ofType:@"jpg"]];
        [imgMain setImage:img];
        
        UIGraphicsEndImageContext();
        
        isFlipping = FALSE;
        
		imgRight.alpha=0.0f;
        imgLeftFold.alpha=0.0f;
        [self showInfo];
        
        
        
        
        
        
		return;
    }
    
    //[self.view sendSubviewToBack:vMap];
}

#pragma mark Swipe

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    gestureStartPoint = [touch locationInView:self.view]; 
	[super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	//NSLog(@"gestureStartPoint x = %f  y = %f  ", gestureStartPoint.x, gestureStartPoint.y);
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint currentPosition = [touch locationInView:self.view];
	//NSLog(@"currentPositionx = %f", currentPosition.x);
	//CGFloat deltaX = fabsf(gestureStartPoint.x - currentPosition.x);
	swipeLength = gestureStartPoint.x - currentPosition.x;
	[super touchesMoved:touches	withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesEnded %i", swipeLength );
    if (isShowingIntro || isFlipping) 
    {
        swipeLength = 0;
    }
    if (swipeLength > 170) 
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(doSwipeRightToLeft)];
        imgMain.transform = CGAffineTransformMakeScale(1.0f,1.0f);
        [UIView commitAnimations];
        return;
    }
    if (swipeLength < -170) 
    {
        NSLog(@"touchesEnded -170");
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(doSwipeLeft)];
        imgMain.transform = CGAffineTransformMakeScale(1.0f,1.0f);
        [UIView commitAnimations];
        return;
    }
    
	swipeLength = 0;
    
    tapCount++;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint currentPosition = [touch locationInView:self.view];

    switch (tapCount)
    {
        case 1: //single tap
            [self performSelector:@selector(singleTap) withObject: nil afterDelay: .8];
            tapLocation.x = currentPosition.x;
            tapLocation.y = currentPosition.y;
            break;
        case 2: //double tap
            if (currentPicture == 2000) return;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
            tapCount = 0;
            
            imgMain.transform = CGAffineTransformMakeScale(1.0f,1.0f); 
            
            int tapDistance = abs(currentPosition.x - tapLocation.x);
            
            //NSLog(@"double tap x = %f, y = %f     tapDistance %d", currentPosition.x, currentPosition.y,tapDistance); //34 350
            if (tapDistance > 120)  
            {
                break;
            }
            
            if ((NSLocationInRange(currentPosition.x, NSMakeRange(600, 1000-660))) && (NSLocationInRange(currentPosition.y, NSMakeRange(34, 650-34))))
            {
                if (isShowingIntro)
                {
                    [self showIntroMap:(0)]; 
                }
                else
                {
                    canShowMap = !canShowMap;
                    [self showMap];
                }
            }
            
            if ((NSLocationInRange(currentPosition.x, NSMakeRange(20, 360))) && (NSLocationInRange(currentPosition.y, NSMakeRange(20, 620))) )
            {
                if (isShowingIntro)
                {
                    if (canShowInfo)
                    {
                        [self showIntroInfo:(0)];
                    }
                }
                else
                {
                    canShowInfo = !canShowInfo;
                    [self showInfo];
                }
            }
            
            break;
        default:
            break;
    }
    
	[super touchesEnded:touches withEvent:event];
}

- (void)singleTap
{	
    tapCount = 0;
}


- (void) doSwipeRightToLeft
{
    isFlipping = TRUE;
    swipeLength = 0;
    currentPicture++;
    
    pcMain.currentPage += 1;
    

    NSArray  * aCP = [NSArray arrayWithObjects:[NSNumber numberWithInteger:45],[NSNumber numberWithInteger:138],[NSNumber numberWithInteger:241],[NSNumber numberWithInteger:349],
                      [NSNumber numberWithInteger:425],[NSNumber numberWithInteger:515],[NSNumber numberWithInteger:632],[NSNumber numberWithInteger:740],
                      [NSNumber numberWithInteger:812],[NSNumber numberWithInteger:927],nil];
    NSArray  * aNP = [NSArray arrayWithObjects:[NSNumber numberWithInteger:100],[NSNumber numberWithInteger:200],[NSNumber numberWithInteger:300],[NSNumber numberWithInteger:400],
                      [NSNumber numberWithInteger:500],[NSNumber numberWithInteger:600],[NSNumber numberWithInteger:700],[NSNumber numberWithInteger:800],
                      [NSNumber numberWithInteger:900],[NSNumber numberWithInteger:1000],nil];

    if ([aCP containsObject:[NSNumber numberWithInt:currentPicture]])
    {
        [mkMain removeAnnotations:mkMain.annotations];
        [self.maGPSData removeAllObjects];
        unsigned int elementNumber = [aCP indexOfObject: [NSNumber numberWithInt:currentPicture]];
        //NSLog(@")))))))))))))    fond it %i at position %i", currentPicture, elementNumber);
        currentPicture = [[aNP objectAtIndex:elementNumber] integerValue];
        if (elementNumber < (aCP.count -1) )
        {
            int finalPictureInSet = [[aCP objectAtIndex:elementNumber + 1] integerValue];
            pcMain.numberOfPages = (finalPictureInSet - currentPicture);
            NSLog(@"number of pages = %i and final pic is %i", pcMain.numberOfPages, finalPictureInSet);
            
        }
        else
        {
            pcMain.numberOfPages = 30;
        }
        pcMain.currentPage = -1;
    }
    if (currentPicture == 2001) return;
    if (currentPicture == 1031) 
    {
        pcMain.hidden = TRUE;
        currentPicture = 2000;  
        
    }
    //NSLog(@"currentPicture it    at position %i", currentPicture);
    imgLeft.alpha=1.0f;
    imgLeftFold.alpha=1.0f;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:(pageSwipeSpeed / 3)];
    lblInfo.alpha=0.0f;
    tvMain.alpha=0.0f;
    vMap.alpha=0.0f;
    [UIView commitAnimations];
    
    CGRect screenRectLeft = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    UIGraphicsBeginImageContext(screenRectLeft.size);
    CGContextRef ctxLeft = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctxLeft, screenRectLeft);
    [self.view.layer renderInContext:ctxLeft];
    UIImage *imCaptured = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imageRefRight = CGImageCreateWithImageInRect(imCaptured.CGImage, CGRectMake(512, 48, 512, 683));
    [imgRight setImage:[UIImage imageWithCGImage:imageRefRight]];
    CGImageRelease(imageRefRight);
    UIGraphicsEndImageContext();
    imgRight.alpha=1.0f;
    NSString *mypic = [NSString stringWithFormat:@"%d", currentPicture];
    //NSLog(@"currentPicture is :%d",currentPicture);
    
    //get left previous pic - shown when half way to full
    UIImage *imgCaptured = imgMain.image;
    CGImageRef imageRef = CGImageCreateWithImageInRect(imgCaptured.CGImage, CGRectMake(0, 0, 512, 683));
    [imgLeftFold setImage:[UIImage imageWithCGImage:imageRef]];
    [imgLeft setImage:[UIImage imageWithCGImage:imageRef]];
    CGImageRelease(imageRef);
    [self.view bringSubviewToFront:imgLeft];
    
    UIImage *img = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:mypic ofType:@"jpg"]];
    [imgMain setImage:img];
    
    [tvMain reloadData];
    
    [self swipeRight:imgRight duration:pageSwipeSpeed isLeft:FALSE];
}

- (void) doSwipeLeft
{
    swipeLength = 0;
    if (currentPicture == 1) return;
    isFlipping = TRUE;    //NSLog(@"currentPicture is :%d",currentPicture);
    currentPicture--;     //NSLog(@"Swipe left to right current pic is %i", currentPicture);  
    pcMain.currentPage -= 1;
    
    if (currentPicture == 1999)
    {
        currentPicture = 1030; 
        pcMain.hidden = FALSE;
        [self stopCredits];
    }
    
    NSArray  * aCP = [NSArray arrayWithObjects:[NSNumber numberWithInteger:44],[NSNumber numberWithInteger:137],[NSNumber numberWithInteger:240],[NSNumber numberWithInteger:347],
                      [NSNumber numberWithInteger:424],[NSNumber numberWithInteger:514],[NSNumber numberWithInteger:631],[NSNumber numberWithInteger:739],
                      [NSNumber numberWithInteger:811],[NSNumber numberWithInteger:926],nil];
    NSArray  * aNP = [NSArray arrayWithObjects:[NSNumber numberWithInteger:99],[NSNumber numberWithInteger:199],[NSNumber numberWithInteger:299],[NSNumber numberWithInteger:399],
                      [NSNumber numberWithInteger:499],[NSNumber numberWithInteger:599],[NSNumber numberWithInteger:699],[NSNumber numberWithInteger:799],
                      [NSNumber numberWithInteger:899],[NSNumber numberWithInteger:999],nil];
    
    if ([aNP containsObject:[NSNumber numberWithInt:currentPicture]])
    {
        [mkMain removeAnnotations:mkMain.annotations];
        [self.maGPSData removeAllObjects];
        unsigned int elementNumber = [aNP indexOfObject: [NSNumber numberWithInt:currentPicture]];
        //NSLog(@"************  found it %i at position %i", currentPicture, elementNumber);
        currentPicture = [[aCP objectAtIndex:elementNumber] integerValue];
        int finalPictureInSet = [[aNP objectAtIndex:elementNumber] integerValue];
        pcMain.numberOfPages = (currentPicture - (finalPictureInSet - 100));
        //NSLog(@"number of pages = %i and final pic is %i", pcMain.numberOfPages, (finalPictureInSet - 100));
        pcMain.currentPage = pcMain.numberOfPages;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:(pageSwipeSpeed / 3)];
    lblInfo.alpha=0.0f;
    tvMain.alpha=0.0f;
    vMap.alpha=0.0f;
    [UIView commitAnimations];
    
    imgLeft.alpha=1.0f;
    imgLeftFold.alpha=1.0f;
    imgRight.alpha=0.0f;
    
    //currentPicture
    NSString *mypic = [NSString stringWithFormat:@"%d", currentPicture];
    //NSLog(@"currentPicture is :%d",currentPicture);
    UIImage *img = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:mypic ofType:@"jpg"]];
    CGRect screenRectLeft = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    UIGraphicsBeginImageContext(screenRectLeft.size);
    CGContextRef ctxLeft = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctxLeft, screenRectLeft);
    [self.view.layer renderInContext:ctxLeft];
    CGImageRef imageRefRight = CGImageCreateWithImageInRect(img.CGImage, CGRectMake(512, 0, 512, 683));
    [imgRight setImage:[UIImage imageWithCGImage:imageRefRight]];
    CGImageRelease(imageRefRight);
    UIImage *imgCaptured = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imageRefLeft = CGImageCreateWithImageInRect(imgCaptured.CGImage, CGRectMake(0, 48, 512, 683));
    [imgLeft setImage:[UIImage imageWithCGImage:imageRefLeft]];
    CGImageRelease(imageRefLeft);
    CGImageRef imageRefLeftFold = CGImageCreateWithImageInRect(img.CGImage, CGRectMake(0, 0, 512, 683));
    [imgLeftFold setImage:[UIImage imageWithCGImage:imageRefLeftFold]];
    CGImageRelease(imageRefLeftFold);
    imgLeft.alpha=1.0f;
    imgLeftFold.alpha=1.0f;
    UIGraphicsEndImageContext();
    [self leftToMiddle:imgLeft duration:pageSwipeSpeed];
    [tvMain reloadData];
}

#pragma mark -
#pragma mark Move Arrows


- (void)moveImage:(UIImageView *)image duration:(NSTimeInterval)duration curve:(int)curve x:(CGFloat)x y:(CGFloat)y
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The transform matrix
    CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
    image.transform = transform;
    // Commit the changes
    [UIView commitAnimations];
}

-(void) animArrow
{
    if (animOne)
    {
        [self moveImage:imgArrowRight duration:1.6 curve:UIViewAnimationCurveLinear x:50.0 y:12.0];
        [self moveImage:imgArrowUp duration:1.6 curve:UIViewAnimationCurveLinear x:-6.0 y:32.0];
    }
    else
    {
        [self moveImage:imgArrowRight duration:1.6 curve:UIViewAnimationCurveLinear x:-50.0 y:-12.0];
        [self moveImage:imgArrowUp duration:1.6 curve:UIViewAnimationCurveLinear x:6.0 y:-32.0];
    }
    animOne = !animOne;
}

-(void) animArrow2
{
    if (animTwo)
    {
        [self moveImage:imgArrowLeft duration:1.6 curve:UIViewAnimationCurveLinear x:-50.0 y:-12.0];
    }
    else
    {
        [self moveImage:imgArrowLeft duration:1.6 curve:UIViewAnimationCurveLinear x:50.0 y:12.0];
    }
    animTwo=!animTwo;
}

-(void) animArrow3
{
    if (animOne)
    {
        [self moveImage:imgArrowDown duration:1.6 curve:UIViewAnimationCurveLinear x:12.0 y:-50.0];
        animOne = FALSE;
    }
    else
    {
        [self moveImage:imgArrowDown duration:1.6 curve:UIViewAnimationCurveLinear x:-12.0 y:50.0];
        animOne = TRUE;
    }
    
}
-(void) hideCredits
{
    //NSLog(@"hideCredits");
    lblCredits.hidden = TRUE;
    imgCreditMask.hidden = TRUE;
}

-(void) animCredits
{
    [lblCredits.layer removeAllAnimations];

    lblCredits.transform = CGAffineTransformMakeTranslation(0, 0);     
    CGRect frame = lblCredits.frame;
    frame.origin.y = 550.0;
    lblCredits.frame = frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:pageSwipeSpeed * 2];
    lblCredits.hidden = FALSE;
    imgCreditMask.hidden = FALSE;
    [UIView commitAnimations];

    [UILabel beginAnimations:nil context:NULL];
    [UILabel setAnimationDuration:30.0f];
    [UILabel setAnimationCurve:UIViewAnimationCurveLinear];
    [UILabel setAnimationBeginsFromCurrentState:YES];
    [UILabel setAnimationDelegate:self];
    [UILabel setAnimationDidStopSelector:@selector(creditsHaveEnded)];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -1000);
    lblCredits.transform = transform;
    [UILabel commitAnimations];

}

-(void) stopCredits
{
    [UILabel beginAnimations:nil context:NULL];
    [UILabel setAnimationDuration:0.0f];
    [UILabel setAnimationCurve:UIViewAnimationCurveLinear];
    [UILabel setAnimationBeginsFromCurrentState:YES];
    [UILabel setAnimationDelegate:self];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 0);
    lblCredits.transform = transform;
    [UILabel commitAnimations];
    [self hideCredits];
}

-(void) creditsHaveEnded
{
    [self stopCredits];
}

#pragma mark -
#pragma mark End

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [lblTitle release];
    lblTitle = nil;
    //[self setShowIntroMap:nil];
    [lblIntroMap release];
    lblIntroMap = nil;
    [imgArrowRight release];
    imgArrowRight = nil;
    [lblHowWork release];
    lblHowWork = nil;
    [lbl1 release];
    lbl1 = nil;
    [imgArrowUp release];
    imgArrowUp = nil;
    [imgArrowLeft release];
    imgArrowLeft = nil;
    [lbl2 release];
    lbl2 = nil;
    [btnExplore release];
    btnExplore = nil;
    [lblInfo release];
    lblInfo = nil;
    [tvInfo release];
    tvInfo = nil;
    [lbl3 release];
    lbl3 = nil;
    [imgArrowDown release];
    imgArrowDown = nil;
    [tvMain release];
    tvMain = nil;
    [lblntroInfo release];
    lblntroInfo = nil;
    [mkMain release];
    mkMain = nil;
    [btnWeb release];
    btnWeb = nil;
    [vMap release];
    vMap = nil;
    [scMap release];
    scMap = nil;
    [btnWallpaper release];
    btnWallpaper = nil;
    [btnDiary release];
    btnDiary = nil;
    [btnVideo release];
    btnVideo = nil;
    [btnWallpaper release];
    btnWallpaper = nil;
    [self setLblCredits:nil];
    [self setImgCreditMask:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [imgMain release];
    [imgLeft release];
    [imgRight release];
    [pcMain release];
    [imgLeftFold release];
    [mkIntro release];
    [lblTitle release];
    [showIntroMap release];
    [lblIntroMap release];
    [imgArrowRight release];
    [lblHowWork release];
    [lbl1 release];
    [imgArrowUp release];
    [imgArrowLeft release];
    [lbl2 release];
    [btnExplore release];
    [lblInfo release];
    [tvInfo release];
    [lbl3 release];
    [imgArrowDown release];
    [tvMain release];
    [lblntroInfo release];
    [mkMain release];
    [btnWeb release];
    [pcWeb release];
    [vMap release];
    [scMap release];
    [btnWallpaper release];
    [btnDiary release];
    [btnVideo release];
    [btnWallpaper release];
    [lblCredits release];
    [imgCreditMask release];
    [super dealloc];
}


@end
