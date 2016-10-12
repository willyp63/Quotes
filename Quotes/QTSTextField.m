//
//  QTSTextField.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QTSTextField.h"
#import "constants.h"

static CGFloat const FIELD_HIEGHT = 45.0f;

@implementation QTSTextField

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
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, FIELD_HIEGHT);
    self.borderStyle = UITextBorderStyleNone;
    self.layer.cornerRadius = 0.0f;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.font = [UIFont fontWithName:MAIN_FONT_NON_BOLD size:18.0f];
    
    // add left padding unless text is centerd
    if (self.textAlignment != NSTextAlignmentCenter) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, FIELD_HIEGHT)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
}

@end
