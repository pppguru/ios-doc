//
//  AccountConfigServiceAgreementOneViewController.h
//  IMYourDoc
//
//  Created by Manpreet on 26/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontHeaderLabel.h"
#import "SimpleFontButton.h"


@interface AccountConfigServiceAgreementViewOneController : UIViewController <WebHelperDelegate>
{
    IBOutlet UILabel *navBarLbl;
    
    IBOutlet UIWebView *agreementWebV, *agreement2WebV;
    
    IBOutlet FontHeaderLabel *oathLbl;
    
    IBOutlet SimpleFontButton *agreeBtn, *disagreeBtn;
}


@property (strong, nonatomic) NSDictionary *dataDict;

@property (nonatomic) BOOL isSecondAgreement;


- (IBAction)submitTap;


- (IBAction)agreeTap:(UIButton *)sender;


@end

