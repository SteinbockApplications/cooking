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
    
    
    
    UILabel * joinLabel;
    
    UIImageView * cover;
    UIView * topBar;
    
    
    //updated with data
    UIImageView * profileIV;
    NSString * name;
    NSString * location;
    NSString * skill;
    NSString * bio;
    float score;
    int votes;
    NSMutableArray * recipes;
    NSMutableArray * followers;
}
@end
@implementation chefVC
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}
-(void)setup{
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    
}

//DATA
-(void)beginWithUserID:(NSString *)userID {
    
    //pull the data
    NSDictionary * d = _donkey.users[userID];
    NSLog(@"d is %@", d);
    
    name = d[@"name"];
    location = d[@"location"];
    skill = d[@"skill"];
    bio = d[@"bio"];
    score = [d[@"score"] floatValue];
    votes = [d[@"votes"] intValue];
    recipes = [NSMutableArray new];
    NSArray * recipeIDs = d[@"recipes"];
    for (NSString * recipeID in recipeIDs){
        NSDictionary * recipe = _donkey.recipes[recipeID];
        [recipes addObject:recipe];
    }
    followers = [NSMutableArray new];
    NSArray * followerIDs = d[@"followers"];
    for (NSString * followerID in followerIDs){
        NSDictionary * follower = _donkey.users[followerID];
        [followers addObject:follower];
    }
    
    [followers addObject:_donkey.deviceUser];
    
    //layout
    [self layout]; //--> general layout --> fixed size
    [self layoutTopView]; //--> overlay on top view (stars, name, bio, location, skill) --> fixed size
    float recipeOffset = [self layoutRecipeView]; //--> shows recipes for this user --> dynamic size
    [self layoutFollowingViewAtOffset:recipeOffset]; //--> shows followers for this user --> dynamic size
    [self layoutTopBar]; //--> follow and back
    
    mainScroller.contentSize = CGSizeMake(w, recipeOffset + 220);
    
}

