//
//  VCardAffilication.h
//  IMYourDoc
//
//  Created by Harminder on 06/04/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VCardAffilication : NSManagedObject

@property (nonatomic, retain) NSNumber * hosp_id;
@property (nonatomic, retain) NSNumber * isPrimary;
@property (nonatomic, retain) NSString * name;

@end
