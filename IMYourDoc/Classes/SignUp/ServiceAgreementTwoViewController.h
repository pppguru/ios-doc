//
//  ServiceAgreementTwoViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 19/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextView.h"
#import "FontHeaderLabel.h"
#import "SimpleFontButton.h"


@interface ServiceAgreementTwoViewController : UIViewController<WebHelperDelegate>
{
    IBOutlet UILabel *navBarLbl;
	
    IBOutlet FontHeaderLabel *oathLbl;
    
    IBOutlet SimpleFontButton *agreeBtn, *disagreeBtn;
	
	IBOutlet FontLabel *agreeLbl, *disagreeLbl;
	
	IBOutlet UIImageView *agreeImgV, *disagreeImgV;
    
    IBOutlet UIWebView *agreement1WebV, *agreement2WebV;
}


@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) RegistrationType registrationType;


- (IBAction)navBack;

- (IBAction)userAgree;

- (IBAction)userDisagree;

- (IBAction)userSubmitAgreement;


@end

