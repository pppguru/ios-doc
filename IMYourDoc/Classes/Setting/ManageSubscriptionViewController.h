//
//  ManageSubscriptionViewController.h
//  IMYourDoc
//
//  Created by Harminder on 24/06/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ManageSubscriptionViewController : UIViewController<WebHelperDelegate>{
        UIAlertView *subAlert;
}
- (IBAction)action_CancelSubscription:(id)sender;
- (IBAction)action_UpdateCreditCard:(id)sender;

@end
