//
//  ServiceAgreementOneViewController.h
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


@interface ServiceAgreementOneViewController : UIViewController <ASIHTTPRequestDelegate, WebHelperDelegate,UIAlertViewDelegate>
{
    IBOutlet UIWebView *serviceWebV;

    IBOutlet FontHeaderLabel *navBarLbl;
    
    IBOutlet UIButton *agreeBtn, *disagreeBtn;
    
	IBOutlet UIImageView *agreeImgV, *disagreeImgV;
	
    IBOutlet FontLabel *oathLbl, *agreeLbl, *disagreeLbl;
}


@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) RegistrationType registrationType;


- (IBAction)navBack;

- (IBAction)userAgree;

- (IBAction)userDisagree;

- (IBAction)submitAgreement;


@end

