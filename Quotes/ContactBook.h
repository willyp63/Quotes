//
//  ContactScan.h
//  Quotes
//
//  Created by Wil Pirino on 10/8/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface ContactBook : NSObject

+ (void)contactsWith:(NSString *)substring completionHandler:(void (^)(NSArray<Contact *> *contacts))completion;

@end
