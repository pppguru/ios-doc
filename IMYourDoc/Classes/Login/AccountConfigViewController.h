//
//  TempPasswordViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 13/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "FontTextField.h"
#import "IMYourDocButton.h"


@interface AccountConfigViewController : UIViewController <UITextFieldDelegate>
{
    CGRect keyBRect;
    
    IBOutlet UILabel *titleLbl;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet FontTextField *pwdTF, *confirmPwdTF, *securityAnsTF, *pinTF, *confirmPinTF, *securityQuesTF;
}

@property (strong, nonatomic) NSDictionary *dataDict;

- (IBAction)submitTap;


@end

