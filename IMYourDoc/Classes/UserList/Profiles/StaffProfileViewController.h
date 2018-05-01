//
//  StaffProfileViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 05/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontBoldLabel.h"
#import "IMYourDocButton.h"
#import "SimpleFontButton.h"
#import "ChatViewController.h"
#import "ImageViewAsincLoader.h"


@interface StaffProfileViewController : UIViewController <MFMailComposeViewControllerDelegate, WebHelperDelegate>
{
    BOOL profileFetched;
    
    NSDictionary *searchDict;
    
    IBOutlet UILabel *pracL, *primaryL, *secondaryL;
    
    IBOutlet FontBoldLabel *nameLbl;
    
    IBOutlet UITableView *hospListTB;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet IMYourDocButton *staffBtn;
    
    IBOutlet UIView *hospitalSubV, *profV;
    
    IBOutlet ImageViewAsincLoader *profileImg;
    
    IBOutlet SimpleFontButton *mailBtn, *phoneBtn, *removeUserBtn;
    
    IBOutlet FontLabel *userNameLbl, *secureL, *picNumLbl, *practiceLbl, *hospitalLbl;
    
    IBOutlet NSLayoutConstraint *verticalSpaceConstrain, *hospBottomConst, *hospTopConst;
}


@property (nonatomic) BOOL fromSearch;

@property (nonatomic, strong) NSString *toUserName;

@property (nonatomic, strong) NSMutableDictionary *profileDict;


- (void)fetchProfile;

- (void)populateData;


- (void)viewByMethod:(BOOL)viewByPatient;


- (IBAction)mailTap;

- (IBAction)backTap;

- (IBAction)phoneTap;

- (IBAction)staffTap;

- (IBAction)removeUserTap;


@end

