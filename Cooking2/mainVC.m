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
    
    NSArray * sortedNew;
    NSArray * sortedUsers;
    NSArray * sortedRecipes;
    
    NSMutableArray * userCells;
    NSMutableArray * recipeCells;
    
    int userTouchIndex;
    UIView * userContentView;
    int recipeTouchIndex;
    UIView * recipeContentView;
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
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = CGRectMake(0, 0, w, h);
    mainScroller.contentSize = CGSizeMake(3*w, h);
    mainScroller.pagingEnabled = true;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    //mainScroller.delegate = self;
    mainScroller.alwaysBounceHorizontal = true;
    [self.view addSubview:mainScroller];
    
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
    
    newScroller = [UIScrollView new];
    newScroller.frame = CGRectMake(0, 100, w, h-100);
    newScroller.showsVerticalScrollIndicator = false;
    newScroller.showsHorizontalScrollIndicator = false;
    newScroller.delegate = self;
    newScroller.alwaysBounceVertical = true;
    [mainScroller addSubview:newScroller];
    
    UILabel * chefLabel = [UILabel new];
    chefLabel.frame = CGRectMake(w, 10, w, 50);
    chefLabel.text = @"KÖCHE";
    chefLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    chefLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroller addSubview:chefLabel];
    
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
    
    UILabel * recipeLabel = [UILabel new];
    recipeLabel.frame = CGRectMake(w*2, 10, w, 50);
    recipeLabel.text = @"REZEPTE";
    recipeLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    recipeLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroller addSubview:recipeLabel];
    
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
    
    UIView * topBar = [UIView new];
    topBar.frame = CGRectMake(0, 0, w, 100);
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
    
    UIView * cantonBar = [UIView new];
    cantonBar.frame = CGRectMake(0, 60, w, 40);
    cantonBar.backgroundColor = [UIColor whiteColor];
    [topBar addSubview:cantonBar];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(0, 0, w, 0.5f);
    div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    [cantonBar addSubview:div];
    
    UILabel * cantonLabel = [UILabel new];
    cantonLabel.frame = cantonBar.bounds;
    cantonLabel.text = @"SCHWEIZWEIT";
    cantonLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
    cantonLabel.textAlignment = NSTextAlignmentCenter;
    cantonLabel.textColor = [UIColor blackColor];
    [cantonBar addSubview:cantonLabel];
    
    UIButton * cantonButton = [UIButton new];
    cantonButton.frame = cantonBar.bounds;
    [cantonButton addTarget:self action:@selector(changeCanton) forControlEvents:UIControlEventTouchUpInside];
    [cantonBar addSubview:cantonButton];

    UIImageView * cantonDiv = [UIImageView new];
    cantonDiv.frame = CGRectMake(0, 39.5, w, 0.5f);
    cantonDiv.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    [cantonBar addSubview:cantonDiv];
    
    
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
    
    //set filter defaults
    canton = @"Schweizweit";
    
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

    [self updateStatusBarAppearance:nil];
}

//DATA
-(void)metaReady {
    
    [self sortData];
    [self refreshScroller];
    
}
-(void)changeGroup {
    
    [self refreshScroller];
    
}
-(void)openFilter:(UIButton *)button {
    
    /*
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
     */
    
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

-(void)sortData {
    
    sortedUsers = [_donkey sortUsersForCanton:canton];
    sortedRecipes = [_donkey sortRecipesForCanton:canton];
    NSLog(@"sorted recipes is %@", sortedRecipes);
    
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
    for (int n = 0; n < sortedUsers.count; n++){
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
    for (int n = 0; n < sortedRecipes.count; n++){
        [recipeCells addObject:[NSObject new]];
    }
    
    [self scrollViewDidScroll:recipeScroller];

    
    //NEW
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
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
                       NSDictionary * d = sortedUsers[n];
                       [cell updateForUser:d];
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
        NSLog(@"User contentview is %@ and scroller is %@", userContentView, userScroller);

    } else if ([scrollView isEqual:recipeScroller]){
        
        cellSize = CGSizeMake(w, 240);
        
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
                NSDictionary * d = sortedRecipes[n];
                [cell updateForRecipe:d];
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
        
        recipeContentView.transform = CGAffineTransformMakeTranslation(0, y);
        recipeContentView.frame = CGRectMake(0, 0, w, tallyY);
        recipeScroller.contentSize = CGSizeMake(w, tallyY);
        
        NSLog(@"Recipe contentview is %@ and scroller is %@", recipeContentView, recipeScroller);
        
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
         NSLog(@"index: %i", userTouchIndex);
        
        
    } else if ([scrollView isEqual:recipeScroller]){
        
        //grab the location of the touch event
        CGPoint location = [recipeScroller.panGestureRecognizer locationInView:recipeScroller];
        int yTouch = location.y; //grab y coordinate
        recipeTouchIndex = (yTouch -10) / 250; //calculate the index of the cell
        NSLog(@"index: %i", recipeTouchIndex);
    }
}


-(void)search {
    
}
-(void)profile {
    
    _chefVC = [chefVC new];
    [self addChildViewController:_chefVC];
    [self.view addSubview:_chefVC.view];
    
}



//CHEF + RECIPE VC PUSH POP
-(void)cellClick:(UIButton *)button {
    
    NSLog(@"cell click");
    
    mainCell * cell = (mainCell *)button.superview;
    int index = (int)[cells indexOfObject:cell];
    
    NSLog(@"index is %i", index);
    selectedGroup = @"recipe";
    
    if ([selectedGroup isEqualToString:@"user"]){
        [self pushChefVC:nil];
    } else {
        [self pushRecipeVC:nil];
    }
    
    
    
}
-(void)pushChefVC:(NSNotification *)n{
    
    NSLog(@"PUSH CHEF VC");
    
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
    
    NSLog(@"PUSH RECIPE VC");
    
    //create vc + set recipe
    _recipeVC = [recipeVC new];
    [self addChildViewController:_recipeVC];
    [self.view addSubview:_recipeVC.view];
    
    
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
