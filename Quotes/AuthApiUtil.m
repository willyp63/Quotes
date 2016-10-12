//
//  AuthApiUtil.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "AuthApiUtil.h"
#import "ApiUtil.h"

@implementation AuthApiUtil

+ (void)registerWithParams:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil postTo:@"http://murmuring-refuge-84679.herokuapp.com/auth/register" withParams:params authorized:NO completionHandler:completionHandler];
}

+ (void)loginWithParams:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil postTo:@"http://murmuring-refuge-84679.herokuapp.com/auth/login" withParams:params authorized:NO completionHandler:completionHandler];
}

+ (void)logoutWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    [ApiUtil postTo:@"http://murmuring-refuge-84679.herokuapp.com/auth/logout" withParams:nil authorized:YES completionHandler:completionHandler];
}

+ (void)refreshWithCompletionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    [ApiUtil postTo:@"http://murmuring-refuge-84679.herokuapp.com/auth/refresh" withParams:nil authorized:YES completionHandler:completionHandler];
}

@end
