//
//  SearchButton.m
//  Quotes
//
//  Created by Wil Pirino on 10/11/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "SearchButton.h"

@implementation SearchButton

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
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self setImage:[UIImage imageNamed:@"searchIcon"] forState:UIControlStateNormal];
    [self setTitle:@"" forState:UIControlStateNormal];
}

@end
