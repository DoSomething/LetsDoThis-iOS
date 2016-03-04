//
//  DSOCampaign.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOCampaign.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCampaign ()

@property (strong, nonatomic, readwrite) NSDictionary *dictionary;
@property (assign, nonatomic, readwrite) NSInteger campaignID;
@property (strong, nonatomic, readwrite) NSString *coverImage;
@property (strong, nonatomic, readwrite) NSString *reportbackNoun;
@property (strong, nonatomic, readwrite) NSString *reportbackVerb;
@property (strong, nonatomic, readwrite) NSString *solutionCopy;
@property (strong, nonatomic, readwrite) NSString *solutionSupportCopy;
@property (strong, nonatomic, readwrite) NSString *status;
@property (strong, nonatomic, readwrite) NSString *tagline;
@property (strong, nonatomic, readwrite) NSString *title;
@property (strong, nonatomic, readwrite) NSString *type;
@property (strong, nonatomic, readwrite) NSURL *coverImageURL;

@end

@implementation DSOCampaign

- (instancetype)initWithCampaignID:(NSInteger)campaignID {
    self = [super init];

    if (self) {
        _campaignID = campaignID;
    }
    return self;
}


- (instancetype)initWithCampaignID:(NSInteger)campaignID title:(id)title {
    self = [super init];

    if (self) {
        _campaignID = campaignID;
        _title = title;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary*)values {
    self = [super init];

    if (self) {
        _campaignID = [values valueForKeyAsInt:@"id"];
        _title = [values valueForKeyAsString:@"title"];
        _status = [values valueForKeyAsString:@"status"];
        _type = [values valueForKeyAsString:@"type"];
        _tagline = [values valueForKeyAsString:@"tagline"];
        _reportbackNoun = [values valueForKeyPath:@"reportback_info.noun"];
        _reportbackVerb = [values valueForKeyPath:@"reportback_info.verb"];
        _coverImage = [[values valueForKeyPath:@"cover_image.default.sizes.landscape"] valueForKeyAsString:@"uri"];
        _solutionCopy = [[values valueForKeyPath:@"solutions.copy"] valueForKeyAsString:@"raw"];
        _solutionSupportCopy = [[values valueForKeyPath:@"solutions.support_copy"] valueForKeyAsString:@"raw"];
    }
	
    return self;
}

- (NSDictionary *)dictionary {
    NSString *coverImage;
    if (self.coverImage) {
        coverImage = self.coverImage;
    }
    else {
        coverImage = @"";
    }
    // @todo This is hack for default solutionCopy nullValue not being set
    if (!self.solutionCopy) {
        self.solutionCopy = @"";
    }
    if (!self.solutionSupportCopy) {
        self.solutionSupportCopy = @"";
    }
    NSDictionary *reportbackInfo = @{@"noun" : self.reportbackNoun, @"verb" : self.reportbackVerb};
    NSDictionary *dict = @{
             @"id" : [NSNumber numberWithInteger:self.campaignID],
             @"status": self.status,
             @"title" : self.title,
             @"image_url" : coverImage,
             @"tagline" : self.tagline,
             @"type" : self.type,
             @"reportback_info" : reportbackInfo,
             @"solutionCopy" : self.solutionCopy,
             @"solutionSupportCopy" : self.solutionSupportCopy,
             };
    return dict;
}

@end
