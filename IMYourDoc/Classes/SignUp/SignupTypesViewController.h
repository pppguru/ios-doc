//
//  SignupTypesViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 20/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontTextView.h"
#import "SimpleFontButton.h"
#import "LoginViewController.h"


@interface SignupTypesViewController : UIViewController
{
	BOOL patientInfoSelected, providerInfoSelected, staffInfoSelected;
	
	
	IBOutlet UILabel *staffLbl, *patientLbl, *providerLbl;
	
	IBOutlet FontTextView *staffTxtView, *patientTxtView, *providerTxtView;
	
	IBOutlet UIImageView *staffInfoImgV, *patientInfoImgV, *providerInfoImgV;
	
	IBOutlet UIView *staffContainer, *patientContainer, *providerContainer, *regisChoicesContainer;
	
    IBOutlet UIButton *staffInfoBtn,  *patientInfoBtn, *providerInfoBtn;
    
    IBOutlet SimpleFontButton *staffRegisBtn, *patientRegisBtn, *providerRegisBtn;
	
	IBOutlet NSLayoutConstraint *staffTFHeightConstraint, *patientTFHeightConstraint, *providerTFHeightConstraint, *staffContainerHeightConstraint, *patientContainerHeightConstraint, *providerContainerHeightConstraint, *patLeadSpaceConst, *patTrailSpaceConst, *staffLeadSpaceConst, *staffTrailSpaceConst, *provLeadSpaceConst, *provTrailSpaceConst;
}


@property (nonatomic) CGFloat regisContainerHeight;



- (void)staffAnimationMethod;

- (void)patientAnimationMethod;

- (void)providerAnimationMethod;


- (IBAction)navBack;

- (IBAction)staffInfo;

- (IBAction)patientInfo;

- (IBAction)staffSignup;

- (IBAction)providerInfo;

- (IBAction)patientSignup;

- (IBAction)providerSignup;


@end

