//
//  AboveKeyBoardView.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "AboveKeyBoardView.h"
#import "constants.h"

static CGFloat const CHAR_COUNT_WIDTH = 100.0f;
static CGFloat const BUTTON_WIDTH = 150.0f;
static NSString *const BUTTON_TITLE = @"Quote It";

@implementation AboveKeyBoardView

- (id)initWithFrame:(CGRect)frame buttonAction:(SEL)buttonAction target:(id)target {
    self = [super initWithFrame:frame];
    if (self) {
        // char count
        self.charCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CHAR_COUNT_WIDTH, frame.size.height)];
        self.charCount.text = [NSString stringWithFormat:@"%d", CHARACTER_LIMIT];
        self.charCount.textAlignment = NSTextAlignmentCenter;
        self.charCount.textColor = [UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0];
        [self addSubview:self.charCount];
        
        // quote it button
        self.quoteItButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.quoteItButton addTarget:target action:buttonAction forControlEvents:UIControlEventTouchUpInside];
        [self.quoteItButton setTitle:BUTTON_TITLE forState:UIControlStateNormal];
        [self.quoteItButton setTitleColor:[UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0] forState:UIControlStateNormal];
        self.quoteItButton.titleLabel.font = [UIFont fontWithName:MAIN_FONT size:24.0f];
        self.quoteItButton.frame = CGRectMake(frame.size.width - BUTTON_WIDTH, 0, BUTTON_WIDTH, frame.size.height);
        [self addSubview:self.quoteItButton];
    }
    return self;
}

@end
