//
//  MovieModel.h
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-23.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject
@property (nonatomic,strong)NSString* title;
@property (nonatomic,strong)NSURL* posterURL;
@property (nonatomic,strong)NSURL* backgroundPath;
@property (nonatomic,strong)NSString* movieDescription;
@property (nonatomic,strong)NSString* movieID;
@property (nonatomic,strong)NSDate* releaseDate;
@property (nonatomic,strong)NSNumber* voteAverage;
@property (nonatomic)int runtime;
@property (nonatomic,strong) NSURL* highQualityPoster;
@property (nonatomic,strong) NSURL* lowQualityPoster;

- (instancetype)initWithDictionary:(NSDictionary*) jsonDictionary;
- (NSString*)getReleaseDate;
- (NSString*)getRunTime;
- (void)setDetailedDataWithJSON:(NSDictionary*)responseDictionary;
- (NSString*)getTrailerID;
- (BOOL)hasTrailer;
@end
