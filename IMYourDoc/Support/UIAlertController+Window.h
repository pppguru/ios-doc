//
//  UIAlertController+Window.h
//  IMYourDoc
//
//  Created by Expert Software Dev on 9/26/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIAlertController (Window)

- (void)show;
- (void)show:(BOOL)animated;

@end