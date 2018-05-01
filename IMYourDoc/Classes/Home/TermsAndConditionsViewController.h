//
//  TermsAndConditionsViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 14/05/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FontLabel.h"

@interface TermsAndConditionsViewController : UIViewController

{
    IBOutlet UILabel *titleLbl;

    IBOutlet FontLabel *secureL;
    
    IBOutlet UIImageView *secureIcon;
    
    IBOutlet UIWebView *conditionsWebV;
}





@end
