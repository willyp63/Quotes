//
//  QuoteView.h
//  Quotes
//
//  Created by Wil Pirino on 10/10/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuoteView : UITextView

+ (CGFloat)heightOfText:(NSString *)text withFont:(UIFont *)font width:(CGFloat)width;

@end
