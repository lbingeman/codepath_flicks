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
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIImageView+CustomImageFade.h"

#define RELOAD_DATA_TIME 60.0f

typedef NS_ENUM(NSInteger, MovieListType) {
    MovieListTypeNowPlaying,
    MovieListTypeTopRated,
};

typedef NS_ENUM(NSInteger, MovieDisplayType) {
    MovieDisplayTypeList,
    MovieDisplayTypeGrid,
};

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
{
    bool shouldBeginEditing;
    bool searchBarActive;
}

    @property (strong,nonatomic) NetworkManager* networkManager;
    @property (strong,nonatomic) UIRefreshControl* refreshControl;

    @property (weak, nonatomic) IBOutlet UICollectionView *movieCollectionView;
    @property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
    @property (weak, nonatomic) IBOutlet UIView *networkError;
    @property (weak, nonatomic) IBOutlet UISegmentedControl *movieSegmentControl;

    @property (nonatomic, assign) MovieListType type;
    @property (nonatomic, assign) MovieDisplayType displayType;
    @property (nonatomic,strong) NSDate* lastDataLoad;

    @property (strong, nonatomic) NSArray<MovieModel*>* movies;
    @property (strong,nonatomic) NSArray<MovieModel*>* filteredMovies;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.movieCollectionView.dataSource = self;
    self.movieCollectionView.delegate = self;
    
    self.searchBar.delegate = self;
    
    self.movies = [NSArray new];
    self.filteredMovies = [NSArray new];
    
    self.networkManager = [NetworkManager new];
    
    shouldBeginEditing = YES;
    searchBarActive = NO;
    
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
    
    [self.movieSegmentControl addTarget:self action:@selector(viewTypeChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.movieCollectionView insertSubview:self.refreshControl atIndex:0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    if(!self.lastDataLoad || fabs([self.lastDataLoad timeIntervalSinceNow]) > RELOAD_DATA_TIME){
        [self fetchMovies];
    }
}


//search bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(![searchBar isFirstResponder]){
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        searchBarActive = NO;
        shouldBeginEditing = NO;
    }else{
        if(searchText.length > 0){
            searchBarActive = YES;
            NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@", searchText];
            self.filteredMovies = [self.movies filteredArrayUsingPredicate:resultPredicate];
        } else{
            searchBarActive = NO;
        }
    }
    [self.movieCollectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBarActive = YES;
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    searchBarActive = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self.movieCollectionView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    bool boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


// collection view data source
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieModel* movie;
    if(searchBarActive == YES){
        movie = [self.filteredMovies objectAtIndex:indexPath.row];
    } else{
       movie = [self.movies objectAtIndex:indexPath.row];
    }
    if(self.displayType == MovieDisplayTypeGrid){
        MovieCollectionViewCell* movieCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"movieGridCell" forIndexPath:indexPath];
        [movieCell.moviePoster setImageFadeLoadWithURL:[movie posterURL]];
        return movieCell;
    } else{
        MovieCell* movieCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"movieListCell" forIndexPath:indexPath];
        movieCell.overview.text = movie.movieDescription;
        movieCell.movieTitle.text = movie.title;
        [movieCell.posterImage setImageFadeLoadWithURL:[movie posterURL]];
        return movieCell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(searchBarActive == YES){
        return self.filteredMovies.count;
    } else{
        return self.movies.count;
    }
}

// collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger totalWidth = collectionView.bounds.size.width;
    NSInteger cellsPerRow = 3;
    if(self.displayType == MovieDisplayTypeList){
        return CGSizeMake(totalWidth, collectionView.bounds.size.height/4);
    }
    CGFloat dimensions = (totalWidth) / cellsPerRow;
    return CGSizeMake(dimensions, dimensions*1.5);
}


//segment control for view type (Grid <-> List)
- (IBAction)viewTypeChanged:(UISegmentedControl *)sender {
    self.displayType = sender.selectedSegmentIndex;
    [self.movieCollectionView reloadData];
}


//segue controls (Movie List -> Detail view)
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieViewController* newViewController = segue.destinationViewController;
    NSIndexPath* indexPath = [self.movieCollectionView indexPathForCell:sender];
    MovieModel* currentMovie;
    if(searchBarActive == YES){
        currentMovie = [self.filteredMovies objectAtIndex:indexPath.row];
    } else{
        currentMovie = [self.movies objectAtIndex:indexPath.row];
    }
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:newViewController.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Loading";
    
    [self.networkManager fetchMovieDetailsWithID:[currentMovie movieID] completionHandler:^(NSError* error, NSDictionary* dictionary){
        if(!error){
            [currentMovie setDetailedDataWithJSON:dictionary];
            [newViewController setMovie:currentMovie];
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideHUDForView:newViewController.view animated:YES];
                [newViewController reloadScreen];
            });
        } else{
            NSLog(@"%@",error.description);
        }
    }];
}


// Refresh on Pull Controls
-(void)refreshControl:(UIRefreshControl*)refreshControl {
    [self fetchMovies];
}


// Get Movie Data
-(void)fetchMovies {
    void(^completionHandler)(NSError*, NSArray*) = ^(NSError* error, NSArray* movies){
        if (!error) {
            self.movies = movies;
            self.lastDataLoad = [NSDate date];
            dispatch_async(dispatch_get_main_queue(),^{
                [self.refreshControl endRefreshing];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.networkError setHidden:YES];
                [self.movieCollectionView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(),^{
                [self.networkError setHidden:NO];
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



