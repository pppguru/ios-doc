//
//  UIPlaceHolderTextView.h
//  Woodi
//
//  Created by harry on 25/11/13.
//  Copyright (c) 2013 Nipun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end