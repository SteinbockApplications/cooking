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
#import "Fish.h"

#import "addVC.h"
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)



#import "chefVC.h"
#import "recipeVC.h"

#import "recipeCVC.h"
#import "chefCVC.h"

@interface mainVC () {
    
    Peacock * _peacock;
    Donkey * _donkey;
    Dog * _dog;
    Fish * _fish;
    User * currentUser;
    
    openVC * _openVC;
    chefVC * _chefVC;
    recipeVC * _recipeVC;
    
    addVC * _addVC;

    
    float w;
    float h;
    
    UIView * addButtonView;
    UIButton * addButton;
    
    bool statusBarIsHidden;
    bool statusBarIsDark;
    
    
    UIScrollView * mainScroller;
    UIView * contentView;
    
    NSString * selectedGroup;
    NSString * selectedCanton;
    NSString * selectedRange;
    
    NSArray * sortedListing;
    NSMutableArray * cells;
    
    //

    NSString * canton;
    
    
    //
    UIScrollView * newScroller;
    UIScrollView * userScroller;
    UIScrollView * recipeScroller;
    
    UIImageView * mainScrollerCover;
    
    NSArray * sortedNew;
    NSArray * sortedUsers;
    NSArray * sortedRecipes;
    
    NSMutableArray * userCells;
    NSMutableArray * recipeCells;
    
    int userTouchIndex;
    UIView * userContentView;
    int recipeTouchIndex;
    UIView * recipeContentView;
    
    //
    UIView * cantonView;
    UIScrollView * cantonScroller;
    NSMutableArray * cantonLabels;
    UIImageView * cantonCover;
    bool cantonsAreShowing;
    UILabel * cantonLabel;
    UIImageView * cantonArrow;
    
    //
    UIView * topBar;
    UILabel * initialsLabel;
    UIImageView * profileIV;
    
    //
    int page;
    
    UICollectionView * recentCV;
    UICollectionView * chefCV;
    UICollectionView * recipeCV;

    NSMutableDictionary * downloads;
    NSMutableArray * recentPaths;
    NSMutableArray * userPaths;
    NSMutableArray * recipePaths;
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

    //notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popOpenVC) name:@"kPopOpenVC" object:nil]; //openVC
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popAddVC) name:@"kPopAddVC" object:nil]; //popADdVC
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metaReady) name:@"kMetaReady" object:nil]; //metaReady
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileReady:) name:@"kFileReady" object:nil]; //status bar
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushChefVC:) name:@"kPushChefVC" object:nil]; //pushChef
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popChefVC) name:@"kPopChefVC" object:nil]; //popChef
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushRecipeVC:) name:@"kPushRecipeVC" object:nil]; //pushRecipe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popRecipeVC) name:@"kPopRecipeVC" object:nil]; //popRecipe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarUpdate:) name:@"kStatusBarUpdate" object:nil]; //status bar

    
    //animals
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    _dog = [Dog sharedInstance];
    _fish = [Fish sharedInstance];
    
    //layout vars
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;

    downloads = [NSMutableDictionary new];
}
-(void)layout{
    
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9f];
    
    [self layoutScrollers];
    [self layoutCantonView];
    [self layoutTopBar];
    [self layoutAddButton];

}
-(void)begin{
    
    [_fish deleteFiles];
    
    //load current user
    [_donkey loadCurrentUser];
    
    //fetch meta
    [_dog fetchMetaData];

    //if there's no user, push openVC
    if (!_donkey.deviceUser){
        [self pushOpenVCShouldAnimate:false];
    } else {
        
        //update ui
        initialsLabel.text = [_peacock initialsForName:_donkey.deviceUser[@"name"]];
        //profile IV
        NSLog(@"load for this user: %@", _donkey.deviceUser);
    
        //set initial ui
        [_peacock updateStatusBarIsDark:true isHidden:false];

    }

    [mainScrollerCover setAlpha:0.0f];
    
} //requests meta from dog

