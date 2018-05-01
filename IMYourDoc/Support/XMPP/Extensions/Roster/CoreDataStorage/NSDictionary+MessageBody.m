//
//  NSDictionary+MessageBody.m
//  IMYourDoc
//
//  Created by OSX on 26/11/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "NSDictionary+MessageBody.h"

@implementation NSDictionary (MessageBody)
@dynamic  timestamp,to,from,messageID,content,file_path,file_type;


-(NSString*)to
{
    return [self objectForKey:@"to"];
    
}
-(void)setTo:(NSString *)to{
    
}
-(NSString*)from
{
    return [self objectForKey:@"from"];
    
}

-(NSString*)messageID
{
    return [self objectForKey:@"messageID"];
    
}
-(NSString*)file_path
{
    return [self objectForKey:@"file_path"];
    
}

-(NSString*)file_type
{
    return [self objectForKey:@"file_type"];
    
}

-(NSString*)timestamp
{
    return [self objectForKey:@"timestamp"];
    
}
-(NSString*)content
{
    return [self objectForKey:@"content"];
    
}



@end
