//
//  SearchView.h
//  Quotes
//
//  Created by Wil Pirino on 10/13/16.
//  Copyright © 2016 Wil Pirino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewDelegate <NSObject>

- (void)searchView:(id)searchView didCancelWithText:(NSString *)text;
- (void)searchView:(id)searchView didChangeTextTo:(NSString *)text;

@end

@interface SearchView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) id <SearchViewDelegate> delegate;

@end
