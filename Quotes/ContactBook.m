//
//  ContactScan.m
//  Quotes
//
//  Created by Wil Pirino on 10/8/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "ContactBook.h"
#import <Contacts/Contacts.h>
#import "constants.h"

@implementation ContactBook

+ (void)contactsWith:(NSString *)substring completionHandler:(void (^)(NSArray<Contact *> *contacts))completion {
    // check for compatibility (iOS9 or later)
    if ([CNContactStore class]) {
        CNEntityType entityType = CNEntityTypeContacts;
        
        // check if authorized
        if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined) {
            CNContactStore * contactStore = [[CNContactStore alloc] init];
            
            // request authorization
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(granted){
                    completion([self getContactsWith:substring]);
                } else {
                    completion(@[]);
                }
            }];
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized) {
            // already authorized
            completion([self getContactsWith:substring]);
        } else {
            // user said no :(
            completion(@[]);
        }
    } else {
        // TODO allow for backward compatibility
        completion(@[]);
    }
}

+ (NSArray<Contact *> *)getContactsWith:(NSString *)substring {
    // gather contacts that match substring query
    CNContactStore *addressBook = [[CNContactStore alloc] init];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingName:substring];
    NSArray *keysToFetch = @[CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactThumbnailImageDataKey];
    NSArray<CNContact *> *contacts = [addressBook unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:nil];
    
    // map CNContacts to Contacts
    NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[contacts count]];
    for (CNContact *contact in contacts) {
        Contact *myContact = [[Contact alloc] initWithCNContact:contact];
        [mapped addObject:myContact];
    }
    
    // add user contact
    NSString *firstName = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_NAME_KEY];
    NSString *lastName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_NAME_KEY];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    //check for match
    if ([[fullName lowercaseString] containsString:[substring lowercaseString]]) {
        // get phone
        NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:PHONE_NUMBER_KEY];
        
        // load user image
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [[NSUserDefaults standardUserDefaults] objectForKey:PHONE_NUMBER_KEY]];
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        
        // ad to list
        Contact *userContact = [[Contact alloc] initWithPhoneNumber:phoneNumber firstName:firstName lastName:lastName imageData:imageData];
        [mapped insertObject:userContact atIndex:0];
    }
    
    return mapped;
}

@end
