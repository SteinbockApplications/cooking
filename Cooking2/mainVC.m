//
//  mainVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "mainVC.h"
#import "Peacock.h"
#import "User.h"
#import "openVC.h"
#import "Donkey.h"
#import "Dog.h"
#import "chefVC.h"
#import "editVC.h"
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

#import "mainCell.h"
#import "filterVC.h"

#import "chefVC.h"

@interface mainVC () {

    Peacock * _peacock;
    Donkey * _donkey;
    Dog * _dog;
    User * currentUser;
    
    openVC * _openVC;
    chefVC * _chefVC;
    
    editVC * _editVC;
    filterVC * _filterVC;
    
    float w;
    float h;
    
    UIView * addButtonView;
    UIButton * addButton;
    
    bool statusBarIsHidden;
    
    
    UIScrollView * mainScroller;
    UIView * contentView;
    
    NSString * selectedGroup;
    NSString * selectedCanton;
    NSString * selectedRange;
    
    NSArray * sortedListing;
    NSMutableArray * cells;
    
    //
    UIButton * rangeButton;
    UIButton * cantonButton;
    NSString * range;
    NSString * canton;

    UISegmentedControl * seg;
}

@end

@implementation mainVC

//SETUP
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
    [self begin];
}
-(void)setup{
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metaReady) name:@"kMetaReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popOpenVC) name:@"kPopOpenVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popEditVC) name:@"kPopEditVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarAppearance:) name:@"kStatusBarAppearance" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popFilterVC:) name:@"kPopFilterVC" object:nil];
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    _dog = [Dog sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    
    
}
-(void)layout{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = self.view.bounds;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.delegate = self;
    mainScroller.alwaysBounceVertical = true;
    mainScroller.userInteractionEnabled = true;
    [self.view addSubview:mainScroller];
    
    contentView = [UIView new];
    [mainScroller addSubview:contentView];
    
    UIView * topBar = [UIView new];
    topBar.frame = CGRectMake(0, 0, w, 110);
    topBar.backgroundColor = _peacock.appColour;
    [self.view addSubview:topBar];
    
    UIButton * searchButton = [UIButton new];
    searchButton.frame = CGRectMake(0, 20, 40, 40);
    [searchButton setImage:[[UIImage imageNamed:@"search-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [searchButton setTintColor:[UIColor whiteColor]];
    [searchButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:searchButton];

    seg = [[UISegmentedControl alloc] initWithItems:@[@"Köche",@"Rezepte"]];
    seg.frame = CGRectMake((w-200)/2, 25, 200, 30);
    seg.tintColor = [UIColor whiteColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular] forKey:NSFontAttributeName];
    [seg setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [seg addTarget:self action:@selector(changeGroup) forControlEvents:UIControlEventValueChanged];
   //[topBar addSubview:seg];

    UIButton * profileButton = [UIButton new];
    profileButton.frame = CGRectMake(w-50, 20, 40, 40);
    [profileButton setImage:[[UIImage imageNamed:@"chef-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [profileButton setTintColor:[UIColor whiteColor]];
    [profileButton addTarget:self action:@selector(profile) forControlEvents:UIControlEventTouchUpInside];
    profileButton.layer.cornerRadius = 20;
    profileButton.layer.borderColor = [UIColor whiteColor].CGColor;
    profileButton.layer.borderWidth = 1.0f;
    profileButton.clipsToBounds = true;
    [topBar addSubview:profileButton];

    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(0, 69, w, 0.5);
    div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [topBar addSubview:div];
    
    //FILTERS
    UIView * filterView = [UIView new];
    filterView.frame = CGRectMake(0, 70, w, 40);
    filterView.backgroundColor = [_peacock.appColour colorWithAlphaComponent:1.5f];
    [topBar addSubview:filterView];
    
    rangeButton = [UIButton new];
    rangeButton.frame = CGRectMake(0, 0, w/2, 40);
    [rangeButton setTitle:@"Alle" forState:UIControlStateNormal];
    [rangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rangeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [rangeButton addTarget:self action:@selector(openFilter:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:rangeButton];
    
    UIImageView * filterDiv = [UIImageView new];
    filterDiv.frame = CGRectMake(w/2, 0, 0.5, 40);
    filterDiv.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [filterView addSubview:filterDiv];
    
    cantonButton = [UIButton new];
    cantonButton.frame = CGRectMake(w/2, 0, w/2, 40);
    [cantonButton setTitle:@"Schweizweit" forState:UIControlStateNormal];
    [cantonButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cantonButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [cantonButton addTarget:self action:@selector(openFilter:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:cantonButton];
    
    
    //ADD BUTTON
    addButtonView = [UIView new];
    addButtonView.frame = CGRectMake(w-80, h-80, 60, 60);
    addButtonView.backgroundColor = _peacock.appColour;
    addButtonView.layer.cornerRadius = 30.0f;
    [self.view addSubview:addButtonView];
    
    addButton = [UIButton new];
    addButton.frame = addButtonView.bounds;
    [addButton setImage:[[UIImage imageNamed:@"add-120.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [addButton setTintColor:[UIColor whiteColor]];
    [addButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [addButton addTarget:self action:@selector(pushEditVC) forControlEvents:UIControlEventTouchUpInside];
    [addButtonView addSubview:addButton];
    
    
}
-(void)begin{
    
    //set seg defaults
    seg.selectedSegmentIndex = 0;
    if ([selectedGroup isEqualToString:@"recipe"]){
        seg.selectedSegmentIndex = 1;
    }
    
    //set filter defaults
    range = @"Alle";
    canton = @"Schweizweit";
    selectedGroup = @"user";
    
    //set preferences
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"preferredListing"]){
        selectedGroup = [[NSUserDefaults standardUserDefaults] valueForKey:@"preferredListing"];
    }

    //fetch meta
    [_dog fetchMetaData];
    
    //load current user
    [_donkey loadCurrentUser];

    //if there's no user, push openVC
    if (!_donkey.deviceUser){
        [self pushOpenVCShouldAnimate:false];
    } else {
        NSLog(@"load for this user: %@", _donkey.deviceUser);
    }
}

//DATA
-(void)metaReady {
    [self refreshScroller];
}
-(void)changeGroup {
    
    selectedGroup = @"user";
    if (seg.selectedSegmentIndex == 1){
        selectedGroup = @"recipe";
    }
    
    [self refreshScroller];
    
}
-(void)openFilter:(UIButton *)button {
    
    //determine filter
    NSString * filter = @"range";
    NSString * selected = range;
    if ([button isEqual:cantonButton]){
        filter = @"canton";
        selected = canton;
    }
    
    //create vc + set filter
    _filterVC = [filterVC new];
    [self addChildViewController:_filterVC];
    [self.view addSubview:_filterVC.view];
    [_filterVC beginWithFilter:filter withSelected:selected];
    
    //animate ui
    _filterVC.view.transform = CGAffineTransformMakeTranslation(0, h);
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _filterVC.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                     }];

}
-(void)popFilterVC:(NSString *)filter {
    
    //animate ui
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _filterVC.view.transform = CGAffineTransformMakeTranslation(0, h);
                     }
                     completion:^(BOOL finished){
                     
                         [_filterVC removeFromParentViewController];
                         [_filterVC.view removeFromSuperview];
                         _filterVC = nil;
                         
                     }];

    NSLog(@"filters are: %@", filter);
    
    //
    
    [self refreshScroller];
}
-(int)daysForRange {
    if ([range isEqualToString:@"Alle"]){
        return -1;
    } else if ([range isEqualToString:@"Heute"]){
        return 1;
    } else if ([range isEqualToString:@"Woche"]){
        return 7;
    } else if ([range isEqualToString:@"Monat"]){
        return 31;
    }
    
    return 0;
}
-(void)refreshScroller {
    
    //set list based on group
    if ([selectedGroup isEqualToString:@"user"]){ 
        sortedListing = [_donkey sortUsersByScoreForCanton:@"all" inRange:-1];
    } else {
        sortedListing = [_donkey sortRecipesByScoreForCanton:@"all" inRange:[self daysForRange]];
    }

    //empty out
    for (NSObject * obj in cells){
        if ([obj isKindOfClass:[mainCell class]]){
            mainCell * cell = (mainCell *)obj;
            [cell removeFromSuperview];
        }
    }
    
    //create new
    cells = [NSMutableArray new];
    for (int n = 0; n < sortedListing.count; n++){
        [cells addObject:[NSObject new]];
    }
    
    //force update
    [self scrollViewDidScroll:mainScroller];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (![scrollView isEqual:mainScroller]){
        return;
    }
    
    //set vars
    float topMargin = -h; //distance above y at which cells should disappear
    float bottomMargin = h; //distance below y + h at which cells should disappear
    float y = mainScroller.contentOffset.y; //actual content offset
    float tallyY = 110; //the running height of y offset for cells
    float tallyX = 0;
    CGSize cellSize = CGSizeMake(w, 200);
    
    //KEY: update content size (moving counter scroll)
    //contentView.transform = CGAffineTransformMakeTranslation(0, y);
    
    //add and remove cells depending on offset
    for (int n = 0; n < cells.count; n++){
        
        
        //check if the object at the
        //nth index is an allocated cell
        bool isCell = false;
        if ([cells[n] isKindOfClass:[mainCell class]]){ isCell = true; }
        
        if (tallyY + cellSize.height - topMargin < y){//cells above not meeting threshold
            
            if (isCell){ //Removes the cells above if they exist
                [[cells objectAtIndex:n] removeFromSuperview];
                [cells replaceObjectAtIndex:n withObject:[NSObject new]];
            }
        } else if (tallyY > y + mainScroller.frame.size.height + bottomMargin){ //cells below not meeting threshold
            
            if (isCell){ //Removes the cells below if they exist
                [[cells objectAtIndex:n] removeFromSuperview];
                [cells replaceObjectAtIndex:n withObject:[NSObject new]];
            }
            
        } else {
            
            //Create the cell if none exists
            if (!isCell){
                
                NSLog(@"CREATE");
                
                //create the cell, set frame and add to contentView
                mainCell * cell = [[mainCell alloc] initWithFrame:CGRectMake(tallyX, tallyY, cellSize.width, cellSize.height)];
                cell.layer.shouldRasterize = true;
                cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
                cell.opaque = true;
                cell.clipsToBounds = true;
                cell.backgroundColor = [UIColor redColor];
                [contentView addSubview:cell];
                
                //data
                NSDictionary * d = sortedListing[n];
                if ([selectedGroup isEqualToString:@"user"]){
                    [cell updateForUser:d];
                } else {
                    [cell updateForRecipe:d];
                }
            
                [cell.button addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
                
                /*
                //media
                if ([cachedThumbs[n] isKindOfClass:[UIImage class]]){ //thumb is available
                    //if a file exists, show it now
                    cell.iv.image = cachedThumbs[n];
                } else {
                    //otherwise pull it
                    [_dog fetchFile:seal.thumbFN fromFolder:@"thumbs" callback:seal.thumbFN];
                }
                */
                
                //replace NSObject with cell
                [cells replaceObjectAtIndex:n withObject:cell];
            }
        }
        
        tallyX += cellSize.width;
        if (tallyX >= w){
            tallyX = 0;
            tallyY += cellSize.height;
            
        }

    }
    
    
    contentView.frame = CGRectMake(0,0, w, cells.count*cellSize.height);
    mainScroller.contentSize = CGSizeMake(w, cells.count*cellSize.height);
    //NSLog(@"CELLS IS %@", cells);
    

    //parallax effect
    float travelDistance = h + cellSize.height;
    for (int n = 0; n < cells.count; n++){
        NSObject * obj = cells[n];
        if ([obj isKindOfClass:[mainCell class]]){
            mainCell * cell = cells[n];
            float cellY = [contentView convertPoint:cell.frame.origin toView:self.view].y+cellSize.height;
            float p = cellY/travelDistance; //percentage complete of vertical journey
            cell.bgIV.transform = CGAffineTransformMakeTranslation(0, p*-30);
        }
    }
    
    
}


-(void)cellClick:(UIButton *)button {
    
    NSLog(@"cell click");
    
    mainCell * cell = button.superview;
    int index = (int)[cells indexOfObject:cell];
    
    NSLog(@"index is %i", index);
    
    if ([selectedGroup isEqualToString:@"user"]){
        
    }
    //create vc + set chef
    _chefVC = [chefVC new];
    [self addChildViewController:_chefVC];
    [self.view addSubview:_chefVC.view];
    
    
    //animate ui
    _chefVC.view.transform = CGAffineTransformMakeTranslation(w, 0);
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _chefVC.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                     }];
    
    
}
-(void)search {
    
}
-(void)profile {
    
    _chefVC = [chefVC new];
    [self addChildViewController:_chefVC];
    [self.view addSubview:_chefVC.view];
    
}



//EDIT (NEW RECIPE)
-(void)pushEditVC {
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         addButtonView.frame = self.view.frame;
                         addButton.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45)), CGAffineTransformMakeTranslation(w-60, 15));
                     }
                     completion:^(BOOL finished){
                         _editVC = [editVC new];
                         [self addChildViewController:_editVC];
                         [self.view addSubview:_editVC.view];
                     }];
    
    CABasicAnimation * corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    corner.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    corner.toValue = @(0.0f);
    corner.duration = 0.6f;
    corner.removedOnCompletion = false;
    corner.fillMode = kCAFillModeForwards;
    [addButtonView.layer addAnimation:corner forKey:@"corner"];
    
}
-(void)popEditVC {
    
    [_editVC removeFromParentViewController];
    [_editVC.view removeFromSuperview];
    _editVC = nil;
    
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         addButtonView.frame = CGRectMake(w-80, h-80, 60, 60);
                         addButton.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    CABasicAnimation * corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    corner.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    corner.toValue = @(30.0f);
    corner.duration = 0.6f;
    corner.removedOnCompletion = false;
    corner.fillMode = kCAFillModeForwards;
    [addButtonView.layer addAnimation:corner forKey:@"corner"];
    
    
}
-(void)profileUpdated:(NSNotification *)n {
    
    /*
    if (_openVC){
        
        [UIView animateWithDuration:0.6f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             _openVC.view.transform = CGAffineTransformMakeTranslation(0, _openVC.view.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
    }
    */
}

//OPEN
-(void)pushOpenVCShouldAnimate:(bool)animate {

    _openVC = [openVC new];
    [self addChildViewController:_openVC];
    [self.view addSubview:_openVC.view];
    
    if (animate){
        
    }
}
-(void)popOpenVC {
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         _openVC.view.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         
                         [_openVC removeFromParentViewController];
                         [_openVC.view removeFromSuperview];
                         _openVC = nil;
                     
                     }];
    
    [self refreshScroller];
    
}

