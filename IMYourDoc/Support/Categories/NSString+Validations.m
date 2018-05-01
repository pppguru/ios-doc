//
//  NSString+Validations.m
//  IMYourDoc
//
//  Created by Harminder on 03/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//


#import "NSString+Validations.h"


@implementation NSString (Validations)


- (NSInteger)exactLength;
{
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
}

-(void)checkStringLength:(stringLenthcompletionBlock)competionBlock
{
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]>2000)
    {
        competionBlock(false,[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
        
    }
    else{
          competionBlock(true,[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    }
    
}


- (BOOL)isEmail
{
    NSString *strEmailMatchstring = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    
    
    NSPredicate *emailpredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strEmailMatchstring];
    
    
    return [emailpredicate evaluateWithObject:self];
}


- (BOOL)isCorrectUserName
{
    if ([self rangeOfString:@" "].location != NSNotFound)
    {
        return NO;
    }
    
    
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    
    return ([self rangeOfCharacterFromSet:set].location == NSNotFound);
}


- (BOOL)isCorrectPassword
{
    NSString *strPass = @"^\(?=.*\\d)\(?=.*[a-z])\(?=.*[A-Z]).{6,}$";
    
    
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strPass];
    
    
    return [passTest evaluateWithObject:self];
}


@end

