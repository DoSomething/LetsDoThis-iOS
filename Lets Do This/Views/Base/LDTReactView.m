//
//  LDTReactView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/12/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTReactView.h"
#import <RCTRootView.h>

@implementation LDTReactView

- (void)awakeFromNib {
    // @todo: Figure out how to handle this.
    NSString *urlString = @"http://localhost:8081/index.ios.bundle";
    // @todo: Pass moduleName as parameter to custom init?
    NSURL *jsCodeLocation = [NSURL URLWithString:urlString];
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName: @"NewsStoryBox" initialProperties:nil launchOptions:nil];
    [self addSubview:rootView];
    // This is from tutorial, but the width is set to 600.
    // rootView.frame = self.bounds;
    // Hardcode to screenWidth instead, for now
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    rootView.frame = CGRectMake(0, 0, screenWidth, self.bounds.size.height);
}

@end
