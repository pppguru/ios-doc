//
//  NSMutableArray+OlderMessages.m
//  IMYourDoc
//
//  Created by OSX on 24/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "NSMutableArray+OlderMessages.h"

@implementation NSMutableArray (OlderMessages)


+(NSMutableArray* )getChatFrom:(XMPPIQ *)iq
{
    
    
    NSArray *arr_fromElements = [[iq elementForName:@"chat"] elementsForName: @"from"];

    NSMutableArray * temp_FromJason=[NSMutableArray new];
    for( NSXMLElement * obj_from in arr_fromElements )
    {
        NSXMLElement * obj_body= [obj_from  elementForName: @"body"];
        
        NSData *data = [[obj_body stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSDictionary class]])
        {
            
            if ([[json valueForKey:@"content"] isEqualToString:@"~$^^xxx*xxx~$^^"])
            {
                
            }
            else{
                [temp_FromJason addObject:json];
                
                
            }
            
        }
        
        
        
        
    }
    return temp_FromJason;
    
}

+(NSString*)getChatWith:(XMPPIQ *)iq
{
    NSMutableArray *arr_from=[ NSMutableArray getChatFrom:iq];
    NSMutableArray *arr_to=[ NSMutableArray getChatTo:iq];
    
    
    
        if (arr_to.count>0&&arr_from.count>0)
        {
          
            
        }
       if (arr_to.count>0)
       {
        
        
      }
    
    else if (arr_from.count>0)
    {
        
    }
    
    
    return nil;
}
+(NSMutableArray* )getChatTo:(XMPPIQ *)iq
{
    
    

    NSArray *arr_toElements =      [[iq elementForName:@"chat"] elementsForName: @"to"];
    NSMutableArray * temp_ToJson=[NSMutableArray new];
    for( NSXMLElement * obj_from in arr_toElements )
    {
        NSXMLElement * obj_body= [obj_from  elementForName: @"body"];
        
        NSData *data = [[obj_body stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSDictionary class]])
        {
            
            if ([[json valueForKey:@"content"] isEqualToString:@"~$^^xxx*xxx~$^^"])
            {
                
            }
            else{
                [temp_ToJson addObject:json];
                
                
            }
            
        }
        
        
        
        
    }
    return temp_ToJson;
    
}
+(NSArray*)broadcastMembersList:(NSArray*)members
{
    NSMutableArray *arr_jidStatus=[[NSMutableArray alloc]init];
    
    for (NSString *  jid in members)
    {
        NSMutableDictionary * dict_jidStatus =[[NSMutableDictionary alloc]init];
       
        [dict_jidStatus setValue:@"Active" forKey:@"status"];
     [dict_jidStatus setValue:jid forKey:@"jid"];
        [arr_jidStatus addObject:dict_jidStatus ];
        
    }
    
    
    
    return [arr_jidStatus copy];
    
    
}

@end
