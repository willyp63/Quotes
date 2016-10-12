//
//  QTSButton.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QTSButton.h"
#import "constants.h"

@implementation QTSButton

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
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [[UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0] CGColor];
}

@end
