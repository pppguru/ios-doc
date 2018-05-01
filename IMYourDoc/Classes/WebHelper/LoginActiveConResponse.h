//
//  LoginActiveConResponse.h
//  IMYourDoc
//
//  Created by OSX on 20/04/16.
//  Copyright (c) 2016 vijayvir . All rights reserved.
//

#import "JSONModel.h"

@protocol ActiveConversation
@end
@protocol Messages
@end
@protocol Status
@end


@interface Status : JSONModel
@property (strong, nonatomic)  NSString<Optional> *   date;
@property (strong, nonatomic)  NSString<Optional> *   fromJID;
@property (strong, nonatomic)  NSString<Optional> *   messageID;
@property(strong ,nonatomic )  NSString<Optional> *  status;

//By ME
@property (strong,nonatomic)   NSNumber  <Optional> * lastStatus ;
@property (strong,nonatomic)   NSString  <Optional> * lastStatus_str ;

@end


@interface Messages : JSONModel
@property (strong, nonatomic) NSString<Optional> *   FileType;
@property (strong, nonatomic) NSString<Optional> *   dateOfMessage;
@property (strong, nonatomic) NSString<Optional> *   fromJID;
@property(strong ,nonatomic ) NSString<Optional> *  messageID;
@property (strong, nonatomic) NSString<Optional> *   body;
@property (strong, nonatomic) NSString<Optional> *   subject;
@property(strong ,nonatomic ) NSString<Optional> *   toJID;
@property(strong ,nonatomic ) NSString<Optional> *  type;
@property(strong ,nonatomic ) NSArray <Status> *      status;

@property (strong,nonatomic)   NSNumber  <Optional> * lastStatus ;

//By ME
@property(strong ,nonatomic  )NSNumber  <Optional>  * messageType;

@end

@interface ActiveConversation : JSONModel

@property (strong, nonatomic) NSString<Optional> *   lastActive;
@property (strong, nonatomic) NSString<Optional> *   last_active_sec;
@property (strong, nonatomic) NSString<Optional> *   jid;

@property(strong ,nonatomic ) NSArray <Messages> *   messages;
@end



@interface LoginActiveConResponse : JSONModel
@property(strong ,nonatomic ) NSArray <ActiveConversation> *   active_conversations;
@end
