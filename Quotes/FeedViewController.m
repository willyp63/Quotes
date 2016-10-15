//
//  FeedViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "FeedViewController.h"
#import "Quote.h"
#import "constants.h"
#import "QuoteView.h"
#import "QuotesTableView.h"
#import "QuotesStore.h"

static CGFloat const ANIMATION_TIME = 0.5f;
static CGFloat const UI_PADDING = 20.0f;
static CGFloat const SEARCH_VIEW_HEIGHT = 40.0f;

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) SearchView *searchView;
@property (nonatomic) CGRect titleViewInitialFrame;
@property (nonatomic) CGRect searchViewInitialFrame;

@property (weak, nonatomic) IBOutlet QuotesTableView *quotesTableView;
@property (strong, nonatomic) QuotesStore *quotesStore;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create store
    self.quotesStore = [[QuotesStore alloc] init];
    
    // strech image in search button
    self.searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.searchButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    // give quotes table a top border
    UIView *topBorderView = [[UIView alloc] initWithFrame:CGRectMake(self.quotesTableView.frame.origin.x,
                                                                     self.quotesTableView.frame.origin.y,
                                                                     self.quotesTableView.frame.size.width,
                                                                     0.5f)];
    topBorderView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:topBorderView];
    self.quotesTableView.frame = CGRectMake(self.quotesTableView.frame.origin.x,
                                            self.quotesTableView.frame.origin.y + 0.5f,
                                            self.quotesTableView.frame.size.width,
                                            self.quotesTableView.frame.size.height - 0.5f);
}

- (void)viewWillAppear:(BOOL)animated {
    // refresh table
    [self fetchQuotesWithForceRequest:YES];
}

- (IBAction)showSearchField:(id)sender {
    [self animateInSearchView];
}

- (void)animateInSearchView {
    // Make Search Button Inactive
    [self.searchButton setUserInteractionEnabled:NO];
    
    // Slide Title View Left
    CGRect currFrame = self.titleView.frame;
    CGFloat searchButtonWidth = self.searchButton.frame.size.width;
    self.titleViewInitialFrame = self.titleView.frame;
    CGRect endAnimationFrame = CGRectMake(UI_PADDING + searchButtonWidth - currFrame.size.width, currFrame.origin.y, currFrame.size.width, currFrame.size.height);
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.titleView.frame = endAnimationFrame;
    }completion:nil];
    
    
    // Create, add, and Animate in Search View
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.searchViewInitialFrame = CGRectMake(screenWidth + UI_PADDING, statusBarHeight, screenWidth - searchButtonWidth - (UI_PADDING * 2), SEARCH_VIEW_HEIGHT);
    endAnimationFrame = CGRectMake(searchButtonWidth + UI_PADDING, statusBarHeight, self.searchViewInitialFrame.size.width, SEARCH_VIEW_HEIGHT);
    
    self.searchView = [[SearchView alloc] initWithFrame:self.searchViewInitialFrame];
    self.searchView.delegate = self; // make self delegate
    
    [self.view addSubview:self.searchView];
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.searchView.frame = endAnimationFrame;
    }completion:nil];
}

- (void)animateOutSearchView {
    // Dismiss Keyboard
    [self.view endEditing:YES];
    
    // Slide Title View Right
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.titleView.frame = self.titleViewInitialFrame;
    }completion:nil];
    
    
    // Animate out Search View and then remove
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.searchView.frame = self.searchViewInitialFrame;
    }completion:^(BOOL finished){
        // remove search view
        [self.searchView removeFromSuperview];
        self.searchView = nil;
        
        // Make Search Button Active
        [self.searchButton setUserInteractionEnabled:YES];
    }];
}

#pragma mark SearchViewDelegate
- (void)searchView:(id)searchView didCancelWithText:(NSString *)text {
    [self animateOutSearchView];
    
    // clear cached queries to avoid using up too much memory
    [self.quotesStore clearCachedQueries];
    
    // fetch all quotes
    [self fetchQuotesWithForceRequest:NO];
}

-(void)searchView:(id)searchView didChangeTextTo:(NSString *)text {
    // fetch quotes for query
    if ([text isEqualToString:@""]) {
        [self fetchQuotesWithForceRequest:NO];
    } else {
        [self fetchQuotesWithQuery:text forceRequest:NO];
    }
}

- (void)fetchQuotesWithForceRequest:(BOOL)forceRequest {
    // hide quotes table if there are no quotes currently in the table
    if (!self.quotesTableView.quotes.count) {
        [self.quotesTableView setShowingLoader:YES];
    }
    
    // fetch quotes from store
    [self.quotesStore fetchMyQuotesWithForceRequest:forceRequest completionHandler:^(NSArray<Quote *> *quotes, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.quotesTableView.quotes = quotes;
                [self.quotesTableView setShowingLoader:NO];
                [self.quotesTableView reloadData];
            });
        } else {
            NSLog(@"Error loading quotes!");
        }
    }];
}

- (void)fetchQuotesWithQuery:(NSString *)query forceRequest:(BOOL)forceRequest {
    // hide quotes table if there are no quotes currently in the table
    if (!self.quotesTableView.quotes.count) {
        [self.quotesTableView setShowingLoader:YES];
    }
    
    // fetch quotes from store
    [self.quotesStore fetchMyQuotesWithQuery:query forceRequest:forceRequest completionHandler:^(NSArray<Quote *> *quotes, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.quotesTableView.quotes = quotes;
                [self.quotesTableView setShowingLoader:NO];
                [self.quotesTableView reloadData];
            });
        } else {
            NSLog(@"Error loading quotes!");
        }
    }];
}

@end
