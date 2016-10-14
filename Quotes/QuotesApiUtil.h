//
//  QuotesApiUtil.h
//  Quotes
//
//  Created by Wil Pirino on 10/11/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuotesApiUtil : NSObject

+ (void)postQuoteWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

+ (void)getMyQuotesWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

+ (void)getMySaidQuotesWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

+ (void)getMyHeardQuotesWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

+ (void)getMyQuotesWithQuery:(NSString *)query completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

@end
