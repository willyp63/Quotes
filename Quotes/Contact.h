//
//  Contact.h
//  Quotes
//
//  Created by Wil Pirino on 10/10/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

@interface Contact : NSObject

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSData *imageData;

-(id)initWithCNContact:(CNContact *)contact;
-(id)initWithPhoneNumber:(NSString *)phoneNumber fullName:(NSString *)fullName imageData:(NSData *)imageData;

@end
