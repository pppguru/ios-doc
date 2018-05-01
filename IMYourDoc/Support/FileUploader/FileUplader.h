//
//  FileUplader.h
//  IMYourDoc
//
//  Created by Manpreet on 08/02/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "ChatMessage.h"

@interface FileUplader : ASIFormDataRequest

@property(nonatomic,strong)ChatMessage* message;

+(FileUplader*)createRequestWithChatMessage:(ChatMessage*)message WithManagedObjectContext:(NSManagedObjectContext*)context;
@end
