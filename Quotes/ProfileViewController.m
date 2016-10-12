//
//  ProfileViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "ProfileViewController.h"
#import "A0SimpleKeychain.h"
#import "AuthApiUtil.h"
#import "QTSImageView.h"
#import "constants.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet QTSImageView *profileImage;

@property (weak, nonatomic) IBOutlet UITabBar *feedTabs;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // config saidBy/heardBy tabs
    self.feedTabs.tintColor = [UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0];
    self.feedTabs.selectedItem = self.feedTabs.items[0];
    for (UITabBarItem *item in self.feedTabs.items) {
        [item setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:MAIN_FONT size:18.0f]} forState:UIControlStateNormal];
        [item setTitlePositionAdjustment:UIOffsetMake(0, -12)];
    }
    
    // set name label from user defaults
    NSString *firstName = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_NAME_KEY];
    NSString *lastName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_NAME_KEY];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    // load profile image
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [[NSUserDefaults standardUserDefaults] objectForKey:PHONE_NUMBER_KEY]];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    if (imagePath) {
        self.profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    }
}

- (IBAction)logout:(id)sender {
    // remove token from keychain
    [[A0SimpleKeychain keychain] setString:@"" forKey:JWT_KEY];
    
    [self performSegueWithIdentifier:@"logout" sender:self];
}

@end
