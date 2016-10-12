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

+ (void)registerWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil postTo:@"http://murmuring-refuge-84679.herokuapp.com/auth/register" withBody:body authorized:NO completionHandler:completionHandler];
}

+ (void)loginWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil postTo:@"http://murmuring-refuge-84679.herokuapp.com/auth/login" withBody:body authorized:NO completionHandler:completionHandler];
}

@end
