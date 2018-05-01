//
//  IMYOURDOCNavigationController.m
//  IMYourDoc
//
//  Created by OSX on 22/02/16.
//  Copyright (c) 2016 Sarvjeet. All rights reserved.
//

#import "IMYOURDOCNavigationController.h"
#import "RDCallbackAlertView.h"
#import "AppDelegate+ClassMethods.h"
#import "Reachability.h"
@interface IMYOURDOCNavigationController ()

@end

@implementation IMYOURDOCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



+ (BOOL)isNetworkAvailable
{
    CFNetDiagnosticRef dReference;
    dReference = CFNetDiagnosticCreateWithURL (NULL, (__bridge CFURLRef)[NSURL URLWithString:@"www.apple.com"]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively (dReference, NULL);
    
    CFRelease (dReference);
    
    if ( status == kCFNetDiagnosticConnectionUp )
    {
        NSLog (@"Connection is Available");
        return YES;
    }
    else
    {
        NSLog (@"Connection is down");
        return NO;
    }
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
/*    Reachability * rechability=[AppDel reachanlity_HostAddress_OpenFire];
    if([rechability currentReachabilityStatus]!=NotReachable)
    {
        if([[rechability currentReachabilityFlags] isEqualToString:@"-R -------"])
        {
            
            //Internet and host is avaialable
            if ([[AppDel xmppStream] isConnected])
            {
                [AppData sendLocalNotificationForSecurelyConnected];
                
            }
            else
            {
                [[AppDel xmppReconnect] manualStart];
            }
            
            
        }
        else if([[rechability currentReachabilityFlags] isEqualToString:@"-R -----l-"])
        {
            
            //Internet Not avaialable
       
            
            [AppData sendLocalNotificationForNotInternetConnection];
        }
        
        
        else
        {
            //exeption cases
            
            if ([[AppDel xmppStream] isConnected])
            {
                [AppData sendLocalNotificationForSecurelyConnected];
                
            }
            else
                [AppData sendLocalNotificationForNotConnected];
        }    }
    else
    {
        [AppData sendLocalNotificationForNotConnected];
        NSLog(@".... host not reachable  %u",[rechability currentReachabilityStatus]);
        [AppDel setAppIsDisconnected:YES];
    }
    */
    /*

    
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        

        
        
        NSURL *myURL = [NSURL URLWithString: @"http://www.google.com"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: myURL];
        request.timeoutInterval = 4 ;
        NSURLResponse *response;
        NSError *error;
    
        NSData *myData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
        
        
        if (response)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               
//                               [[RDCallbackAlertView alloc] initWithTitle:@"NetworkStatus  Not Reachable" message:[NSString stringWithFormat:@"%@",response] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
//                                {
//                                    
//                                } otherButtonTitles:@"Update", nil];
//                               
                           });
            
            
            
            
            NSHTTPURLResponse* newResp = (NSHTTPURLResponse*)response;
            NSString *ConnectiontType = [newResp.allHeaderFields objectForKey:@"Connection"];
            
            if ([ConnectiontType isEqualToString:@"close"])
            {
                 dispatch_async(dispatch_get_main_queue(), ^
                {
                
                     [AppData sendLocalNotificationForNotConnected];
                     
                     
                   
                 });
                
               
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   
                                 
                                   
                                   [AppData sendLocalNotificationForSecurelyConnected];
                               });
                
            }
            
            
           

        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [AppData sendLocalNotificationForNotConnected];
                
                
            });
        }
    
    
    
    });
    
 
    */
    
  

  
    
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    
   
    
}

@end
