//
//  RDCallbackAlertView.h
//  UIAlertTest101
//
//  Created by Nipun on 02/07/14.
//  Copyright (c) 2014 Nipun. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface RDCallbackAlertView : UIAlertView <UIAlertViewDelegate>
{
    
}


@property (nonatomic, strong) void (^alertCallBack)(int a);


- (void) showWithCompletionHandler: (void (^) (int)) completionHandler;


- (void)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle andCompletionHandler: (void (^) (int)) completionHandler otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;


- (RDCallbackAlertView *)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;


- (void)initWithHeading:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle andCompletionHandler: (void (^) (int)) completionHandler otherButtonTitles:(NSArray *)otherButtonTitles;


@end

