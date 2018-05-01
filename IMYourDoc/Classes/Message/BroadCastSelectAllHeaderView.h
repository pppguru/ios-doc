//
//  BroadCastSelectAllHeaderView.h
//  IMYourDoc
//
//  Created by OSX on 08/02/16.
//  Copyright (c) 2016 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BroadCastSelectAllHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) void (^callBackBlockHeaderView)(BOOL state);

- (IBAction)action_select:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_all;

@end
