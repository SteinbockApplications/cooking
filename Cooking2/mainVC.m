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

#import "editVC.h"
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

#import "mainCell.h"
#import "filterVC.h"

#import "chefVC.h"
#import "recipeVC.h"


//
#import "userCell.h"
#import "recipeCell.h"

@interface mainVC () {
    
    Peacock * _peacock;
    Donkey * _donkey;
    Dog * _dog;
    User * currentUser;
    
    openVC * _openVC;
    chefVC * _chefVC;
    recipeVC * _recipeVC;
    
    editVC * _editVC;
    filterVC * _filterVC;
    
    float w;
    float h;
    
    UIView * addButtonView;
    UIButton * addButton;
    
    bool statusBarIsHidden;
    bool statusBarIsLight;
    
    
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
    
    UIImageView * mainscrollerCover;
    
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
    
    //
    int page;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushChefVC:) name:@"kPushChefVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popChefVC) name:@"kPopChefVC" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushRecipeVC:) name:@"kPushRecipeVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popRecipeVC) name:@"kPopRecipeVC" object:nil];
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    _dog = [Dog sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;

}
-(void)layout{
    
    self.view.backgroundColor = _peacock.appleGrey;
    
    [self layoutScrollers];
    [self layoutAddButton];
    [self layoutCantonView];
    [self layoutTopBar];


}
-(void)begin{
    
    //load current user
    [_donkey loadCurrentUser];
    
    //fetch meta
    [_dog fetchMetaData];

    //if there's no user, push openVC
    if (!_donkey.deviceUser){
        [self pushOpenVCShouldAnimate:false];
    } else {
        NSLog(@"load for this user: %@", _donkey.deviceUser);
    }

    //set initial ui
    [self updateStatusBarAppearance:nil];
    [mainscrollerCover setAlpha:0.0f];
} //requests meta from dog

