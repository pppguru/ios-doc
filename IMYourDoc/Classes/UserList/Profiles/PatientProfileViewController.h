//
//  PatientProfileViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 04/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontBoldLabel.h"
#import "IMYourDocButton.h"
#import "FontHeaderLabel.h"
#import "SimpleFontButton.h"


@interface PatientProfileViewController : UIViewController <MFMailComposeViewControllerDelegate,WebHelperDelegate>
{
    IBOutlet FontBoldLabel *nameLbl;
    
    IBOutlet FontHeaderLabel *picNumLbl;
    
    IBOutlet IMYourDocButton  *patientBtn;
    
    IBOutlet FontLabel *userNameLbl, *secureL;
    
    IBOutlet UIImageView  *secureIcon;
    
    IBOutlet ImageViewAsincLoader *profileImg;
    
    IBOutlet SimpleFontButton *mailBtn, *phoneBtn, *removeUserBtn;
}


@property (nonatomic) BOOL fromSearch;

@property (nonatomic, strong) NSString *toUserName;

@property (nonatomic, strong) NSMutableDictionary *profileDict;


- (void)fetchProfile;

- (void)populateData;


- (IBAction)mailTap;

- (IBAction)backTap;

- (IBAction)phoneTap;

- (IBAction)addPatientTap;

- (IBAction)removeUserTap;


@end

