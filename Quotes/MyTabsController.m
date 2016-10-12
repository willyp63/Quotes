//
//  MyTabsViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "MyTabsController.h"

@interface MyTabsController ()

@end

@implementation MyTabsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // move bar icons up
    for(UITabBarItem * tabBarItem in self.tabBar.items){
        tabBarItem.title = @"";
        tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(nonnull UITabBarItem *)item {
    _prevSelectedIndex = self.selectedIndex;
}

@end
