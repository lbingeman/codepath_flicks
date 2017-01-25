//
//  ViewController.m
//  Flicks
//
//  Created by Laura Bingeman on 2017-01-23.
//  Copyright © 2017 Laura Bingeman. All rights reserved.
//

#import "ViewController.h"
#import "MovieCell.h"
#import "NetworkManager.h"
#import "MovieModel.h"
#import "MovieViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

typedef NS_ENUM(NSInteger, MovieListType) {
    MovieListTypeNowPlaying,
    MovieListTypeTopRated,
};

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
    @property (strong,nonatomic) NetworkManager* networkManager;
    @property (strong,nonatomic) UIRefreshControl* refreshControl;
    @property (weak, nonatomic) IBOutlet UITableView *movieTableView;
    @property (strong, nonatomic) NSArray<MovieModel*>* movies;
    @property (weak, nonatomic) IBOutlet UIView *networkError;
    @property (weak, nonatomic) IBOutlet UISegmentedControl *movieSegmentControl;
    @property (nonatomic, assign) MovieListType type;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.movieTableView.dataSource = self;
    self.movieTableView.delegate = self;
    
    self.movies = [NSArray new];

    self.networkManager = [NetworkManager new];
    
    static NSDictionary<NSString *, NSNumber *> *restorationIdentifierToTypeMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        restorationIdentifierToTypeMapping = @{
                                               @"nowPlaying": @(MovieListTypeNowPlaying),
                                               @"topRated": @(MovieListTypeTopRated),
                                               };
    });
    self.type = restorationIdentifierToTypeMapping[self.restorationIdentifier].integerValue;
    
    
    [self fetchMovies];
    
    [self.movieSegmentControl addTarget:self action:@selector(viewTypeChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.movieTableView insertSubview:self.refreshControl atIndex:0];
    
    
}
- (IBAction)viewTypeChanged:(UISegmentedControl *)sender {
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//UI Table View Data Source Functions
// how do I build the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell* cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell"];
    
    MovieModel* currentMovie = [self.movies objectAtIndex:indexPath.row];
    cell.overview.text = currentMovie.movieDescription;
    cell.movieTitle.text = currentMovie.title;

    [cell.posterImage setImageWithURL:[currentMovie posterURL]];
    
    return cell;
}

// how many rows in my table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.movies count];
}

//segue controls
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieViewController* newViewController = segue.destinationViewController;
    NSIndexPath* indexPath = [self.movieTableView indexPathForCell:sender];
    newViewController.movie = [self.movies objectAtIndex:indexPath.row];
}

-(void)refreshControl:(UIRefreshControl*)refreshControl {
    [self fetchMovies];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//-(void)fetchNowPlaying {
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [self.networkManager fetchNowPlayingMovies:^(NSError* error, NSArray* movies){
//        if (!error) {
//            self.movies = movies;
//            dispatch_async(dispatch_get_main_queue(),^{
//                [self.movieTableView reloadData];
//                [self.refreshControl endRefreshing];
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//        } else {
//            NSLog(@"An error occurred: %@", error.description);
//            [self.networkError setHidden:NO];
//        }
//    }];
//}
//
//-(void)fetchTopMovies {
//    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeAnnularDeterminate;
//    hud.label.text = @"Loading";
//    [self.networkManager fetchTopMovies:^(NSError* error, NSArray* movies){
//        if (!error) {
//            self.movies = movies;
//            dispatch_async(dispatch_get_main_queue(),^{
//                [self.movieTableView reloadData];
//                [self.refreshControl endRefreshing];
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//        } else {
//            NSLog(@"An error occurred: %@", error.description);
//        }
//    }];
//}

-(void)fetchMovies {
    void(^completionHandler)(NSError*, NSArray*) = ^(NSError* error, NSArray* movies){
        if (!error) {
            self.movies = movies;
            dispatch_async(dispatch_get_main_queue(),^{
                [self.movieTableView reloadData];
                [self.refreshControl endRefreshing];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        } else {
            NSLog(@"An error occurred: %@", error.description);
            [self.networkError setHidden:NO];
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    };
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Loading";
    switch (self.type) {
        case MovieListTypeTopRated:
            [self.networkManager fetchTopMovies:completionHandler];
            break;
        default:
            [self.networkManager fetchNowPlayingMovies:completionHandler];
            break;
    }
}





@end
