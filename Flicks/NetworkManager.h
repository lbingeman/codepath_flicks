//
//  NetworkManager.h
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-23.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieModel.h"

@interface NetworkManager : NSObject
- (void)fetchNowPlayingMovies: (void(^)(NSError *,NSArray*))completionHandler;
- (void)fetchTopMovies: (void(^)(NSError *,NSArray*))completionHandler;
- (void)fetchMovieDetailsWithID:(NSString*)movieID completionHandler:(void(^)(NSError *,NSDictionary*))completionHandler;
@end