//STATUS BAR
-(void)updateStatusBarAppearance:(NSNotification *)n {
    statusBarIsHidden = [n.object boolValue];
    [self setNeedsStatusBarAppearanceUpdate];
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden{
    return statusBarIsHidden;
}

//OTHER
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 
 */

/*
 //top bar effect
 if (lastOffset < scrollView.contentOffset.y) { //up
 
 if (topBar.frame.origin.y > -40 && scrollView.contentOffset.y > 0){
 topOffset += (lastOffset-scrollView.contentOffset.y)/5;
 topOffset = MAX(-40, topOffset);
 topBar.transform = CGAffineTransformMakeTranslation(0, topOffset);
 
 float p = topOffset / -40;
 backButton.alpha = 1-p;
 
 }
 
 } else if (lastOffset > scrollView.contentOffset.y) {//down
 
 if (topBar.frame.origin.y < 0 && scrollView.contentOffset.y < scrollView.contentSize.height-scrollView.frame.size.height){
 topOffset += (lastOffset-scrollView.contentOffset.y)/5;
 topOffset = MIN(0, topOffset);
 topBar.transform = CGAffineTransformMakeTranslation(0, topOffset);
 
 float p = topOffset / -40;
 backButton.alpha = 1-p;
 }
 }
 
 lastOffset = scrollView.contentOffset.y;
 */



@end
