//
//  Destination+NYTimes.m
//  TravelIteneraryMaker
//
//  Created by TJ Lindsley on 6/24/14.
//  Copyright (c) 2014 TJ Lindsley. All rights reserved.
//

#import "Destination+NYTimes.h"
#import "NYTimesArticleFetcher.h"
#import "Place+NYTimes.h"

@implementation Destination (NYTimes)

+ (Destination *)destinationWithArticleInfo:(NSDictionary *)articleDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    //NSLog(@"Destination with article info has been called");
    Destination *destination = nil;
    
    
    NSString *articleID = [articleDictionary valueForKey:NYTIMES_ARTICLE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Destination"];
    request.predicate = [NSPredicate predicateWithFormat:@"articleID = %@", articleID];
    NSArray *headline = [articleDictionary valueForKey:@"headline"];
    NSRange range = [[headline valueForKey:NYTIMES_ARTICLE_HEADLINE] rangeOfString: @"36 Hours In" options: NSCaseInsensitiveSearch];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1))
    {
        //handle error
    }
    else if ([matches count])
    {
        destination = [matches firstObject];
        
        //dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher",NULL);
        //dispatch_async(fetchQ, ^{
        //    [self updateDestinationThumbnailImage:destination inManagedObjectContext:context];
        //    NSLog(@"Title: %@, was just updated", destination.title);
        //dispatch_async(dispatch_get_main_queue(), ^{
        //});
        //});
    }
    else if (range.location != NSNotFound && [[articleDictionary valueForKeyPath:NYTIMES_ARTICLE_URL] isKindOfClass:[NSString class]])
    {
        NSLog(@"This is the Article Name: %@", [headline valueForKey:NYTIMES_ARTICLE_HEADLINE]);
        NSLog(@"This is the Article URL: %@", [articleDictionary valueForKeyPath:NYTIMES_ARTICLE_URL]);
        destination = [NSEntityDescription insertNewObjectForEntityForName:@"Destination" inManagedObjectContext:context];
        destination.articleID = articleID;
        destination.date = [articleDictionary valueForKeyPath:NYTIMES_ARTICLE_DATE];
        destination.saved = NO;

        destination.url = [articleDictionary valueForKeyPath:NYTIMES_ARTICLE_URL];
        
        NSArray *newDestination = [articleDictionary valueForKey:@"keywords"];
        NSString *tempString = [NYTimesArticleFetcher pullLocationFromArray:newDestination];
        
        //NSArray *headline = [articleDictionary valueForKey:@"headline"];
        destination.title = [headline valueForKey:NYTIMES_ARTICLE_HEADLINE];
        
        if ([[NYTimesArticleFetcher pullCountryName:tempString] isEqualToString:@"Other"])
        {
            if ([[NYTimesArticleFetcher usaCities] containsObject:[NYTimesArticleFetcher pullCityName:tempString]])
                 {
                     destination.country = @"United States";
                     destination.city = [NYTimesArticleFetcher pullCityName:tempString];
                 }
            else if ([[NYTimesArticleFetcher countryCities] containsObject:[NYTimesArticleFetcher pullCityName:tempString]])
            {
                destination.city = [NYTimesArticleFetcher pullLocationFromTitleString:[headline valueForKey:NYTIMES_ARTICLE_HEADLINE]];
                destination.country = [NYTimesArticleFetcher pullCityName:tempString];
            }
            else if ([[NYTimesArticleFetcher pullCityName:tempString] isEqualToString:@""])
            {
                destination.city = [NYTimesArticleFetcher pullLocationFromTitleString:[headline valueForKey:NYTIMES_ARTICLE_HEADLINE]];
                destination.country = [NYTimesArticleFetcher pullCountryName:tempString];
            }
            else
            {
                destination.city = [NYTimesArticleFetcher pullCityName:tempString];
                destination.country = [NYTimesArticleFetcher pullCityName:tempString];
            }
        }
        else
        {
        destination.city = [NYTimesArticleFetcher pullCityName:tempString];
        destination.country = [NYTimesArticleFetcher pullCountryName:tempString];
        }
        NSArray *newMedia = [articleDictionary valueForKey:@"multimedia"];
        destination.thumbnailImageURL = [NYTimesArticleFetcher pullThumbnailFromArray:newMedia];
        
        NSLog(@"This is the destinaiton that was just added: %@", destination);
        
    }
    return destination;
}
    
+ (void)updateDestinationThumbnailImage:(Destination *)destination inManagedObjectContext:(NSManagedObjectContext *)context
{

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *imageDestination = [NSEntityDescription entityForName:@"Destination" inManagedObjectContext:context];
    [fetchRequest setEntity:imageDestination];
    
    NSError *error;
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
   
    for (Destination *destinationToUpdate in fetchedObjects) {
        if (destination == destinationToUpdate)
        {
            NSLog(@"Title: %@", destinationToUpdate.title);
            destinationToUpdate.thumbnailImage = [NSData dataWithContentsOfURL: [NSURL URLWithString:destinationToUpdate.thumbnailImageURL]];
        }
    }
}

+ (void)updateDestinationIsSaved:(NSUInteger)destinationID inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *savedDestination = [NSEntityDescription entityForName:@"Destination" inManagedObjectContext:context];
    [fetchRequest setEntity:savedDestination];
    
    NSError *error;
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for (Destination *destinationToUpdate in fetchedObjects) {
        if (destinationID == destinationToUpdate.hash)
        {
            if(destinationToUpdate.saved == NO)
               {
                   NSLog(@"Title: %@ has bee set to yes", destinationToUpdate.title);
                   [destinationToUpdate setValue:[NSNumber numberWithBool:YES] forKey:@"saved"];
                   [destinationToUpdate setValue:[Place placeWithURL:destinationToUpdate.url inManagedObjectContext:context] forKey:@"places"];
                   [context save:NULL];
               }
            else
               {
                   NSLog(@"Title: %@ has been set to no", destinationToUpdate.title);
                   [destinationToUpdate setValue:NO forKey:@"saved"];
                   [destinationToUpdate setValue:[Place removePlaceWithURL:destinationToUpdate.url inManagedObjectContext:context] forKey:@"places"];
                   [context save:NULL];
               }
        }
    }
}

+ (void)loadDestinationsFromArticleArray:(NSArray *)destinations inManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *destination in destinations)
    {
        //NSLog(@"Calling destination with artcile info");
        [self destinationWithArticleInfo:destination inManagedObjectContext:context];
    }
    
}

@end
