//
//  MovieModel.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-23.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "MovieModel.h"
#define REGULAR_RES_POSTER "https://image.tmdb.org/t/p/w342"
#define HIGH_RES_POSTER "https://image.tmdb.org/t/p/original"
#define LOW_RES_POSTER "https://image.tmdb.org/t/p/w45"

@interface MovieModel()
    @property (nonatomic) NSDictionary* video;
@end

@implementation MovieModel
- (instancetype)initWithDictionary:(NSDictionary*) jsonDictionary {
    self = [super init];
    if(self){
        _title = jsonDictionary[@"title"];
        _movieDescription = jsonDictionary[@"overview"];
        _posterURL = [[NSURL URLWithString:@REGULAR_RES_POSTER] URLByAppendingPathComponent:jsonDictionary[@"poster_path"]];
        _highQualityPoster = [[NSURL URLWithString:@HIGH_RES_POSTER] URLByAppendingPathComponent:jsonDictionary[@"poster_path"]];
        _lowQualityPoster = [[NSURL URLWithString:@LOW_RES_POSTER] URLByAppendingPathComponent:jsonDictionary[@"poster_path"]];
        _movieID = jsonDictionary[@"id"];
        _backgroundPath = [[NSURL URLWithString:@LOW_RES_POSTER] URLByAppendingPathComponent:jsonDictionary[@"backdrop_path"]];
        _voteAverage = jsonDictionary[@"vote_average"];
        _releaseDate = [self dateFromJSONString:jsonDictionary[@"release_date"]];
    }
    return self;
}

- (void)setDetailedDataWithJSON:(NSDictionary*)responseDictionary{
    @try {
        self.runtime = [responseDictionary[@"runtime"] intValue];
        NSArray* videos = responseDictionary[@"videos"][@"results"];
        if(videos.count != 0){
            self.video = videos[0];
        } else{
            self.video = nil;
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    
}

- (NSString*)getTrailerID {
    if(self.video){
        return self.video[@"key"];
    } else{
        return nil;
    }
}

- (BOOL)hasTrailer {
    if(self.video){
        return YES;
    } else{
        return NO;
    }
}

- (NSString*)getRunTime {
    int hours = self.runtime / 60;
    int minutes = self.runtime % 60;
    return [NSString stringWithFormat:@"%d hr %d mins",hours,minutes];
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
