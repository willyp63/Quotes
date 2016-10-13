//
//  Quote.h
//  Quotes
//
//  Created by Wil Pirino on 10/12/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface Quote : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *saidAt;
@property (strong, nonatomic) Contact *saidBy;
@property (strong, nonatomic) NSArray<Contact *> *heardBy;

- (NSString *)heardByFullNameList;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
