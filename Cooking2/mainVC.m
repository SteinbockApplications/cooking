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

@interface mainVC () {

    Peacock * _peacock;
    Donkey * _donkey;
    Dog * _dog;
    User * currentUser;
    
    openVC * _openVC;
    chefVC * _chefVC;
    
    editVC * _editVC;
    
    float w;
    float h;
    
    UIView * addButtonView;
    UIButton * addButton;
    
    bool statusBarIsHidden;
    
}

@end

@implementation mainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
    [self begin];
}
-(void)setup{
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popOpenVC) name:@"kPopOpenVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popEditVC) name:@"kPopEditVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarAppearance:) name:@"kStatusBarAppearance" object:nil];
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    _dog = [Dog sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    
    
}
-(void)layout{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIView * topBar = [UIView new];
    topBar.frame = CGRectMake(0, 0, w, 60);
    topBar.backgroundColor = _peacock.appColour;
    [self.view addSubview:topBar];
    
    UIButton * searchButton = [UIButton new];
    searchButton.frame = CGRectMake(0, 20, 40, 40);
    [searchButton setImage:[[UIImage imageNamed:@"search-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [searchButton setTintColor:[UIColor whiteColor]];
    [searchButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:searchButton];
    
    float width = (w-80)/2;
    
    UIButton * chefButton = [UIButton new];
    chefButton.frame = CGRectMake(40, 20, width, 40);
    [chefButton setTitle:@"Chef" forState:UIControlStateNormal];
    [topBar addSubview:chefButton];
    
    UIButton * recipeButton = [UIButton new];
    recipeButton.frame = CGRectMake(40+width, 20, width, 40);
    [recipeButton setTitle:@"Rezept" forState:UIControlStateNormal];
    [topBar addSubview:recipeButton];

    UIButton * profileButton = [UIButton new];
    profileButton.frame = CGRectMake(w-40, 20, 40, 40);
    [profileButton setImage:[[UIImage imageNamed:@"profile-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [profileButton setTintColor:[UIColor whiteColor]];
    [profileButton addTarget:self action:@selector(profile) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:profileButton];
    
    //profileButton.backgroundColor = [UIColor redColor];
    
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
    
    //fetch meta
    [_dog fetchMetaData];
    
    //load current user
    [_donkey loadCurrentUser];
    NSLog(@"current user is %@", _donkey.currentUser);

    //if there's no user, push openVC
    if (!_donkey.currentUser){
        [self pushOpenVCShouldAnimate:false];
    } else {
        
    }
    

}

//DATA
-(void)metaReady {
    
    NSLog(@"META READY");
    
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




@end
