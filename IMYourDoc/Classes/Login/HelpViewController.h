//
//  HelpViewController.h
//  IMYourDoc
//
//  Created by Sarvjeet on 17/01/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface HelpViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    IBOutlet UILabel *mailAddressLbl, *phoneNumberLbl;
}


- (IBAction)navBack;

- (IBAction)mailTap;

- (IBAction)phoneTap;


@end

