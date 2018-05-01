//
//  GroupListCell.h
//  IMYourDoc
//
//  Created by OSX on 25/08/15.
//  Copyright (c) 2015 Sarvjeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FontLabel.h"
#import "ImageViewAsincLoader.h"

@interface GroupListCell : UITableViewCell
@property (nonatomic, unsafe_unretained) IBOutlet ImageViewAsincLoader *userIMGV;
@property (nonatomic, unsafe_unretained) IBOutlet FontLabel *roleLB, *userNameLB;
@end










