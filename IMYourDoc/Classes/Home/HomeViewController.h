//
//  HomeViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 17/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "ImageViewAsincLoader.h"
#import "BroadCastViewController.h"

@interface HomeViewController : UIViewController
{
    UIActivityViewController *activityVC;
    
    IBOutlet ImageViewAsincLoader *secureImg, *userProfilePic;
    
    IBOutlet UIView *messageCountView, *accntCountView, *profilePicContainer, *bigV, *profileContainer;
    
    IBOutlet UILabel *msgLbl, *secureLbl, *welcomeLbl, *feedbackLbl, *msgCountLbl, *userListLbl, *userNameLbl, *accntSettingLbl, *accntCountLbl, *externalContactsLbl;
    
    IBOutlet UIImageView *shareIcon;
}


- (void) updateMessagCount;

- (void)checkInternetConnection:(BOOL)isConnected;


- (IBAction)userList;

- (IBAction)shareTap;

- (IBAction)showMessages;

- (IBAction)userFeedback;

- (IBAction)accountSetting;

- (IBAction)showOfflineMessages;


@end

