//
//  profileVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "profileVC.h"
#import "Peacock.h"

#import "Donkey.h"

#import "User.h"
@interface profileVC () {
    
    Peacock * _peacock;
    Donkey * _donkey;
    
    User * currentUser;
    
    float w;
    float h;
    
    UIScrollView * mainScroller;
    UIView * contentView;
    
}

@end

@implementation profileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
    [self begin];
}
-(void)setup{
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    
    currentUser = _donkey.currentUser;
}
-(void)layout{
    
    self.view.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.110 alpha:1];
    
    
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = self.view.bounds;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.delegate = self;
    [self.view addSubview:mainScroller];
    
    contentView = [UIView new];
    [mainScroller addSubview:contentView];
    
    UIButton * closeButton = [UIButton new];
    closeButton.frame = CGRectMake(w-60, 20, 60, 60);
    [closeButton setImage:[[UIImage imageNamed:@"close-120.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [closeButton setTintColor:[UIColor whiteColor]];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [closeButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    
    float yOff = 0;
    [self layoutScoreViewAtOffset:yOff];
    yOff += 100 + 10;
    [self layoutProfileViewAtOffset:yOff];
    yOff += 340;
    [self layoutRecipeViewAtOffset:yOff];
    yOff += 300;
    [self layoutFollowingViewAtOffset:yOff];
    yOff += 300;
    
    contentView.frame = CGRectMake(0, 0, w, yOff);
    mainScroller.contentSize = CGSizeMake(w, yOff);
}
-(void)begin{
    
}

-(void)layoutScoreViewAtOffset:(float)yOff {
    
    UIView * scoreView = [UIView new];
    scoreView.frame = CGRectMake(0, yOff, w, 100);
    scoreView.backgroundColor = _peacock.appColour;
    [mainScroller addSubview:scoreView];
    
    UILabel * scoreLabel = [UILabel new];
    scoreLabel.frame = CGRectMake(20, 20, w-40, 50);
    scoreLabel.font = [UIFont systemFontOfSize:40.0f weight:UIFontWeightThin];
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.textAlignment = NSTextAlignmentLeft;
    scoreLabel.text = @"9.2";
    [scoreView addSubview:scoreLabel];
}

-(void)layoutProfileViewAtOffset:(float)yOff {
    
    UIView * profileView = [UIView new];
    profileView.frame = CGRectMake(0, yOff, w, 340);
    profileView.backgroundColor = [UIColor blackColor];
    [mainScroller addSubview:profileView];
    
    UIImageView * bgIV = [UIImageView new];
    bgIV.frame = profileView.bounds;
    bgIV.contentMode = UIViewContentModeScaleAspectFill;
    bgIV.image = [UIImage imageNamed:@"king.jpeg"];
    bgIV.clipsToBounds = true;
    [profileView addSubview:bgIV];
    
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = bgIV.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, [UIColor blackColor].CGColor, nil];
    gradient.locations = @[@0.0,@1.0];
    [bgIV.layer insertSublayer:gradient atIndex:0];
    
    UIVisualEffectView * vs = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    vs.frame = bgIV.bounds;
    [bgIV addSubview:vs];
    
    
    float localY = 60.0f;
    
    UIImageView * profileIVHolder = [UIImageView new];
    profileIVHolder.frame = CGRectMake((w-160)/2, localY, 160, 160);
    profileIVHolder.layer.cornerRadius = 80.0f;
    profileIVHolder.clipsToBounds = true;
    [profileView addSubview:profileIVHolder];
    
    UIImageView * profileIV = [UIImageView new];
    profileIV.frame = CGRectMake(-20, -20, 200, 200);
    profileIV.contentMode = UIViewContentModeScaleAspectFill;
    profileIV.image = [UIImage imageNamed:@"king.jpeg"];
    [profileIVHolder addSubview:profileIV];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRoundedRect(path, nil, CGRectMake(120, 80, 60, 60), 30, 30);
    CGPathAddRect(path, nil, profileIVHolder.bounds);
    shapeLayer.path = path;
    CGPathRelease(path);
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    profileIVHolder.layer.mask = shapeLayer;
    
    UIButton * editButton = [UIButton new];
    editButton.frame = CGRectMake(profileIVHolder.frame.origin.x + 120 + 5, profileIVHolder.frame.origin.y + 80 + 5, 50, 50);
    editButton.layer.cornerRadius = 25.0f;
    editButton.backgroundColor = _peacock.appColour;
    [editButton setImage:[[UIImage imageNamed:@"edit-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [editButton setTintColor:[UIColor whiteColor]];
    [editButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [profileView addSubview:editButton];
    
    localY += 170;
    
    UILabel * nameLabel = [UILabel new];
    nameLabel.frame = CGRectMake(20, localY, w-40, 40);
    nameLabel.font = [UIFont systemFontOfSize:30.0f weight:UIFontWeightThin];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = currentUser.name;
    nameLabel.adjustsFontSizeToFitWidth = true;
    [profileView addSubview:nameLabel];
    
    localY += 35;
    
    UILabel * locationLabel = [UILabel new];
    locationLabel.frame = CGRectMake(20, localY, w-40, 30);
    locationLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.textAlignment = NSTextAlignmentCenter;
    locationLabel.text = currentUser.location;
    locationLabel.adjustsFontSizeToFitWidth = true;
    [profileView addSubview:locationLabel];
    
    localY += 35;
    
    UIButton * recipeButton = [UIButton new];
    recipeButton.frame = CGRectMake(0, localY, w/2, 40);
    [recipeButton setTitle:@"Recipes" forState:UIControlStateNormal];
    [recipeButton setTitleColor:_peacock.appColour forState:UIControlStateNormal];
    [recipeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightBold]];
    [profileView addSubview:recipeButton];
    
    UIButton * favouriteButton = [UIButton new];
    favouriteButton.frame = CGRectMake(w/2, localY, w/2, 40);
    [favouriteButton setTitle:@"Favourites" forState:UIControlStateNormal];
    [favouriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [favouriteButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [profileView addSubview:favouriteButton];
    
}
-(void)layoutRecipeViewAtOffset:(float)yOff {
    
    
    UIView * recipeView = [UIView new];
    recipeView.frame = CGRectMake(0, yOff, w, 300);
    recipeView.backgroundColor = [UIColor blackColor];
    [mainScroller addSubview:recipeView];
    
    
}


-(void)layoutFollowingViewAtOffset:(float)yOff {
    
    UIView * followingView = [UIView new];
    followingView.frame = CGRectMake(0, yOff, w, 300);
    followingView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.110 alpha:1];
    [mainScroller addSubview:followingView];
    
    
    float localY = 0;
    
    UIButton * recipeButton = [UIButton new];
    recipeButton.frame = CGRectMake(0, localY, w/2, 40);
    [recipeButton setTitle:@"Following" forState:UIControlStateNormal];
    [recipeButton setTitleColor:_peacock.appColour forState:UIControlStateNormal];
    [recipeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightBold]];
    [followingView addSubview:recipeButton];
    
    UIButton * favouriteButton = [UIButton new];
    favouriteButton.frame = CGRectMake(w/2, localY, w/2, 40);
    [favouriteButton setTitle:@"Followers" forState:UIControlStateNormal];
    [favouriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [favouriteButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [followingView addSubview:favouriteButton];
    
    
    
    
}

-(void)popSelf {
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
