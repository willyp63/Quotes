//
//  QuotesApiUtil.m
//  Quotes
//
//  Created by Wil Pirino on 10/11/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QuotesApiUtil.h"
#import "ApiUtil.h"
#import "constants.h"

@implementation QuotesApiUtil

+ (void)postQuoteWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler{
    
    [ApiUtil postTo:[NSString stringWithFormat:@"%@/quotes", BASE_API_URL] withBody:body authorized:YES completionHandler:completionHandler];
}

+ (void)getMyQuotesWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil getFrom:[NSString stringWithFormat:@"%@/quotes/me", BASE_API_URL] withAuthorized:YES completionHandler:completionHandler];
}

+ (void)getMySaidQuotesWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil getFrom:[NSString stringWithFormat:@"%@/quotes/me/said", BASE_API_URL] withAuthorized:YES completionHandler:completionHandler];
}

+ (void)getMyHeardQuotesWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil getFrom:[NSString stringWithFormat:@"%@/quotes/me/heard", BASE_API_URL] withAuthorized:YES completionHandler:completionHandler];
}

@end
