//
//  NSError+LDT.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/28/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "NSError+LDT.h"
#import "NSDictionary+DSOJsonHelper.h"

@implementation NSError (LDT)

- (BOOL)networkConnectionError {
    NSInteger code = self.code;
    // Many thanks to http://nshipster.com/nserror/#cfurlconnection-&-cfurlprotocol-errors
    return (code == -1001 || code == -1005 || code == -1009 || code == -1018 || code == -1019 || code == -1020);
}

- (NSString *)readableTitle {
    return [self readableStringAsTitle:YES];

}
- (NSString *)readableMessage {
    return [self readableStringAsTitle:NO];
}

- (NSString *)readableStringAsTitle:(BOOL)isTitle {
    if (self.code == -1001) {
        if (isTitle) {
            return @"The request timed out.";
        }
        else {
            return @"Seems like the Internet is trying to cause drama.";
        }
    }
    else if (self.networkConnectionError) {
        if (isTitle) {
            return @"No connection.";
        }
        else {
            return @"Seems like the Internet is trying to cause drama.";
        }
    }
    if (self.code != 500 && self.localizedFailureReason) {
        if (isTitle) {
            return self.localizedDescription;
        }
        else return self.localizedFailureReason;
    }
    if (isTitle) {
        return @"Oops! Our bad.";
    }
    return @"Looks like there was an issue with that request. We're looking into it now!";
}

@end
