//
//  AboveKeyBoardView.h
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboveKeyBoardView : UIView

@property (strong, nonatomic) UILabel *charCount;
@property (strong, nonatomic) UIButton *quoteItButton;

- (id)initWithFrame:(CGRect)frame buttonAction:(SEL)buttonAction target:(id)target;

@end
