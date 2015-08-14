//
//  LDTUserProfileViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserProfileViewController.h"
#import "LDTButton.h"
#import "LDTTheme.h"
#import "LDTMessage.h"
#import "LDTUserConnectViewController.h"
#import "LDTCampaignListViewController.h"
#import "LDTSettingsViewController.h"
#import "DSOCampaign.h"

@interface LDTUserProfileViewController ()<UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) NSMutableArray *campaignsDoing;
@property (strong, nonatomic) NSMutableArray *campaignsCompleted;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

static NSString *cellIdentifier;

@implementation LDTUserProfileViewController

#pragma mark - NSObject

-(instancetype)initWithUser:(DSOUser *)user {
    self = [super initWithNibName:@"LDTUserProfileView" bundle:nil];

    if (self) {
        self.user = user;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = nil;
    self.nameLabel.text = [self.user displayName];
    self.avatarImageView.image = self.user.photo;
    [self styleView];

    cellIdentifier = @"rowCell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

    // @todo: Add conditional to only display if self.user != current user
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped:)];
    self.navigationItem.rightBarButtonItem = settingsButton;
}

- (void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];

    // @todo Sync User from API.

    [[DSOAPI sharedInstance] fetchCampaignsWithCompletionHandler:^(NSDictionary *campaigns) {

        self.campaignsDoing = [[NSMutableArray alloc] init];
        self.campaignsCompleted = [[NSMutableArray alloc] init];

        for (NSNumber *campaignID in self.user.campaignIDsDoing) {
            if ([campaigns objectForKey:campaignID]) {
                DSOCampaign *campaign = campaigns[campaignID];
                [self.campaignsDoing addObject:campaign];
            }
        }
        // @todo: Loop through campaignIdsCompleted

        [self.tableView reloadData];

    } errorHandler:^(NSError *error) {
        [LDTMessage displayErrorMessageForError:error];
    }];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationItem.title = @"";
}

#pragma Mark - LDTUserProfileViewController

- (void) styleView {
    [LDTTheme setLightningBackground:self.headerView];
    [self.avatarImageView addCircleFrame];

    self.nameLabel.text = [self.nameLabel.text uppercaseString];
    [self.nameLabel setFont:[LDTTheme fontBoldWithSize:30]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;

    // Stolen from http://stackoverflow.com/questions/19802336/ios-7-changing-font-size-for-uitableview-section-headers
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[LDTTheme fontBold]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentCenter];

}

- (IBAction)settingsTapped:(id)sender {
    LDTSettingsViewController *destVC = [[LDTSettingsViewController alloc] initWithNibName:@"LDTSettingsView" bundle:nil];

    [self.navigationController pushViewController:destVC animated:YES];
}

#pragma mark -- UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = nil;
    switch (section) {
        case 0:
            header = [@"Currently doing" uppercaseString];
            break;
        case 1:
            header = [@"Been there, done good" uppercaseString];
            break;
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount;
    switch (section) {
        case 0:
            rowCount =  [self.campaignsDoing count];
            break;
        case 1:
            rowCount = [self.campaignsCompleted count];
            break;
        default:
            rowCount = 1;
    }
    return rowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    DSOCampaign *campaign;
    if (indexPath.section == 0) {
        campaign = self.campaignsDoing[indexPath.row];
    }
    else {
        campaign = self.campaignsCompleted[indexPath.row];
    }
    cell.textLabel.text = [campaign.title uppercaseString];
    cell.userInteractionEnabled = YES;
    cell.textLabel.font = [LDTTheme fontBold];
    return cell;
}

@end
