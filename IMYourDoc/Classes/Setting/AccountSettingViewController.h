//
//  AccountSettingViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 23/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate+ClassMethods.h"
#import "ManageSubscriptionViewController.h"
#import <MessageUI/MessageUI.h>

@interface AccountSettingViewController : UIViewController<WebHelperDelegate,MFMailComposeViewControllerDelegate>
{
    UISlider *notiSlider;
    
    UIAlertView *subAlert;
    
    IBOutlet UIScrollView *scrlV;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet FontLabel *secureL, *pendingCountL;
    
    IBOutlet UILabel *titleL, *requestHL, *pSettingHL, *sSettingHL, *oSettingHL, *profileL, *personalL, *emailL, *dMangL, *nMethodL, *securityL, *lastUpL, *notifySettingL, *manageHL, *manageSubL, *updateCreditL;
    
    IBOutlet NSLayoutConstraint *personalSettingTop;
}


@property (nonatomic, assign) BOOL isFwdNav;



- (IBAction)navBack;

- (IBAction)logoutTap;


- (IBAction)accountSettingsTap:(UIButton *)sender;


@end

