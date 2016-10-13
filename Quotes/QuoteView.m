//
//  QuoteView.m
//  Quotes
//
//  Created by Wil Pirino on 10/10/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QuoteView.h"
#import "Contact.h"

@implementation QuoteView

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
    self.editable = NO;
}

-(void)setText:(NSString *)text {
    // attr string
    NSString *spacedText = [NSString stringWithFormat:@"  %@  ", text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:spacedText
                                                                                         attributes:
                                                   @{NSFontAttributeName: self.font,
                                                     NSForegroundColorAttributeName: self.textColor}];
    
    // insert left quote
    NSTextAttachment *leftQuoteAttachment = [[NSTextAttachment alloc] init];
    leftQuoteAttachment.image = [UIImage imageNamed:@"leftQuotions"];
    [attributedString insertAttributedString:[NSAttributedString attributedStringWithAttachment:leftQuoteAttachment] atIndex:0];
    
    // insert right quote
    NSTextAttachment *rightQuoteAttachment = [[NSTextAttachment alloc] init];
    rightQuoteAttachment.image = [UIImage imageNamed:@"rightQuotions"];
    [attributedString insertAttributedString:[NSAttributedString attributedStringWithAttachment:rightQuoteAttachment] atIndex:[attributedString length] - 1];
    
    // set text
    self.attributedText = attributedString;
}

// bubble up touch began
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[self superview] touchesBegan:touches withEvent:event];
}

@end
