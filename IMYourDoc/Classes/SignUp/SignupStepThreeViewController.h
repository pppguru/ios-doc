//
//  SignupStepThreeViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 21/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"
#import "AutocompletionTableView.h"


@interface SignupStepThreeViewController : UIViewController <UITextFieldDelegate, AutocompletionTableViewDelegate, WebHelperDelegate>
{
    BOOL fetchingHospital;
    
    IBOutlet FontLabel *step1L;
    
    IBOutlet UIScrollView *TFScroll;

    IBOutlet UIButton *selectHospBtn;
    
    IBOutlet NSLayoutConstraint *verticalHtConst;
    
	IBOutlet FontTextField *phoneTF, *pincodeTF, *zipcodeTF, *hospitalNameTF, *practiceTF, *desigTF, *jobTitleTF, *secondaryHospTF;
    
    IBOutlet UIView *hospitalNameV, *TFContainer, *StepsContainer, *practiceV, *secHospitalV, *jobV, *designationV;
}


@property (nonatomic, strong) NSDictionary *hospital;

@property (nonatomic, strong) NSMutableArray *practiceType, *jobTitle, *designation, *secondryHosp;

@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) RegistrationType registrationType;

@property (nonatomic, strong) AutocompletionTableView *autoCompTV, *autoJobCompTV, *autoDesigCompTV;


- (IBAction)navBack;

- (IBAction)navForward;


@end

