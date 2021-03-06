//
//  GoogleProvider.m
//  ARAnalyticsTests
//
//  Created by orta therox on 05/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "GoogleAnalyticsProvider.h"
#import "ARAnalyticsProviders.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface GoogleAnalyticsProvider ()

@property (nonatomic, strong) id <GAITracker> tracker;

- (void) dispatchGA;

@end

@implementation GoogleAnalyticsProvider
#ifdef AR_GOOGLEANALYTICS_EXISTS

- (id)initWithIdentifier:(NSString *)identifier {
    NSAssert([GAI class], @"Google Analytics SDK is not included");

    if ((self = [super init])) {
        self.tracker = [[GAI sharedInstance] trackerWithTrackingId:identifier];

        for( NSString *inactiveEvent in @[ UIApplicationWillResignActiveNotification,
                                           UIApplicationWillTerminateNotification,
                                           UIApplicationDidEnterBackgroundNotification ]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(dispatchGA)
                                                         name:inactiveEvent
                                                       object:nil];
        }
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)identifyUserWithID:(NSString *)userID andEmailAddress:(NSString *)email {
    // Not allowed in GA
    // https://developers.google.com/analytics/devguides/collection/ios/v3/customdimsmets#pii

    // The Google Analytics Terms of Service prohibit sending of any personally identifiable information (PII) to Google Analytics servers. For more information, please consult the Terms of Service.

    // Ideally we would put an assert here but if you have multiple providers that wouldn't make sense.
}

- (void)setUserProperty:(NSString *)property toValue:(NSString *)value {
    [self.tracker set:property value:value];
}

- (void)event:(NSString *)event withProperties:(NSDictionary *)properties {
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:@"default"
                                                                           action:event
                                                                            label:nil
                                                                            value:nil];
    [self.tracker send:[builder build]];
}

- (void)didShowNewPageView:(NSString *)pageTitle {
    [self event:@"Screen view" withProperties:@{ @"screen": pageTitle }];
    [self.tracker set:kGAIScreenName value:pageTitle];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)logTimingEvent:(NSString *)event withInterval:(NSNumber *)interval {
    [self event:event withProperties:@{ @"length": interval }];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createTimingWithCategory:@"default"
                                                                          interval:interval
                                                                              name:event
                                                                             label:nil];
    [self.tracker send:[builder build]];
}

#pragma mark - Dispatch

- (void)dispatchGA {
    [[GAI sharedInstance] dispatch];
}

#endif
@end
