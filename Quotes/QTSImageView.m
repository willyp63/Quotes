//
//  QTSImageView.m
//  Quotes
//
//  Created by Wil Pirino on 10/10/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QTSImageView.h"

@implementation QTSImageView

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
    self.layer.cornerRadius = self.frame.size.height / 2.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

@end
