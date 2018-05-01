//
//  RDCallbackAlertView.m
//  UIAlertTest101
//
//  Created by Nipun on 02/07/14.
//  Copyright (c) 2014 Nipun. All rights reserved.
//


#import "RDCallbackAlertView.h"


@implementation RDCallbackAlertView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
    }
    
    return self;
}


- (void)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle andCompletionHandler: (void (^) (int)) completionHandler otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self.alertCallBack = completionHandler;
    
    
    id test = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
    
    
    va_list args;
    
    
    va_start(args, otherButtonTitles);
    
    
    for (NSString *btnTitle = otherButtonTitles; btnTitle != nil; btnTitle = va_arg(args, NSString *))
    {
        [test addButtonWithTitle:btnTitle];
    }
    
    
    va_end(args);
    
    
    [self show];
}


- (RDCallbackAlertView *)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
    
    
    va_list args;
    
    
    va_start(args, otherButtonTitles);
    
    
    for (NSString *btnTitle = otherButtonTitles; btnTitle != nil; btnTitle = va_arg(args, NSString *))
    {
        [self addButtonWithTitle:btnTitle];
    }
    
    
    va_end(args);
    
    
    return self;
}


- (void)initWithHeading:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle andCompletionHandler: (void (^) (int)) completionHandler otherButtonTitles:(NSArray *)otherButtonTitles
{
    self.alertCallBack = completionHandler;
    
    
    id test = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
    
    
    for (NSString *title in otherButtonTitles)
    {
        [(UIAlertView *)test addButtonWithTitle:title];
    }
    
    
    [self show];
}


- (void) showWithCompletionHandler: (void (^) (int)) completionHandler
{
    self.alertCallBack = completionHandler;
    
    
    [self show];
}


#pragma mark - UIAlertDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertCallBack)
    {
        self.alertCallBack((int)buttonIndex);
    }
}


@end

