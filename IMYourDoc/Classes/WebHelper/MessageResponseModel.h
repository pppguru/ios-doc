//
//  MessageResponseModel.h
//  IMYourDoc
//
//  Created by Nicholas Graff on 7/6/16.
//  Copyright © 2016 vijayvir . All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"
#import "ContentModel.h"
#import "NilModel.h"
#import "LastMessageModel.h"

@interface MessageResponseModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSArray<LastMessageModel *> *content;
@property (nonatomic, assign) BOOL first;
@property (nonatomic, assign) BOOL last;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSNumber *numberOfElements;
@property (nonatomic, copy) NSNumber *size;
@property (nonatomic, strong) NilModel *sort;
@property (nonatomic, copy) NSNumber *totalElements;
@property (nonatomic, copy) NSNumber *totalPages;

@end
