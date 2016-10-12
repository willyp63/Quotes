//
//  AuthApiUtil.h
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthApiUtil : NSObject

+ (void)registerWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

+ (void)loginWithBody:(NSDictionary *)body completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

@end
