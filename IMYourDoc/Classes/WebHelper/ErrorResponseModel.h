//
//  ErrorResponseModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/12/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface ErrorResponseModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *timestamp;
@property (nonatomic, copy) NSNumber *status;
@property (nonatomic, copy) NSString *error;
@property (nonatomic, copy) NSString *exception;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) BOOL propagated;

@end
