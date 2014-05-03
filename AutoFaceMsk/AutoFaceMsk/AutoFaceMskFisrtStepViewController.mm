//
//  AutoFaceMskFisrtStepViewController.m
//  AutoFaceMsk
//
//  Created by agent on 12-10-17.
//  Copyright (c) 2012年 agent. All rights reserved.
//

#import "AutoFaceMskFisrtStepViewController.h"
#import "GPUImage.h"
#import "SVProgressHUD.h"
#import "CLImageEditor.h"
//#import "opencv2/opencv.hpp"

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@interface UIImage(UIImageScale)
-(UIImage*)scaleToSize:(CGSize)size;
-(UIImage*)getSubImage:(CGRect)rect;
@end

@implementation UIImage(UIImageScale)

//截取部分图像
-(UIImage*)getSubImage:(CGRect)rect
{
    @autoreleasepool{
        CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
        CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
        
        UIGraphicsBeginImageContext(smallBounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, smallBounds, subImageRef);
        UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        CGImageRelease(subImageRef);
        
        return smallImage;
    }
}
-(UIImage *)scaleToSize:(CGSize)targetSize
{
    @autoreleasepool{
        UIImage *sourceImage = self;
        UIImage *newImage = nil;
        
        CGSize imageSize = sourceImage.size;
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        
        CGFloat targetWidth = targetSize.width;
        CGFloat targetHeight = targetSize.height;
        
        CGFloat scaleFactor = 0.0;
        CGFloat scaledWidth = targetWidth;
        CGFloat scaledHeight = targetHeight;
        
        CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
        
        if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
            
            CGFloat widthFactor = targetWidth / width;
            CGFloat heightFactor = targetHeight / height;
            
            if (widthFactor < heightFactor)
                scaleFactor = widthFactor;
            else
                scaleFactor = heightFactor;
            
            scaledWidth  = width * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            // center the image
            
            if (widthFactor < heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            } else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
        
        
        // this is actually the interesting part:
        
        UIGraphicsBeginImageContext(targetSize);
        
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width  = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [sourceImage drawInRect:thumbnailRect];
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if(newImage == nil) NSLog(@"could not scale image");
        
        
        return newImage ;
    }
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end

@interface AutoFaceMskFisrtStepViewController (UtilityMethods)<CLImageEditorDelegate, CLImageEditorTransitionDelegate, CLImageEditorThemeDelegate>
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation AutoFaceMskFisrtStepViewController

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IMAGESWIDTH (iPhone5 ? 320 : 320)
#define IMAGESHEIGHT (iPhone5 ? 400 : 312)

#define imageThreshold 1000

#define imageLow 0.5
#define imageHigh 0.8

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData *imageData = UIImagePNGRepresentation(tempImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
}

- (UIImage *)readPushImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"pushImage"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *pushImage = [UIImage imageWithData:data];
    
    return pushImage;
}

- (UIImage *)readUndoImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"undoImage"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *undoImage = [UIImage imageWithData:data];
    
    return undoImage;
}

- (UIImage *)readUndoMaskImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"undoMaskImage"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *undoMaskImage = [UIImage imageWithData:data];
    
    return undoMaskImage;
}

- (UIImage *)readBackImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"backImage"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *backImage = [UIImage imageWithData:data];
    
    return backImage;
}

- (UIImage *)readMaskImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"maskImage"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *maskImage = [UIImage imageWithData:data];
    
    return maskImage;
}

- (UIImage *)readMaskTempletImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"maskImageTemplet"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *maskImageTemplet = [UIImage imageWithData:data];
    
    return maskImageTemplet;
}

- (UIImage *)readInitImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"initImage"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *initImage = [UIImage imageWithData:data];
    
    return initImage;
}

- (UIImage *)readInitImageTmp
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"initImageTmp"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *initImageTmp = [UIImage imageWithData:data];
    
    return initImageTmp;
}

