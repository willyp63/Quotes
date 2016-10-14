//
//  QuotesStore.h
//  Quotes
//
//  Created by Wil Pirino on 10/14/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Quote.h"

@interface QuotesStore : NSObject

- (void)clearCachedQueries;

- (void)fetchMyQuotesWithForceRequest:(BOOL)forceRequest completionHandler:(void (^)(NSArray<Quote *> *quotes, NSError *error))completionHandler;

- (void)fetchMyQuotesWithQuery:(NSString *)query forceRequest:(BOOL)forceRequest completionHandler:(void (^)(NSArray<Quote *> *quotes, NSError *error))completionHandler;

- (void)fetchMySaidQuotesWithForceRequest:(BOOL)forceRequest completionHandler:(void (^)(NSArray<Quote *> *quotes, NSError *error))completionHandler;

- (void)fetchMyHeardQuotesWithForceRequest:(BOOL)forceRequest completionHandler:(void (^)(NSArray<Quote *> *quotes, NSError *error))completionHandler;

@end
