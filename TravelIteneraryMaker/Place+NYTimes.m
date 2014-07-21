//
//  Place+NYTimes.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 7/6/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "Place+NYTimes.h"

@implementation Place (NYTimes)

+ (Place *)placeWithURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context
{
        Place *place = nil;

        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        NSURL *newURL = [NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"www" withString:@"mobile"]];
    dispatch_queue_t fetchQ = dispatch_queue_create("article fetcher",NULL);
    dispatch_async(fetchQ, ^{
        NSError *error;
        place.savedArticle = [NSString stringWithContentsOfURL:newURL encoding: NSUTF8StringEncoding error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
        });
        });
        return place;
}

+ (Place *)removePlaceWithURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
    
    place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
    dispatch_queue_t fetchQ = dispatch_queue_create("article fetcher",NULL);
    dispatch_async(fetchQ, ^{
        place.savedArticle = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
    return place;
}

@end