- (UIImage *)readPixelImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"pixelImage"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *pixelImage = [UIImage imageWithData:data];
    
    return pixelImage;
}

- (UIImage *)readLastImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"lastImage"];
    NSData *data=[NSData dataWithContentsOfFile:fullPathToFile];
    UIImage *maskImageTemp = [UIImage imageWithData:data];
    
    return maskImageTemp;
}

- (void)readPlist
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths    objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"Setting.plist"];
    
    NSMutableArray *array=[[NSMutableArray alloc] initWithContentsOfFile:filename];
    if (([[array objectAtIndex:0] floatValue]  == 2)) {
        pictureQuality = YES;
    } else {
        pictureQuality = NO;
    }
    
    if (([[array objectAtIndex:1] floatValue]  == 2)) {
        faceQuality = YES;
    } else {
        faceQuality = NO;
    }
}


- (void)writePlist{
    NSNumber *pictureQualitySet = [NSNumber numberWithFloat:1];
    NSNumber *faceQualitySet = [NSNumber numberWithFloat:1];
    
    NSMutableArray *array=[[NSMutableArray alloc]init];
    [array  addObject:pictureQualitySet];
    [array  addObject:faceQualitySet];
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths    objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"Setting.plist"];
    
    [array writeToFile:filename  atomically:YES];
}

- (void)fisrtConfig
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths    objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"Setting.plist"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filename]){
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path=[paths    objectAtIndex:0];
        NSString *filename=[path stringByAppendingPathComponent:@"Setting.plist"];
        
        NSMutableArray *array=[[NSMutableArray alloc] initWithContentsOfFile:filename];
        
        if (array.count < 1) {
            [self writePlist];
        }
    } else {
        [self writePlist];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Smart Mosaic", @"Smart Mosaic");
    
    scaleMsk = 1;
    scaleEffect = 0.03;
    faceBound = CGRectMake(0, 0, 0, 0);
    
    isEraseMsk = NO;
    _undoButton.enabled = NO;
    isRotated = NO;
    _btnEdit.hidden = YES;
    
    _btnMsk.frame = CGRectMake(_btnMsk.frame.origin.x + 25, _btnMsk.frame.origin.y, _btnMsk.frame.size.width, _btnMsk.frame.size.height);
    _btnErase.frame = CGRectMake(_btnErase.frame.origin.x + 30, _btnErase.frame.origin.y, _btnErase.frame.size.width, _btnErase.frame.size.height);
    _undoButton.frame = CGRectMake(_undoButton.frame.origin.x - 30, _undoButton.frame.origin.y, _undoButton.frame.size.width, _undoButton.frame.size.height);
    _btnShare.frame = CGRectMake(_btnShare.frame.origin.x - 25, _btnShare.frame.origin.y, _btnShare.frame.size.width, _btnShare.frame.size.height);
    
    [self fisrtConfig];
    [self readPlist];
    
    
    contextMsk = [CIContext contextWithOptions:nil];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Album",@"Album") style:UIBarButtonItemStyleBordered target:self action:@selector(showPicture)];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    if (_imgPickerControll == nil)
    {
        _imgPickerControll = [[UIImagePickerController alloc] init];
        _imgPickerControll.delegate = self;
    }
    
    [SVProgressHUD show];
    [self performSelector:@selector(initImage) withObject:nil afterDelay:0.3];
    
    if (_pointsView != nil) {
        [_pointsView removeFromSuperview];
    }

    self.pointsView = [[JBCroppableView alloc] initWithImageView:CGRectMake(0,  44, IMAGESWIDTH, IMAGESHEIGHT + 16)];
    
    [self.pointsView addPoints:4];
    
    [self.view addSubview:self.pointsView];
    
    [self performSelector:@selector(displayAD) withObject:nil afterDelay:5];
    
    /**_adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
     _adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
     _adView.delegate = self;**/
    
    _imageView.frame = CGRectMake(0, 44, IMAGESWIDTH, IMAGESHEIGHT);
    
    self.scrollView.minimumZoomScale=1.0;
    self.scrollView.maximumZoomScale=6.0;
    self.scrollView.contentSize=_imageView.frame.size;
    self.scrollView.delegate=self;
    
    
	// Do any additional setup after loading the view.
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    interstitial_.delegate = nil;
    [self performSelector:@selector(displayADAgain) withObject:nil afterDelay:40];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    [interstitial_ presentFromRootViewController:self];
}