//DATA
-(void)metaReady {
    
    //update the data + ui
    [self cantonDidChange]; //uses  preferred canton
    
} //meta has returned --> update data + ui (cantonDidChange)
-(void)cantonDidChange {
    
    //update the data
    [_donkey sortDataForPreferredCanton];
    
    
    recentPaths = [NSMutableArray new];
    for (NSDictionary * d in _donkey.cantonRecents){

        NSString * path = @"";
        if ([d[@"type"] isEqualToString:@"user"]){
            path = [NSString stringWithFormat:@"%@/%@", d[@"userID"], @"profile_thumb.jpg"];
        } else if ([d[@"type"] isEqualToString:@"recipe"]){
            path = [NSString stringWithFormat:@"%@/%@/%@", d[@"userID"], d[@"recipeID"], @"hero.jpg"];
        }
        [recentPaths addObject:path];
        
    }
    
    userPaths = [NSMutableArray new];
    for (NSDictionary * d in _donkey.cantonUsers){
        [userPaths addObject:[NSString stringWithFormat:@"%@/%@", d[@"userID"], @"profile_thumb.jpg"]];
    }
    
    recipePaths = [NSMutableArray new];
    for (NSDictionary * d in _donkey.cantonRecipes){
        [recipePaths addObject:[NSString stringWithFormat:@"%@/%@/%@", d[@"userID"], d[@"recipeID"], @"hero.jpg"]];
    }
    NSLog(@"recent paths: %@", recentPaths);
    NSLog(@"userpaths is %@", userPaths);
    NSLog(@"recipepaths is %@", recipePaths);
    
    
    //update the ui
    [self refreshScroller];
    [self updateUIForSelectedCanton];
    
} //updates data for canton + updates ui

