//
//  Destination+NYTimes.h
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/24/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "Destination.h"

@interface Destination (NYTimes)

+ (Destination *)destinationWithArticleInfo:(NSDictionary *)articleDictionary inManagedObjectContext:(NSManagedObjectContext *)context; //provides the destination and the context of where the object needs to be created

+ (void)loadDestinationsFromArticleArray:(NSArray *)destinations inManagedObjectContext:(NSManagedObjectContext *)context; //Array of NYTimes NSDictionaries bulk loaded into DB

+ (void)updateDestinationThumbnailImage:(Destination *)destination inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)updateDestinationIsSaved:(NSUInteger)destinationID inManagedObjectContext:(NSManagedObjectContext *)context;


@end