- (void)displayAD{
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.delegate = self;
    interstitial_.adUnitID = @"a150fb0a119ace5";
    [interstitial_ loadRequest:[GADRequest request]];
}

// When user dismisses the interstitial.
- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial {
    interstitial_.delegate = nil;
    [self performSelector:@selector(displayADAgain) withObject:nil afterDelay:60];
}

- (void)displayADAgain{
    // Prepare next interstitial.
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"a150fb0a119ace5";
    interstitial_.delegate = self;
    [interstitial_ loadRequest:[GADRequest request]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self.navigationController setToolbarHidden:NO animated:NO];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    [self fisrtConfig];
    [self readPlist];
}

- (void)initImage
{
    CGRect rect = CGRectMake(0, 0, _revImage.size.width, _revImage.size.height);
    UIGraphicsBeginImageContext(rect.size);
    [_revImage drawInRect:rect];
    _revImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (_revImage.size.width > _revImage.size.height) {
        _revImage = [_revImage imageRotatedByDegrees:90.0];
        isRotated = YES;
    } else {
        isRotated = NO;
    }
    
    UIImage *scaleImage = [_revImage scaleToSize:[self frameForImage:_revImage inImageViewAspectFit:_imageView].size];
    
    _imageView.image = scaleImage;
    
    [self saveImage:scaleImage WithName:@"pushImage"];
    [self saveImage:scaleImage WithName:@"backImage"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"maskImageTemplet"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile]){
        UIImage *mskImage = nil;
        
        CGRect rect = [self frameForImage:_imageView.image inImageViewAspectFit:_imageView];
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
        [mskImage drawInRect:rect];
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // Draw a dark gray background
        [[UIColor blackColor] setFill];
        CGContextFillRect(context, rect);
        
        mskImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self saveImage:mskImage WithName:@"maskImageTemplet"];
    }
    [self saveImage:[self readMaskTempletImage] WithName:@"maskImage"];
    
    [self performSelectorOnMainThread:@selector(LoadingAutoFaceMskData) withObject:nil waitUntilDone:NO];
    [self performSelectorInBackground:@selector(saveInitImage) withObject:nil];
    
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showPicture {
    _imgPickerControll.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_imgPickerControll animated:YES completion:nil];
}

