//
//  LoginActiveConResponse.m
//  IMYourDoc
//
//  Created by OSX on 20/04/16.
//  Copyright (c) 2016 vijayvir . All rights reserved.
//

#import "LoginActiveConResponse.h"
#import "ChatMessage+ClassMethod.h"
#import "AppDelegate.h"

@implementation LoginActiveConResponse

@end
@implementation ActiveConversation
@end
@implementation Messages
-(NSNumber*)messageType
{
    
    if ([self.type  isEqualToString:@"chat"])
    {
        return [NSNumber numberWithInt:1];
        
    }
    else if ([self.type  isEqualToString:@"group"])
    {
        return [NSNumber numberWithInt:2];
    }
        
    return [NSNumber numberWithInt:4];
}



-(NSNumber*)lastStatus
{
    
    if([self.type isEqualToString:@"group"])
    {
        if(![self.fromJID isEqualToString: [AppDel myJID]])
        {
            for (Status * stsObject in self.status)
            {
                if([stsObject.fromJID isEqualToString:[AppDel myJID]])
                {
                    
                    switch ([stsObject.lastStatus intValue]) {
                        case ChatStateType_Read:
                            return [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                            
                            break;
                        case ChatStateType_Delivered:
                            return [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                            
                            break;
                        case ChatStateType_Notification_EmailSent:
                            return [NSNumber numberWithInt:ChatStateType_NoneByReciever];
                            
                            break;
                            
                        default:
                            break;
                    }
                    return stsObject.lastStatus;
                    
                }
            }
        }
        
        
    }
    
    
    
    for (Status * stsObject in self.status)
    {
        
        if (_lastStatus == nil )
        {
             _lastStatus =  stsObject.lastStatus;
        }
        else if (_lastStatus  != stsObject.lastStatus)
          {
         
              
              if (stsObject.lastStatus == [NSNumber numberWithInt:ChatStateType_displayedByReciever]||stsObject.lastStatus == [NSNumber numberWithInt:ChatStateType_Read])
              {
                  _lastStatus = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                  
              }
              
           
              
              else if (stsObject.lastStatus == [NSNumber numberWithInt:ChatStateType_deliveredByReciever]
                       ||stsObject.lastStatus == [NSNumber numberWithInt:ChatStateType_Delivered])
              {
                  
                  if ( _lastStatus == [NSNumber numberWithInt:ChatStateType_displayedByReciever]||_lastStatus == [NSNumber numberWithInt:ChatStateType_Read])
                  {
                      _lastStatus = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                      
                      ;
                      
                  }
                  else{
                      _lastStatus = [NSNumber numberWithInt:ChatStateType_deliveredByReciever];
                  }
                  
                  
              }
            
          
              
              else if (stsObject.lastStatus == [NSNumber numberWithInt:ChatStateType_Notification_EmailSent])
              {
                  
                  if ( _lastStatus == [NSNumber numberWithInt:ChatStateType_displayedByReciever]||_lastStatus == [NSNumber numberWithInt:ChatStateType_Read])
                  {
                      _lastStatus = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                      
                      ;
                      
                  }
               else   if ( _lastStatus == [NSNumber numberWithInt:ChatStateType_Delivered]||_lastStatus == [NSNumber numberWithInt:ChatStateType_deliveredByReciever])
                  {
                      _lastStatus = [NSNumber numberWithInt:ChatStateType_Delivered];
                      
                      ;
                      
                  }
                  
                  else{
                      _lastStatus = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                  }
                  
                  
              }
              else if (stsObject.lastStatus == [NSNumber numberWithInt:ChatStateType_Sending])
              {
                  
                  if ( _lastStatus == [NSNumber numberWithInt:ChatStateType_displayedByReciever]||_lastStatus == [NSNumber numberWithInt:ChatStateType_Read])
                  {
                      _lastStatus = [NSNumber numberWithInt:ChatStateType_displayedByReciever];
                      
                      ;
                      
                  }
                  else   if ( _lastStatus == [NSNumber numberWithInt:ChatStateType_Delivered]||_lastStatus == [NSNumber numberWithInt:ChatStateType_deliveredByReciever])
                  {
                      _lastStatus = [NSNumber numberWithInt:ChatStateType_Delivered];
                      
                      ;
                      
                  }
                 else if ( _lastStatus == [NSNumber numberWithInt:ChatStateType_Notification_EmailSent])
                 {
                     _lastStatus = [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
                     
                     ;
                     
                 }
                  else{
                      _lastStatus = [NSNumber numberWithInt:ChatStateType_Sending];
                  }
                  
                  
              }
              else
              {
                  
                  NSLog(@"Shirin%@",stsObject.lastStatus);
                  
                  
                  
                  
              }
              
              
          }
        
        
        
     
    }
    
    
    

    
    if (_lastStatus == nil )
    {
        _lastStatus =  [NSNumber numberWithInt:ChatStateType_Read];
    }
    
    
    return _lastStatus;
    
}

@end
@implementation Status
//    [status]: Deliver,Display,Notification


-(NSString*)lastStatus_str{
    NSArray *joinedComponents = [self.status componentsSeparatedByString:@","];
    
    //NSUInteger indexOfTheObject = [myArray indexOfObject: @"my string"];
    
    
    //    ChatStateType_Sending =0 ,
    //    ChatStateType_Sent =1,
    //    ChatStateType_Delivered=2,    // Sender side
    //    ChatStateType_Read=3,
    //    ChatStateType_Notification_EmailSent =4 ,
    //    ChatStateType_NotDelivered  = 5,
    //    ChatStateType_deliveredByReciever = 100,  // Reciever Side
    //    ChatStateType_displayedByReciever = 101
    
    
    if (joinedComponents.count>0)
    {
        if ([joinedComponents containsObject: @"Display"])
        {
            return @"Read";
            
            
        }
        else if ([joinedComponents containsObject: @"Deliver"])
        {
            return @"Deliver";
            
        }
        else if ([joinedComponents containsObject: @"Notification"])
        {
            return @"Notification Sent";
            
        }
        
    }
    
   
    
    
    
    
  return self.status;
}
-(NSNumber*)lastStatus
{
    
    NSArray *joinedComponents = [self.status componentsSeparatedByString:@","];
    


    if (joinedComponents.count>0)
    {
        if ([joinedComponents containsObject: @"Display"])
        {
            return [NSNumber numberWithInt:ChatStateType_Read];
            
            
        }
        else if ([joinedComponents containsObject: @"Deliver"])
        {
            return [NSNumber numberWithInt:ChatStateType_Delivered];
            
        }
        else if ([joinedComponents containsObject: @"Notification"])
        {
            return [NSNumber numberWithInt:ChatStateType_Notification_EmailSent];
            
        }
        
    }
    
    else{
        NSLog(@"%@",self.status);
        
    }
    
 

        
    
    
    return [NSNumber numberWithInt:ChatStateType_Read];
    
}
@end