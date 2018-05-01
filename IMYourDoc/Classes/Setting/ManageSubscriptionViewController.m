//
//  ManageSubscriptionViewController.m
//  IMYourDoc
//
//  Created by Harminder on 24/06/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ManageSubscriptionViewController.h"


@interface ManageSubscriptionViewController ()

@end

@implementation ManageSubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



#pragma mark - action
- (IBAction)action_CancelSubscription:(id)sender {
    
    
    // if  it not automatically
    [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Are you sure you want to cancel your subscription? All providers on your contact list and conversations will be removed from your device." cancelButtonTitle:@"NO" andCompletionHandler:^(int btnIndex)
     
     {
         if (btnIndex==1)
         {
             if ([AppDel appIsDisconnected])
             {
                 [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
             }
             
             else
             {
                 
                 [AppDel showSpinnerWithText:@"Cancelling Subscription.."];
                 
                 
                 
                 NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"unsubscribeUser",
                                                                             [AppData appData].XMPPmyJID,
                                                                             [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"],
                                                                             nil]
                                                                    forKeys:[NSArray arrayWithObjects:@"method", @"user_name", @"login_token", nil]];
                 
                 [[WebHelper sharedHelper] setWebHelperDelegate:self];
                 
                 [[WebHelper sharedHelper] sendRequest:dict tag:S_CancelSubscription delegate:self];
             }
         }
         
         
     } otherButtonTitles:@"YES", nil];
    
    
}

- (IBAction)action_UpdateCreditCard:(id)sender {
    
     /* {    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
        
        return;
    }
    
    
    [AppDel showSpinnerWithText:@"Processing..."];
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"getPaymentKeyDetails", @"method",
                          
                          
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_GetPaymentKeyDetails delegate:self];

} */
    
}

#pragma mark - Alert view Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{


}

#pragma mark - web services

-(void)didFailedWithError:(NSError *)error{
    
}

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_CancelSubscription)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {
            [AppDel signOutFromAppSilent];
            
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    /*
    else  if ([WebHelper sharedHelper].tag == S_GetPaymentKeyDetails)
    {
        [AppDel hideSpinner];
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
            [AppDel hideSpinner];
            
       
            
//            {
//             StripeViewController *obj_stripeVC=[[StripeViewController alloc]initWithNibName:@"StripeViewController" bundle:[NSBundle mainBundle]];
//             obj_stripeVC.str_publishable_key=[response objectForKey:@"publishable_key"];
//             obj_stripeVC.str_payment_amount=[response objectForKey:@"payment_amount"];
//             obj_stripeVC.callBackBlock=^(NSString* token, NSString * expMonth,NSString*expYear)
//             {
//      
//             };
//             [self.navigationController pushViewController:obj_stripeVC animated:YES];
//             }
         
            
            
            
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        { [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        
    }
     
     */
    
}



@end
