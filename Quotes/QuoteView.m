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
    self.attributedText = [QuoteView attributedTextWithText:text font:self.font color:self.textColor];
}

+ (NSAttributedString *)attributedTextWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    // attr string
    NSString *spacedText = [NSString stringWithFormat:@"  %@  ", text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:spacedText
                                                                                         attributes:
                                                   @{NSFontAttributeName: font, NSForegroundColorAttributeName: color}];
    
    // insert left quote
    NSTextAttachment *leftQuoteAttachment = [[NSTextAttachment alloc] init];
    leftQuoteAttachment.image = [UIImage imageNamed:@"leftQuotions"];
    [attributedString insertAttributedString:[NSAttributedString attributedStringWithAttachment:leftQuoteAttachment] atIndex:0];
    
    // insert right quote
    NSTextAttachment *rightQuoteAttachment = [[NSTextAttachment alloc] init];
    rightQuoteAttachment.image = [UIImage imageNamed:@"rightQuotions"];
    [attributedString insertAttributedString:[NSAttributedString attributedStringWithAttachment:rightQuoteAttachment] atIndex:[attributedString length] - 1];
    
    return attributedString;
}

+ (CGFloat)heightOfText:(NSString *)text withFont:(UIFont *)font width:(CGFloat)width {
    NSAttributedString *attrText = [QuoteView attributedTextWithText:text font:font color:[UIColor blackColor]];
    
    CGRect quoteRect = [attrText boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    return quoteRect.size.height;
}

// bubble up touch began
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[self superview] touchesBegan:touches withEvent:event];
}

@end
