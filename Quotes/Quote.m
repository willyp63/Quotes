//
//  Quote.m
//  Quotes
//
//  Created by Wil Pirino on 10/12/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "Quote.h"

@implementation Quote

-(id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _text = [dictionary objectForKey:@"text"];
        _saidAt = [dictionary objectForKey:@"saidAt"];
        
        NSDictionary *saidByDict = [dictionary objectForKey:@"saidBy"];
        _saidBy = [[Contact alloc] initWithPhoneNumber:[saidByDict objectForKey:@"phoneNumber"]
                                             firstName:[saidByDict objectForKey:@"firstName"]
                                              lastName:[saidByDict objectForKey:@"lastName"]
                                             imageData:[NSData data]];
        
        NSMutableArray<Contact *> *heardBy = [NSMutableArray arrayWithCapacity:[[dictionary objectForKey:@"heardBy"] count]];
        for (NSDictionary *heardByDict in [dictionary objectForKey:@"heardBy"]) {
            [heardBy addObject:[[Contact alloc] initWithPhoneNumber:[heardByDict objectForKey:@"phoneNumber"]
                                                          firstName:[heardByDict objectForKey:@"firstName"]
                                                           lastName:[heardByDict objectForKey:@"lastName"]
                                                          imageData:[NSData data]]];
        }
        _heardBy = heardBy;
    }
    return  self;
}

- (NSString *)heardByFullNameList {
    NSString *list = @"";
    for (int i = 0; i < self.heardBy.count; i++) {
        if (i == self.heardBy.count - 1) {
            list = [list stringByAppendingString:self.heardBy[i].fullName];
        } else {
            list = [list stringByAppendingString:[NSString stringWithFormat:@"%@, ", self.heardBy[i].fullName ]];
        }
    }
    return list;
}

@end
