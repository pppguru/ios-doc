//
//  PhysicianProfileViewController.h
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
#import "FontHeaderLabel.h"
#import "IMYourDocButton.h"


#import "HospitalListCell.h"
#import "SimpleFontButton.h"
#import "ImageViewAsincLoader.h"


@interface PhysicianProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate,WebHelperDelegate>
{
    BOOL profileFetched;
    
    NSDictionary *searchDict;
    
    IBOutlet UILabel *pracL, *primaryL, *secondaryL;
    
    IBOutlet FontBoldLabel *nameLbl;
    
    IBOutlet UITableView *hospListTB;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet UIView *profileContainer;
        
    IBOutlet IMYourDocButton *physicianBtn;
    
    IBOutlet ImageViewAsincLoader *profileImg;
    
    IBOutlet SimpleFontButton *mailBtn, *phoneBtn, *removeUserBtn;
    
    IBOutlet FontLabel *userNameLbl, *secureL, *practiceLbl, *hospitalLbl, *picNumLbl;
    
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

- (IBAction)physicianTap;

- (IBAction)removeUserTap;


@end

