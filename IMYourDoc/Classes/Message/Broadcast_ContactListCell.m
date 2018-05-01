//
//  Broadcast_ContactListCell.m
//  IMYourDoc
//
//  Created by OSX on 17/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import "Broadcast_ContactListCell.h"

@implementation Broadcast_ContactListCell

- (void)awakeFromNib {
    // Initialization code
    _image_user.layer.cornerRadius = 30;
    _image_user.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)action_select:(id)sender
{
    _btn_select.selected=!_btn_select.selected;
    _callBackBlock(_userJId,_btn_select.selected);
    
    
}
@end
