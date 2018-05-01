//
//  StatusModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/12/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"
#import "StatInfoModel.h"

@interface StatusModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSArray<StatInfoModel *> *emailed;
@property (nonatomic, strong) NSArray<StatInfoModel *> *delivered;
@property (nonatomic, strong) NSArray<StatInfoModel *> *acknowledged;
@property (nonatomic, strong) NSArray<StatInfoModel *> *notified;
@property (nonatomic, strong) NSArray<StatInfoModel *> *displayed;

@end
