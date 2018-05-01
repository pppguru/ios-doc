
#import "AppDelegate.h"
#import "BCBubbleViewCell.h"
#import "AttachmentWebViewController.h"

#define  TAG_B 105598
#define  TAG_AttachmentImage 1037858
#define  TAG_infoLB 10373828
#define  TAG_usernameLB 103732288
#define  TAG_statudLB 975532288
#define  TAG_AttachmentImageBtn 342103788
#define  TAG_lbl_messageContent 343057738
#define  TAG_lbl_SubjectContent 357542738
#define TAG_messageStatLB  908732877
#define TAG_timeLB 13024099

const CGFloat BCBubbleWidthOffset = 50.0f;
const CGFloat BCBubbleImageSize = 30.0f;

@implementation BCBubbleViewCell



@synthesize lbl_messageContent,lbl_SubjectContent,lbl_readBy, lbl_dileveredTo,lbl_status;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _bubbleView=(UIImageView *)[self viewWithTag:TAG_B];
        if(_bubbleView==nil)
            _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bubbleView.userInteractionEnabled = YES;
        _bubbleView.tag=TAG_B;
        [self.contentView addSubview:_bubbleView];
        
        self.lbl_messageContent=(TTTAttributedLabel *)[self viewWithTag:TAG_lbl_messageContent ];
        if(lbl_messageContent==nil)
            self.lbl_messageContent= [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        lbl_messageContent.tag=TAG_lbl_messageContent;
        
        
        self.lbl_messageContent.contentMode = UIViewContentModeScaleAspectFill;
      
        self.lbl_messageContent.numberOfLines = 0;
        self.lbl_messageContent.lineBreakMode = NSLineBreakByWordWrapping;
        self.lbl_messageContent.textColor = [UIColor blackColor];
        self.lbl_messageContent.font = [UIFont fontWithName:@"CentraleSansRndLight" size:17];
        self.lbl_messageContent.textColor = [UIColor whiteColor];
        [self.lbl_messageContent sizeToFit];
        self.lbl_messageContent.userInteractionEnabled = YES;
        
        self.lbl_messageContent.delegate = self;
        self.lbl_messageContent.enabledTextCheckingTypes=NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber;
        [_bubbleView addSubview:self.lbl_messageContent];
        
        
        //•••••••••••••••••••••••••••••••••••••••••••••••••••••
        
        self.lbl_SubjectContent=(TTTAttributedLabel *)[self viewWithTag:TAG_lbl_SubjectContent ];
        if(lbl_SubjectContent==nil)
            self.lbl_SubjectContent= [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        lbl_SubjectContent.tag=TAG_lbl_SubjectContent;
        self.lbl_SubjectContent.contentMode = UIViewContentModeScaleAspectFill;
        
        self.lbl_SubjectContent.numberOfLines = 0;
        self.lbl_SubjectContent.lineBreakMode = NSLineBreakByWordWrapping;
        self.lbl_SubjectContent.textColor = [UIColor blackColor];
        self.lbl_SubjectContent.font = [UIFont fontWithName:@"CentraleSansRndLight" size:16];
        self.lbl_SubjectContent.textColor = [UIColor whiteColor];
        [self.lbl_SubjectContent sizeToFit];
        self.lbl_SubjectContent.userInteractionEnabled = YES;
        
        self.lbl_SubjectContent.delegate = self;
   
        [_bubbleView addSubview:self.lbl_SubjectContent];
        
      
        
        self.imageView.userInteractionEnabled = YES;
        self.imageView.layer.cornerRadius = 5.0;
        self.imageView.layer.masksToBounds = YES;
        
        
        
        
   
     
        
        _selectedBubbleColor = BCBubbleTableViewCellBubbleColorAqua;
        _canCopyContents = YES;
        _selectionAdjustsColor = YES;
        
        
        _attachmentImage=(UIImageView *)[self viewWithTag:TAG_AttachmentImageBtn ];
        if(_attachmentImage==nil)
            _attachmentImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _attachmentImage.tag=TAG_AttachmentImageBtn;
  
        _attachmentImage.contentMode = UIViewContentModeScaleAspectFill;
        _attachmentImage.clipsToBounds = YES;
        _attachmentImage.userInteractionEnabled = NO;
        
        
        
        
        [self addSubview:_attachmentImage];
        
        

        _timeLB=(UILabel *)[self viewWithTag:TAG_timeLB ];
        if(_timeLB==nil)
            _timeLB = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLB.tag=TAG_timeLB;
        _timeLB.font = [UIFont fontWithName:@"CentraleSansRndLight" size:10];
        _timeLB.textAlignment = NSTextAlignmentLeft;
        self.timeLB.textColor = [UIColor whiteColor];
        
        [_bubbleView addSubview:_timeLB];
        
      
        
        lbl_readBy=(UILabel*)[self viewWithTag:TAG_messageStatLB];
        if(lbl_readBy==nil)
            lbl_readBy = [[UILabel alloc] initWithFrame:CGRectZero];

        lbl_readBy.tag=TAG_messageStatLB;
        lbl_readBy.font = [UIFont fontWithName:@"CentraleSansRndLight" size:10];
        lbl_readBy.textAlignment = NSTextAlignmentRight;
        self.lbl_readBy.textColor = [UIColor darkGrayColor];
        
        
        
        [self addSubview:lbl_readBy];
        
        _infoButton=(UIButton*)[self viewWithTag:TAG_infoLB];
        if(_infoButton==nil)
            _infoButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
 
        [_infoButton setImage:[UIImage imageNamed:@"Info_red_icon"] forState:UIControlStateNormal];
        _infoButton.tag=TAG_infoLB;
        _infoButton.tintColor = [UIColor redColor];
        
        [self addSubview:_infoButton];
        
        lbl_dileveredTo=(UILabel *)[self viewWithTag:TAG_usernameLB];
        if(lbl_dileveredTo==nil)
            lbl_dileveredTo = [[UILabel alloc] initWithFrame:CGRectZero];
        

        lbl_dileveredTo.tag=TAG_usernameLB;
        lbl_dileveredTo.font = [UIFont fontWithName:@"CentraleSansRndLight" size:10];
        lbl_dileveredTo.textColor = [UIColor darkGrayColor];
        lbl_dileveredTo.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:lbl_dileveredTo];
        
        
        
        
        lbl_status=(UILabel *)[self viewWithTag:TAG_statudLB];
        if(lbl_status==nil)
            lbl_status = [[UILabel alloc] initWithFrame:CGRectZero];
        
        lbl_status.tag=TAG_statudLB;
        lbl_status.font = [UIFont fontWithName:@"CentraleSansRndLight" size:10];
        lbl_status.textColor = [UIColor darkGrayColor];
        lbl_status.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:lbl_status];
        
        
        
        
        [self resetFramesWhenCellIsNotNil];
     

 }
    
    
    return self;
}




