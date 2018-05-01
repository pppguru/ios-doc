//
//  NSString+Validations.h
//  IMYourDoc
//
//  Created by Harminder on 03/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef void (^stringLenthcompletionBlock) (BOOL isLess, NSString * string);

@interface NSString (Validations)


- (NSInteger)exactLength;


- (BOOL)isEmail;

- (BOOL)isCorrectUserName;

- (BOOL)isCorrectPassword;

-(void)checkStringLength:(stringLenthcompletionBlock)competionBlock;
@end

