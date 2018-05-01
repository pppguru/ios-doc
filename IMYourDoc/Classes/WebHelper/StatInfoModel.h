//
//  StatInfoModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/12/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface StatInfoModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDate *date;

@end