//DATA
-(void)metaReady {
    
    //update the data + ui
    [self cantonDidChange]; //uses  preferred canton
    
} //meta has returned --> update data + ui (cantonDidChange)
-(void)cantonDidChange {
    
    //update the data
    [_donkey sortDataForPreferredCanton];
    
    //update the ui
    [self refreshScroller];
    [self updateUIForSelectedCanton];
    
    //NSLog(@"_donkey users is %@", _donkey.cantonUsers);
    
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
    
    UIImageView * profileIV = [UIImageView new];
    profileIV.frame = CGRectMake(w-40, 22, 30, 30);
    profileIV.layer.cornerRadius = 15.0f;
    profileIV.contentMode = UIViewContentModeScaleAspectFit;
    profileIV.clipsToBounds = true;
    profileIV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    [topBar addSubview:profileIV];
    
    UILabel * initialsLabel = [UILabel new];
    initialsLabel.frame = profileIV.bounds;
    initialsLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
    initialsLabel.textAlignment = NSTextAlignmentCenter;
    initialsLabel.textColor = [UIColor whiteColor];
    [profileIV addSubview:initialsLabel];
    
    initialsLabel.text = @"DG";
    
    
    
    
    
    /*
     UIView * labelView = [UIView new];
     labelView.frame = CGRectMake(0, 0, w*3, 60);
     labelView.backgroundColor = [UIColor whiteColor];
     [mainScroller addSubview:labelView];
     
     UILabel * newLabel = [UILabel new];
     newLabel.frame = CGRectMake(0, 10, w, 50);
     newLabel.text = @"NEUES";
     newLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
     newLabel.textAlignment = NSTextAlignmentCenter;
     [mainScroller addSubview:newLabel];
     */
    /*
     UILabel * chefLabel = [UILabel new];
     chefLabel.frame = CGRectMake(w, 10, w, 50);
     chefLabel.text = @"KÖCHE";
     chefLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
     chefLabel.textAlignment = NSTextAlignmentCenter;
     [mainScroller addSubview:chefLabel];
     */
    /*
     UILabel * recipeLabel = [UILabel new];
     recipeLabel.frame = CGRectMake(w*2, 10, w, 50);
     recipeLabel.text = @"REZEPTE";
     recipeLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
     recipeLabel.textAlignment = NSTextAlignmentCenter;
     [mainScroller addSubview:recipeLabel];
     */
    /*
     */
    
}
-(void)search {
    
}
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
    topCellDiv.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
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
    div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
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
    cantonDiv.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
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
                             mainscrollerCover.alpha = 0.0f;

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
                             mainscrollerCover.alpha = 1.0f;
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
    [addButton addTarget:self action:@selector(pushEditVC) forControlEvents:UIControlEventTouchUpInside];
    [addButtonView addSubview:addButton];
    
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
    
    newScroller = [UIScrollView new];
    newScroller.frame = CGRectMake(0, 100, w, h-100);
    newScroller.showsVerticalScrollIndicator = false;
    newScroller.showsHorizontalScrollIndicator = false;
    newScroller.delegate = self;
    newScroller.alwaysBounceVertical = true;
    [mainScroller addSubview:newScroller];
    
    userScroller = [UIScrollView new];
    userScroller.frame = CGRectMake(w, 100, w, h-100);
    userScroller.showsVerticalScrollIndicator = false;
    userScroller.showsHorizontalScrollIndicator = false;
    userScroller.delegate = self;
    userScroller.alwaysBounceVertical = true;
    [mainScroller addSubview:userScroller];
    
    userContentView = [UIView new];
    userContentView.frame = userScroller.bounds;
    [userScroller addSubview:userContentView];
    
    recipeScroller = [UIScrollView new];
    recipeScroller.frame = CGRectMake(w*2, 100, w, h-100);
    recipeScroller.showsVerticalScrollIndicator = false;
    recipeScroller.showsHorizontalScrollIndicator = false;
    recipeScroller.delegate = self;
    recipeScroller.alwaysBounceVertical = true;
    [mainScroller addSubview:recipeScroller];
    
    recipeContentView = [UIView new];
    recipeContentView.frame = recipeScroller.bounds;
    [recipeScroller addSubview:recipeContentView];
    
    mainscrollerCover = [UIImageView new];
    mainscrollerCover.frame = self.view.bounds;
    mainscrollerCover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.view addSubview:mainscrollerCover];
    
}
-(void)refreshScroller {
    
    //USER
    //empty out
    for (NSObject * obj in userCells){
        if ([obj isKindOfClass:[userCell class]]){
            userCell * cell = (userCell *)obj;
            [cell removeFromSuperview];
        }
    }
    
    //create new
    userCells = [NSMutableArray new];
    for (int n = 0; n < _donkey.cantonUsers.count; n++){
        [userCells addObject:[NSObject new]];
    }
    
    //force update
    [self scrollViewDidScroll:userScroller];
    
    
    //RECIPE
    for (NSObject * obj in recipeCells){
        if ([obj isKindOfClass:[recipeCell class]]){
            recipeCell * cell = (recipeCell *)obj;
            [cell removeFromSuperview];
        }
    }
    recipeCells = [NSMutableArray new];
    for (int n = 0; n < _donkey.cantonRecipes.count; n++){
        [recipeCells addObject:[NSObject new]];
    }
    
    [self scrollViewDidScroll:recipeScroller];
    
    
    //NEW
} //updates ui for the selected canton
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:mainScroller]){
        float xOff = mainScroller.contentOffset.x;
        float fPage = xOff / w;
        page = roundf(fPage);
        return;
    }
    
    //set vars
    float topMargin = -h; //distance above y at which cells should disappear
    float bottomMargin = h; //distance below y + h at which cells should disappear
    float y = scrollView.contentOffset.y; //actual content offset
    float tallyY = 10; //the running height of y offset for cells
    float tallyX = 10;
    float padding = 10;
    CGSize cellSize;
    
    if ([scrollView isEqual:userScroller]){

        cellSize = CGSizeMake(w, 80);

           for (int n = 0; n < userCells.count; n++){
               
               bool isCell = false;
               if ([userCells[n] isKindOfClass:[userCell class]]){ isCell = true; }
               if (tallyY + cellSize.height - topMargin < y){//cells above not meeting threshold
                   
                   if (isCell){ //Removes the cells above if they exist
                       [[userCells objectAtIndex:n] removeFromSuperview];
                       [userCells replaceObjectAtIndex:n withObject:[NSObject new]];
                   }
                   
               } else if (tallyY > y + scrollView.frame.size.height + bottomMargin){ //cells below not meeting threshold
                   
                   if (isCell){ //Removes the cells below if they exist
                       [[userCells objectAtIndex:n] removeFromSuperview];
                       [userCells replaceObjectAtIndex:n withObject:[NSObject new]];
                   }
                   
               } else if (!isCell) {
                           
                       //create the cell, set frame and add to contentView
                       userCell * cell = [[userCell alloc] initWithFrame:CGRectMake(tallyX, tallyY, cellSize.width-2*tallyX, cellSize.height)];
                       cell.layer.shouldRasterize = true;
                       cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
                       cell.opaque = true;
                       cell.clipsToBounds = true;
                       cell.transform = CGAffineTransformMakeTranslation(0, -y);
                       [userContentView addSubview:cell];
                       
                       //data
                       NSDictionary * d = _donkey.cantonUsers[n];
                   [cell updateForUser:d atRank:n+1];
                       [cell.button addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
                       
                       //replace NSObject with cell
                       [userCells replaceObjectAtIndex:n withObject:cell];
               }
               
               tallyY += cellSize.height + padding;
               
               userCell * cell = userCells[n];
               if ([cell isKindOfClass:[userCell class]]){
                   int deviation = abs(userTouchIndex - n);
                   float delay = deviation * 0.03;
                   float duration = 1.0f - delay;
                   [UIView animateWithDuration:duration
                                         delay:delay
                        usingSpringWithDamping:0.8
                         initialSpringVelocity:0.7
                                       options:UIViewAnimationOptionCurveEaseInOut| UIViewAnimationOptionAllowUserInteraction
                                    animations:^{
                                        cell.transform = CGAffineTransformMakeTranslation(0, -y);
                                    }
                                    completion:^(BOOL finished){
                                        
                                    }];
               }
           }
        
        userContentView.transform = CGAffineTransformMakeTranslation(0, y);
        userContentView.frame = CGRectMake(0, 0, w, tallyY);
        userScroller.contentSize = CGSizeMake(w, tallyY);
       // NSLog(@"User contentview is %@ and scroller is %@", userContentView, userScroller);

    } else if ([scrollView isEqual:recipeScroller]){
        
        cellSize = CGSizeMake(w, 240);
        recipeContentView.transform = CGAffineTransformMakeTranslation(0, y);
        
        for (int n = 0; n < recipeCells.count; n++){
            
            bool isCell = false;
            if ([recipeCells[n] isKindOfClass:[recipeCell class]]){ isCell = true; }
            if (tallyY + cellSize.height - topMargin < y){//cells above not meeting threshold
                
                if (isCell){ //Removes the cells above if they exist
                    [[recipeCells objectAtIndex:n] removeFromSuperview];
                    [recipeCells replaceObjectAtIndex:n withObject:[NSObject new]];
                }
                
            } else if (tallyY > y + scrollView.frame.size.height + bottomMargin){ //cells below not meeting threshold
                
                if (isCell){ //Removes the cells below if they exist
                    [[recipeCells objectAtIndex:n] removeFromSuperview];
                    [recipeCells replaceObjectAtIndex:n withObject:[NSObject new]];
                }
                
            } else if (!isCell) {
                
                //create the cell, set frame and add to contentView
                recipeCell * cell = [[recipeCell alloc] initWithFrame:CGRectMake(tallyX, tallyY, cellSize.width-2*tallyX, cellSize.height)];
                cell.layer.shouldRasterize = true;
                cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
                cell.opaque = true;
                cell.clipsToBounds = true;
                cell.transform = CGAffineTransformMakeTranslation(0, -y);
                [recipeContentView addSubview:cell];

                //data
                NSDictionary * d = _donkey.cantonRecipes[n];
                [cell updateForRecipe:d atRank:n+1];
                [cell.button addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
                
                //replace NSObject with cell
                [recipeCells replaceObjectAtIndex:n withObject:cell];
            }
            
            //increment tally
            tallyY += cellSize.height + padding;
            
            //bounce
            recipeCell * cell = recipeCells[n];
            if ([cell isKindOfClass:[recipeCell class]]){
                int deviation = abs(recipeTouchIndex - n);
                float delay = deviation * 0.03;
                float duration = 1.0f - delay;
                [UIView animateWithDuration:0.4
                                      delay:0.3
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:0.7
                                    options:UIViewAnimationOptionCurveEaseInOut| UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     cell.transform = CGAffineTransformMakeTranslation(0, -y);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
        }
        
        
        recipeContentView.frame = CGRectMake(0, 0, w, tallyY);
        recipeScroller.contentSize = CGSizeMake(w, tallyY);
        
     //   NSLog(@"Recipe contentview is %@ and scroller is %@", recipeContentView, recipeScroller);
        
        /*
        //parallax effect
        float travelDistance = h + cellSize.height;
        for (int n = 0; n < recipeCells.count; n++){
            NSObject * obj = recipeCells[n];
            if ([obj isKindOfClass:[recipeCell class]]){
                recipeCell * cell = recipeCells[n];
                float cellY = [recipeScroller convertPoint:cell.frame.origin toView:self.view].y+cellSize.height;
                float p = cellY/travelDistance;
                cell.recipeIV.transform = CGAffineTransformMakeTranslation(0, p*-30);
            }
        }
        */
    }

    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:userScroller]){
        
        //grab the location of the touch event
        CGPoint location = [userScroller.panGestureRecognizer locationInView:userScroller];
        int yTouch = location.y; //grab y coordinate
        userTouchIndex = (yTouch - 10) / 90; //calculate the index of the cell
        // NSLog(@"index: %i", userTouchIndex);
        
        
    } else if ([scrollView isEqual:recipeScroller]){
        
        //grab the location of the touch event
        CGPoint location = [recipeScroller.panGestureRecognizer locationInView:recipeScroller];
        int yTouch = location.y; //grab y coordinate
        recipeTouchIndex = (yTouch -10) / 250; //calculate the index of the cell
       //  NSLog(@"index: %i", recipeTouchIndex);
    }
}

//CELLS ACTIONS
-(void)cellClick:(UIButton *)button {

    if (page == 1){
        
        NSObject * object = (NSObject *)button.superview;
        int index = (int)[userCells indexOfObject:object];
        NSDictionary * d = _donkey.cantonUsers[index];
        NSString * userID = d[@"userID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushChefVC" object:userID];
        
    } else if (page == 2){
        
        NSObject * object = (NSObject *)button.superview;
        int index = (int)[recipeCells indexOfObject:object];
        NSDictionary * d = _donkey.cantonRecipes[index];
        NSString * recipeID = d[@"recipeID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushRecipeVC" object:recipeID];
        
    }

    
}
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
    
    NSLog(@"PREF");
    return UIStatusBarStyleDefault;
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
