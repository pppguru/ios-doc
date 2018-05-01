//
//  HospitalModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/5/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface HospitalModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *creatorPhoneNumber;
@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL primary;

@end