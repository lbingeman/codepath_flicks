//
//  MovieModel.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-23.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "MovieModel.h"
#define LOW_RES_POSTER "https://image.tmdb.org/t/p/w342"
@implementation MovieModel
- (instancetype)initWithDictionary:(NSDictionary*) jsonDictionary {
    self = [super init];
    if(self){
        _title = jsonDictionary[@"title"];
        _movieDescription = jsonDictionary[@"overview"];
        _posterURL = [[NSURL URLWithString:@LOW_RES_POSTER] URLByAppendingPathComponent:jsonDictionary[@"poster_path"]];
        _movieID = jsonDictionary[@"id"];
        _backgroundPath = [[NSURL URLWithString:@LOW_RES_POSTER] URLByAppendingPathComponent:jsonDictionary[@"backdrop_path"]];
        _voteAverage = jsonDictionary[@"vote_average"];
        _releaseDate = [self dateFromJSONString:jsonDictionary[@"release_date"]];
    }
    return self;
}

- (NSString*)getReleaseDate {
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    return [dateFormatter stringFromDate:self.releaseDate];
}

- (NSDate*)dateFromJSONString:(NSString*)date {
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter dateFromString:date];
}
@end
