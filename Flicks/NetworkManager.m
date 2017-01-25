//
//  NetworkManager.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-23.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "NetworkManager.h"
#import "MovieModel.h"
@implementation NetworkManager

- (void)fetchNowPlayingMovies: (void(^)(NSError *,NSArray*))completionHandler {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString =
    [@"https://api.themoviedb.org/3/movie/now_playing?api_key=" stringByAppendingString:apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self fetchMovies:completionHandler url:url];
}

- (void)fetchTopMovies: (void(^)(NSError *,NSArray*))completionHandler {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString =
    [@"https://api.themoviedb.org/3/movie/top_rated?api_key=" stringByAppendingString:apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self fetchMovies:completionHandler url:url];
}


- (void)fetchMovies: (void(^)(NSError *,NSArray*))completionHandler url:(NSURL*)theURL {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:theURL];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    if([responseDictionary[@"results"] isKindOfClass:[NSArray class]]){
                                                        NSArray* movieResults = responseDictionary[@"results"];
                                                        NSMutableArray* movies = [NSMutableArray new];
                                                        for(NSDictionary* dictionary in movieResults){
                                                            MovieModel* movie = [[MovieModel alloc] initWithDictionary:dictionary];
                                                            [movies addObject:movie];
                                                        }
                                                        return completionHandler(nil,movies);
                                                    }
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    return completionHandler(error,nil);
                                                }
                                            }];
    [task resume];
}


@end
