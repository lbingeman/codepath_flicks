//
//  MovieViewController.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-24.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "MovieViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#define buffer 20.0f;
@interface MovieViewController ()

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContent];
    

    //Resize movie overview
    NSLog(@"View:%f",_movieView.frame.size.height);
    [_movieOverview sizeToFit];

    //set scroll view
    [self setScrollView];
    
    
    
}
- (void)setScrollView {
    
    float contentHeight = self.movieView.frame.size.height;
    self.movieScrollView.contentSize = CGSizeMake(self.movieScrollView.bounds.size.width, contentHeight);

    CGFloat offsetSize = self.movieView.frame.size.height - self.movieTitle.frame.size.height - buffer;
    self.movieScrollView.contentInset = UIEdgeInsetsMake(offsetSize, 0, 0, 0);
    self.movieScrollView.scrollIndicatorInsets= UIEdgeInsetsMake(offsetSize, 0, 0, 0);

}

- (void)setContent{
    self.movieOverview.text = self.movie.movieDescription;
    self.movieTitle.text = self.movie.title;
    [self.posterImage setImageWithURL:[_movie posterURL]];
    self.releaseDateLabel.text = [self.movie getReleaseDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
