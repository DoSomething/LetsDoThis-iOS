//
//  LDTCampaignDetailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailViewController.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailCampaignCell.h"
#import "LDTCampaignDetailReportbackItemCell.h"
#import "LDTHeaderCollectionReusableView.h"
#import "LDTUserProfileViewController.h"
#import "LDTSubmitReportbackViewController.h"
#import "LDTMessage.h"


typedef NS_ENUM(NSInteger, LDTCampaignDetailSectionType) {
    LDTCampaignDetailSectionTypeCampaign,
    LDTCampaignDetailSectionTypeReportback
};

@interface LDTCampaignDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LDTCampaignDetailCampaignCellDelegate, LDTReportbackItemDetailViewDelegate>

@property (nonatomic, assign) BOOL isDoing;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) NSMutableArray *reportbackItems;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation LDTCampaignDetailViewController

#pragma mark - NSObject

- (instancetype)initWithCampaign:(DSOCampaign *)campaign {
    self = [super initWithNibName:@"LDTCampaignDetailView" bundle:nil];

    if (self) {
        self.campaign = campaign;
        self.reportbackItems = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleBackBarButton];

    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;

    [self styleView];
    [self fetchReportbackItems];
    [LDTMessage setDefaultViewController:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect rect = self.navigationController.navigationBar.frame;
    float y = -rect.origin.y;
    self.collectionView.contentInset = UIEdgeInsetsMake(y,0,0,0);
}

#pragma mark - LDTCampaignDetailViewController

- (void)styleView {
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleClear];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
}

- (void)fetchReportbackItems {
    NSArray *statusValues = @[@"promoted", @"approved"];
    for (NSString *status in statusValues) {
        [[DSOAPI sharedInstance] loadReportbackItemsForCampaigns:@[self.campaign] status:status completionHandler:^(NSArray *rbItems) {
		[self.reportbackItems addObjectsFromArray:rbItems];
        [self.collectionView reloadData];
        } errorHandler:^(NSError *error) {
            [LDTMessage displayErrorMessageForError:error];
        }];
    }
}

- (void)configureCampaignCell:(LDTCampaignDetailCampaignCell *)cell {
    cell.delegate = self;
    cell.campaign = self.campaign;
    cell.titleLabelText = self.campaign.title;
    cell.taglineLabelText = self.campaign.tagline;
    cell.solutionCopyLabelText = self.campaign.solutionCopy;
    cell.solutionSupportCopyLabelText = self.campaign.solutionSupportCopy;
    cell.coverImageURL = self.campaign.coverImageURL;
    NSString *actionButtonTitle = @"Stop being bored";
    if ([self.user isDoingCampaign:self.campaign]) {
        actionButtonTitle = @"Prove it";
    }
    else if ([self.user hasCompletedCampaign:self.campaign]) {
        actionButtonTitle = @"Proved it";
    }
    cell.actionButtonTitle = actionButtonTitle;
}

- (void)configureReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView forIndexPath:(NSIndexPath *)indexPath {
    reportbackItemDetailView.delegate = self;
    DSOReportbackItem *reportbackItem = self.reportbackItems[indexPath.row];
    reportbackItemDetailView.reportbackItem = reportbackItem;
    reportbackItemDetailView.campaignButtonTitle = @"";
    reportbackItemDetailView.captionLabelText = reportbackItem.caption;
    reportbackItemDetailView.quantityLabelText = [NSString stringWithFormat:@"%li %@ %@", reportbackItem.quantity, reportbackItem.campaign.reportbackNoun, reportbackItem.campaign.reportbackVerb];
    reportbackItemDetailView.reportbackItemImageURL = reportbackItem.imageURL;
    reportbackItemDetailView.userAvatarImage = reportbackItem.user.photo;
    reportbackItemDetailView.userCountryNameLabelText = reportbackItem.user.countryName;
    reportbackItemDetailView.userDisplayNameButtonTitle = reportbackItem.user.displayName;
}

-(DSOUser *)user {
	return [DSOUserManager sharedInstance].user;
}

#pragma mark - LDTCampaignDetailCampaignCellDelegate

- (void)didClickActionButtonForCell:(LDTCampaignDetailCampaignCell *)cell {
    if ([self.user isDoingCampaign:cell.campaign]) {
        UIAlertController *reportbackPhotoAlertController = [UIAlertController alertControllerWithTitle:@"Pics or it didn't happen!" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *cameraAlertAction;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:self.imagePickerController animated:YES completion:NULL];
            }];
        }
        else {
            cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Nada
            }];
        }

        UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePickerController animated:YES completion:NULL];
        }];

        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [reportbackPhotoAlertController dismissViewControllerAnimated:YES completion:nil];
        }];

        [reportbackPhotoAlertController addAction:cameraAlertAction];
        [reportbackPhotoAlertController addAction:photoLibraryAlertAction];
        [reportbackPhotoAlertController addAction:cancelAlertAction];
        [self presentViewController:reportbackPhotoAlertController animated:YES completion:nil];
    }
    else {
        [[DSOUserManager sharedInstance] signupUserForCampaign:cell.campaign completionHandler:^(NSDictionary *response) {
             [LDTMessage showNotificationWithTitle:@"You're signed up!" type:TSMessageNotificationTypeSuccess];
             cell.actionButtonTitle = @"Prove it";
         } errorHandler:^(NSError *error) {
             [LDTMessage displayErrorMessageForError:error];
         }];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == LDTCampaignDetailSectionTypeReportback) {
        return self.reportbackItems.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == LDTCampaignDetailSectionTypeCampaign) {
        LDTCampaignDetailCampaignCell *cell = (LDTCampaignDetailCampaignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
        [self configureCampaignCell:cell];
		
        return cell;
    }

    if (indexPath.section == LDTCampaignDetailSectionTypeReportback) {
        LDTCampaignDetailReportbackItemCell *cell = (LDTCampaignDetailReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
        [self configureReportbackItemDetailView:cell.reportbackItemDetailView forIndexPath:indexPath];
		
        return cell;
    }

    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        LDTHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
        headerView.titleLabel.text = [@"Who's doing it now" uppercaseString];
        reusableView = headerView;
    }
    return reusableView;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = 480;
    if (indexPath.section == LDTCampaignDetailSectionTypeCampaign) {
        // @todo: Can this be dynamic based on the Campaign Detail cell's content?
        height = 660;
    }
    return CGSizeMake(width, height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == LDTCampaignDetailSectionTypeReportback) {
        // Width is ignored here.
        return CGSizeMake(60.0f, 50.0f);
    }
    return CGSizeMake(0.0f, 0.0f);
}

# pragma mark - LDTReportbackItemDetailViewDelegate

- (void)didClickCampaignTitleButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    return;
}

- (void)didClickUserNameButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    LDTUserProfileViewController *destVC = [[LDTUserProfileViewController alloc] initWithUser:reportbackItemDetailView.reportbackItem.user];
    [self.navigationController pushViewController:destVC animated:YES];
}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    viewController.title = [NSString stringWithFormat:@"I did %@", self.campaign.title].uppercaseString;
    [viewController styleRightBarButton];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    DSOReportbackItem *reportbackItem = [[DSOReportbackItem alloc] initWithCampaign:self.campaign];
    reportbackItem.image = info[UIImagePickerControllerEditedImage];
    LDTSubmitReportbackViewController *destVC = [[LDTSubmitReportbackViewController alloc] initWithReportbackItem:reportbackItem];
    UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
    [self.navigationController presentViewController:destNavVC animated:YES completion:nil];
}

@end
