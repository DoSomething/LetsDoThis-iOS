//
//  LDTWebViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 5/16/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTWebViewController : UIViewController

// If downloadable is true, a toolbar is displayed allowing user to download file at webViewURL and open in a UIDocumentInteractionController.
- (instancetype)initWithWebViewURL:(NSURL *)webViewURL title:(NSString *)navigationTitle screenName:(NSString *)screenName isDownloadable:(BOOL)downloadable;

@end
