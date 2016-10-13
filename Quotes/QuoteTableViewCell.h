//
//  QuoteTableViewCell.h
//  Quotes
//
//  Created by Wil Pirino on 10/12/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuoteView.h"

@interface QuoteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *saidAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *saidByLabel;
@property (weak, nonatomic) IBOutlet UITextView *heardByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *saidByImageView;
@property (weak, nonatomic) IBOutlet QuoteView *quoteView;

@end
