//
//  MovieViewController.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-24.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "MovieViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "UIImageView+CustomImageFade.h"

#define buffer 20.0f;
@interface MovieViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *runTime;
    @property (weak, nonatomic) IBOutlet UILabel *starAmount;
    @property (weak, nonatomic) IBOutlet UIView *trailerPlay;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadScreen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadScreen {
    [self setContent];
    
    //Resize movie overview
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
- (IBAction)playTapped:(UITapGestureRecognizer *)sender {
    [self playVideoWithVideoID:[self.movie getTrailerID]];
}

- (void)setContent{
    self.movieOverview.text = self.movie.movieDescription;
    self.movieTitle.text = self.movie.title;
    [self.posterImage setImageWithLowQualityURL:self.movie.lowQualityPoster highQualityURL:self.movie.highQualityPoster];
    self.releaseDateLabel.text = [self.movie getReleaseDate];
    self.runTime.text = [self.movie getRunTime];
    self.starAmount.text = [NSString stringWithFormat:@"%.1f",self.movie.voteAverage.floatValue];
    self.trailerPlay.hidden = ![self.movie hasTrailer];
}

//Trailer Playing
- (void) playVideoWithVideoID:(NSString*)videoID {
    XCDYouTubeVideoPlayerViewController* videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerViewController.moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
}

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
    MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (finishReason == MPMovieFinishReasonPlaybackError)
    {
        NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
        // Handle error
    }
}

@end
