//
//  SearchView.m
//  Quotes
//
//  Created by Wil Pirino on 10/13/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "SearchView.h"
#import "constants.h"

static CGFloat const HORIZONTAL_PADDING = 8.0f;
static CGFloat const VERTICAL_PADDING = 2.0f;

static CGFloat const CANCEL_BUTTON_WIDTH = 65.0f;
static CGFloat const CLEAR_TEXT_BUTTON_PADDING = 8.0f;

@interface SearchView ()

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *clearTextButton;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation SearchView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customSetup];
    }
    return self;
}

-(void)customSetup {
    self.text = @"";
    
    // Create TextField
    CGFloat myHeightMinusPadding = self.bounds.size.height - (VERTICAL_PADDING * 2);
    CGRect textFieldRect = CGRectMake(HORIZONTAL_PADDING,
                                      VERTICAL_PADDING,
                                      self.bounds.size.width - myHeightMinusPadding - CANCEL_BUTTON_WIDTH - (HORIZONTAL_PADDING * 4),
                                      myHeightMinusPadding);
    self.textField = [[UITextField alloc] initWithFrame:textFieldRect];
    self.textField.delegate = self;
    
    // Create ClearTextButton
    CGRect clearTextButtonRect = CGRectMake(self.textField.frame.size.width + (HORIZONTAL_PADDING * 2) + CLEAR_TEXT_BUTTON_PADDING,
                                      VERTICAL_PADDING + CLEAR_TEXT_BUTTON_PADDING,
                                      myHeightMinusPadding - (CLEAR_TEXT_BUTTON_PADDING * 2),
                                      myHeightMinusPadding - (CLEAR_TEXT_BUTTON_PADDING * 2));
    self.clearTextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.clearTextButton.frame = clearTextButtonRect;
    self.clearTextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.clearTextButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.clearTextButton setImage:[UIImage imageNamed:@"xIcon"] forState:UIControlStateNormal];
    [self.clearTextButton setTintColor:[UIColor blackColor]];
    [self.clearTextButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create Cancel Button
    CGRect cancelButtonRect = CGRectMake(self.clearTextButton.frame.origin.x + myHeightMinusPadding + HORIZONTAL_PADDING - CLEAR_TEXT_BUTTON_PADDING,
                                        VERTICAL_PADDING,
                                        CANCEL_BUTTON_WIDTH,
                                        myHeightMinusPadding);
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelButton.frame = cancelButtonRect;
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0f] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:MAIN_FONT size:18.0f];
    [self.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    // add subviews
    [self addSubview:self.textField];
    [self addSubview:self.clearTextButton];
    [self addSubview:self.cancelButton];
    
    // pull up keyboard
    [self.textField becomeFirstResponder];
}

-(void)clearText:(UIButton *)sender {
    self.textField.text = @"";
    
    // notify delegate
    [self.delegate searchView:self didChangeTextTo:@""];
}

-(void)cancel:(UIButton *)sender {
    self.textField.text = @"";
    
    // notify delegate
    [self.delegate searchView:self didCancelWithText:self.text];
}

#pragma mark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // get new new text after update
    NSString *newText = [NSString stringWithString:self.textField.text];
    newText = [newText stringByReplacingCharactersInRange:range withString:string];
    
    // notify delegate
    [self.delegate searchView:self didChangeTextTo:newText];
    
    return YES;
}

@end
