//
//  NSMutableDictionary+Contact.h
//  IMYourDoc
//
//  Created by OSX on 01/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Contact)
{

    
}
-(NSMutableDictionary*)sortedArrayWithTitles:(NSMutableArray*)arr_contacts;
-(NSMutableDictionary *)searchExternalContactWithText:(NSString*)search_string contactArray:(NSMutableArray*)arr_contacts;
@end
