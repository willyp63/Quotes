//
//  ApiUtil.h
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiUtil : NSObject

+ (void)postTo:(NSString *)urlString withBody:(NSDictionary *)body authorized:(BOOL)authorized completionHandler:(void (^)(NSDictionary *jsonData, NSURLResponse *response, NSError *error))completionHandler;

@end
