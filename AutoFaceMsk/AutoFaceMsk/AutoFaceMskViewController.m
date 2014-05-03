//
//  AutoFaceMskViewController.m
//  AutoFaceMsk
//
//  Created by agent on 12-10-16.
//  Copyright (c) 2012年 agent. All rights reserved.
//

#import "AutoFaceMskViewController.h"
#import "AutoFaceMskFisrtStepViewController.h"

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@interface AutoFaceMskViewController ()
- (void)showPicture;

@end

@implementation AutoFaceMskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_imgPickerControll == nil)
    {
        _imgPickerControll = [[UIImagePickerController alloc] init];
        _imgPickerControll.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (IBAction)pushFirstStepView:(id)sender {
    [self showPicture];
}

- (void)showPicture {
    [self presentViewController:_imgPickerControll animated:YES completion:nil];
    _imgPickerControll.navigationItem.rightBarButtonItem = nil;
}

- (void)dismissPicture {
    //[_imgPickerControll dismissModalViewControllerAnimated:NO];
    [[_imgPickerControll presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UINavigationItem *ipcNavBarTopItem;
    
    // add done button to right side of nav bar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home",@"Home")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(dismissPicture)];
    
    UINavigationBar *bar = navigationController.navigationBar;
    [bar setHidden:NO];
    ipcNavBarTopItem = bar.topItem;
    ipcNavBarTopItem.title = NSLocalizedString(@"Choose Photo",@"Choose Photo");
    ipcNavBarTopItem.LeftBarButtonItem = doneButton;
    
    UIView *custom = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:custom];
    [viewController.navigationItem setRightBarButtonItem:btn animated:YES];
}

- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData* imageData = UIImagePNGRepresentation(tempImage);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
    
    _pushImage = image;
    
    [self performSegueWithIdentifier:@"push to PhotoPreview" sender:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // tell our delegate we are finished with the picker
    //[picker dismissModalViewControllerAnimated:NO];
    [[picker presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    picker = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AutoFaceMskFisrtStepViewController class]]) {
        AutoFaceMskFisrtStepViewController *nextViewController = segue.destinationViewController;
        nextViewController.revImage = _pushImage;
        _pushImage = nil;
        [self setImgPickerControll:nil];
    }
}

- (void)viewDidUnload {
    [self setImgPickerControll:nil];
    [super viewDidUnload];
}


@end