//TOPBAR
-(void)layoutTopBar {
    
    //TOPBAR
    topBar = [UIView new];
    topBar.frame = CGRectMake(0, 0, w, 60);
    topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topBar];
    
    CAGradientLayer * topBarGradient = [CAGradientLayer layer];
    topBarGradient.frame = CGRectMake(0, 0, w, 60);
    topBarGradient.colors = [NSArray arrayWithObjects:
                             (id)[UIColor whiteColor].CGColor,
                             (id)[UIColor whiteColor].CGColor,
                             (id)[[UIColor whiteColor] colorWithAlphaComponent:(0.0f)].CGColor,
                             (id)[UIColor whiteColor].CGColor,
                             (id)[UIColor whiteColor].CGColor,
                             nil];
    topBarGradient.locations = @[@0.0,@0.2,@0.5,@0.8,@1.0];
    topBarGradient.startPoint = CGPointMake(0.0f, 0.5f);
    topBarGradient.endPoint = CGPointMake(1.0f, 0.5f);
    [topBar.layer insertSublayer:topBarGradient atIndex:0];
    
    UIImageView * searchIV = [UIImageView new];
    searchIV.frame = CGRectMake(10, 22, 30, 30);
    searchIV.contentMode = UIViewContentModeScaleAspectFit;
    searchIV.image = [[UIImage imageNamed:@"search-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    searchIV.tintColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    [topBar addSubview:searchIV];
    
    profileIV = [UIImageView new];
    profileIV.frame = CGRectMake(w-40, 22, 30, 30);
    profileIV.layer.cornerRadius = 15.0f;
    profileIV.contentMode = UIViewContentModeScaleAspectFit;
    profileIV.clipsToBounds = true;
    profileIV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    [topBar addSubview:profileIV];
    
    initialsLabel = [UILabel new];
    initialsLabel.frame = profileIV.bounds;
    initialsLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
    initialsLabel.textAlignment = NSTextAlignmentCenter;
    initialsLabel.textColor = [UIColor whiteColor];
    [profileIV addSubview:initialsLabel];
    
}

//SEARCH
-(void)search {
    
}

//PROFILE
-(void)profile {
    
}

//CANTONS
-(void)layoutCantonView {
    
    cantonView = [UIView new];
    cantonView.frame = CGRectMake(0, -h+100, w, h);
    cantonView.backgroundColor = _peacock.appleGrey;
    [self.view addSubview:cantonView];
    
    //top cell (Schweizweit)
    UIView * topCell = [UIView new];
    topCell.frame = CGRectMake(0, 0, w, 80);
    [cantonView addSubview:topCell];
    
    UILabel * topCellLabel = [UILabel new];
    topCellLabel.frame = CGRectMake(20, 20, w-40, 60);
    topCellLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightBold];
    topCellLabel.text = [_donkey.cantons[0] uppercaseString];
    [topCell addSubview:topCellLabel];
    
    cantonLabels = [NSMutableArray new];
    [cantonLabels addObject:topCellLabel];
    
    UIButton * topCellButton = [UIButton new];
    topCellButton.frame = topCell.bounds;
    [topCellButton addTarget:self action:@selector(cantonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [topCellButton setTag:0];
    [topCell addSubview:topCellButton];
    
    UIImageView * topCellDiv = [UIImageView new];
    topCellDiv.frame = CGRectMake(0, 79.5f, w, 0.5f);
    topCellDiv.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [topCellButton addSubview:topCellDiv];
    
    //scroller
    cantonScroller = [UIScrollView new];
    cantonScroller.frame = CGRectMake(0, 80, w, h-120);
    cantonScroller.showsVerticalScrollIndicator = false;
    cantonScroller.showsHorizontalScrollIndicator = false;
    [cantonView addSubview:cantonScroller];
    
    //layout the cells
    float yOff = 0;
    for (int n = 1; n<_donkey.cantons.count; n++){
        
        NSString * cantonString = [_donkey.cantons[n] uppercaseString];
        
        UIView * cell = [UIView new];
        cell.frame = CGRectMake(0, yOff, w, 40);
        [cantonScroller addSubview:cell];
        
        UILabel * label = [UILabel new];
        label.frame = CGRectMake(20, 0, w-40, 40);
        label.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightBold];
        label.text = cantonString;
        [cell addSubview:label];
        [cantonLabels addObject:label];
        
        UIButton * button = [UIButton new];
        button.frame = cell.bounds;
        [button addTarget:self action:@selector(cantonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:n];
        [cell addSubview:button];
        
        UIImageView * div = [UIImageView new];
        div.frame = CGRectMake(20, 39.5f, w-20, 0.5f);
        div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
        [cell addSubview:div];
        
        if (n == _donkey.cantons.count-1){
            div.alpha = 0.0f;
        }
        
        yOff += 40;
    }
    
    //update the size
    cantonScroller.contentSize = CGSizeMake(w, yOff);
    
    //canton cover
    cantonCover = [UIImageView new];
    cantonCover.frame = CGRectMake(0, 0, w, h-40);
    cantonCover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    [cantonView addSubview:cantonCover];
    
    //bar
    UIView * cantonBar = [UIView new];
    cantonBar.frame = CGRectMake(0, h-40, w, 40);
    cantonBar.backgroundColor = [UIColor whiteColor];
    [cantonView addSubview:cantonBar];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(0, 0, w, 0.5f);
    div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    [cantonBar addSubview:div];
    
    cantonLabel = [UILabel new];
    cantonLabel.frame = CGRectMake(0, 0, w, 40);
    cantonLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightBold];
    cantonLabel.textAlignment = NSTextAlignmentCenter;
    cantonLabel.textColor = [UIColor blackColor];
    [cantonBar addSubview:cantonLabel];
    
    cantonArrow = [UIImageView new];
    cantonArrow.frame = CGRectMake(w-35, 10, 20, 20);
    cantonArrow.image = [[UIImage imageNamed:@"down-64.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cantonArrow.tintColor = [UIColor blackColor];
    [cantonBar addSubview:cantonArrow];
    
    UIButton * toggleCantonButton = [UIButton new];
    toggleCantonButton.frame = cantonLabel.bounds;
    [toggleCantonButton addTarget:self action:@selector(toggleCantonSelection) forControlEvents:UIControlEventTouchUpInside];
    [cantonBar addSubview:toggleCantonButton];
    
    UIImageView * cantonDiv = [UIImageView new];
    cantonDiv.frame = CGRectMake(0, 39.5, w, 0.5f);
    cantonDiv.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    [cantonBar addSubview:cantonDiv];
    
} //layout the canton view itself
-(void)toggleCantonSelection {
    
    if (cantonsAreShowing){
        cantonsAreShowing = false;
        [UIView animateWithDuration:0.8f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             topBar.transform = CGAffineTransformIdentity;
                             cantonView.transform = CGAffineTransformIdentity;
                             cantonArrow.transform = CGAffineTransformIdentity;
                             cantonCover.alpha = 1.0f;
                             mainScrollerCover.alpha = 0.0f;

                         }
                         completion:^(BOOL finished){
                         }];
       
        [UIView animateWithDuration:0.8f
                              delay:0.3f
             usingSpringWithDamping:0.5f
              initialSpringVelocity:1.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             addButtonView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){
                         }];
        
    } else {
        
        cantonsAreShowing = true;
        [UIView animateWithDuration:0.8f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             topBar.transform = CGAffineTransformMakeTranslation(0, -60);
                             cantonView.transform = CGAffineTransformMakeTranslation(0, h-100);
                             cantonArrow.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
                             cantonCover.alpha = 0.0f;
                             mainScrollerCover.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                         }];
        
        
        [UIView animateWithDuration:0.8f
                              delay:0.1f
             usingSpringWithDamping:0.8f
              initialSpringVelocity:1.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             addButtonView.transform = CGAffineTransformMakeTranslation(0, 100);
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
} //user pulls down the canton options
-(void)cantonSelected:(UIButton *)button {
    
    //set the new canton
    [_donkey setPreferredCanton:_donkey.cantons[button.tag]];
    
    //update the data + ui
    [self cantonDidChange];
    
} //user has selected a canton
-(void)updateUIForSelectedCanton {
    
    //update canton scroller label colour
    int index = (int)[_donkey.cantons indexOfObject:_donkey.selectedCanton];
    
    //deselect all but selected label
    for (int n = 0; n<cantonLabels.count; n++ ){
        
        UILabel * label = cantonLabels[n];
        if (n == index){
            label.textColor = _peacock.appColour;
        } else {
            label.textColor = [UIColor blackColor];
        }
    }
    
    //update the canton label
    [UIView transitionWithView:cantonLabel
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        cantonLabel.text = _donkey.selectedCanton.uppercaseString;
                    }
                    completion:^(BOOL finished){
                    }];

    
    //toggle the closing
    if (cantonsAreShowing){
        [self toggleCantonSelection];
    }

} //update the ui for the selected canton

//ADDING
-(void)layoutAddButton {
    
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
    [addButton addTarget:self action:@selector(pushAddVC) forControlEvents:UIControlEventTouchUpInside];
    [addButtonView addSubview:addButton];
    
}
-(void)pushAddVC {
    
    //update status bar
    [_peacock updateStatusBarIsDark:false isHidden:false];
    
    //animate button view --> frame
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
                         
                         _addVC = [addVC new];
                         [self addChildViewController:_addVC];
                         [self.view addSubview:_addVC.view];
                         
                     }];
    
    //animate button view layer --> corner radius
    CABasicAnimation * corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    corner.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    corner.toValue = @(0.0f);
    corner.duration = 0.6f;
    corner.removedOnCompletion = false;
    corner.fillMode = kCAFillModeForwards;
    [addButtonView.layer addAnimation:corner forKey:@"corner"];
    
}
-(void)popAddVC {
    
    //update status bar
    [_peacock updateStatusBarIsDark:true isHidden:false];
    
    //remove the VC
    [_addVC removeFromParentViewController];
    [_addVC.view removeFromSuperview];
    _addVC = nil;

    //animate button view --> frame
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
    
    //animate button view --> corner radius
    CABasicAnimation * corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    corner.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    corner.toValue = @(30.0f);
    corner.duration = 0.6f;
    corner.removedOnCompletion = false;
    corner.fillMode = kCAFillModeForwards;
    [addButtonView.layer addAnimation:corner forKey:@"corner"];
    
    
}
-(void)profileUpdated:(NSNotification *)n {
}

