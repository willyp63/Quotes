//
//  FeedViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "FeedViewController.h"
#import "SearchButton.h"

static CGFloat const ANIMATION_TIME = 0.5f;
static CGFloat const UI_PADDING = 20.0f;
static CGFloat const SEARCH_VIEW_HEIGHT = 40.0f;

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet SearchButton *searchButton;

@property (strong, nonatomic) UIView *searchView;
@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UIButton *cancelSearchButton;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)showSearchField:(id)sender {
    [self slideTitleViewLeft];
    [self animateInSearchView];
}

- (void)animateInSearchView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat searchButtonWidth = self.searchButton.frame.size.width;
    
    CGRect startAnimationFrame = CGRectMake(screenWidth + UI_PADDING, statusBarHeight, screenWidth - searchButtonWidth - (UI_PADDING * 2), SEARCH_VIEW_HEIGHT);
    CGRect endAnimationFrame = CGRectMake(searchButtonWidth + UI_PADDING, statusBarHeight, startAnimationFrame.size.width, SEARCH_VIEW_HEIGHT);
    
    self.searchView = [[UIView alloc] initWithFrame:startAnimationFrame];
    self.searchView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.searchView];
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.searchView.frame = endAnimationFrame;
    }completion:^(BOOL finished){
        
    }];
}

- (void)slideTitleViewLeft {
    CGRect currFrame = self.titleView.frame;
    CGFloat searchButtonWidth = self.searchButton.frame.size.width;
    CGRect endAnimationFrame = CGRectMake(UI_PADDING + searchButtonWidth - currFrame.size.width, currFrame.origin.y, currFrame.size.width, currFrame.size.height);
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.titleView.frame = endAnimationFrame;
    }completion:^(BOOL finished){
        
    }];
}

@end
