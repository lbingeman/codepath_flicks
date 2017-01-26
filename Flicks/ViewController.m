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
#import "MovieCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>


typedef NS_ENUM(NSInteger, MovieListType) {
    MovieListTypeNowPlaying,
    MovieListTypeTopRated,
};

typedef NS_ENUM(NSInteger, MovieDisplayType) {
    MovieDisplayTypeList,
    MovieDisplayTypeGrid,
};

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
    @property (strong,nonatomic) NetworkManager* networkManager;
    @property (strong,nonatomic) UIRefreshControl* refreshControl;
    @property (weak, nonatomic) IBOutlet UITableView *movieTableView;
    @property (weak, nonatomic) IBOutlet UICollectionView *movieCollectionView;
    @property (strong, nonatomic) NSArray<MovieModel*>* movies;
    @property (weak, nonatomic) IBOutlet UIView *networkError;
    @property (weak, nonatomic) IBOutlet UISegmentedControl *movieSegmentControl;
    @property (nonatomic, assign) MovieListType type;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *movieCollectionFlow;
    @property (nonatomic, assign) MovieDisplayType displayType;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.movieTableView.dataSource = self;
    self.movieTableView.delegate = self;
    
    self.movieCollectionView.dataSource = self;
    self.movieCollectionView.delegate = self;
    
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
    self.displayType = self.movieSegmentControl.selectedSegmentIndex;
    
    [self showAndHideDisplayTypes];
    [self fetchMovies];
    
    [self.movieSegmentControl addTarget:self action:@selector(viewTypeChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.movieTableView insertSubview:self.refreshControl atIndex:0];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell* movieCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"movieCollectionCell" forIndexPath:indexPath];
 
    MovieModel* movie = [self.movies objectAtIndex:indexPath.row];
    [movieCell.moviePoster setImageWithURL:[movie posterURL]];
    
    return movieCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (void)showAndHideDisplayTypes {
    switch (self.displayType) {
        case MovieDisplayTypeList:
            self.displayType = MovieDisplayTypeList;
            
            [self.movieTableView setHidden:NO];
            [self.movieCollectionView setHidden:YES];
            
            [self.movieTableView reloadData];
            
            break;
        case MovieDisplayTypeGrid:
            self.displayType = MovieDisplayTypeGrid;
            
            [self.movieCollectionView setHidden:NO];
            [self.movieTableView setHidden:YES];
            
            [self.movieCollectionView reloadData];
            
            break;
    }
}

- (IBAction)viewTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case MovieDisplayTypeList:
            self.displayType = MovieDisplayTypeList;
            break;
        case MovieDisplayTypeGrid:
            self.displayType = MovieDisplayTypeGrid;
            break;
    }
    [self showAndHideDisplayTypes];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger totalWidth = collectionView.bounds.size.width;
    NSInteger cellsPerRow = 3;
    CGFloat dimensions = (totalWidth) / cellsPerRow;
    return CGSizeMake(dimensions, dimensions*1.5);
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

-(void)fetchMovies {
    void(^completionHandler)(NSError*, NSArray*) = ^(NSError* error, NSArray* movies){
        if (!error) {
            self.movies = movies;
            dispatch_async(dispatch_get_main_queue(),^{
                switch (self.displayType) {
                    case MovieDisplayTypeList:
                        [self.movieTableView reloadData];
                        break;
                    case MovieDisplayTypeGrid:
                        [self.movieCollectionView reloadData];
                        break;
                }
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