- (void)dismissPicture {
    //[_imgPickerControll dismissModalViewControllerAnimated:NO];
    [[_imgPickerControll presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UINavigationItem *ipcNavBarTopItem;
    
    // add done button to right side of nav bar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(dismissPicture)];
    
    
    UINavigationBar *bar = navigationController.navigationBar;
    [bar setHidden:NO];
    ipcNavBarTopItem = bar.topItem;
    ipcNavBarTopItem.title = NSLocalizedString(@"Choose Photo",@"Choose Photo");
    ipcNavBarTopItem.rightBarButtonItem = doneButton;
}

- (void)initImageFromSelect
{
    CGRect rect = CGRectMake(0, 0, _revImage.size.width, _revImage.size.height);
    UIGraphicsBeginImageContext(rect.size);
    [_revImage drawInRect:rect];
    _revImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (_revImage.size.width > _revImage.size.height) {
        _revImage = [_revImage imageRotatedByDegrees:90.0];
        isRotated = YES;
    } else {
        isRotated = NO;
    }
    
    UIImage *scaleImage = [_revImage scaleToSize:[self frameForImage:_revImage inImageViewAspectFit:_imageView].size];
    
    _imageView.image = scaleImage;
    
    [self saveImage:scaleImage WithName:@"pushImage"];
    [self saveImage:scaleImage WithName:@"backImage"];
    [self saveImage:[self readMaskTempletImage] WithName:@"maskImage"];
    
    [self performSelectorOnMainThread:@selector(LoadingAutoFaceMskData) withObject:nil waitUntilDone:NO];
    [self performSelectorInBackground:@selector(saveInitImage) withObject:nil];
    
    _undoButton.enabled = NO;
    
    [SVProgressHUD dismiss];
}

- (void)saveInitImage
{
    if (_revImage.size.width > imageThreshold) {
        if (pictureQuality) {
            [self saveImage:[_revImage scaleToSize:CGSizeMake(_revImage.size.width * imageHigh, _revImage.size.height * imageHigh)] WithName:@"initImage"];
        } else {
            [self saveImage:[_revImage scaleToSize:CGSizeMake(_revImage.size.width * imageLow, _revImage.size.height * imageLow)] WithName:@"initImage"];
        }
    } else {
        [self saveImage:_revImage WithName:@"initImage"];
    }
    _revImage = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    _imageView.image = nil;
    isRotated = NO;
    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
    editor.delegate = self;
    
    [picker pushViewController:editor animated:YES];
}


#pragma mark- CLImageEditor delegate

- (void)imageEditor:(CLImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image
{
    _revImage = image;
    
    [editor dismissViewControllerAnimated:YES completion:nil];
    
    [SVProgressHUD show];
    [self performSelector:@selector(initImageFromSelect) withObject:nil afterDelay:0.3];
}

- (void)imageEditor:(CLImageEditor *)editor willDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled
{
    //[self refreshImageView];
}

- (void)refreshImageView
{
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimate:NO];
}

- (void)resetImageViewFrame
{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    _imageView.frame = CGRectMake(0, 0, W, H);
    _imageView.superview.bounds = _imageView.bounds;
}

- (void)resetZoomScaleWithAnimate:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // tell our delegate we are finished with the picker
    //[picker dismissModalViewControllerAnimated:NO];
    [[picker presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    picker = nil;
}

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    /**AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
     [editorController setDelegate:self];
     [self presentViewController:editorController animated:YES completion:nil];**/
}

- (void)editMskImage{
    UIImage *mskImage = [self readMaskImage];
    mskImage = [mskImage scaleToSize:_imageView.image.size];
    
    isEraseMsk = NO;
    
    [self mskImage:[self readPushImage] withMaskImage:mskImage];
    [_imageView setImage:nil];
    _imageView.image = [self readPushImage];
    
    [SVProgressHUD dismiss];
}


- (IBAction)editImage:(id)sender {
    [self displayEditorForImage:[self readInitImage]];
}

-(void)LoadingAutoFaceMskData;
{
    UIImage *pushImage = [self readPushImage];
    [self saveImage:pushImage WithName:@"undoImage"];
    _undoButton.enabled = YES;
    
    if (isRotated == YES) {
        [self autoFaceMskImage:[pushImage imageRotatedByDegrees:-90.0]];
    } else {
        [self autoFaceMskImage:pushImage];
    }
    _imageView.image = [self readPushImage];
}

- (IBAction)resetImage:(id)sender {
    [self saveImage:[self readUndoMaskImage] WithName:@"maskImage"];
    
    isEraseMsk = NO;
    
    [SVProgressHUD show];
    [self performSelector:@selector(loadIngUndoImage) withObject:nil afterDelay:0.3];
    
    _undoButton.enabled = NO;
}


- (UIImage* )rotateImage:(UIImage *)image {
    int kMaxResolution = 320;
    // Or whatever
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width  /  height;
        if (ratio > 1 ) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch (orient) {
        case UIImageOrientationUp:
            //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0 );
            break;
        case UIImageOrientationDown:
            //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width );
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0 );
            break;
        case UIImageOrientationLeft:
            //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate( transform, 3.0 * M_PI / 2.0   );
            break;
        case UIImageOrientationRightMirrored:
            //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate( transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0 );
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform );
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

- (void)autoFaceMskImage:(UIImage *)inputImage
{
    CIImage *image = [CIImage imageWithCGImage:inputImage.CGImage];
    
    CIImage *maskImage = nil;
    
    NSDictionary *detectorOptions = nil;
    
    if (faceQuality) {
        detectorOptions =  [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                       forKey:CIDetectorAccuracy];
    } else {
        detectorOptions =  [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow
                                                       forKey:CIDetectorAccuracy];
    }
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:detectorOptions];
    NSArray *faceArray = [detector featuresInImage:image options:nil];
    
    if (faceArray.count>0) {
        CIFilter *filterBlend = [CIFilter filterWithName:@"CIBlendWithMask"];
        CIImage *imageMask = [CIImage imageWithCGImage:[self applyGPUImageBrightFilter:inputImage withScale:-1.0].CGImage];
        CIImage *pixelImageMask = [CIImage imageWithCGImage:[self applyGPUImageBrightFilter:inputImage withScale:1.0].CGImage];
        
        for (CIFeature *f in faceArray) {
            faceBound = [f bounds];
            
            CIVector *cen = [CIVector vectorWithX:faceBound.origin.x + faceBound.size.width/2. Y:faceBound.origin.y + faceBound.size.height/2.];
            CGFloat radius = MIN(faceBound.size.width, faceBound.size.height)/1.5;
            
            CIFilter *radialGradient = [CIFilter filterWithName:@"CIRadialGradient" keysAndValues:
                                        @"inputRadius0", [NSNumber numberWithFloat:radius],
                                        @"inputRadius1", [NSNumber numberWithFloat:radius + 1.0f],
                                        @"inputColor0", [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0],
                                        @"inputColor1", [CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0],
                                        @"inputCenter", cen,
                                        nil];
            
            CIImage *circleImage = [radialGradient valueForKey:kCIOutputImageKey];
            
            maskImage = circleImage;
            CIImage *pixelImage = nil;
            
            pixelImage = [CIImage imageWithCGImage:[self applyGPUImagePixellateFilter:inputImage].CGImage];
            
            [filterBlend setValue:image forKey:@"inputBackgroundImage"];
            [filterBlend setValue:maskImage forKey:@"inputMaskImage"];
            [filterBlend setValue:pixelImage forKey:@"inputImage"];
            
            image = [filterBlend valueForKey:kCIOutputImageKey];
            
            [filterBlend setValue:imageMask forKey:@"inputBackgroundImage"];
            [filterBlend setValue:maskImage forKey:@"inputMaskImage"];
            [filterBlend setValue:pixelImageMask forKey:@"inputImage"];
            
            imageMask = [filterBlend valueForKey:kCIOutputImageKey];
        }
        
        CGImageRef cgimg =[contextMsk createCGImage:image fromRect:[image extent]];
        
        UIImage *newImg = [UIImage imageWithCGImage:cgimg];
        
        if (isRotated == YES) {
            newImg = [newImg imageRotatedByDegrees:90.0];
        }
        
        [self saveImage:newImg WithName:@"pushImage"];
        
        CGImageRelease(cgimg);
        
        cgimg =[contextMsk createCGImage:imageMask fromRect:[imageMask extent]];
        
        newImg = [UIImage imageWithCGImage:cgimg];
        
        if (isRotated == YES) {
            newImg = [newImg imageRotatedByDegrees:90.0];
        }
        
        CGRect imageFrame = [self frameForImage:_imageView.image inImageViewAspectFit:_imageView];
        newImg = [newImg scaleToSize:CGSizeMake(IMAGESWIDTH, IMAGESHEIGHT)];
        newImg = [newImg getSubImage:imageFrame];
        
        [self saveImage:[self readMaskImage] WithName:@"undoMaskImage"];
        [self saveImage:newImg WithName:@"maskImage"];
        
        CGImageRelease(cgimg);
        
    }
}

- (void)dismissSuccess {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Not Detected Face",@"Not Detected Face")];
}

-(CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIImageView*)imageView
{
    float imageRatio = image.size.width / image.size.height;
    
    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;
    
    if(imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;
        
        float width = scale * image.size.width;
        
        float topLeftX = (imageView.frame.size.width - width) * 0.5;
        
        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;
        
        float height = scale * image.size.height;
        
        float topLeftY = (imageView.frame.size.height - height) * 0.5;
        
        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
    }
}


- (CGPoint)convertCGPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2
{
    point1.y = rect1.height - point1.y;
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}

- (void)makeMskImageAndSave
{
    UIImage *mskImage = nil;
    [self saveImage:[self readMaskImage] WithName:@"undoMaskImage"];
    
    CGRect imageFrame = [self frameForImage:_imageView.image inImageViewAspectFit:_imageView];
    
    mskImage = [self.pointsView maskImageFromFile:CGRectMake(0, 0, imageFrame.size.width, imageFrame.size.height) isEarse:isEraseMsk withImageFrame:imageFrame withScalePoint:_scrollView.bounds.origin];
    
    [self saveImage:mskImage WithName:@"maskImage"];
}

- (void)loadIngMskImage
{
    UIImage *pushImage = [self readBackImage];
    
    _undoButton.enabled = YES;
    
    [self makeMskImageAndSave];
    
    [self mskImage:pushImage withMaskImage:[[self readMaskImage] scaleToSize:pushImage.size]];
    
    self.imageView.image = [self readPushImage];
    
    mskRect = CGRectMake(0, 0, 0, 0);
    
    [SVProgressHUD dismiss];
}

- (void)loadIngUndoImage
{
    UIImage *pushImage = [self readBackImage];
    
    [self mskImage:pushImage withMaskImage:[[self readMaskImage] scaleToSize:pushImage.size]];
    
    self.imageView.image = [self readPushImage];
    
    mskRect = CGRectMake(0, 0, 0, 0);
    
    [SVProgressHUD dismiss];
}

- (void)mskImage:(UIImage *)inputImage withMaskImage:(UIImage *)maskImgae
{
    CIImage *image = [CIImage imageWithCGImage:inputImage.CGImage];
    
    CIImage *pixelImage = nil;
    
    CIImage *maskCIImage = [CIImage imageWithCGImage:maskImgae.CGImage];
    
    pixelImage = [CIImage imageWithCGImage:[self applyGPUImagePixellateFilter:inputImage].CGImage];
    
    CIFilter *filterBlend = [CIFilter filterWithName:@"CIBlendWithMask"];
    [filterBlend setValue:image forKey:@"inputBackgroundImage"];
    [filterBlend setValue:maskCIImage forKey:@"inputMaskImage"];
    [filterBlend setValue:pixelImage forKey:@"inputImage"];
    
    CIImage *mskImage = [filterBlend valueForKey:kCIOutputImageKey];
    
    CGImageRef cgimg =[contextMsk createCGImage:mskImage fromRect:[mskImage extent]];
    
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    [self saveImage:newImg WithName:@"pushImage"];
    
    CGImageRelease(cgimg);
}

-(UIImage *)applyGPUImagePixellateFilter:(UIImage *)image{
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    
    GPUImagePixellateFilter *passthroughFilter = [[GPUImagePixellateFilter alloc] init];
    // Linear downsampling
    [passthroughFilter setFractionalWidthOfAPixel:scaleEffect];
    
    [stillImageSource addTarget:passthroughFilter];
    [stillImageSource processImage];
    UIImage *currentFilteredImage = [passthroughFilter imageFromCurrentlyProcessedOutput];
    
    //show on imageView
    return currentFilteredImage;
}

-(UIImage *)applyGPUImageBrightFilter:(UIImage *)image withScale:(CGFloat)Scale{
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    
    GPUImageBrightnessFilter *passthroughFilter = [[GPUImageBrightnessFilter alloc] init];;
    // Linear downsampling
    [passthroughFilter setBrightness:Scale];
    
    [stillImageSource addTarget:passthroughFilter];
    [stillImageSource processImage];
    UIImage *currentFilteredImage = [passthroughFilter imageFromCurrentlyProcessedOutput];
    
    //show on imageView
    return currentFilteredImage;
}

- (void)mskInitImage:(UIImage *)inputImage withMaskImage:(UIImage *)maskImgae
{
    CIImage *image = [CIImage imageWithCGImage:inputImage.CGImage];
    
    CIImage *pixelImage = nil;
    
    CIImage *maskCIImage = [CIImage imageWithCGImage:maskImgae.CGImage];
    
    pixelImage = [CIImage imageWithCGImage:[self applyGPUImagePixellateFilter:inputImage].CGImage];
    
    CIFilter *filterBlend = [CIFilter filterWithName:@"CIBlendWithMask"];
    [filterBlend setValue:image forKey:@"inputBackgroundImage"];
    [filterBlend setValue:maskCIImage forKey:@"inputMaskImage"];
    [filterBlend setValue:pixelImage forKey:@"inputImage"];
    
    CIImage *mskImage = [filterBlend valueForKey:kCIOutputImageKey];
    
    CGImageRef cgimg =[contextMsk createCGImage:mskImage fromRect:[mskImage extent]];
    
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    [self saveImage:newImg WithName:@"lastImage"];
    
    CGImageRelease(cgimg);
}

- (void)makeLastMaskImage
{
    UIImage *initImage = nil;
    initImage = [self readInitImage];
    
    [self mskInitImage:initImage withMaskImage:[[self readMaskImage] scaleToSize:initImage.size]];
    _undoButton.enabled = NO;
    
    Class avcClass = NSClassFromString(@"UIActivityViewController");
    if (avcClass) {
        NSArray *activityItems = nil;
        UIImage *lastMaskImage = [self readLastImage];
        
        if (lastMaskImage != nil) {
            if (isRotated == YES) {
                activityItems =  [NSArray arrayWithObjects:[lastMaskImage imageRotatedByDegrees:-90.0], nil];
            } else {
                activityItems = [NSArray arrayWithObjects:lastMaskImage, nil];
            }
            
            if (activityItems != nil) {
                UIActivityViewController *activityController =
                [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                  applicationActivities:nil];
                
                if (activityController != nil) {
                    [self presentViewController:activityController animated:YES completion:nil];
                    
                    [activityController setCompletionHandler:^(NSString *act, BOOL done)
                     {
                         NSString *ServiceMsg = @"Completed";
                         
                         if ( done )
                         {
                             [SVProgressHUD showSuccessWithStatus:ServiceMsg];
                         }
                     }];
                }
                [SVProgressHUD dismiss];
            }
        }
    }
}

- (IBAction)shareImage:(id)sender {
    [SVProgressHUD show];
    [self performSelector:@selector(makeLastMaskImage) withObject:nil afterDelay:0.3];
}

- (IBAction)sliderEffectValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    scaleEffect = slider.value / 100;
}

