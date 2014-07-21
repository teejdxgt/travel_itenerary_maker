//
//  NYTimesArticleFetcher.h
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/23/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NYTimesArticleFetcher : NSObject

#define NYTIMES_ARTICLE_URL @"web_url"
#define NYTIMES_ARTICLE_GEO_LOCATION @"value"
#define NYTIMES_ARTICLE_ID @"_id"
#define NYTIMES_ARTICLE_DATE @"pub_date"
#define NYTIMES_ARTICLE_HEADLINE @"main"

+ (NSURL *)URLforArticles:(int)page;
+ (NSString *)pullCountryName:(NSString *)locationValue;
+ (NSString *)pullCityName:(NSString *)locationValue;
+ (NSArray *)sortfromArray:(NSMutableArray *)unsortedArray;
+ (NSArray *)usaStates;
+ (NSArray *)canadaStates;
+ (NSArray *)usaCities;
+ (NSArray *)countryCities;
+ (NSString *)pullLocationFromArray:(NSArray *)destinationArray;
+ (NSString *)pullLocationFromTitleString:(NSString *)titleString;
+ (NSString *)pullThumbnailFromArray:(NSArray *)mediaArray;
+ (BOOL)doesString:(NSString *)string containCharacter:(char)character;

@end
