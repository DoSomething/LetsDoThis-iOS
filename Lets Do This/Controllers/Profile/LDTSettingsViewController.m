//
//  LDTSettingsViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTSettingsViewController.h"
#import "DSOAPI.h"
#import "LDTButton.h"
#import "LDTMessage.h"
#import "LDTTheme.h"
#import "LDTUserConnectViewController.h"

@interface LDTSettingsViewController()
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;
@property (weak, nonatomic) IBOutlet LDTButton *logoutButton;
- (IBAction)logoutButtonTouchUpInside:(id)sender;

@end

@implementation LDTSettingsViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Settings" uppercaseString];
    [self theme];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        [self.notificationsSwitch setOn:NO];
    }
    else {
        [self.notificationsSwitch setOn:YES];
    }

}

#pragma LDTSettingsViewController

- (void)theme {
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logoutButton setTitle:[@"Logout" uppercaseString] forState:UIControlStateNormal];
    [self.logoutButton setBackgroundColor:[LDTTheme clickyBlue]];
}

- (IBAction)logoutTapped:(id)sender {
    [self confirmLogout];
}

- (void) displayNotificationsInfo {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Notification settings"
                                                                  message:@"Change your notification settings from Settings > Lets Do This."
                                                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *confirm = [UIAlertAction
                              actionWithTitle:@"Oh, ok"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [view dismissViewControllerAnimated:YES completion:nil];
                              }];

    [view addAction:confirm];
    [self presentViewController:view animated:YES completion:nil];
}


- (void) confirmLogout {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Are you sure? We’ll miss you."
                                     message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *confirm = [UIAlertAction
                             actionWithTitle:@"Logout"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self logout];
                             }];
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        
        [view addAction:confirm];
        [view addAction:cancel];
        [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)logoutButtonTouchUpInside:(id)sender {
    [self confirmLogout];
}

- (void) logout {
    [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *response) {
        LDTUserConnectViewController *destVC = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];

        [self.navigationController pushViewController:destVC animated:YES];
    } errorHandler:^(NSError *error) {
        [LDTMessage errorMessage:error];
    }];
}
@end
