//
//  ImYouDocViewController.h
//  IMYourDoc
//
//  Created by OSX on 15/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate+ClassMethods.h"


#import "FontLabel.h"
#import "FontTextView.h"
#import "FontTextField.h"
#import "FontBoldLabel.h"
#import "FontHeaderLabel.h"
#import "SimpleFontButton.h"

@interface ImYouDocViewController : UIViewController<SecureDelegate>
{
    // SecurityBarContainner
    IBOutlet FontLabel *secure_lbl;
    IBOutlet UIImageView *secure_image;
}
@end
