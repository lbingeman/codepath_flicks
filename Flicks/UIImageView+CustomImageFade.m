//
//  UIImageView+CustomImageFade.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-26.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "UIImageView+CustomImageFade.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation UIImageView (CustomImageFade)
-(void)setImageFadeLoadWithURL:(NSURL*)url {
    __weak UIImageView *weakImageview = self;
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest* imageRequest, NSHTTPURLResponse* imageResponse, UIImage* image){
        UIImageView *strongImageview = weakImageview;
        if(imageResponse != nil){
            [strongImageview setAlpha:0];
            strongImageview.image = image;
            [UIView animateWithDuration:0.3 animations:^{
                strongImageview.alpha = 1.0;
            }];
        } else{
            strongImageview.image = image;
        }
    } failure:^(NSURLRequest* imageRequest, NSHTTPURLResponse* imageResponse, NSError* error){
        
    }];
}

-(void)setImageWithLowQualityURL:(NSURL*)lowURL highQualityURL:(NSURL*)highURL {
    NSURLRequest* highRequest = [NSURLRequest requestWithURL:highURL];
    NSURLRequest* lowRequest = [NSURLRequest requestWithURL:lowURL];
    
    __weak UIImageView* weakImageView = self;
    
    [self setImageWithURLRequest:lowRequest placeholderImage:nil success:^(NSURLRequest* smallImageRequest, NSHTTPURLResponse* smallImageResponse, UIImage* smallImage){
        UIImageView* strongImageView = weakImageView;
        strongImageView.image = smallImage;
        
        if(smallImageResponse != nil){
            strongImageView.alpha = 0.0;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            __weak UIImageView* weakImageViewLarge = strongImageView;
            strongImageView.alpha = 1.0;

            [strongImageView setImageWithURLRequest:highRequest placeholderImage:smallImage success:^(NSURLRequest* imageRequest, NSHTTPURLResponse* imageResponse, UIImage* image){
                UIImageView* strongImageViewLarge = weakImageViewLarge;
                if(imageResponse != nil){
                    [strongImageViewLarge setAlpha:0];
                    strongImageViewLarge.image = image;
                    [UIView animateWithDuration:0.3 animations:^{
                        strongImageViewLarge.alpha = 1.0;
                    }];
                } else{
                    strongImageViewLarge.image = image;
                }
            } failure:^(NSURLRequest* imageRequest, NSHTTPURLResponse* imageResponse, NSError* error){
                
            }];
        }];
    } failure:^(NSURLRequest* imageRequest, NSHTTPURLResponse* imageResponse, NSError* error){
        
    }];
}
@end
