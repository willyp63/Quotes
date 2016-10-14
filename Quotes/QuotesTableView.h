//
//  QuotesTableView.h
//  Quotes
//
//  Created by Wil Pirino on 10/14/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quote.h"

@interface QuotesTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL showingLoader;

@property (strong, nonatomic) NSArray<Quote *> *quotes;

@end
