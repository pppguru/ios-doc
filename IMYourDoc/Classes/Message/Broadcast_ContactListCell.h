//
//  Broadcast_ContactListCell.h
//  IMYourDoc
//
//  Created by OSX on 17/07/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontLabel.h"

#import "XMPPJID.h"

@interface Broadcast_ContactListCell : UITableViewCell<NSCoding>
{
    
}

@property (strong, nonatomic) IBOutlet UIImageView *image_user;
@property (strong, nonatomic) IBOutlet FontLabel *lbl_name;
@property (strong, nonatomic) IBOutlet UIButton *btn_select;
@property(strong,nonatomic)XMPPJID *userJId;
@property (nonatomic, copy) void (^callBackBlock)(XMPPJID *userJId,BOOL state);
- (IBAction)action_select:(id)sender;

@end
