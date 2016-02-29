//
//  DSOUserManager.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOUserManager.h"
#import <SSKeychain/SSKeychain.h>
#import "GAI+LDT.h"
#import <Crashlytics/Crashlytics.h>
#import "LDTAppDelegate.h"
#import <RCTEventDispatcher.h>

@interface DSOUserManager()

@property (strong, nonatomic, readwrite) DSOUser *user;
@property (strong, nonatomic) NSMutableArray *mutableCampaigns;

@end

@implementation DSOUserManager

#pragma mark - Singleton

+ (DSOUserManager *)sharedInstance {
    static DSOUserManager *_sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];

    if (self) {
        self.mutableCampaigns = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Accessors

- (void)setUser:(DSOUser *)user {
    _user = user;
    if (user) {
        [[Crashlytics sharedInstance] setUserIdentifier:user.userID];
    }
    else {
        [[Crashlytics sharedInstance] setUserIdentifier:nil];
    }
}

- (NSString *)currentService {
    return [DSOAPI sharedInstance].baseURL.absoluteString;
}

#pragma mark - DSOUserManager

- (LDTAppDelegate *)appDelegate {
    return ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
}

- (BOOL)userHasCachedSession {
    return self.sessionToken.length > 0;
}

- (void)createSessionWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] loginWithEmail:email password:password completionHandler:^(DSOUser *user) {
        self.user = user;
        // Needed for when we're logging in as a different user.
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserChanged" body:user.dictionary];
        [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:user.sessionToken];
        // Save session in Keychain for when app is quit.
        [SSKeychain setPassword:user.sessionToken forService:self.currentService account:@"Session"];
        [SSKeychain setPassword:self.user.userID forService:self.currentService account:@"UserID"];
        if (completionHandler) {
            completionHandler(user);
        }
      } errorHandler:^(NSError *error) {
          if (errorHandler) {
              errorHandler(error);
          }
      }];
}

- (NSString *)sessionToken {
    return [SSKeychain passwordForService:self.currentService account:@"Session"];
}

- (void)continueSessionWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    if (self.sessionToken.length == 0) {
        // @todo: Should return error here.
        return;
    }

    // @todo: Once Northstar API supports it, actively check for whether or saved session is valid before trying to start.
    // @see https://github.com/DoSomething/northstar/issues/186
    [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:self.sessionToken];

    NSString *userID = [SSKeychain passwordForService:self.currentService account:@"UserID"];
    [[DSOAPI sharedInstance] loadUserWithID:userID completionHandler:^(DSOUser *user) {
        self.user = user;
        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)endSession {
    [SSKeychain deletePasswordForService:self.currentService account:@"Session"];
    [SSKeychain deletePasswordForService:self.currentService account:@"UserID"];
    self.user = nil;
}

- (void)endSessionWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *responseDict) {
        [self endSession];
        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        // Only perform logout tasks if error is NOT a lack of connectivity.
        if (error.code != -1009) {
            [self endSession];
        }
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)signupUserForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOCampaignSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] postSignupForCampaign:campaign completionHandler:^(DSOCampaignSignup *signup) {
        [[GAI sharedInstance] trackEventWithCategory:@"campaign" action:@"submit signup" label:[NSString stringWithFormat:@"%li", (long)campaign.campaignID] value:nil];
        // @todo Just send raw response vs signup.dictionary to avoid potential bugs like https://github.com/DoSomething/LetsDoThis-iOS/issues/850
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserActivity" body:signup.dictionary];
        if (completionHandler) {
            completionHandler(signup);
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)postUserReportbackItem:(DSOReportbackItem *)reportbackItem completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] postReportbackItem:reportbackItem completionHandler:^(NSDictionary *reportbackDict) {
        [[GAI sharedInstance] trackEventWithCategory:@"campaign" action:@"submit reportback" label:[NSString stringWithFormat:@"%li", (long)reportbackItem.campaign.campaignID] value:nil];
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserActivity" body:reportbackDict];
        if (completionHandler) {
            completionHandler(reportbackDict);
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

-(void)postAvatarImage:(UIImage *)avatarImage sendAppEvent:(BOOL)sendAppEvent completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] postAvatarForUser:[DSOUserManager sharedInstance].user avatarImage:avatarImage completionHandler:^(id responseObject) {

        NSDictionary *responseDict = responseObject[@"data"];
        self.user.avatarURL = responseDict[@"photo"];
        NSLog(@"postAvatarImage currentUserChanged eventDispatcher");
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserChanged" body:responseDict];

        if (completionHandler) {
            completionHandler(responseDict);
        }
    } errorHandler:^(NSError * error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (DSOCampaign *)campaignWithID:(NSInteger)campaignID {
    for (DSOCampaign *campaign in self.mutableCampaigns) {
        if (campaign.campaignID == campaignID) {
            return campaign;
        }
    }
    return nil;
}

- (void)loadAndStoreCampaignWithID:(NSInteger)campaignID completionHandler:(void (^)(DSOCampaign *))completionHandler errorHandler:(void (^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] loadCampaignWithID:campaignID completionHandler:^(DSOCampaign *campaign) {
        [self.mutableCampaigns addObject:campaign];
        NSLog(@"[DSOUserManager] Stored Campaign ID %li.", (long)campaign.campaignID);
        if (completionHandler) {
            completionHandler(campaign);
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

@end
