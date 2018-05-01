//
//  ChangeSecurityQuestionViewController.h
//  IMYourDoc
//
//  Created by OSX on 07/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"
#import "FontHeaderLabel.h"



@interface ChangeSecurityQuestionViewController : UIViewController<UITextFieldDelegate,WebHelperDelegate>
{
    
   
    IBOutlet IMYourDocButton *btn_save;
    IBOutlet FontTextField *txt_secAnswer;
    IBOutlet FontTextField *txt_SecQuestion;
    IBOutlet FontLabel *lbl_secAns;
    IBOutlet FontLabel *lbl_secQue;
    
    IBOutlet UILabel *lbl_title;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UIView *ViewCon_Ques;
    
    IBOutlet UIView *viewCon_Ans;
}

- (IBAction)action_save:(id)sender;


@end
