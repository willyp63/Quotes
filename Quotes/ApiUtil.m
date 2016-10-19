//
//  ApiUtil.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "ApiUtil.h"
#import "A0SimpleKeychain.h"
#import "constants.h"

@implementation ApiUtil

+ (NSData *)jsonDataWithDictionary:(NSDictionary *)dict {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (void)postTo:(NSString *)urlString withBody:(NSDictionary *)body authorized:(BOOL)authorized completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler{
    
    // format request
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (authorized) {
        // set Auth header
        NSString *token = [[A0SimpleKeychain keychain] stringForKey:JWT_KEY];
        if (!token) {
            token = [[NSUserDefaults standardUserDefaults] objectForKey:JWT_KEY];
        }
        sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type": @"application/json",
                                                       @"Accept": @"application/json",
                                                       @"Authorization": [NSString stringWithFormat:@"Token %@", token]};
    } else {
        sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type": @"application/json",
                                                       @"Accept": @"application/json"};
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // format body
    if (body) {
        NSData *requestData = [self jsonDataWithDictionary:body];
        request.HTTPBody = requestData;
    }
    
    // make request
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            // check for error code
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode != 200) {
                completionHandler(jsonData, response, [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil]);
            } else {
                completionHandler(jsonData, response, error);
            }
        } else {
            completionHandler(@{}, response, error);
        }
    }];
    [postDataTask resume];
}

+ (void)getFrom:(NSString *)urlString withAuthorized:(BOOL)authorized completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler {
    
    // format request
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (authorized) {
        // set Auth header
        NSString *token = [[A0SimpleKeychain keychain] stringForKey:JWT_KEY];
        if (!token) {
            token = [[NSUserDefaults standardUserDefaults] objectForKey:JWT_KEY];
        }
        sessionConfiguration.HTTPAdditionalHeaders = @{@"Accept": @"application/json",
                                                       @"Authorization": [NSString stringWithFormat:@"Token %@", token]};
    } else {
        sessionConfiguration.HTTPAdditionalHeaders = @{@"Accept": @"application/json"};
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    // make request
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            // check for error code
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode != 200) {
                completionHandler(jsonData, response, [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil]);
            } else {
                completionHandler(jsonData, response, error);
            }
        } else {
            completionHandler(@{}, response, error);
        }
    }];
    [getDataTask resume];
}

@end
