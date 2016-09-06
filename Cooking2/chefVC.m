//
//  chefVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "chefVC.h"
#import "peacock.h"
#import "donkey.h"

@interface chefVC () {
  
    Peacock * _peacock;
    Donkey * _donkey;
 
    float w;
    float h;

    UIScrollView * mainScroller;
    UIView * starView;
    UILabel * starLabel;
    UILabel * nameLabel;
    UILabel * bioLabel;
    UILabel * locationLabel;
    UILabel * skillLabel;
    UILabel * joinLabel;
    
    
    UIImageView * cover;
    UIView * topBar;
}
@end
@implementation chefVC
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
}
-(void)setup{

    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;

}
-(void)layout{

    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView * profileIV = [UIImageView new];
    profileIV.frame = self.view.bounds;
    profileIV.backgroundColor = [UIColor darkGrayColor];
    profileIV.contentMode = UIViewContentModeScaleAspectFill;
    profileIV.clipsToBounds = true;
    profileIV.image = [UIImage imageNamed:@"cookd.png"];
    [self.view addSubview:profileIV];
    
    cover = [UIImageView new];
    cover.frame = profileIV.bounds;
    cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:cover];
    
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = profileIV.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, [UIColor blackColor].CGColor, nil];
    gradient.locations = @[@0.0,@0.5,@1.0];
    [cover.layer insertSublayer:gradient atIndex:0];
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = self.view.bounds;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.delegate = self;
    mainScroller.alwaysBounceVertical = true;
    mainScroller.userInteractionEnabled = true;
    [self.view addSubview:mainScroller];
    
    [self layoutTopView];
    [self layoutRecipeView];
    [self layoutFollowingView];
    mainScroller.contentSize = CGSizeMake(w, h+220+180+60);
   
    
    topBar = [UIView new];
    topBar.frame = CGRectMake(0, 0, w, 75);
    topBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];
    [self.view addSubview:topBar];
    
    CAGradientLayer * topBarGradient = [CAGradientLayer layer];
    topBarGradient.frame = topBar.bounds;
    topBarGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] colorWithAlphaComponent:0.5f].CGColor, (id)[UIColor clearColor].CGColor, nil];
    topBarGradient.locations = @[@0.0,@1.0];
    [topBar.layer insertSublayer:topBarGradient atIndex:0];

    UIButton * backButton = [UIButton new];
    backButton.frame = CGRectMake(10, 30, 30, 30);
    [backButton setImage:[[UIImage imageNamed:@"arrow_left_thin-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:backButton];
    
    UIView * followButtonView = [UIView new];
    followButtonView.frame = CGRectMake(w-90, 25, 80, 40);
    followButtonView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
    followButtonView.layer.borderWidth = 0.5f;
    [topBar addSubview:followButtonView];
    
    UILabel * followButtonLabel = [UILabel new];
    followButtonLabel.frame = followButtonView.bounds;
    followButtonLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    followButtonLabel.textColor = [UIColor whiteColor];
    followButtonLabel.textAlignment = NSTextAlignmentCenter;
    followButtonLabel.text = @"Folgen";
    [followButtonView addSubview:followButtonLabel];
    
}

-(void)layoutTopView {
    
    float xOff = 20;
    float yOff = h-30;
    locationLabel = [UILabel new];
    locationLabel.frame = CGRectMake(xOff, yOff, 0, 20);
    locationLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    locationLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    locationLabel.text = @"Appenzell-Ausserrhoden";
    [locationLabel sizeToFit];
    [mainScroller addSubview:locationLabel];
    
    xOff += locationLabel.frame.size.width + 5;
    [mainScroller addSubview:[self breakerDotAtPoint:CGPointMake(xOff, yOff+5)]];
    xOff += 15;
    
    skillLabel = [UILabel new];
    skillLabel.frame = CGRectMake(xOff, yOff, 0, 20);
    skillLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    skillLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    skillLabel.text = @"Hausfrau";
    [skillLabel sizeToFit];
    [mainScroller addSubview:skillLabel];
    
    bioLabel = [UILabel new];
    bioLabel.frame = CGRectMake(0, 0, w-40, 0);
    bioLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    bioLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
    bioLabel.text = @"It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.";
    bioLabel.textAlignment = NSTextAlignmentJustified;
    [bioLabel setNumberOfLines:0];
    [bioLabel sizeToFit];
    [mainScroller addSubview:bioLabel];
    
    xOff = 20;
    yOff = yOff-bioLabel.frame.size.height-5;
    bioLabel.frame = CGRectMake(xOff, yOff, w-40, bioLabel.frame.size.height);
    
    
    NSString * name = @"Karine Sutter";
    NSArray * array = [name componentsSeparatedByString:@" "];
    if (array.count == 2){
        
        NSString * second = array[1];
        UILabel * secondLabel = [UILabel new];
        secondLabel.frame = CGRectMake(0, 0, w-40, 0);
        secondLabel.font = [UIFont systemFontOfSize:40.0f weight:UIFontWeightBold];
        secondLabel.textColor = [UIColor whiteColor];
        secondLabel.text = second;
        [secondLabel setNumberOfLines:0];
        [secondLabel sizeToFit];
        [mainScroller addSubview:secondLabel];
        
        yOff = yOff-secondLabel.frame.size.height;
        secondLabel.frame = CGRectMake(xOff, yOff, w-40, secondLabel.frame.size.height);

        NSString * first = array[0];
        UILabel * firstLabel = [UILabel new];
        firstLabel.frame = CGRectMake(0, 0, w-40, 0);
        firstLabel.font = [UIFont systemFontOfSize:40.0f weight:UIFontWeightThin];
        firstLabel.textColor = [UIColor whiteColor];
        firstLabel.text = first;
        [firstLabel setNumberOfLines:0];
        [firstLabel sizeToFit];
        [mainScroller addSubview:firstLabel];
        
        yOff = yOff-firstLabel.frame.size.height+10;
        firstLabel.frame = CGRectMake(xOff, yOff, w-40, firstLabel.frame.size.height);
    }
  
    
    yOff -= 20;
    starView = [UIView new];
    starView.clipsToBounds = true;
    [mainScroller addSubview:starView];
    
    float score = 4.8;
    if (score){
        
        float localX = 0;
        for (int n = 0; n < 5; n++){
            UIImageView * starIV = [UIImageView new];
            starIV.frame = CGRectMake(localX, 0, 20, 20);
            starIV.contentMode = UIViewContentModeScaleAspectFit;
            starIV.image = [[UIImage imageNamed:@"star_full-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            starIV.tintColor = _peacock.appColour;
            [starView addSubview:starIV];
            localX += 25;
        }
        float width = score * 20 + (int)score * 5;
        starView.frame = CGRectMake(xOff, yOff, width, 20);
        
        UILabel * scoreLabel = [UILabel new];
        scoreLabel.frame = CGRectMake(xOff + width + 5, yOff, w-(xOff + width + 5)-20, 20);
        scoreLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
        scoreLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
        scoreLabel.text = [NSString stringWithFormat:@"(%.1f)", score];
        [mainScroller addSubview:scoreLabel];
    }
    
    
    
}

-(void)layoutRecipeView {
    
    float yOff = h;
    UIView * recipeView = [UIView new];
    recipeView.frame = CGRectMake(0, yOff, w, 220);
    [mainScroller addSubview:recipeView];
    
    float localY = 0;
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, localY, w-40, 0.5f);
    div.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [recipeView addSubview:div];
    
    UILabel * recipeLabel = [UILabel new];
    recipeLabel.frame = CGRectMake(20, localY, w-40, 40);
    recipeLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    recipeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
    recipeLabel.text = @"Alle Gerichte (22)";
    [recipeView addSubview:recipeLabel];
    
    UIImageView * dropIV = [UIImageView new];
    dropIV.frame = CGRectMake(w-44, localY+8, 24, 24);
    dropIV.contentMode = UIViewContentModeScaleAspectFit;
    dropIV.image = [[UIImage imageNamed:@"arrow_down_fat-64.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    dropIV.tintColor = _peacock.appColour;
    [recipeView addSubview:dropIV];
    
    UIButton * recipeButton = [UIButton new];
    recipeButton.frame = recipeLabel.bounds;
    [recipeView addSubview:recipeButton];
    
    localY += 40;
    
    UIImageView * divB = [UIImageView new];
    divB.frame = CGRectMake(20, localY, w-40, 0.5f);
    divB.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [recipeView addSubview:divB];

    UIScrollView * recipeScroller = [UIScrollView new];
    recipeScroller.frame = CGRectMake(0, localY, w, 180);
    [recipeView addSubview:recipeScroller];
    
    float localX = 20.0f;
    for (int n = 0; n < 5; n++){
        
        UIView * cell = [UIView new];
        cell.frame = CGRectMake(localX, 0, 160, 180);
        [recipeScroller addSubview:cell];
        
        UIImageView * recipeIV = [UIImageView new];
        recipeIV.frame = CGRectMake(0, 10, 160, 100);
        recipeIV.contentMode = UIViewContentModeScaleAspectFill;
        recipeIV.clipsToBounds = true;
        recipeIV.image = [UIImage imageNamed:@"recipe.png"];
        [cell addSubview:recipeIV];
        
        [cell addSubview:[self starViewWithScore:4.5f ofColour:_peacock.appColour forHeight:15 atPoint:CGPointMake(0, 115)]];
        
        UILabel * recipeName = [UILabel new];
        recipeName.frame = CGRectMake(0, 135, 160, 0);
        recipeName.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
        recipeName.textColor = [UIColor whiteColor];
        recipeName.text = @"Gourmet Burger and chips a la francaise";
        recipeName.numberOfLines = 2;
        [recipeName sizeToFit];
        [cell addSubview:recipeName];
        
        localX += 170;
        
    }
    recipeScroller.contentSize = CGSizeMake(localX+10, 180);
    
    
}

-(void)layoutFollowingView {
    
    
    float yOff = h + 240;
    UIView * followingView = [UIView new];
    followingView.frame = CGRectMake(0, yOff, w, 220);
    [mainScroller addSubview:followingView];
    
    float localY = 0;
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, localY, w-40, 0.5f);
    div.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [followingView addSubview:div];
    
    UILabel * followingLabel = [UILabel new];
    followingLabel.frame = CGRectMake(20, localY, w-40, 40);
    followingLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    followingLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
    followingLabel.text = @"Followers (104)";
    [followingView addSubview:followingLabel];
    
    UIImageView * dropIV = [UIImageView new];
    dropIV.frame = CGRectMake(w-44, localY+8, 24, 24);
    dropIV.contentMode = UIViewContentModeScaleAspectFit;
    dropIV.image = [[UIImage imageNamed:@"arrow_down_fat-64.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    dropIV.tintColor = _peacock.appColour;
    [followingView addSubview:dropIV];
    
    UIButton * followingButton = [UIButton new];
    followingButton.frame = followingLabel.bounds;
    [followingView addSubview:followingButton];
    
    localY += 40;
    
    UIImageView * divB = [UIImageView new];
    divB.frame = CGRectMake(20, localY, w-40, 0.5f);
    divB.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [followingView addSubview:divB];
    
    UIScrollView * followingScroller = [UIScrollView new];
    followingScroller.frame = CGRectMake(0, localY, w, 180);
    [followingView addSubview:followingScroller];
    
    float localX = 20.0f;
    for (int n = 0; n < 104; n++){
        
        UIView * cell = [UIView new];
        cell.frame = CGRectMake(localX, 0, 100, 100);
        [followingScroller addSubview:cell];
        
        UIImageView * followerIV = [UIImageView new];
        followerIV.frame = CGRectMake(10, 10, 80, 80);
        followerIV.layer.cornerRadius = 40.0f;
        followerIV.contentMode = UIViewContentModeScaleAspectFill;
        followerIV.clipsToBounds = true;
        followerIV.image = [UIImage imageNamed:@"cookc.png"];
        [cell addSubview:followerIV];

        UILabel * followerName = [UILabel new];
        followerName.frame = CGRectMake(0, 95, 90, 0);
        followerName.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
        followerName.textColor = [UIColor whiteColor];
        followerName.text = @"Mark Sutter";
        followerName.textAlignment = NSTextAlignmentCenter;
        followerName.numberOfLines = 2;
        [followerName sizeToFit];
        [cell addSubview:followerName];
        followerName.frame = CGRectMake(5+(90-followerName.frame.size.width)/2, 95, followerName.frame.size.width, followerName.frame.size.height);
        localX += 100;
        
    }
    followingScroller.contentSize = CGSizeMake(localX+10, 180);
    
}
-(UIImageView *)breakerDotAtPoint:(CGPoint)point {
    
    UIImageView * dot = [UIImageView new];
    dot.frame = CGRectMake(point.x, point.y, 10, 10);
    dot.layer.cornerRadius = 5;
    dot.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    return dot;
}

-(UIView *)starViewWithScore:(float)score ofColour:(UIColor *)colour forHeight:(float)height atPoint:(CGPoint)point {

    UIView * view = [UIView new];
    
    UIView * holder = [UIView new];
    holder.clipsToBounds = true;
    [view addSubview:holder];
    
    float localX = 0;
    for (int n = 0; n < 5; n++){
        UIImageView * starIV = [UIImageView new];
        starIV.frame = CGRectMake(localX, 0, height, height);
        starIV.contentMode = UIViewContentModeScaleAspectFit;
        starIV.image = [[UIImage imageNamed:@"star_full-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        starIV.tintColor = colour;
        [holder addSubview:starIV];
        localX += height+5;
    }
    
    float width = score * height + (int)score * 5;
    holder.frame = CGRectMake(0, 0, width, height);

    UILabel * scoreLabel = [UILabel new];
    scoreLabel.frame = CGRectMake(width+5, 0, 45, height);
    scoreLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    scoreLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    scoreLabel.text = [NSString stringWithFormat:@"(%.1f)", score];
    [view addSubview:scoreLabel];
    
    view.frame = CGRectMake(point.x, point.y, width + 50, height);
    
    return view;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:mainScroller]){
        
        float y = scrollView.contentOffset.y;
        float p = y / h;
        float a = MIN(0.3 + p, 0.8);
        cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:a];
        
      
        a = MIN(p*4,0.8);
        topBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:a];
        
    }
    
}


//OTHER
-(void)popSelf {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopChefVC" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
