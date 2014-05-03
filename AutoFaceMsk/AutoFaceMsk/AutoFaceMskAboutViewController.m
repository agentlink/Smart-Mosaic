//
//  AutoFaceMskAboutViewController.m
//  AutoFaceMsk
//
//  Created by agent on 12-10-17.
//  Copyright (c) 2012年 agent. All rights reserved.
//

#import "AutoFaceMskAboutViewController.h"

@interface AutoFaceMskAboutViewController ()

@end

@implementation AutoFaceMskAboutViewController

- (id) init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    
	return self;
}

#pragma mark - View lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Settings", @"Settings");
    
    //初始化 admob
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    GADRequest *rq = [GADRequest request];
    rq.testing = NO;
    
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a150fb0a119ace5";
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    bannerView_.frame = CGRectMake(0, 0, bannerView_.frame.size.width, bannerView_.frame.size.height);
    [self.view addSubview:bannerView_];
    
    bannerView_.delegate = self;
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
    
    __block typeof (self) bself = self;
    
	[self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        section.headerTitle = NSLocalizedString(@"Settings", @"Settings":);
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath){
            cell.textLabel.text = NSLocalizedString(@"Picture quality", @"Picture quality");
        } whenSelected:^(NSIndexPath *indexPath) {
            [bself performSegueWithIdentifier:@"Push to PictureQuality" sender:nil];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath){
            cell.textLabel.text = NSLocalizedString(@"Face Recognition strength", @"Face Recognition strength");
        } whenSelected:^(NSIndexPath *indexPath) {
            [bself performSegueWithIdentifier:@"Push to Face Recognition strength" sender:nil];
        }];
    }];
	
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        section.headerTitle = NSLocalizedString(@"More apps", @"More apps":);
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"AgedPhoto", @"AgedPhoto");
            cell.imageView.image = [UIImage imageNamed:@"AgedPhoto"];
            cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/app/agedphoto/id659267578?mt=8&ign-mpt=uo%3D2"]];
		}];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"FaceCamera Pro", @"FaceCamera Pro");
            cell.imageView.image = [UIImage imageNamed:@"FaceCameraPro"];
            cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/app/face-camera-pro/id541710773?ls=1&mt=8"]];
		}];
        
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Smart Mosaic Pro", @"Smart Mosaic Pro");
            cell.imageView.image = [UIImage imageNamed:@"SmartMosaic Pro"];
            cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/app/smart-mosaic-pro-photo-mosaic/id570980749?ls=1&mt=8"]];
		}];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Smart Mosaic HD Pro", @"Smart Mosaic HD Pro");
            cell.imageView.image = [UIImage imageNamed:@"SmartMosaicHD Pro"];
            cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/app/smart-mosaic-hd-pro-photo/id578072496?ls=1&mt=8"]];
		}];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"FaceCamera", @"FaceCamera");
            cell.imageView.image = [UIImage imageNamed:@"FaceCamera"];
            cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/app/face-camera/id549468763?ls=1&mt=8"]];
		}];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Smart Mosaic HD", @"Smart Mosaic HD");
            cell.imageView.image = [UIImage imageNamed:@"SmartMosaicHD"];
            cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/app/smart-mosaic-hd-photo-mosaic/id595360266?ls=1&mt=8"]];
		}];
        
	}];
    
	[self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        section.headerTitle = NSLocalizedString(@"Other", @"Other":);
        
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Rate us in the App Store!", @"Rate us in the App Store!");
			cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/app/smart-mosaic-photo-mosaic/id594876382?ls=1&mt=8"]];
		}];
        
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			cell.textLabel.text = NSLocalizedString(@"Contact the Author", @"Contact the Author");
            cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
            [bself sendMail];
		}];
        
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			cell.textLabel.text = NSLocalizedString(@"Version: 7.0.0", @"Version");
			cell.accessoryType = UITableViewCellAccessoryNone;
		} whenSelected:^(NSIndexPath *indexPath) {
			//TODO
		}];
	}];
}

- (void)sendMail
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setToRecipients:[NSArray arrayWithObjects:@"rabbit20110410@gmail.com", nil]];
    [controller setSubject: @"Smart Mosaic"];
    [controller setMailComposeDelegate:self];
    [self presentViewController:controller animated:YES completion:nil];
}

/**
 //客户端接收到广告后调用
 - (void)adViewDidReceiveAd:(GADBannerView *)view
 {
 _imageView.frame = CGRectMake(0, bannerView_.frame.size.height, IMAGESWIDTH, IMAGESHEIGHT);
 
 if (_pointsView != nil) {
 [_pointsView removeFromSuperview];
 }
 
 self.pointsView = [[JBCroppableView alloc] initWithImageView:CGRectMake(0,  bannerView_.frame.size.height, IMAGESWIDTH, IMAGESHEIGHT + bannerView_.frame.size.height)];
 [self.pointsView addPoints:4];
 
 [self.view addSubview:self.pointsView];
 }
 
 - (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error;
 {
 if (_pointsView != nil) {
 [_pointsView removeFromSuperview];
 }
 
 self.pointsView = [[JBCroppableView alloc] initWithImageView:CGRectMake(0,  0, IMAGESWIDTH, IMAGESHEIGHT)];
 [self.pointsView addPoints:4];
 
 [self.view addSubview:self.pointsView];
 }**/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    [super viewWillAppear:animated];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
