//
//  AutoFaceMskViewController.h
//  AutoFaceMsk
//
//  Created by agent on 12-10-16.
//  Copyright (c) 2012年 agent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoFaceMskViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{

}
@property (strong,nonatomic) UIImagePickerController *imgPickerControll;
@property (weak,nonatomic) UIImage *pushImage;
- (IBAction)pushFirstStepView:(id)sender;
@end
