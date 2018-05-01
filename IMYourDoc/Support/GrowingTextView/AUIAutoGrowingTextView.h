//
//  AUIAutoGrowingTextView.h
//
//  Created by Adam on 10/10/13.
//

#import <UIKit/UIKit.h>

#import "UIPlaceHolderTextView.h"

@interface AUIAutoGrowingTextView : UIPlaceHolderTextView

@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat minHeight;

// TODO:
//@property(nonatomic) UIControlContentVerticalAlignment verticalAlignment;

@end


