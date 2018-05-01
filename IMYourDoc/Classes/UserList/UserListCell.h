//
//  UserListCell.h
//  IMYourDoc
//
//  Created by Nipun on 18/11/14.
//
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FontLabel.h"
#import "ImageViewAsincLoader.h"


@interface UserListCell : UITableViewCell
{
    
}


@property (nonatomic, unsafe_unretained) IBOutlet ImageViewAsincLoader *userIMGV;

@property (nonatomic, unsafe_unretained) IBOutlet FontLabel *roleLB, *userNameLB;

@property (weak, nonatomic) IBOutlet FontLabel *lblThirdRow;
@property (weak, nonatomic) IBOutlet FontLabel *lblFourthRow;

@end

