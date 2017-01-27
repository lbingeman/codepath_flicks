//
//  NetworkManager.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-23.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "NetworkManager.h"

#define API_KEY "a07e22bc18f5cb106bfe4cc1f83ad8ed"
@implementation NetworkManager

- (void)fetchNowPlayingMovies: (void(^)(NSError *,NSArray*))completionHandler {
    NSString *urlString =
    [@"https://api.themoviedb.org/3/movie/now_playing?api_key=" stringByAppendingString:@API_KEY];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self fetchMovies:completionHandler url:url];
}

- (void)fetchTopMovies: (void(^)(NSError *,NSArray*))completionHandler {
    NSString *urlString =
    [@"https://api.themoviedb.org/3/movie/top_rated?api_key=" stringByAppendingString:@API_KEY];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self fetchMovies:completionHandler url:url];
}

- (void)fetchMovieDetailsWithID:(NSString*)movieID completionHandler:(void(^)(NSError *,NSDictionary*))completionHandler {
    NSString *urlString =
    [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@&append_to_response=videos",movieID,@API_KEY];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self networkRequestWithJSONResponseFromURL:url completionHandler:completionHandler];
}



- (void)networkRequestWithJSONResponseFromURL:(NSURL*)url completionHandler: (void(^)(NSError*,NSDictionary*))completionHandler  {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
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
                                                    completionHandler(nil,responseDictionary);
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    return completionHandler(error,nil);
                                                }
                                            }];
    [task resume];
}
    
- (void)fetchMovies: (void(^)(NSError *,NSArray*))completionHandler url:(NSURL*)url {
    [self networkRequestWithJSONResponseFromURL:url completionHandler:^(NSError* _Nullable error,NSDictionary* _Nullable responseDictionary){
        if(error){
            NSLog(@"An error occurred: %@", error.description);
            return completionHandler(error,nil);
        }
        if([responseDictionary[@"results"] isKindOfClass:[NSArray class]]){
            NSArray* movieResults = responseDictionary[@"results"];
            NSMutableArray* movies = [NSMutableArray new];
            for(NSDictionary* dictionary in movieResults){
                MovieModel* movie = [[MovieModel alloc] initWithDictionary:dictionary];
                [movies addObject:movie];
            }
            return completionHandler(nil,movies);
        }
    }];
    
}


@end
