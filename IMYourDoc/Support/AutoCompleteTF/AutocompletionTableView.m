//
//  AutocompletionTableView.m
//
//  Created by Gushin Arseniy on 11.03.12.
//  Copyright (c) 2012 Arseniy Gushin. All rights reserved.
//


#import "AutocompletionTableView.h"


@interface AutocompletionTableView () 


@property (nonatomic, strong) NSArray *suggestionOptions; // of selected NSStrings
@property (nonatomic, strong) UITextField *textField; // will set automatically as user enters text
@property (nonatomic, strong) UIFont *cellLabelFont; // will copy style from assigned textfield


@end


@implementation AutocompletionTableView


@synthesize suggestionsDictionary = _suggestionsDictionary;
@synthesize suggestionOptions = _suggestionOptions;
@synthesize textField = _textField;
@synthesize cellLabelFont = _cellLabelFont;
@synthesize options = _options;


#pragma mark - Initialization

- (UITableView *)initWithTextField:(UITextField *)textField andFrame:(CGRect)tfFrame inViewController:(UIViewController *) parentViewController withOptions:(NSDictionary *)options
{
    //set the options first
    self.options = options;
    
    
    // frame must align to the textfield
    CGRect frame = CGRectMake(10, tfFrame.origin.y + tfFrame.size.height, ([[UIScreen mainScreen] bounds].size.width - 20), 90);
    
	
    // save the font info to reuse in cells
    self.cellLabelFont = textField.font;
    
    
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    
    self.delegate = self;
    
	self.dataSource = self;
    
	self.scrollEnabled = YES;
    
    // turn off standard correction
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // to get rid of "extra empty cell" on the bottom
    // when there's only one cell in the table
    
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, 0, ([[UIScreen mainScreen] bounds].size.width - 20), 1)];
	
	v.backgroundColor = [UIColor clearColor];
    
	[self setTableFooterView:v];
	
	self.hidden = YES;
    
	[parentViewController.view addSubview:self];
	
    return self;
}


#pragma mark - Logic staff

- (BOOL) substringIsInDictionary:(NSString *)subString
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    
	NSRange range;
    
    if (_autoCompleteDelegate && [_autoCompleteDelegate respondsToSelector:@selector(autoCompletion:suggestionsFor:)])
	{
        self.suggestionsDictionary = [_autoCompleteDelegate autoCompletion:self suggestionsFor:subString];
    }
    
    for (NSString *tmpString in self.suggestionsDictionary)
    {
        // Suggestions dictionary seems to contain a null string. Boolean logic modified accordingly
        if (tmpString != (id)[NSNull null])
        {
            range = ([[self.options valueForKey:ACOCaseSensitive] isEqualToNumber:[NSNumber numberWithInt:1]]) ? [tmpString rangeOfString:subString] : [tmpString rangeOfString:subString options:NSCaseInsensitiveSearch];
            
            if (range.location != NSNotFound) [tmpArray addObject:tmpString];
            
        }
    }
    
    if ([tmpArray count] > 0)
    {
        self.suggestionOptions = tmpArray;
        
		return YES;
    }
	
    return NO;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestionOptions.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 30;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
	
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    if ([self.options valueForKey:ACOUseSourceFont]) 
    {
        cell.textLabel.font = [self.options valueForKey:ACOUseSourceFont];
    }
	
	else
    {
        cell.textLabel.font = self.cellLabelFont;
    }
	
    cell.textLabel.adjustsFontSizeToFitWidth = NO;
	
    cell.textLabel.text = [self.suggestionOptions objectAtIndex:indexPath.row];

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textField setText:[self.suggestionOptions objectAtIndex:indexPath.row]];
    
    if (_autoCompleteDelegate && [_autoCompleteDelegate respondsToSelector:@selector(autoCompletion:didSelectAutoCompleteSuggestionWithIndex:)])
	{
        [_autoCompleteDelegate autoCompletion:self didSelectAutoCompleteSuggestionWithIndex:indexPath.row];
    }
    
    [self hideOptionsView];
}


#pragma mark - UITextField delegate

- (void)textFieldValueChanged:(UITextField *)textField
{
    self.textField = textField;
    
    
    CGRect frame = [[textField.window.subviews objectAtIndex:0] convertRect:textField.frame fromView:textField.superview];
    
    self.frame = CGRectMake(10, frame.origin.y + frame.size.height, ([[UIScreen mainScreen] bounds].size.width - 20), 90);
    
    
	NSString *curString = textField.text;
    
    if (![curString length])
    {
        [self hideOptionsView];
        
		return;
    }
	
	else if ([self substringIsInDictionary:curString])
	{
		[self showOptionsView];
		
		[self reloadData];
	}
	
	else
		[self hideOptionsView];
}


#pragma mark - Options view control

- (void)showOptionsView
{
    self.hidden = NO;
}


- (void) hideOptionsView
{
    self.hidden = YES;
}


@end
