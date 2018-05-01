
//
//  FeedbackViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 23/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextView.h"
#import "RDCallbackAlertView.h"
#import "TermsAndConditionsViewController.h"


@interface FeedbackViewController : UIViewController <UITextViewDelegate,WebHelperDelegate>
{
    BOOL feedbackTVAllSet;

    CGFloat feedbackTVHeight;
    
    IBOutlet UIScrollView *TVScroll;
	
	IBOutlet UIButton *editingDoneBtn;
	
    IBOutlet UIView *feedBackContainer;
    
    IBOutlet FontLabel *secureL, *pleaseL;
    
    IBOutlet FontTextView *feedbackTxtView;

    IBOutlet UIButton *webLinkBtn, *phnBtn, *termsBtn;
    
    IBOutlet UIImageView *editingDoneImgIcon, *secureIcon;
    
    IBOutlet UILabel *titleLbl, *detail1, *detail2, *detail3, *detail4, *detail5;

    IBOutlet NSLayoutConstraint *feedbackTVHeightConstraint, *feedbackTVHeightConstraintIpad;
}


- (IBAction)navBack;

- (IBAction)websiteTap;

- (IBAction)contactTap;

- (IBAction)editingDone;

- (IBAction)submitFeedback;

- (IBAction)termsAndConditionsTap;


@end