-(void)didDelieved:(BOOL)boold{
    
    if (boold==YES) {
        lbl_dileveredTo.hidden =NO;
        lbl_readBy.hidden=NO;
        
        lbl_status.hidden=YES;
    }
    else{
        lbl_dileveredTo.hidden =YES;
        lbl_readBy.hidden=YES;
        
        lbl_status.hidden=NO;
    }
    
}



#pragma mark Tableview Data Source

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    return self.contentView.frame.size.height;
}


- (UITableView *)tableView
{
    UIView *tableView = self.superview;
    
    
    while(tableView)
    {
        if ([tableView isKindOfClass:[UITableView class]])
        {
            return (UITableView *)tableView;
        }
        
        
        tableView = tableView.superview;
    }
    
    
    return nil;
}
- (void)setImageForBubbleColor:(BCBubbleColor)color
{
    
    self.bubbleView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"Bubble-%lu.png", (long)color]] resizableImageWithCapInsets:UIEdgeInsetsMake(12.0f, 15.0f, 16.0f, 18.0f) resizingMode:UIImageResizingModeStretch];
    self.bubbleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.bubbleView.transform = CGAffineTransformIdentity;
}
- (void)layoutSubviews
{
    [self updateFramesForAuthorType:self.authorType];
}

- (void)updateFramesForAuthorType:(BCAuthorType)type
{
    [self setImageForBubbleColor:self.bubbleColor];
    
    

    
    
    CGFloat minInset = 0.0f;
    
    
    if ([self.dataSource respondsToSelector:@selector(minInsetForCell:atIndexPath:)])
    {
        minInset = [self.dataSource minInsetForCell:self atIndexPath:[[self tableView] indexPathForCell:self]];
    }
    
    
    CGSize sizeMessage , sizeSubject;
    
    {
        
        UIFont *labelFontMessage = [UIFont systemFontOfSize:17.0f];
        
        NSMutableParagraphStyle *paragraphStyleMessage = [[NSMutableParagraphStyle alloc]init];
        //set the line break mode
        paragraphStyleMessage.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:labelFontMessage,
                                  NSFontAttributeName,
                                  paragraphStyleMessage,
                                  NSParagraphStyleAttributeName,
                                  nil];
        
        
        
        
        UIFont *labelFontSubject = [UIFont systemFontOfSize:16.0f];
        
        NSMutableParagraphStyle *paragraphStyleSubject = [[NSMutableParagraphStyle alloc]init];
        //set the line break mode
        paragraphStyleSubject.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attrDictSubject = [NSDictionary dictionaryWithObjectsAndKeys:labelFontSubject,
                                  NSFontAttributeName,
                                  paragraphStyleSubject,
                                  NSParagraphStyleAttributeName,
                                  nil];
        
        
        
        if (self.imageView.image == nil)
        {
            self.imageView.image = [UIImage imageNamed:@"profile"];
        }
        
        if (self.imageView.image)
        {
            sizeMessage = [self.lbl_messageContent.text boundingRectWithSize:CGSizeMake((self.frame.size.width - minInset - BCBubbleWidthOffset - BCBubbleImageSize - 8.0f), CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:attrDict
                                                              context:nil].size;
            
            sizeSubject = [self.lbl_SubjectContent.text boundingRectWithSize:CGSizeMake((self.frame.size.width - minInset - BCBubbleWidthOffset - BCBubbleImageSize - 8.0f), CGFLOAT_MAX)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:attrDictSubject
                                                                     context:nil].size;
            
        }
        
        else
        {
            
           
           
            
            
            sizeMessage = [self.lbl_messageContent.text boundingRectWithSize:CGSizeMake((self.frame.size.width - minInset - BCBubbleWidthOffset), CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:attrDict
                                                              context:nil].size;
            
            sizeSubject = [self.lbl_SubjectContent.text boundingRectWithSize:CGSizeMake((self.frame.size.width - minInset - BCBubbleWidthOffset - BCBubbleImageSize - 8.0f), CGFLOAT_MAX)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:attrDictSubject
                                                                     context:nil].size;
            
        }
        
        
        if (sizeMessage.width < 100 && sizeSubject.width   <100  )
        {
            sizeMessage.width = 100;
             sizeSubject.width = 100;
        }
        
        
        if (type == BCBubbleTableViewCellAuthorTypeSelf)
     {

        {
            
            
            
            self.bubbleView.frame =
            CGRectMake(
                       (self.contentView.frame.size.width - (sizeMessage.width + BCBubbleWidthOffset+BCBubbleImageSize)),
                       10.0f,
                       (sizeMessage.width + BCBubbleWidthOffset),
                       (sizeMessage.height +sizeSubject.height +(4*15)));
            
            self.imageView.frame = CGRectMake(
                                    (self.contentView.frame.size.width - BCBubbleImageSize ),
                                    (self.bubbleView.frame.origin.y+self.bubbleView.frame.size.height - BCBubbleImageSize ),
                                               BCBubbleImageSize,
                                                 BCBubbleImageSize);
            
            
            
            self.lbl_SubjectContent.frame = CGRectMake(
                                                       self.bubbleView.bounds.origin.x+10,
                                                       15.0f,
                                                       (sizeSubject.width + BCBubbleWidthOffset - 23.0f),
                                                       sizeSubject.height);
     
            
           
            
            self.lbl_messageContent.frame =
            CGRectMake(
                       self.bubbleView.bounds.origin.x+10,
                       (lbl_SubjectContent.frame.origin.y  +lbl_SubjectContent.frame.size.height+ 15.0f),
                       (sizeMessage.width + BCBubbleWidthOffset - 23.0f),
                       sizeMessage.height);
            
            
            self.timeLB.frame = CGRectMake(
                                           self.bubbleView.bounds.origin.x+10,
                                           ( lbl_messageContent.frame.origin.y  +lbl_messageContent.frame.size.height+ 5.0f),
                                          100,
                                           10);
               
               
            
            
            self.lbl_SubjectContent.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            self.lbl_messageContent.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            self.timeLB.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
         
            self.bubbleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            
            
            
            
            self.contentView.frame= CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.bubbleView.frame.size.height + 10 + 20+10);
            

            
            
            lbl_readBy.frame = CGRectMake(
                                          self.contentView.center.x-70,
                                         (self.contentView.frame.size.height  -30 ),
                                          100,
                                          10);
            
            lbl_dileveredTo.frame = CGRectMake(
              lbl_readBy.frame.origin.x+lbl_readBy.frame.size.width+10,
             (self.contentView.frame.size.height  -30 ),
                                               100,
                                               10);
            
            lbl_status.frame = CGRectMake(
                                             (self.contentView.frame.size.width - 100 ),
                                               (self.contentView.frame.size.height  -30 ),
                                               100,
                                               10);
        
            
            
            
            }
            
  
  
        }
        

    }
}





