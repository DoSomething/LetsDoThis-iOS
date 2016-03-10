//
//  NSError+LDT.h
//  Lets Do This
//
//  Created by Aaron Schachter on 10/28/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

@interface NSError (LDT)

- (BOOL)networkConnectionError;
- (NSInteger)networkResponseCode;
- (NSString *)readableTitle;
- (NSString *)readableMessage;

@end
