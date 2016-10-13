//
//  QuoteTableViewCell.m
//  Quotes
//
//  Created by Wil Pirino on 10/12/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QuoteTableViewCell.h"
#import "QuoteView.h"

@implementation QuoteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
