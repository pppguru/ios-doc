//
//  DetailOfMessageViewController.h
//  IMYourDoc
//
//  Created by OSX on 22/01/16.
//  Copyright (c) 2016 Sarvjeet. All rights reserved.
//

#import "ImYouDocViewController.h"
#import  "ChatMessage+ClassMethod.h"

@interface DetailOfMessageViewController : ImYouDocViewController
@property (weak, nonatomic) IBOutlet UITextView *txt_detialOfCell;

@property(nonatomic,strong)ChatMessage *chatMessage;

@end
