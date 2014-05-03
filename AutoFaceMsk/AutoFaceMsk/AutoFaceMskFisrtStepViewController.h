//
//  AutoFaceMskFisrtStepViewController.h
//  AutoFaceMsk
//
//  Created by agent on 12-10-17.
//  Copyright (c) 2012年 agent. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AFPhotoEditorController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "JBCroppableView.h"
#import "GADInterstitial.h"
//#import <iAd/iAd.h>

@interface AutoFaceMskFisrtStepViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,GADInterstitialDelegate, UIScrollViewDelegate>
{
    CGPoint VICPoint;
    BOOL isRotated;
    BOOL isEraseMsk;
    BOOL canEarse;
    BOOL pictureQuality;
    BOOL faceQuality;

    CGFloat scaleMsk;
    CGFloat scaleEffect;
    
    NSTimer *timer;
    UILabel *popScaleMskEffectView;
    
	long long expectedLength;
	long long currentLength;
    
    CGRect faceBound;
    CIContext *contextMsk;
    CGRect mskRect;
    
    GADInterstitial *interstitial_;
}

@property (strong,nonatomic) UIImagePickerController *imgPickerControll;
@property (strong, nonatomic) UIImage *revImage;
@property (nonatomic, strong) JBCroppableView *pointsView;

@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UISlider *scaleMskEffect;

@property (weak, nonatomic) IBOutlet UIButton *btnMsk;
@property (weak, nonatomic) IBOutlet UIButton *btnErase;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnSub;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)editImage:(id)sender;
- (IBAction)resetImage:(id)sender;
- (IBAction)shareImage:(id)sender;
- (IBAction)sliderEffectValue:(id)sender;
- (IBAction)eraseMsk:(id)sender;
- (IBAction)makeMsk:(id)sender;
- (IBAction)addPoint:(id)sender;
- (IBAction)subPoint:(id)sender;

@end