//SCROLLING
-(void)layoutScrollers {
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = CGRectMake(0, 0, w, h);
    mainScroller.contentSize = CGSizeMake(3*w, h);
    mainScroller.pagingEnabled = true;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.alwaysBounceHorizontal = true;
    mainScroller.delegate = self;
    [self.view addSubview:mainScroller];
    
    UICollectionViewFlowLayout * recentFlow = [UICollectionViewFlowLayout new];
    recentFlow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    recentFlow.minimumLineSpacing = 0.0f;
    recentFlow.minimumInteritemSpacing = 0.0f;
    recentFlow.scrollDirection = UICollectionViewScrollDirectionVertical;

    recentCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, w, h-100) collectionViewLayout:recentFlow];
    recentCV.delegate = self;
    recentCV.dataSource = self;
    recentCV.scrollEnabled = true;
    recentCV.bounces = true;
    recentCV.showsVerticalScrollIndicator = false;
    recentCV.alwaysBounceVertical = true;
    recentCV.backgroundColor = [UIColor clearColor];
    [recentCV registerClass:[chefCVC class] forCellWithReuseIdentifier:@"chefCell"];
    [recentCV registerClass:[recipeCVC class] forCellWithReuseIdentifier:@"recipeCell"];
    [mainScroller addSubview:recentCV];

    UICollectionViewFlowLayout * chefFlow = [UICollectionViewFlowLayout new];
    chefFlow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    chefFlow.minimumLineSpacing = 0.0f;
    chefFlow.minimumInteritemSpacing = 0.0f;
    chefFlow.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    chefCV = [[UICollectionView alloc] initWithFrame:CGRectMake(w, 100, w, h-100) collectionViewLayout:chefFlow];
    chefCV.delegate = self;
    chefCV.dataSource = self;
    chefCV.scrollEnabled = true;
    chefCV.bounces = true;
    chefCV.showsVerticalScrollIndicator = false;
    chefCV.alwaysBounceVertical = true;
    chefCV.backgroundColor = [UIColor clearColor];
    [chefCV registerClass:[chefCVC class] forCellWithReuseIdentifier:@"chefCell"];
    [mainScroller addSubview:chefCV];

    UICollectionViewFlowLayout * recipeFlow = [UICollectionViewFlowLayout new];
    recipeFlow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    recipeFlow.minimumLineSpacing = 0.0f;
    recipeFlow.minimumInteritemSpacing = 0.0f;
    recipeFlow.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    recipeCV = [[UICollectionView alloc] initWithFrame:CGRectMake(2*w, 100, w, h-100) collectionViewLayout:recipeFlow];
    recipeCV.delegate = self;
    recipeCV.dataSource = self;
    recipeCV.scrollEnabled = true;
    recipeCV.bounces = true;
    recipeCV.showsVerticalScrollIndicator = false;
    recipeCV.alwaysBounceVertical = true;
    recipeCV.backgroundColor = [UIColor clearColor];
    [recipeCV registerClass:[recipeCVC class] forCellWithReuseIdentifier:@"recipeCell"];
    [mainScroller addSubview:recipeCV];

    mainScrollerCover = [UIImageView new];
    mainScrollerCover.frame = self.view.bounds;
    mainScrollerCover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:mainScrollerCover];
    
}
-(void)refreshScroller {
    
    [recentCV reloadData];
    [chefCV reloadData];
    [recipeCV reloadData];
    
} //updates ui for the selected canton
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:mainScroller]){
        float xOff = mainScroller.contentOffset.x;
        float fPage = xOff / w;
        page = roundf(fPage);
        return;
    }
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    

}


