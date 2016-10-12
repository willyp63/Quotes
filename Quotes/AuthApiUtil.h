//
//  AuthApiUtil.h
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthApiUtil : NSObject

+ (void)registerWithParams:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

+ (void)loginWithParams:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

+ (void)logoutWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

+ (void)refreshWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

@end
