//
//  AutoFaceMskPictureQualityViewController.m
//  AutoFaceMsk
//
//  Created by link on 13-7-17.
//  Copyright (c) 2013年 agent. All rights reserved.
//

#import "AutoFaceMskPictureQualityViewController.h"

@interface AutoFaceMskPictureQualityViewController ()
{
    NSIndexPath *low;
    NSIndexPath *high;
}

@end

@implementation AutoFaceMskPictureQualityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)readPlist
{
    @autoreleasepool{
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path=[paths    objectAtIndex:0];
        NSString *filename=[path stringByAppendingPathComponent:@"Setting.plist"];
        
        NSMutableArray *array=[[NSMutableArray alloc] initWithContentsOfFile:filename];
        if (([[array objectAtIndex:0] floatValue] == 2)) {
            pictureQuality = YES;
        } else {
            pictureQuality = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    [self readPlist];
}

- (void)writePlist:(NSNumber *)pictureQualitySet{
    @autoreleasepool{
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path=[paths    objectAtIndex:0];
        NSString *filename=[path stringByAppendingPathComponent:@"Setting.plist"];
        
        NSMutableArray *array=[[NSMutableArray alloc]init];
        [array  addObject:pictureQualitySet];
        
        NSMutableArray *arrayRead=[[NSMutableArray alloc] initWithContentsOfFile:filename];
        [array  addObject:[NSNumber numberWithFloat:[[arrayRead objectAtIndex:1] floatValue]]];

        [array writeToFile:filename  atomically:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Picture quality", @"Picture quality");
    
    __block typeof (self) bself = self;
    
    [self readPlist];
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
			staticContentCell.reuseIdentifier = @"DetailTextCell";
            
            cell.textLabel.text = NSLocalizedString(@"Low quality", @"Low quality");
            if (!bself->pictureQuality) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            bself->low = indexPath;
        } whenSelected:^(NSIndexPath *indexPath) {
            [bself writePlist:[NSNumber numberWithFloat:1]];
            
            UITableViewCell *cell = [bself.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *cellHigh = [bself.tableView cellForRowAtIndexPath:bself->high];
            cellHigh.accessoryType = UITableViewCellAccessoryNone;
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
			staticContentCell.reuseIdentifier = @"DetailTextCell";
            
            cell.textLabel.text = NSLocalizedString(@"High quality", @"High quality");
            if (bself->pictureQuality) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            bself->high = indexPath;
        } whenSelected:^(NSIndexPath *indexPath) {
            [bself writePlist:[NSNumber numberWithFloat:2]];
            
            UITableViewCell *cell = [bself.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *cellLow = [bself.tableView cellForRowAtIndexPath:bself->low];
            cellLow.accessoryType = UITableViewCellAccessoryNone;
        }];
    }];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
