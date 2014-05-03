//
//  AutoFaceMskAboutViewController.h
//  AutoFaceMsk
//
//  Created by agent on 12-10-17.
//  Copyright (c) 2012年 agent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMStaticContentTableViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"

@interface AutoFaceMskAboutViewController : JMStaticContentTableViewController<UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, GADBannerViewDelegate>
{
    GADBannerView *bannerView_; //添加admob广告
}
@end
