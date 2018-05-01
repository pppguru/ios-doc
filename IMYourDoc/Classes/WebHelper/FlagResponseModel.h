//
//  FlagRequestModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/8/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface FlagResponseModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *flagType;
@property (nonatomic, assign) BOOL value;

@end
