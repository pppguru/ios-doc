//
//  EditNameObjectClass.h
//  IMYourDoc
//
//  Created by vijayveer on 14/09/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FontTextField.h"

@interface EditNameObjectClass : NSObject<UITextFieldDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet FontTextField *txt_brdCstGrpName;
@property (weak, nonatomic) IBOutlet UIImageView *btn_edit;

-(void)makeFristResponder;

- (IBAction)action_Edit:(id)sender;

@end
