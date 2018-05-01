//
//  ChangeEmailViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 28/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "FontTextField.h"


@interface ChangeEmailViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate,WebHelperDelegate>
{
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UIView *emailV, *confirmEmailV;
    
    IBOutlet FontTextField *emailTF, *confirmemailTF;
}


- (IBAction)navBack;


@end

