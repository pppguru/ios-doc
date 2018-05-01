//
//  SearchPhysicianViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 28/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"
#import "AutocompletionTableView.h"


@interface SearchPhysicianViewController : UIViewController <UITextFieldDelegate, AutocompletionTableViewDelegate,WebHelperDelegate>
{
    BOOL fetchingHospital;
    
    NSDictionary *searchDict;
    
    IBOutlet UILabel *anyOneL, *titleL;
    
    IBOutlet FontLabel *secureL;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet UIScrollView *TFScrollView;
    
    IBOutlet FontTextField *phyNameTF, *hospitalTF, *pracTypeTF, *providerIdTF , *txt_userName;
    
    IBOutlet UIView *hospitalV, *physNameV, *pracTypeV, *providerV, *TxtFieldContainer;
}


@property (strong, nonatomic) NSMutableArray *practiceType;

@property (strong, nonatomic) NSMutableDictionary *hospital;

@property (nonatomic, strong) AutocompletionTableView *autoCompTV;


- (IBAction)navBack;

- (IBAction)hospitalTap;

- (IBAction)searchPhysician;


@end

