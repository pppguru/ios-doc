//
//  NSMutableDictionary+Contact.m
//  IMYourDoc
//
//  Created by OSX on 01/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "NSMutableDictionary+Contact.h"







@implementation NSMutableDictionary (Contact)
-(NSMutableDictionary*)sortedArrayWithTitles:(NSMutableArray*)arr_contacts{
    
 
    int z_hash= 'Z'+1;
    NSMutableDictionary * dict_ContactsWithTitle=[NSMutableDictionary new];
    
    for (  int i='A';i<=z_hash ; i++)
    {
        NSString *string = [NSString stringWithFormat:@"%c*",i];
      
        if (i==z_hash)
        {
            NSMutableArray* arr_temp=[NSMutableArray new];
        ;
            for(id obj  in [dict_ContactsWithTitle allValues])
            {
                for(id obj2 in obj)
                {
                      [arr_temp addObject:obj2];
                }
                
              
            }
            
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"NOT SELF IN %@",arr_temp];
            NSArray *arr_sorted=[arr_contacts filteredArrayUsingPredicate:predicate];
            NSLog(@"%@",arr_sorted);
            if([arr_sorted count]>0)
            [dict_ContactsWithTitle setObject:arr_sorted forKey:[NSString stringWithFormat:@"#"]];
        }
        else{
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"kABPersonFirstNameProperty LIKE[cd] %@",string ];
            NSArray *arr_sorted=[arr_contacts filteredArrayUsingPredicate:predicate];
            NSLog(@"%@",arr_sorted);
            if([arr_sorted count]>0)
                [dict_ContactsWithTitle setObject:arr_sorted forKey:[NSString stringWithFormat:@"%c",i]];
        }
    
    }
    return dict_ContactsWithTitle;
}
-(NSMutableDictionary *)searchExternalContactWithText:(NSString*)search_string contactArray:(NSMutableArray*)arr_contacts
{
        NSMutableDictionary * dict_ContactsWithTitle=[NSMutableDictionary new];
    NSPredicate * myPredicate = [NSPredicate predicateWithFormat:@"kABPersonFirstNameProperty CONTAINS[cd]  %@ OR  kABPersonLastNameProperty CONTAINS[cd]  %@ OR   kABPersonMiddleNameProperty CONTAINS[cd]  %@ OR   kABPersonEmailProperty CONTAINS[cd]  %@ OR   kABPersonPhone CONTAINS[cd]  %@   ",search_string ,search_string,search_string,search_string,search_string];
    NSArray * filteredArray = [arr_contacts filteredArrayUsingPredicate:myPredicate];
    
     int z_hash= 'Z'+1;
    for (  int i='A';i<=z_hash ; i++)
    {
        NSString *string = [NSString stringWithFormat:@"%c*",i];
        
        if (i==z_hash)
        {
            NSMutableArray* arr_temp=[NSMutableArray new];
           
            for(id obj  in [dict_ContactsWithTitle allValues])
            {
                for(id obj2 in obj)
                {
                    [arr_temp addObject:obj2];
                }
                
                
            }
            
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"NOT SELF IN %@",arr_temp];
            NSArray *arr_sorted=[filteredArray filteredArrayUsingPredicate:predicate];
        
            if([arr_sorted count]>0)
                [dict_ContactsWithTitle setObject:arr_sorted forKey:[NSString stringWithFormat:@"#"]];
        }
        
        else{
        
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"kABPersonFirstNameProperty LIKE[cd] %@",string ];
        NSArray *arr_sorted=[filteredArray filteredArrayUsingPredicate:predicate];
           if([arr_sorted count]>0)
            [dict_ContactsWithTitle setObject:arr_sorted forKey:[NSString stringWithFormat:@"%c",i]];
        }
    }
    return dict_ContactsWithTitle;
    
    
}
@end
