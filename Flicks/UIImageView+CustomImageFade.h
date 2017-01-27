//
//  UIImageView+CustomImageFade.h
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-26.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (CustomImageFade)
     -(void)setImageFadeLoadWithURL:(NSURL*)url;
    -(void)setImageWithLowQualityURL:(NSURL*)lowURL highQualityURL:(NSURL*)highURL;
@end
