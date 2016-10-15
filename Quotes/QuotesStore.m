//
//  QuotesStore.m
//  Quotes
//
//  Created by Wil Pirino on 10/14/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QuotesStore.h"
#import "QuotesApiUtil.h"

@interface QuotesStore ()

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSArray<Quote *> *> *myQuotes;
@property (strong, nonatomic) NSArray<Quote *> *mySaidQuotes;
@property (strong, nonatomic) NSArray<Quote *> *myHeardQuotes;

@end

@implementation QuotesStore

- (id)init {
    self = [super init];
    if (self) {
        self.myQuotes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)clearCachedQueries {
    // save entry in dictionary that holds all the users quotes
    NSArray<Quote *> *allMyQuotes = [self.myQuotes objectForKey:@""];
    if (allMyQuotes) {
        self.myQuotes = [NSMutableDictionary dictionaryWithObjectsAndKeys:allMyQuotes, @"", nil];
    } else {
        self.myQuotes = [NSMutableDictionary dictionary];
    }
}

- (void)fetchMyQuotesWithForceRequest:(BOOL)forceRequest completionHandler:(void (^)(NSArray<Quote *> *quotes, NSError *error))completionHandler {
    NSArray<Quote *> *quotesInStore = [self.myQuotes objectForKey:@""];
    if (!quotesInStore || forceRequest) {
        // make api request
        [QuotesApiUtil getMyQuotesWithCompletionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
            if (!error) {
                [self.myQuotes setObject:[self formatQuotesResponseWithJSONData:jsonData] forKey:@""];
                completionHandler([self.myQuotes objectForKey:@""], nil);
            } else {
                completionHandler(nil, error);
            }
        }];
    } else {
        // return quotes in store
        completionHandler(quotesInStore, nil);
    }
}

- (void)fetchMyQuotesWithQuery:(NSString *)query forceRequest:(BOOL)forceRequest completionHandler:(void (^)(NSArray<Quote *> *quotes, NSError *error))completionHandler {
    
    NSArray<Quote *> *quotesInStore = [self.myQuotes objectForKey:query];
    if (!quotesInStore || forceRequest) {
        // make api request
        [QuotesApiUtil getMyQuotesWithQuery:query completionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
            if (!error) {
                [self.myQuotes setObject:[self formatQuotesResponseWithJSONData:jsonData] forKey:query];
                completionHandler([self.myQuotes objectForKey:query], nil);
            } else {
                completionHandler(nil, error);
            }
        }];
    } else {
        // return quotes in store
        completionHandler(quotesInStore, nil);
    }
}

- (void)fetchMySaidQuotesWithForceRequest:(BOOL)forceRequest completionHandler:(void (^)(NSArray<Quote *> *quotes, NSError *error))completionHandler{
    
    if (!self.mySaidQuotes || forceRequest) {
        // make api request
        [QuotesApiUtil getMySaidQuotesWithCompletionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
            if (!error) {
                self.mySaidQuotes = [self formatQuotesResponseWithJSONData:jsonData];
                completionHandler(self.mySaidQuotes, nil);
            } else {
                completionHandler(nil, error);
            }
        }];
    } else {
        // return quotes in store
        completionHandler(self.mySaidQuotes, nil);
    }
}

- (void)fetchMyHeardQuotesWithForceRequest:(BOOL)forceRequest completionHandler:(void (^)(NSArray<Quote *> *quotes, NSError *error))completionHandler{
    
    if (!self.myHeardQuotes || forceRequest) {
        // make api request
        [QuotesApiUtil getMyHeardQuotesWithCompletionHandler:^(NSDictionary *jsonData, NSURLResponse *response, NSError *error) {
            if (!error) {
                self.myHeardQuotes = [self formatQuotesResponseWithJSONData:jsonData];
                completionHandler(self.myHeardQuotes, nil);
            } else {
                completionHandler(nil, error);
            }
        }];
    } else {
        // return quotes in store
        completionHandler(self.myHeardQuotes, nil);
    }
}

- (NSArray<Quote *> *)formatQuotesResponseWithJSONData:(NSDictionary *)jsonData {
    NSArray *quotesData = [jsonData objectForKey:@"quotes"];
    NSMutableArray *quotes = [NSMutableArray arrayWithCapacity:quotesData.count];
    for (NSDictionary *quoteDict in quotesData) {
        [quotes addObject:[[Quote alloc] initWithDictionary:quoteDict]];
    }
    return quotes;
}

@end