//COLLECTION VIEW
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10,0,10,0);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if ([collectionView isEqual:recentCV]){
        return _donkey.cantonRecents.count;
    } else if ([collectionView isEqual:chefCV]){
        return _donkey.cantonUsers.count;
    } else if ([collectionView isEqual:recipeCV]){
        return _donkey.cantonRecipes.count;
    }
    
    return 0;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * d;
    if ([collectionView isEqual:recentCV]){
        d = _donkey.cantonRecents[indexPath.row];
    } else if ([collectionView isEqual:chefCV]){
        d = _donkey.cantonUsers[indexPath.row];
    } else if ([collectionView isEqual:recipeCV]){
        d = _donkey.cantonRecipes[indexPath.row];
    }
   
    NSString * type = d[@"type"];
    if ([type isEqualToString:@"user"]){
        return CGSizeMake(w-20, 80);
    } else if ([type isEqualToString:@"recipe"]){
        return CGSizeMake(w, 240);
    }
    
    return CGSizeZero;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
  

    UICollectionViewCell * cell;
    
    if ([collectionView isEqual:recentCV]){

        NSDictionary * d = _donkey.cantonRecents[indexPath.row];
        NSString * type = d[@"type"];
        
        if ([type isEqualToString:@"user"]){
            
            chefCVC * customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chefCell" forIndexPath:indexPath];
            customCell.profileLabel.text = [_peacock initialsForName:d[@"name"]];
            customCell.titleLabel.text = d[@"name"];
            customCell.noScoreLabel.text = [NSString stringWithFormat:@"Neues Chef - %@", [_peacock dateForTimestamp:d[@"createTS"]]];
            customCell.noScoreLabel.textColor = _peacock.appColour;
            
            customCell.subtitleLabel.text = d[@"skill"];
            if ([_donkey.selectedCanton isEqualToString:@"Schweizweit"]){
                customCell.subtitleLabel.text = d[@"location"];
            }
            
            customCell.profileIV.image = nil;
            NSString * filepath = [_dog fetchFileFromPath:recentPaths[indexPath.row] withCallback:recentPaths[indexPath.row]];
            if (filepath){ customCell.profileIV.image = [UIImage imageWithContentsOfFile:filepath];}
           
            cell = customCell;
        
        } else if ([type isEqualToString:@"recipe"]){

            recipeCVC * customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"recipeCell" forIndexPath:indexPath];
            customCell.titleLabel.text = d[@"recipeName"];
            customCell.noScoreLabel.text = [NSString stringWithFormat:@"Neues Rezept - %@", [_peacock dateForTimestamp:d[@"createTS"]]];
            customCell.noScoreLabel.textColor = _peacock.appColour;
           
            customCell.subtitleLabel.text = d[@"course"];
            if ([_donkey.selectedCanton isEqualToString:@"Schweizweit"]){
                customCell.subtitleLabel.text = d[@"location"];
            }
            
            customCell.recipeIV.image = nil;
            NSString * filepath = [_dog fetchFileFromPath:recentPaths[indexPath.row] withCallback:recentPaths[indexPath.row]];
            if (filepath){ customCell.recipeIV.image = [UIImage imageWithContentsOfFile:filepath]; }
            cell = customCell;
        
        }
        
    } else if ([collectionView isEqual:chefCV]){
        
        NSDictionary * d = _donkey.cantonUsers[indexPath.row];
        
        chefCVC * customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chefCell" forIndexPath:indexPath];
        customCell.profileLabel.text = [_peacock initialsForName:d[@"name"]];
        customCell.titleLabel.text = d[@"name"];
        customCell.subtitleLabel.text = d[@"skill"];
        if ([_donkey.selectedCanton isEqualToString:@"Schweizweit"]){
            customCell.subtitleLabel.text = d[@"location"];
        }
        
        int votes = [d[@"votes"] intValue];
        if (votes < 3){
            customCell.noScoreLabel.text = @"Zu wenige Bewertungen";
        } else {
            float score = [d[@"score"] floatValue];
            customCell.rankLabel.text = [NSString stringWithFormat:@"#%i", (int)indexPath.row+1];
            [customCell addSubview:[_peacock starViewWithScore:score ofColour:_peacock.appColour votes:votes ofColour:_peacock.appleDark forHeight:15.0f atPoint:CGPointMake(80, 10)]];
        }
        
        
        customCell.profileIV.image = nil;
        NSString * filepath = [_dog fetchFileFromPath:userPaths[indexPath.row] withCallback:userPaths[indexPath.row]];
        if (filepath){ customCell.profileIV.image = [UIImage imageWithContentsOfFile:filepath];}
   
        cell = customCell;
        
    } else if ([collectionView isEqual:recipeCV]){
        
        NSDictionary * d = _donkey.cantonRecipes[indexPath.row];
        
        recipeCVC * customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"recipeCell" forIndexPath:indexPath];
        customCell.titleLabel.text = d[@"recipeName"];
        customCell.subtitleLabel.text = d[@"course"];
        if ([_donkey.selectedCanton isEqualToString:@"Schweizweit"]){
            customCell.subtitleLabel.text = d[@"location"];
        }
        
        int votes = [d[@"votes"] intValue];
        if (votes < 3){
            customCell.noScoreLabel.text = @"Zu wenige Bewertungen";
        } else {
            float score = [d[@"score"] floatValue];
            customCell.rankLabel.text = [NSString stringWithFormat:@"#%i", (int)indexPath.row+1];
            [customCell addSubview:[_peacock starViewWithScore:score ofColour:_peacock.appColour votes:votes ofColour:_peacock.appleDark forHeight:15.0f atPoint:CGPointMake(80, 10)]];
        }
        
        
        customCell.recipeIV.image = nil;
        NSString * filepath = [_dog fetchFileFromPath:recipePaths[indexPath.row] withCallback:recipePaths[indexPath.row]];
        if (filepath){ customCell.recipeIV.image = [UIImage imageWithContentsOfFile:filepath]; }
        
        cell = customCell;
    }

    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary * d;
    if ([collectionView isEqual:recentCV]){
        d = _donkey.cantonRecents[indexPath.row];
    } else if ([collectionView isEqual:chefCV]){
        d = _donkey.cantonUsers[indexPath.row];
    } else if ([collectionView isEqual:recipeCV]){
        d = _donkey.cantonRecipes[indexPath.row];
    }
    
    NSString * type = d[@"type"];
    if ([type isEqualToString:@"user"]){
        
        NSString * userID = d[@"userID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushChefVC" object:userID];
        
    } else if ([type isEqualToString:@"recipe"]){
        
        NSString * recipeID = d[@"recipeID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushRecipeVC" object:recipeID];
    }
    

}
- (void)fileReady:(NSNotification *)n {
    
    NSString * path = n.object;
    NSString * localPath = n.userInfo[@"path"];
    NSMutableArray * updatingCells = [NSMutableArray new];
    
    if ([recentPaths containsObject:path]){
        int index = (int)[recentPaths indexOfObject:path];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if ([recentCV.indexPathsForVisibleItems containsObject:indexPath]){
            NSDictionary * d = _donkey.cantonRecents[index];
            if ([d[@"type"] isEqualToString:@"user"]){ //--> is user cell
                [updatingCells addObject:(chefCVC *)[recentCV cellForItemAtIndexPath:indexPath]];
            } else if ([d[@"type"] isEqualToString:@"recipe"]){ //--> is recipe cell
                [updatingCells addObject:(recipeCVC *)[recentCV cellForItemAtIndexPath:indexPath]];
            }
        }
    }
    
    if ([userPaths containsObject:path]){
        int index = (int)[userPaths indexOfObject:path];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if ([chefCV.indexPathsForVisibleItems containsObject:indexPath]){
            [updatingCells addObject:(chefCVC *)[chefCV cellForItemAtIndexPath:indexPath]];
        }
    }

    if ([recipePaths containsObject:path]){
        int index = (int)[recipePaths indexOfObject:path];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if ([recipeCV.indexPathsForVisibleItems containsObject:indexPath]){
           [updatingCells addObject:(recipeCVC *)[recipeCV cellForItemAtIndexPath:indexPath]];
        }
    }
    
    for (NSObject * obj in updatingCells){
        if ([obj isKindOfClass:[chefCVC class]]){
            chefCVC * cell = (chefCVC *)obj;
            [UIView transitionWithView:cell
                              duration:2.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                            animations:^{
                                cell.profileIV.image = [UIImage imageWithContentsOfFile:localPath];
                            }
                            completion:^(BOOL finished){
                            }];
            
        } else if ([obj isKindOfClass:[recipeCVC class]]){
            
                recipeCVC * cell = (recipeCVC *)obj;
                [UIView transitionWithView:cell
                                  duration:2.0f
                                   options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                                animations:^{
                                    cell.recipeIV.image = [UIImage imageWithContentsOfFile:localPath];
                                }
                                completion:^(BOOL finished){
                                }];
      
        }
    }
    
    NSLog(@"N");
}

