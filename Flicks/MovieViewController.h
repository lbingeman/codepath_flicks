//
//  MovieViewController.h
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-24.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieModel.h"
@interface MovieViewController : UIViewController
@property (nonatomic,weak) MovieModel* movie;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UIScrollView *movieScrollView;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *movieOverview;
@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
- (void)reloadScreen;
@end