- (IBAction)eraseMsk:(id)sender {
    isEraseMsk = YES;
    
    [SVProgressHUD show];
    [self performSelector:@selector(loadIngMskImage) withObject:nil afterDelay:0.3];
}

- (IBAction)makeMsk:(id)sender {
    if (_imageView.image) {
        isEraseMsk = NO;
        
        [SVProgressHUD show];
        [self performSelector:@selector(loadIngMskImage) withObject:nil afterDelay:0.3];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (IBAction)addPoint:(id)sender {
    [self addPoint];
}

- (IBAction)subPoint:(id)sender {
    [self removePoint];
}

- (void)addPoint{
    NSMutableArray *oldPoints = [_pointsView.getPoints mutableCopy];
    // CGPoint new = CGPointMake((first.x+last.x)/2.0f, (first.y+last.y)/2.0f);
    
    NSInteger indexOfLargestGap;
    CGFloat largestGap = 0;
    for(int i=0; i< oldPoints.count-1; i++){
        CGPoint first = [[oldPoints objectAtIndex:i] CGPointValue];
        CGPoint last = [[oldPoints objectAtIndex:i+1] CGPointValue];
        CGFloat distance = [self distanceBetween:first And:last];
        if(distance>largestGap){
            indexOfLargestGap = i+1;
            largestGap = distance;
        }
    }
    CGPoint veryFirst = [[oldPoints firstObject] CGPointValue];
    CGPoint veryLast = [[oldPoints lastObject] CGPointValue];
    CGPoint newPoint;
    
    if([self distanceBetween:veryFirst And:veryLast]>largestGap){
        indexOfLargestGap = oldPoints.count;
        newPoint = CGPointMake((veryFirst.x+veryLast.x)/2.0f, (veryFirst.y+veryLast.y)/2.0f);
    } else {
        CGPoint first = [[oldPoints objectAtIndex:indexOfLargestGap-1] CGPointValue];
        CGPoint last = [[oldPoints objectAtIndex:indexOfLargestGap] CGPointValue];
        newPoint = CGPointMake((first.x+last.x)/2.0f, (first.y+last.y)/2.0f);
    }
    
    
    [oldPoints insertObject:[NSValue valueWithCGPoint:newPoint] atIndex:indexOfLargestGap];
    [_pointsView removeFromSuperview];
    _pointsView = [[JBCroppableView alloc] initWithImageView:_pointsView.frame];
    [_pointsView addPointsAt:oldPoints];
    [self.view addSubview:_pointsView];
}

- (void)removePoint{
    NSMutableArray *oldPoints = [_pointsView.getPoints mutableCopy];
    if(oldPoints.count==3) return;
    
    NSInteger indexOfSmallestGap;
    CGFloat smallestGap = INFINITY;
    for(int i=0; i< oldPoints.count; i++){
        int firstIndex = i-1;
        int lastIndex = i +1;
        
        if(firstIndex<0){
            firstIndex = (int)oldPoints.count-1+firstIndex;
        } else if(firstIndex>=oldPoints.count){
            firstIndex = firstIndex-(int)oldPoints.count;
        }
        if(lastIndex<0){
            lastIndex = (int)oldPoints.count-1+lastIndex;
        } else if(lastIndex>=oldPoints.count){
            lastIndex = lastIndex-(int)oldPoints.count;
        }
        
        CGPoint first = [[oldPoints objectAtIndex:firstIndex] CGPointValue];
        CGPoint mid = [[oldPoints objectAtIndex:i] CGPointValue];
        CGPoint last = [[oldPoints objectAtIndex:lastIndex] CGPointValue];
        CGFloat distance = [self distanceFrom:first to:last throuh:mid];
        if(distance<smallestGap){
            indexOfSmallestGap = i;
            smallestGap = distance;
        }
    }
    
    [oldPoints removeObjectAtIndex:indexOfSmallestGap];
    [_pointsView removeFromSuperview];
    _pointsView = [[JBCroppableView alloc] initWithImageView:_pointsView.frame];
    [_pointsView addPointsAt:[NSArray arrayWithArray:oldPoints]];
    [self.view addSubview:_pointsView];
}

-(CGFloat)distanceBetween:(CGPoint)first And:(CGPoint)last{
    CGFloat xDist = (last.x - first.x);
    if(xDist<0) xDist=xDist*-1;
    CGFloat yDist = (last.y - first.y);
    if(yDist<0) yDist=yDist*-1;
    return sqrt((xDist * xDist) + (yDist * yDist));
}
-(CGFloat)distanceFrom:(CGPoint)first to:(CGPoint)last throuh:(CGPoint)middle{
    CGFloat firstToMid = [self distanceBetween:first And:middle];
    CGFloat lastToMid = [self distanceBetween:middle And:last];
    return   firstToMid + lastToMid;
}


@end