//NAVIGATION
-(void)pushChefVC:(NSNotification *)n{
    
    NSLog(@"PUSH CHEF VC");
    
    //create vc + set chef
    _chefVC = [chefVC new];
    [self addChildViewController:_chefVC];
    [self.view addSubview:_chefVC.view];
    [_chefVC beginWithUserID:n.object];
    
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
-(void)popChefVC {
    
    NSLog(@"POP CHEF VC");
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _chefVC.view.transform = CGAffineTransformMakeTranslation(w, 0);
                     }
                     completion:^(BOOL finished){
                         [_chefVC removeFromParentViewController];
                         [_chefVC.view removeFromSuperview];
                         _chefVC = nil;
                     }];
    
}
-(void)pushRecipeVC:(NSNotification *)n{

    //create vc + set recipe
    _recipeVC = [recipeVC new];
    [self addChildViewController:_recipeVC];
    [self.view addSubview:_recipeVC.view];
    [_recipeVC beginWithRecipeID:n.object];
    
    //animate ui
    _recipeVC.view.transform = CGAffineTransformMakeTranslation(w, 0);
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _recipeVC.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                     }];
}
-(void)popRecipeVC{
    
    NSLog(@"POP RECIPE VC");
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _recipeVC.view.transform = CGAffineTransformMakeTranslation(w, 0);
                     }
                     completion:^(BOOL finished){
                         [_recipeVC removeFromParentViewController];
                         [_recipeVC.view removeFromSuperview];
                         _recipeVC = nil;
                     }];
    
    
    
}




//EDIT (NEW RECIPE)


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
    
}

//STATUS BAR
-(void)statusBarUpdate:(NSNotification *)n {
    statusBarIsHidden = [n.object[@"isHidden"] boolValue];
    statusBarIsDark = [n.object[@"isDark"] boolValue];
    [self setNeedsStatusBarAppearanceUpdate];
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    
    if (statusBarIsDark){
        return UIStatusBarStyleDefault;
    }
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


@end
