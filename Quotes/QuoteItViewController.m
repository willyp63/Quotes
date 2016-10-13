//
//  QuoteItViewController.m
//  Quotes
//
//  Created by Wil Pirino on 10/9/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import "QuoteItViewController.h"
#import "MyTabsController.h"
#import "AboveKeyBoardView.h"
#import "QuoteItDetailViewController.h"
#import "constants.h"

static CGFloat const ABOVE_KEYBOARD_VIEW_HEIGHT = 60.0f;
static NSString *const PLACE_HOLDER_TEXT = @"Say Something...";

@interface QuoteItViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textArea;
@property (strong, nonatomic) AboveKeyBoardView *aboveKeyboardView;

@end

@implementation QuoteItViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self clearQuoteText];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // hide navigation and tabs
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    
    // pull up keyboard
    [self.textArea becomeFirstResponder];
    
    // listen for keyboard showing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // show tabs
    self.tabBarController.tabBar.hidden = NO;
    
    // remove keyboard observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    // remove above keyboard view
    if (!animated) {
        [self.aboveKeyboardView removeFromSuperview];
    } else {
        // animate removal
        CGRect initRect = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [UIScreen mainScreen].bounds.size.width, ABOVE_KEYBOARD_VIEW_HEIGHT);
        [UIView animateWithDuration:0.7 animations:^{
            self.aboveKeyboardView.frame = initRect;
        } completion:^(BOOL finsihed){
            [self.aboveKeyboardView removeFromSuperview];
        }];
    }
}
-(void)clearQuoteText {
    self.textArea.text = PLACE_HOLDER_TEXT;
}

- (IBAction)cancel:(id)sender {
    [self clearQuoteText];
    
    // return to previously selected tab
    MyTabsController *mtc = (MyTabsController *)self.tabBarController;
    [mtc setSelectedIndex:mtc.prevSelectedIndex];
}

- (void)showQuoteItDetail:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showQuoteItDetail" sender:self];
}

#pragma mark - UIKeyboardWillShowNotification
- (void)keyboardWasShown:(NSNotification *)notification {
    if (self.aboveKeyboardView) {
        [self.aboveKeyboardView removeFromSuperview];
    }
    
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    // animation frames
    CGRect startAnimationFrame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, keyboardFrame.size.width, ABOVE_KEYBOARD_VIEW_HEIGHT);
    CGRect endAnimationFrame = CGRectMake(0,
                                          [[UIScreen mainScreen] bounds].size.height - keyboardFrame.size.height - ABOVE_KEYBOARD_VIEW_HEIGHT,
                                          keyboardFrame.size.width,
                                          ABOVE_KEYBOARD_VIEW_HEIGHT);
    
    // init view
    self.aboveKeyboardView = [[AboveKeyBoardView alloc] initWithFrame:startAnimationFrame buttonAction:@selector(showQuoteItDetail:) target:self];
    self.aboveKeyboardView.backgroundColor = [UIColor whiteColor];
    
    // enable/disable button
    [self enableButtonIfValidQuote];
    
    // set charcount
    if ([self.textArea.text isEqualToString:PLACE_HOLDER_TEXT]) {
        self.aboveKeyboardView.charCount.text = [NSString stringWithFormat:@"%d", CHARACTER_LIMIT];
    } else {
        self.aboveKeyboardView.charCount.text = [NSString stringWithFormat:@"%li", CHARACTER_LIMIT - self.textArea.text.length];
    }
    
    // add and animate in
    [self.view addSubview:self.aboveKeyboardView];
    [UIView animateWithDuration:0.9 animations:^{
        self.aboveKeyboardView.frame = endAnimationFrame;
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // dont allow new lines
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    
    // clear text if its place holder
    if ([textView.text isEqualToString:PLACE_HOLDER_TEXT]) {
        textView.text = text;
        self.aboveKeyboardView.charCount.text = [NSString stringWithFormat:@"%li", CHARACTER_LIMIT - [text length]];
        [self enableButtonIfValidQuote];
        return NO;
    }
    
    // get new substring
    NSString *newText = [NSString stringWithString:textView.text];
    newText = [newText stringByReplacingCharactersInRange:range withString:text];
    
    // set char count
    if ([newText length] > CHARACTER_LIMIT) {
        self.aboveKeyboardView.charCount.text = @"0";
        return NO;
    }
    
    self.aboveKeyboardView.charCount.text = [NSString stringWithFormat:@"%li", CHARACTER_LIMIT - [newText length]];
    [self enableButtonIfValidQuote];
    return YES;
}

- (void)enableButtonIfValidQuote {
    if ([self.textArea.text isEqualToString:@""] || [self.textArea.text isEqualToString:PLACE_HOLDER_TEXT]) {
        // disable button
        self.aboveKeyboardView.quoteItButton.enabled = NO;
        [self.aboveKeyboardView.quoteItButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    } else {
        // enable button
        self.aboveKeyboardView.quoteItButton.enabled = YES;
        [self.aboveKeyboardView.quoteItButton setTitleColor:[UIColor colorWithRed:MAIN_COLOR_RED green:MAIN_COLOR_GREEN blue:MAIN_COLOR_BLUE alpha:1.0] forState:UIControlStateNormal];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *dest = [segue destinationViewController];
    if ([dest class] == [QuoteItDetailViewController class]) {
        // pass quote to detail VC
        [(QuoteItDetailViewController *)dest setQuoteText: self.textArea.text];
    }
}

@end
