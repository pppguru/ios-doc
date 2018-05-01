//
//  UserAffiliationViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 02/03/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"
#import "AppDelegate.h"
#import "FontTextField.h"


@class UserAffiliationViewController;


@protocol UserAffiliationViewControllerDelegate <NSObject>


@optional


- (void)AffliationController:(UserAffiliationViewController *)controller addedHosptial:(NSDictionary *)addedHosp;


@end


@interface UserAffiliationViewController : UIViewController <UITextFieldDelegate, WebHelperDelegate>
{
    IBOutlet UILabel *titleL;
    
    IBOutlet FontLabel *secureL;
    
    IBOutlet UIScrollView *TFScroll;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet FontTextField *hospitalTF, *cityTF, *phoneTF;
    
    IBOutlet UIView *hospitalV, *cityV, *phoneV, *TxtFieldContainer;
}


@property (nonatomic, strong) id <UserAffiliationViewControllerDelegate> delegate;


- (IBAction)addTap;
- (IBAction)action_back:(id)sender;

@end