+(CGFloat )heightOfCellWithsubject:(NSString*)subject message:(NSString*)message{
    return 0;
}

- (UIColor*) randomColor{
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

-(void)testingFeatures
{

    {
        [self.imageView.layer setBorderColor:[UIColor blueColor].CGColor];
        [self.imageView.layer setBorderWidth:1.0f];
    }

    {
        [self.lbl_messageContent.layer setBorderColor:[UIColor orangeColor].CGColor];
        [self.lbl_messageContent.layer setBorderWidth:1.0f];
        self.lbl_messageContent.backgroundColor  =[self randomColor];
        
        [self.lbl_SubjectContent.layer setBorderColor:[UIColor orangeColor].CGColor];
        [self.lbl_SubjectContent.layer setBorderWidth:1.0f];
        self.lbl_SubjectContent.backgroundColor  =[self randomColor];
    }

    {
        [self.contentView.layer setBorderColor:[UIColor redColor].CGColor];
        [self.contentView.layer setBorderWidth:6.0f];
        self.contentView.backgroundColor=[self randomColor];
        
    }

    {
        [lbl_readBy.layer setBorderColor:[UIColor cyanColor].CGColor];
        [lbl_readBy.layer setBorderWidth:1.0f];
    }
 
    {
        [lbl_status .layer setBorderColor:[UIColor redColor].CGColor];
        [lbl_status.layer setBorderWidth:1.0f];
        lbl_status.backgroundColor=[UIColor yellowColor];
        
        
        [lbl_dileveredTo.layer setBorderColor:[UIColor redColor].CGColor];
        [lbl_dileveredTo.layer setBorderWidth:1.0f];
        lbl_dileveredTo.backgroundColor=[UIColor yellowColor];
    }

    {
        [_timeLB.layer setBorderColor:[UIColor yellowColor].CGColor];
        [_timeLB.layer setBorderWidth:1.0f];
        self.timeLB.backgroundColor  =[self randomColor];
    }
    
    

    {
        [_bubbleView.layer setBorderColor:[UIColor blackColor].CGColor];
        [_bubbleView.layer setBorderWidth:1.0f];
    }

    {
        
        [_attachmentImage.layer setBorderColor:[UIColor brownColor].CGColor];
        [_attachmentImage.layer setBorderWidth:1.0f];
    }
    
    
    
    
    
}
-(void)resetFramesWhenCellIsNotNil
{
    _attachmentImage.frame=CGRectZero;
    
    lbl_dileveredTo.frame =CGRectZero;
    lbl_status.frame =CGRectZero;
    _attachmentImage.frame = CGRectZero;
    _bubbleView.frame =CGRectZero;
    _timeLB.frame = CGRectZero;
    lbl_readBy.frame =CGRectZero;
    _infoButton.frame =CGRectZero;
    self.contentView.frame=CGRectZero;//
    self.imageView.frame=CGRectZero;
    self.lbl_messageContent.frame=CGRectZero;
    self.lbl_SubjectContent.frame=CGRectZero;
    self.detailTextLabel.frame=CGRectZero;
    self.frame=CGRectZero;
    
    self.imageView.image=nil;

    
    
}

#pragma mark  - Setters

- (void)setAuthorType:(BCAuthorType)type
{
    _authorType = type;
    
    
    [self updateFramesForAuthorType:_authorType];
}


- (void)setBubbleColor:(BCBubbleColor)color
{
    _bubbleColor = color;
    
    
    [self setImageForBubbleColor:_bubbleColor];
}







@end
