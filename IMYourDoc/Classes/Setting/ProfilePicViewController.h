//
//  ProfilePicViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 23/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "IMYourDocButton.h"


@interface ProfilePicViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UILabel *titleL;
    
    IBOutlet FontLabel *secureL;
        
	IBOutlet UIImageView *profileImgV, *secureIcon;
	
	IBOutlet IMYourDocButton *cameraBtn, *takePhotoBtn, *selectPhotoBtn;
}


@property (nonatomic, assign) BOOL isFileTransfer;

@property (nonatomic, strong) NSArray *jidArr;

@property (nonatomic, strong) NSString *toUserName;


- (IBAction)navBack;

- (IBAction)submitTap;

- (IBAction)takePhotoMethod;

- (IBAction)selectPhotoMethod;


@end

