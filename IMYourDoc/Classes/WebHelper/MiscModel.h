//
//  MiscModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/5/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface MiscModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;

@end
