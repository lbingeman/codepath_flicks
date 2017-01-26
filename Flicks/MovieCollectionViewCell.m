//
//  MovieCollectionViewCell.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-25.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "MovieCollectionViewCell.h"

@implementation MovieCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.moviePoster.frame = CGRectInset(self.contentView.bounds, 10, 50);
}

@end