//LAYOUT
-(void)layout{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    profileIV = [UIImageView new];
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
    
}
-(void)layoutTopView {
    
    float xOff = 20;
    float yOff = h-30;
    
    UILabel * locationLabel = [UILabel new];
    locationLabel.frame = CGRectMake(xOff, yOff, 0, 20);
    locationLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    locationLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    locationLabel.text = location;
    [locationLabel sizeToFit];
    [mainScroller addSubview:locationLabel];
    
    xOff += locationLabel.frame.size.width + 5;
    [mainScroller addSubview:[self breakerDotAtPoint:CGPointMake(xOff, yOff+5)]];
    xOff += 15;
    
    UILabel * skillLabel = [UILabel new];
    skillLabel.frame = CGRectMake(xOff, yOff, 0, 20);
    skillLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    skillLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    skillLabel.text = skill;
    [skillLabel sizeToFit];
    [mainScroller addSubview:skillLabel];
    
    UILabel * bioLabel = [UILabel new];
    bioLabel.frame = CGRectMake(0, 0, w-40, 0);
    bioLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    bioLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
    bioLabel.text = bio;
    bioLabel.textAlignment = NSTextAlignmentJustified;
    [bioLabel setNumberOfLines:0];
    [bioLabel sizeToFit];
    [mainScroller addSubview:bioLabel];
    
    xOff = 20;
    yOff = yOff-bioLabel.frame.size.height-5;
    bioLabel.frame = CGRectMake(xOff, yOff, w-40, bioLabel.frame.size.height);
    
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
    
    //star view
    if (votes > 3){
        UIView * starView = [_peacock starViewWithScore:score ofColour:_peacock.appColour votes:votes ofColour:_peacock.appleWhite forHeight:22.0f atPoint:CGPointMake(xOff, yOff)];
        [mainScroller addSubview:starView];
    }
    
}
-(float)layoutRecipeView {
    
    float yOff = h;
    UIView * recipeView = [UIView new];
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
    recipeLabel.text = [NSString stringWithFormat:@"Alle Gerichte (%i)", (int)recipes.count];
    [recipeView addSubview:recipeLabel];
    
    UIImageView * dropIV = [UIImageView new];
    dropIV.frame = CGRectMake(w-44, localY+8, 24, 24);
    dropIV.contentMode = UIViewContentModeScaleAspectFit;
    dropIV.image = [[UIImage imageNamed:@"down-64.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
    [recipeView addSubview:recipeScroller];
    
    float localX = 20.0f;
    float scrollerHeight = 160;
    for (NSDictionary * recipe in recipes){
        
        //pull data
        float recipeScore = [recipe[@"score"] floatValue];
        int recipeVotes = [recipe[@"votes"] intValue];
        
        UIView * cell = [UIView new];
        cell.frame = CGRectMake(localX, 0, 160, 180);
        [recipeScroller addSubview:cell];
        
        UIActivityIndicatorView * indy = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 10, 160, 100)];
        [indy setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [indy startAnimating];
        [cell addSubview:indy];
        
        UIImageView * recipeIV = [UIImageView new];
        recipeIV.frame = CGRectMake(0, 10, 160, 100);
        recipeIV.contentMode = UIViewContentModeScaleAspectFill;
        recipeIV.clipsToBounds = true;
        recipeIV.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
        [cell addSubview:recipeIV];
        
        recipeVotes = 10;
        recipeScore = 2;
        float recipeNameY = 115;
        if (recipeVotes > 3){
            recipeNameY = 135;
            scrollerHeight = 180;
            UIView * starView = [_peacock starViewWithScore:recipeScore ofColour:_peacock.appColour votes:recipeVotes ofColour:_peacock.appleWhite forHeight:15.0f atPoint:CGPointMake(0, 115)];
            [cell addSubview:starView];
        }
        
        UILabel * recipeName = [UILabel new];
        recipeName.frame = CGRectMake(0, recipeNameY, 160, 0);
        recipeName.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
        recipeName.textColor = [UIColor whiteColor];
        recipeName.text = recipe[@"recipeName"];
        recipeName.numberOfLines = 2;
        [recipeName sizeToFit];
        [cell addSubview:recipeName];
        
        UIButton * button = [UIButton new];
        button.frame = cell.bounds;
        [button addTarget:self action:@selector(recipeSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:[recipes indexOfObject:recipe]];
        [cell addSubview:button];
        
        localX += 170;
        
    }
    
    recipeView.frame = CGRectMake(0, yOff, w, 40+scrollerHeight);
    recipeScroller.frame = CGRectMake(0, localY, w, scrollerHeight);
    recipeScroller.contentSize = CGSizeMake(localX+10, scrollerHeight);
    return yOff + 40 + scrollerHeight; //return dynamic height (depending on if stars are shown)
}
-(void)layoutFollowingViewAtOffset:(float)yOff {
    
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
    followingLabel.text = [NSString stringWithFormat:@"Followers (%i)", (int)followers.count];
    [followingView addSubview:followingLabel];
    
    UIImageView * dropIV = [UIImageView new];
    dropIV.frame = CGRectMake(w-44, localY+8, 24, 24);
    dropIV.contentMode = UIViewContentModeScaleAspectFit;
    dropIV.image = [[UIImage imageNamed:@"down-64.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
    for (NSDictionary * follower in followers){
        
        UIView * cell = [UIView new];
        cell.frame = CGRectMake(localX, 0, 100, 100);
        [followingScroller addSubview:cell];
        
        UIView * profileCircle = [UIView new];
        profileCircle.frame = CGRectMake(10, 10, 80, 80);
        profileCircle.layer.cornerRadius = 40.0f;
        profileCircle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
        [cell addSubview:profileCircle];
        
        UILabel * profileLabel = [UILabel new];
        profileLabel.frame = profileCircle.bounds;
        profileLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
        profileLabel.textColor = [UIColor whiteColor];
        profileLabel.textAlignment = NSTextAlignmentCenter;
        profileLabel.text = [_peacock initialsForName:follower[@"name"]];
        [profileCircle addSubview:profileLabel];
        
        UIImageView * followerIV = [UIImageView new];
        followerIV.frame = profileCircle.bounds;
        followerIV.layer.cornerRadius = 40.0f;
        followerIV.contentMode = UIViewContentModeScaleAspectFill;
        followerIV.clipsToBounds = true;
        [cell addSubview:followerIV];
        
        UILabel * followerName = [UILabel new];
        followerName.frame = CGRectMake(0, 95, 90, 0);
        followerName.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
        followerName.textColor = [UIColor whiteColor];
        followerName.text = follower[@"name"];
        followerName.textAlignment = NSTextAlignmentCenter;
        followerName.numberOfLines = 2;
        [followerName sizeToFit];
        [cell addSubview:followerName];
        followerName.frame = CGRectMake(5+(90-followerName.frame.size.width)/2, 95, followerName.frame.size.width, followerName.frame.size.height);
        localX += 100;
        
    }
    followingScroller.contentSize = CGSizeMake(localX+10, 180);
    
}
-(void)layoutTopBar {
    
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

//NAVIGATION
-(void)recipeSelected:(UIButton *)button {
    
    int index = (int)button.tag;
    NSDictionary * recipe = recipes[index];
    NSString * recipeID = recipe[@"recipeID"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushRecipeVC" object:recipeID];

    
}
-(void)followerSelected:(UIButton *)button{
    
}

//SCROLLING
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

//CONVENIENCE
-(UIImageView *)breakerDotAtPoint:(CGPoint)point {
    
    UIImageView * dot = [UIImageView new];
    dot.frame = CGRectMake(point.x, point.y, 10, 10);
    dot.layer.cornerRadius = 5;
    dot.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    return dot;
}

//OTHER
-(void)popSelf {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopChefVC" object:nil];
}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
