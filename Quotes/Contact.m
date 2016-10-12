//
//  Contact.m
//  Quotes
//
//  Created by Wil Pirino on 10/10/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "Contact.h"

@implementation Contact

-(id)initWithCNContact:(CNContact *)contact {
    self = [super init];
    if (self) {
        // get name
        _firstName = contact.givenName;
        _lastName = contact.familyName;
        _fullName = [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
        
        // remove trailing space if no last name
        _fullName = [_fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // get phone number (take first one)
        NSArray *numbers = [contact.phoneNumbers valueForKey:@"value"];
        _phoneNumber = [numbers count] == 0 ? @"none" : [numbers[0] stringValue];
        
        // get image data (thumbnail)
        _imageData = contact.thumbnailImageData;
    }
    return self;
}

-(id)initWithPhoneNumber:(NSString *)phoneNumber firstName:(NSString *)firstName lastName:(NSString *)lastName imageData:(NSData *)imageData {
    self = [super init];
    if (self) {
        _firstName = firstName;
        _lastName = lastName;
        _fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        _phoneNumber = phoneNumber;
        _imageData = imageData;
    }
    return self;
}

-(NSDictionary *)dictionaryValue {
    return [NSDictionary dictionaryWithObjectsAndKeys:_firstName, @"firstName", _lastName, @"lastName", _phoneNumber, @"phoneNumber", nil];
}


@end
