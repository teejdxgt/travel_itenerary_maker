//
//  NYTimesArticleFetcher.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/23/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "NYTimesArticleFetcher.h"
#import "NYTimesAPIKey.h"

@implementation NYTimesArticleFetcher

+ (NSURL *)URLForQuery:(NSString *)query forPageNumber:(int)page
{
    query = [NSString stringWithFormat:@"%@q=36+hours+in&fq=news_desk:+Travel&fl=web_url,keywords,_id,pub_date,headline,multimedia&page=%d&api-key=%@", query, page, NYTimesAPIKey];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"This is the fetching URL: %@", [NSURL URLWithString:query]);
    return [NSURL URLWithString:query];
}

+ (NSURL *)URLforArticles:(int)page

{
    return [self URLForQuery:@"http://api.nytimes.com/svc/search/v2/articlesearch.json?" forPageNumber:page];
}

+ (NSString *)pullCityName:(NSString *)locationValue
{
    NSArray *cityName = [locationValue componentsSeparatedByString:@"("];
    return cityName.firstObject;
}

+ (NSString *)pullCountryName:(NSString *)locationValue
{
    NSString *trimmed = [locationValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange openBracket = [trimmed rangeOfString:@"("];
    NSRange closeBracket = [trimmed rangeOfString:@")"];
    NSRange numberRange = NSMakeRange(openBracket.location + 1, closeBracket.location - openBracket.location - 1);
    if (openBracket.length > 0 && closeBracket.length > 0)
    {
        NSString *countryName = [trimmed substringWithRange:numberRange];
            if ([[NYTimesArticleFetcher usaStates] containsObject:countryName])
            {
                countryName = @"United States";
            }
            else if ([[NYTimesArticleFetcher canadaStates] containsObject:countryName])
            {
                countryName = @"Canada";
            }
        return countryName;
    }
    /*else if ([[NYTimesArticleFetcher usaCities] containsObject:[self pullCountryName:trimmed]])
    {
        return @"United States of America";
    }*/
    else
    {
        return @"Other";
    }
}

+ (NSString *)pullLocationFromArray:(NSArray *)destinationArray
{
    NSString *location = [[NSString alloc] init];
    for (int i = 0; i < [destinationArray count]; i++)
    {
        if ([[destinationArray[i] valueForKey:@"name"] isEqualToString:@"glocations"])
        {
            NSString *trimmed = [[destinationArray[i] valueForKey:NYTIMES_ARTICLE_GEO_LOCATION] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (([trimmed rangeOfString:@"("].location != NSNotFound) && [[destinationArray valueForKey:@"name"] count] > 2)
            {
            location =  [destinationArray[i] valueForKey:NYTIMES_ARTICLE_GEO_LOCATION];
            break;
            }
            else
            {
                location =  [destinationArray[i] valueForKey:NYTIMES_ARTICLE_GEO_LOCATION];
            }
        }
        
    }
    return location;
}

+ (NSString *)pullThumbnailFromArray:(NSArray *)mediaArray
{
    NSString *thumbnailURL = [[NSString alloc] init];
    NSString *preURL = @"http://www.nytimes.com/";
    
    for (int i = 0; i < [mediaArray count]; i++)
    {
        if ([[mediaArray[i] valueForKey:@"subtype"] isEqualToString:@"thumbnail"])
        {
            thumbnailURL = [preURL stringByAppendingString:[mediaArray[i] valueForKey:@"url"]];
        }
    }
    return thumbnailURL;
}

+ (NSString *)pullLocationFromTitleString:(NSString *)titleString
{
    NSString *trimmed = [titleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange cityStart = [trimmed rangeOfString:@"in"];
    //NSRange cityEnd = [trimmed rangeOfString:@","];
    NSRange numberRange = NSMakeRange(cityStart.location + 3, trimmed.length - cityStart.location - 3);
    NSString *cityName = [trimmed substringWithRange:numberRange];
    return cityName;
}

+ (NSArray *)sortfromArray:(NSMutableArray *)unsortedArray
{
    if ([unsortedArray.firstObject isEqualToString:@"Travel and Vacations"])
    {
        NSString *firstPlaceHolder = unsortedArray.firstObject;
        NSString *lastPlaceHolder = unsortedArray.lastObject;
        NSArray *sortedArray = @[lastPlaceHolder, firstPlaceHolder];
        return sortedArray;
    }
    else
    {
        NSArray *sortedArray = [NSArray arrayWithArray:unsortedArray];
        return sortedArray;
    }
}

+ (NSArray *)usaStates
{
    return @[@"Mass",@"Ohio",@"Calif",@"Hawaii",@"Wash",@"Md",@"Ill",@"Pa",@"Tenn",@"Colo",@"Wis",@"Ariz",@"Ore",@"Ky",@"SC",@"Ala",@"Alaska",@"Conn", @"DC",@"Fla",@"Ga",@"Idaho",@"La",@"Me",@"Miami Beach, Fla", @"Mich", @"Miss",@"Mo",@"NC",@"Nev",@"NH",@"NJ",@"NM",@"NY",@"NYC",@"Tex",@"Utah",@"Va",@"Vt",@"Wyo",@"RI",@"Manhattan, NY"];
}

+ (NSArray *)canadaStates
{
    return @[@"Quebec",@"Ontario",@"British Columbia"];
}

+ (NSArray *)usaCities
{
    return @[@"New York City",@"Colorado",@"Texas"];
}

+ (NSArray *)countryCities
{
    return @[@"Brazil",@"Caribbean Area",@"China",@"Mexico",@"Puerto Rico"];
}

+ (BOOL)doesString:(NSString *)string containCharacter:(char)character
{
    if ([string rangeOfString:[NSString stringWithFormat:@"%c",character]].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

@end
