//
//  PhysSignupStepFourViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 31/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"
#import "AutocompletionTableView.h"


@interface PhysSignupStepFourViewController : UIViewController <UITextFieldDelegate, AutocompletionTableViewDelegate>
{
    BOOL fetchingHospital;
    
    IBOutlet FontLabel *step1L;

    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet FontTextField *practiceTF, *jobTitleTF, *desigTF;
    
    IBOutlet UIView *practiceV, *pinV, *primaryHospV, *secondaryHospV, *TFContainer, *StepContainer, *jobTitleV, *desigV;
}


@property (nonatomic, assign) RegistrationType registrationType;

@property (nonatomic, strong) AutocompletionTableView *autoCompTV, *autoJobCompTV, *autoDesigCompTV;

@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, strong) NSMutableArray *secondryHosp, *practiceType, *jobTitle, *designation, *hospital;


- (IBAction)navBack;

- (IBAction)navForward;

- (IBAction)selectPrimaryHospital;

- (IBAction)selectSecondaryHospital;


@end

