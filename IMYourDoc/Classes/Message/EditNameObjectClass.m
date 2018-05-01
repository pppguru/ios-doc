//
//  EditNameObjectClass.m
//  IMYourDoc
//
//  Created by vijayveer on 14/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "EditNameObjectClass.h"

@implementation EditNameObjectClass
@synthesize btn_edit,txt_brdCstGrpName;


#pragma mark - action 

- (IBAction)action_Edit:(id)sender
{
    btn_edit.hidden=!btn_edit.hidden;
    if (btn_edit.hidden == NO)
    {
        [txt_brdCstGrpName becomeFirstResponder];
        
    }
    else{
         [txt_brdCstGrpName resignFirstResponder];
    }
    
}

#pragma mark -
-(void)makeFristResponder{
    
}



- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
   [[self.txt_brdCstGrpName valueForKey:@"textInputTraits"] setValue:[UIColor whiteColor] forKey:@"insertionPointColor"];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [txt_brdCstGrpName resignFirstResponder];
    btn_edit.hidden=YES;
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
@end
