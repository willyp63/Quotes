//
//  QuotesApiUtil.m
//  Quotes
//
//  Created by Wil Pirino on 10/11/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QuotesApiUtil.h"
#import "ApiUtil.h"

@implementation QuotesApiUtil

+ (void)postQuoteWithParams:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler{
    
    [ApiUtil postTo:@"http://murmuring-refuge-84679.herokuapp.com/quotes" withParams:params authorized:YES completionHandler:completionHandler];
}

@end
