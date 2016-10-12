//
//  AuthApiUtil.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "AuthApiUtil.h"
#import "ApiUtil.h"
#import "constants.h"

@implementation AuthApiUtil

+ (void)registerWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil postTo:[NSString stringWithFormat:@"%@/auth/register", BASE_API_URL] withBody:body authorized:NO completionHandler:completionHandler];
}

+ (void)loginWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    [ApiUtil postTo:[NSString stringWithFormat:@"%@/auth/login", BASE_API_URL] withBody:body authorized:NO completionHandler:completionHandler];
}

@end
