//
//  LDTActivityViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 12/2/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

@interface LDTActivityViewController : UIActivityViewController

- (instancetype)initWithShareMessage:(NSString *)shareMessage shareImage:(UIImage *)shareImage gaiActionName:(NSString *)gaiActionName;

@end
