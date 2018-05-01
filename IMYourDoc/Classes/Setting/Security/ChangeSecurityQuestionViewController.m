//
//  ChangeSecurityQuestionViewController.m
//  IMYourDoc
//
//  Created by OSX on 07/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "ChangeSecurityQuestionViewController.h"

@interface ChangeSecurityQuestionViewController ()
{
    BOOL bool_ChangeSecRetry, bool_ChangeSecFirstTime;
}


@end

@implementation ChangeSecurityQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   }
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
        [self setRequiredFont1];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    

    txt_SecQuestion.text=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"QuestionString"]];
    txt_secAnswer.text=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"AnswerString"]];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    }


#pragma mark- Action






- (IBAction)action_save:(id)sender
{
    
    
    if (txt_SecQuestion.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Security Question." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [txt_SecQuestion becomeFirstResponder];
        
        return;
    }
    
    else if (txt_secAnswer.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter Security Answer." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
          [txt_secAnswer becomeFirstResponder];
         return;
    }
    
    
    if ([AppDel appIsDisconnected])
    {
        [AppData showAlertWithTitle:nil andMessage:@"No Connection." inVC:self];
           return;
    }
    
    else
    {
        bool_ChangeSecFirstTime = YES;
        
        [self action_saveMethod];
    }
    
    
}

- (void)action_saveMethod
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"updateSecurityInfo", @"method",
                          
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"loginToken"], @"login_token",
                          
                          txt_SecQuestion.text, @"security_question",
                          txt_secAnswer.text, @"security_answer",
                          nil];
    
    [[WebHelper sharedHelper] setWebHelperDelegate:self];
    
    [[WebHelper sharedHelper] sendRequest:dict tag:S_UpdateSecurityInfo delegate:self];
    
    if (bool_ChangeSecRetry && !bool_ChangeSecFirstTime)
    {
        [AppDel showSpinnerWithText:@"Retrying..."];
        
        bool_ChangeSecRetry = NO;
    }
    else
    {
        [AppDel showSpinnerWithText:@"Processing ..."];
        
        bool_ChangeSecRetry = YES;
        
        bool_ChangeSecFirstTime = NO;
    }
    
  
}

#pragma mark - helper function
- (void)setRequiredFont1
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
    
        
        [lbl_secAns setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:25.00]];
        
        [lbl_secQue setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
        [lbl_title setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:25.00]];
        
     
    }
    else
    {
      
        
        
        
        [lbl_secAns setFont:[UIFont fontWithName:@"CentraleSansRndMedium" size:20.00]];
        
        [lbl_secQue setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
        [lbl_title  setFont:[UIFont fontWithName:@"CentraleSansRndLight" size:20.00]];
        
       
    }
}


#pragma mark - textFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}

#pragma mark - keyboard notification

- (void) keyboardWillShow: (NSNotification *) noti
{
    CGRect keyBFrame = [[[noti userInfo] valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    if (txt_secAnswer.isEditing)
    {
        if ( (keyBFrame.origin.y) < (viewCon_Ans.frame.origin.y + txt_secAnswer.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (viewCon_Ans.frame.origin.y + txt_secAnswer.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
        }
    }
    
    else     if (txt_SecQuestion.isEditing)
    {
        if ( (keyBFrame.origin.y) < (ViewCon_Ques.frame.origin.y + txt_SecQuestion.frame.size.height + 50 + 30))
        {
            TFScroll.contentOffset = CGPointMake(0, (ViewCon_Ques.frame.origin.y + txt_SecQuestion.frame.size.height + 50 + 30) - (keyBFrame.origin.y));
        }
    }
    
    
}


- (void) keyboardWillHide: (NSNotification *) noti
{
   TFScroll.contentOffset = CGPointMake(0, 0);
}

#pragma mark - Service Response

- (void)didReceivedresponse:(NSDictionary *)response
{
    [AppDel hideSpinner];
    
    
    if ([WebHelper sharedHelper].tag == S_UpdateSecurityInfo)
    {
        if ([[response objectForKey:@"err-code"] intValue] == 1)    // Success
        {
   
                [[NSUserDefaults standardUserDefaults] setValue:txt_SecQuestion.text forKey:@"QuestionString"];
            [[NSUserDefaults standardUserDefaults] setValue:txt_secAnswer.text forKey:@"AnswerString"];
               [[NSUserDefaults standardUserDefaults] synchronize];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 [self.navigationController popViewControllerAnimated:YES];
                 
             } otherButtonTitles:@"OK", nil];
            
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 600)    // Session expired
        {  [AppDel signOutFromAppSilent];
            [[RDCallbackAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] cancelButtonTitle:nil andCompletionHandler:^(int btnIndex)
             
             {
                 
                 
             } otherButtonTitles:@"OK", nil];
        }
        
        else if ([[response objectForKey:@"err-code"] intValue] == 300)    // Unable to proceed
        {
            [[[UIAlertView alloc] initWithTitle:nil message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}


- (void)didFailedWithError: (NSError *) error
{
    [AppDel hideSpinner];
    
    if ([WebHelper sharedHelper].tag == S_UpdateSecurityInfo)
    {
        if (bool_ChangeSecRetry)
        {
            [self performSelector:@selector(action_saveMethod) withObject:nil afterDelay:0.9];
        }
        else
        {
            [[RDCallbackAlertView alloc] initWithTitle:nil message:@"Cannot detect Internet connection" cancelButtonTitle:nil andCompletionHandler:^(int btnIDX)
             {
                 
                 if (btnIDX==0)
                 {
                     bool_ChangeSecRetry = YES;
                     
                     [self action_saveMethod];
                     
                 }
                 if (btnIDX==1)
                 {
                     bool_ChangeSecRetry = NO;
                 }
                 
             } otherButtonTitles:@"Retry" ,@"Try Later", nil];
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to connect to the server, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}



@end
