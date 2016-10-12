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

+ (void)postQuoteWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler{
    
    [ApiUtil postTo:@"http://murmuring-refuge-84679.herokuapp.com/quotes" withBody:body authorized:YES completionHandler:completionHandler];
}

@end
