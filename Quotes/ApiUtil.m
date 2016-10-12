//
//  ApiUtil.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "ApiUtil.h"
#import "A0SimpleKeychain.h"

@implementation ApiUtil

+ (NSData *)jsonDataWithDictionary:(NSDictionary *)dict {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (void)postTo:(NSString *)urlString withParams:(NSDictionary *)params authorized:(BOOL)authorized completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler{
    
    // format request
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (authorized) {
        // set Auth header
        NSString *token = [[A0SimpleKeychain keychain] stringForKey:@"user-jwt"];
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
    if (params) {
        NSData *requestData = [self jsonDataWithDictionary:params];
        request.HTTPBody = requestData;
    }
    
    // make request
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            completionHandler(jsonData, response, error);
        } else {
            completionHandler(nil, response, error);
        }
    }];
    [postDataTask resume];
}

@end
