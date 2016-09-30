//
//  recipeVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "recipeVC.h"
#import "Peacock.h"
#import "Donkey.h"
#import "Dog.h"

@interface recipeVC () {
    
    Peacock * _peacock;
    Donkey * _donkey;
    Dog * _dog;
    
    float w;
    float h;
    
    UIScrollView * mainScroller;
    UIView * contentView;
    UIImageView * mediaIV;
    UIImageView * chefIV;
    

    
    //data
    
    NSDictionary * recipe;
    NSDictionary * chef;
    
    UIButton * ingredientsButton;
    UIButton * instructionsButton;
    UITextView * prepTV;
    
    UIView * starSlider;
    UILabel * rateHintLabel;
    
    int existingVote;
}

@end

@implementation recipeVC

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}
-(void)setup{
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    _dog = [Dog sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
}
-(void)beginWithRecipeID:(NSString *)recipeID {

    recipe = _donkey.recipes[recipeID];
    chef = _donkey.users[recipe[@"userID"]];
    
    NSString * currentUserID = _donkey.deviceUser[@"userID"];
    NSDictionary * currentUser = _donkey.users[currentUserID];
    NSDictionary * reviews = currentUser[@"reviews"];
    if ([reviews.allKeys containsObject:recipeID]){
        existingVote = [reviews[recipeID] intValue]-1;
    }
    
    
    [self layout]; //general layout
    [self updateRate:existingVote];
}


-(void)layout{
    
    self.view.backgroundColor = [_peacock colourForHex:@"#1a1a1a"];
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = self.view.bounds;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.delegate = self;
    mainScroller.alwaysBounceVertical = true;
    mainScroller.userInteractionEnabled = true;
    [self.view addSubview:mainScroller];
    
    UIButton * backButton = [UIButton new];
    backButton.frame = CGRectMake(10, 30, 30, 30);
    [backButton setImage:[[UIImage imageNamed:@"arrow_left_thin-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    

    float yOff = 0.0f;
    [self layoutTopViewAtOffset:yOff]; yOff += 400; //topView
    [self layoutOptionsViewAtOffset:yOff]; yOff += 60; //favourite + share
    yOff += [self layoutDescriptionViewAtOffset:yOff]; //dynamic height
    yOff += [self layoutCookViewAtOffset:yOff]; //dynamic height
    [self layoutProfileAtOffset:yOff]; yOff += 80;
    [self layoutRankViewAtOffset:yOff]; yOff += 450;
    
    //RATING
   //
   // [self layoutRankViewAtOffset:yOff];

    mainScroller.contentSize = CGSizeMake(w, yOff);
}

//TOPVIEW
-(void)layoutTopViewAtOffset:(float)yOff {
    
    UIView * topView = [UIView new];
    topView.backgroundColor = [UIColor blackColor];
    [mainScroller addSubview:topView];
    
    //BACKGROUND
    UIImageView * recipeIV = [UIImageView new];
    recipeIV.frame = CGRectMake(0, 0, w, 400);
    recipeIV.contentMode = UIViewContentModeScaleAspectFill;
    recipeIV.clipsToBounds = true;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * path = [NSString stringWithFormat:@"http://www.steinbockapplications.com/other/cooking/users/%@/%@/hero.jpg",recipe[@"userID"],recipe[@"recipeID"]];
        UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            recipeIV.image = image;
        });
    });
    [topView addSubview:recipeIV];
    
    UIImageView * cover = [UIImageView new];
    cover.frame = recipeIV.bounds;
    cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    [topView addSubview:cover];
    
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = cover.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, [[UIColor blackColor] colorWithAlphaComponent:1.0f].CGColor, nil];
    gradient.locations = @[@0.0,@0.5,@1.0];
    [cover.layer insertSublayer:gradient atIndex:0];
    
    //TIME VIEW
    UIView * timeView = [UIView new];
    timeView.frame = CGRectMake(w-80, 30, 60, 60);
    timeView.backgroundColor = _peacock.appColour;
    timeView.layer.cornerRadius = 30.0f;
    timeView.clipsToBounds = true;
    [topView addSubview:timeView];
    
    UILabel * timeLabel = [UILabel new];
    timeLabel.frame = timeView.bounds;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.text = [NSString stringWithFormat:@"%imin", [recipe[@"duration"]intValue]];
    [timeView addSubview:timeLabel];
    
    
    
    //LAYOUT UPSIDE DOWN
    float localY = 400;
    float localX = 20;
    
    //DIV
    localY--;
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(localX, localY, w-2*localX, 0.5f);
    div.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [topView addSubview:div];
    
    //COURSE + DIFFICULTY
    localY -= 25;
    UILabel * courseLabel = [UILabel new];
    courseLabel.frame = CGRectMake(localX, localY, 0, 20);
    courseLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    courseLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    courseLabel.text = recipe[@"course"];
    [courseLabel sizeToFit];
    [topView addSubview:courseLabel];
    
    localX += courseLabel.frame.size.width + 5;
    [topView addSubview:[self breakerDotAtPoint:CGPointMake(localX, localY+5)]];
    localX += 15;
    
    UILabel * difficultyLabel = [UILabel new];
    difficultyLabel.frame = CGRectMake(localX, localY, 0, 20);
    difficultyLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    difficultyLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    difficultyLabel.text = recipe[@"difficulty"];
    [difficultyLabel sizeToFit];
    [topView addSubview:difficultyLabel];
    
    //TITLE
    localX = 20;
    NSArray * splitsies = [self splitStringsForTitle:recipe[@"recipeName"]];
    NSString * firstString = splitsies[0];
    NSString * secondString = splitsies[1];
    
    if (secondString.length > 0){
        
        UILabel * nameLabel = [UILabel new];
        nameLabel.frame = CGRectMake(0, 0, w-40, 0);
        nameLabel.font = [UIFont systemFontOfSize:22.0f weight:UIFontWeightThin];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.text = secondString;
        [nameLabel setNumberOfLines:0];
        [nameLabel sizeToFit];
        [topView addSubview:nameLabel];
        
        localY = localY-nameLabel.frame.size.height;
        nameLabel.frame = CGRectMake(localX, localY, w-2*localX, nameLabel.frame.size.height);
        localY += 5; //tighten
    }
    if (firstString.length > 0){
        
        UILabel * nameLabel = [UILabel new];
        nameLabel.frame = CGRectMake(0, 0, w-40, 0);
        nameLabel.font = [UIFont systemFontOfSize:30.0f weight:UIFontWeightBold];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.text = firstString;
        [nameLabel setNumberOfLines:0];
        [nameLabel sizeToFit];
        [topView addSubview:nameLabel];
        
        localY = localY-nameLabel.frame.size.height;
        nameLabel.frame = CGRectMake(localX, localY, w-2*localX, nameLabel.frame.size.height);
    }
    
    //STAR VIEW
    localY -= 20;
    float score = [recipe[@"score"] floatValue];
    int votes = [recipe[@"votes"] intValue];
    
    UIView * starView = [_peacock starViewWithScore:score ofColour:_peacock.appColour votes:votes ofColour:[UIColor whiteColor] forHeight:20 atPoint:CGPointMake(localX, localY)];
    [topView addSubview:starView];
}

//FAVOURITE + SHARE
-(void)layoutOptionsViewAtOffset:(float)yOff{
    
    
    UIView * optionsView = [UIView new];
    optionsView.frame = CGRectMake(0, yOff, w, 60);
    optionsView.backgroundColor = [UIColor blackColor];
    [mainScroller addSubview:optionsView];
    
    //FAVOURITE
    UIView * favouriteView = [UIView new];
    favouriteView.backgroundColor = _peacock.appColour;
    [optionsView addSubview:favouriteView];
    
    UILabel * favouriteLabel = [UILabel new];
    favouriteLabel.frame = CGRectMake(0, 0, 0, 40);
    favouriteLabel.text = @"In Favouriten";
    favouriteLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    favouriteLabel.textColor = [UIColor whiteColor];
    [favouriteLabel sizeToFit];
    [favouriteView addSubview:favouriteLabel];
    
    [favouriteLabel setFrame:CGRectMake(40, 0, favouriteLabel.frame.size.width, 40)];
    [favouriteView setFrame:CGRectMake(20, 10, favouriteLabel.frame.size.width+50, 40)];
    favouriteView.layer.borderColor = _peacock.appColour.CGColor;
    favouriteView.layer.borderWidth = 1.0f;
    
    UIImageView * heartIV = [UIImageView new];
    heartIV.frame = CGRectMake(10, 10, 20, 20);
    heartIV.image = [[UIImage imageNamed:@"heart_full-64.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    heartIV.tintColor = [UIColor whiteColor];
    heartIV.contentMode = UIViewContentModeScaleAspectFit;
    [favouriteView addSubview:heartIV];
    
    UIButton * favouriteButton = [UIButton new];
    favouriteButton.frame = favouriteView.bounds;
    [favouriteButton addTarget:self action:@selector(favourite) forControlEvents:UIControlEventTouchUpInside];
    [favouriteView addSubview:favouriteButton];
    
    
    //SHARE
    UIView * shareView = [UIView new];
    [optionsView addSubview:shareView];
    
    UILabel * shareLabel = [UILabel new];
    shareLabel.frame = CGRectMake(0, 0, 0, 40);
    shareLabel.text = @"Teilen";
    shareLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    shareLabel.textColor = [UIColor whiteColor];
    [shareLabel sizeToFit];
    [shareView addSubview:shareLabel];
    
    [shareLabel setFrame:CGRectMake(40, 0, shareLabel.frame.size.width, 40)];
    [shareView setFrame:CGRectMake(w-20-shareLabel.frame.size.width-50, 10, shareLabel.frame.size.width+50, 40)];
    shareView.layer.borderColor = [UIColor whiteColor].CGColor;
    shareView.layer.borderWidth = 1.0f;
    
    UIImageView * shareIV = [UIImageView new];
    shareIV.frame = CGRectMake(10, 8, 24, 24);
    shareIV.image = [[UIImage imageNamed:@"share_full-64.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    shareIV.tintColor = [UIColor whiteColor];
    shareIV.contentMode = UIViewContentModeScaleAspectFit;
    [shareView addSubview:shareIV];
    
    UIButton * shareButton = [UIButton new];
    shareButton.frame = favouriteView.bounds;
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:shareButton];
    
}
-(void)favourite {
    
}
-(void)share {
    
}

//DESCRIPTION
-(float)layoutDescriptionViewAtOffset:(float)yOff {
    
    UIView * descriptionView = [UIView new];
    descriptionView.backgroundColor = [UIColor blackColor];
    [mainScroller addSubview:descriptionView];
    
    //DESCRIPTION
    UILabel * description = [UILabel new];
    description.frame = CGRectMake(20, 0, w-40, 0);
    description.backgroundColor = [UIColor clearColor];
    description.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    description.textColor = [UIColor whiteColor];
    description.text = recipe[@"introduction"];
    //description.text = @"There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet.";
    description.numberOfLines = 0;
    [description sizeToFit];
    [descriptionView addSubview:description];
    
    descriptionView.frame = CGRectMake(0, yOff, w, description.frame.size.height+10);
    return descriptionView.frame.size.height;
}

//COOK
-(float)layoutCookViewAtOffset:(float)yOff{
    
    UIView * cookView = [UIView new];
    cookView.backgroundColor = [UIColor blackColor];
    [mainScroller addSubview:cookView];
    
    float localY = 0;

    //INGREDIENTS
    UILabel * ingredientsLabel = [UILabel new];
    ingredientsLabel.frame = CGRectMake(20, localY, w-40, 40);
    ingredientsLabel.textColor = [UIColor whiteColor];
    ingredientsLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    ingredientsLabel.text = @"Zutaten";
    [cookView addSubview:ingredientsLabel];
    
    localY += 40;
    
    UILabel * ingredientsText = [UILabel new];
    ingredientsText.frame = CGRectMake(20, localY, w-40, 0);
    ingredientsText.textColor = [UIColor whiteColor];
    ingredientsText.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
    ingredientsText.text = recipe[@"ingredients"];
    
    //ingredientsText.text = @"2 Eier\n150gr Butter\n200ml Wasser\n200gr Safron\n3 Chillies\n2 Esslöffel Rapsöl\n15gr Salz";

    ingredientsText.numberOfLines = 0;
    [ingredientsText sizeToFit];
    [cookView addSubview:ingredientsText];
    
    localY += ingredientsText.frame.size.height;
    localY += 20;
    
    
    //INSTRUCTIONS
    UILabel * instructionsLabel = [UILabel new];
    instructionsLabel.frame = CGRectMake(20, localY, w-40, 40);
    instructionsLabel.textColor = [UIColor whiteColor];
    instructionsLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    instructionsLabel.text = @"Zubereitung";
    [cookView addSubview:instructionsLabel];
    
    localY += 40;
    
    UILabel * instructionsText = [UILabel new];
    instructionsText.frame = CGRectMake(20, localY, w-40, 0);
    instructionsText.textColor = [UIColor whiteColor];
    instructionsText.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
    instructionsText.text = recipe[@"instructions"];
    instructionsText.numberOfLines = 0;
    [instructionsText sizeToFit];
    [cookView addSubview:instructionsText];
    
    localY += instructionsText.frame.size.height;
    localY += 20;
    
    //COOK
    UIButton * cookButton = [UIButton new];
    cookButton.frame = CGRectMake(20, localY, w-40, 60);
    cookButton.layer.borderColor = _peacock.appColour.CGColor;
    cookButton.layer.borderWidth = 1.0f;
    [cookButton setTitle:@"Jetzt Kochen" forState:UIControlStateNormal];
    [cookButton setTitleColor:_peacock.appColour forState:UIControlStateNormal];
    [cookButton.titleLabel setFont:[UIFont systemFontOfSize:30.0f weight:UIFontWeightThin]];
    [cookView addSubview:cookButton];
    
    localY += 60;
    localY += 20;
    
    cookView.frame = CGRectMake(0, yOff, w, localY);
    
    return localY;
}
-(void)cook {
    
    
}

//PROFILE
-(void)layoutProfileAtOffset:(float)yOff {
    
    UIView * chefView = [UIView new];
    chefView.frame = CGRectMake(0, yOff, w, 80);
    chefView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
    chefView.clipsToBounds = true;
    [mainScroller addSubview:chefView];
    
    chefIV = [UIImageView new];
    chefIV.frame =  CGRectMake(0, 0, w, 80);
    chefIV.contentMode = UIViewContentModeScaleAspectFill;
    [chefView addSubview:chefIV];
    
    UIImageView * chefCover = [UIImageView new];
    chefCover.frame = chefView.bounds;
    chefCover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    [chefView addSubview:chefCover];
    
    UIView * profileCircle = [UIView new];
    profileCircle.frame = CGRectMake(10, 10, 60, 60);
    profileCircle.layer.cornerRadius = 30.0f;
    profileCircle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [chefView addSubview:profileCircle];
    
    UILabel * profileLabel = [UILabel new];
    profileLabel.frame = profileCircle.bounds;
    profileLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
    profileLabel.textColor = [UIColor whiteColor];
    profileLabel.textAlignment = NSTextAlignmentCenter;
    profileLabel.text = [_peacock initialsForName:recipe[@"userName"]];
    [profileCircle addSubview:profileLabel];
    
    UIImageView * profileIV = [UIImageView new];
    profileIV.frame = CGRectMake(10, 10, 60, 60);
    profileIV.layer.cornerRadius = 30.0f;
    profileIV.contentMode = UIViewContentModeScaleAspectFill;
    profileIV.clipsToBounds = true;
    [profileCircle addSubview:profileIV];
    
    UILabel * nameLabel = [UILabel new];
    nameLabel.frame = CGRectMake(80, 28, w-120, 20);
    nameLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = recipe[@"userName"];
    [chefView addSubview:nameLabel];
    
    NSArray * recipes = chef[@"recipes"];
    NSString * recipeText = [NSString stringWithFormat:@"%i Gerichte", (int)recipes.count];
    if (recipes.count == 1){ recipeText = @"1 Gericht"; }
    
    UILabel * recipeCountLabel = [UILabel new];
    recipeCountLabel.frame = CGRectMake(80, 50, w-120, 20);
    recipeCountLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    recipeCountLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    recipeCountLabel.text = recipeText;
    [chefView addSubview:recipeCountLabel];
    
    float chefScore = [chef[@"score"] floatValue];
    int chefVotes = [chef[@"votes"] intValue];
    if (chefVotes > 3){
        UIView * chefStar = [_peacock starViewWithScore:chefScore ofColour:_peacock.appColour votes:chefVotes ofColour:[UIColor whiteColor] forHeight:15.0f atPoint:CGPointMake(80, 10)];
        [chefView addSubview:chefStar];
    } else {
        nameLabel.frame = CGRectMake(80, 10, w-120, 30);
        recipeCountLabel.frame = CGRectMake(80, 35, w-120, 30);
    }
    
    UIImageView * arrowIV = [UIImageView new];
    arrowIV.frame = CGRectMake(w-30, 0, 20, 80);
    arrowIV.contentMode = UIViewContentModeScaleAspectFit;
    arrowIV.image = [[UIImage imageNamed:@"next_right_thin-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    arrowIV.tintColor = [UIColor whiteColor];
    [chefView addSubview:arrowIV];
    
    UIButton * chefButton = [UIButton new];
    chefButton.frame = chefView.bounds;
    [chefButton addTarget:self action:@selector(showChef) forControlEvents:UIControlEventTouchUpInside];
    [chefView addSubview:chefButton];
}
-(void)showChef {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushChefVC" object:@"userID"];
}

//RANK
-(void)layoutRankViewAtOffset:(float)yOff {
    
    
    NSDictionary * ranks = [_donkey rankingForRecipe:recipe[@"recipeID"]];
    NSString * cantonal = [NSString stringWithFormat:@"# %@", ranks[@"cantonal"]];
    NSString * national = [NSString stringWithFormat:@"# %@", ranks[@"national"]];
    NSDictionary * percentages = ranks[@"percentages"];
    NSDictionary * voteCount = ranks[@"count"];
    
    UIView * rankView = [UIView new];
    rankView.frame = CGRectMake(0, yOff, w, 450);
    [mainScroller addSubview:rankView];
    
    float localY = 0.0f;
    float localX = 15.0f;
    
    UILabel * cantonLabel = [UILabel new];
    cantonLabel.frame = CGRectMake(20, localY, w-40, 40);
    cantonLabel.textColor = [UIColor whiteColor];
    cantonLabel.textAlignment = NSTextAlignmentLeft;
    cantonLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
    cantonLabel.text = recipe[@"location"];
    [rankView addSubview:cantonLabel];
    
    UILabel * cantonRank = [UILabel new];
    cantonRank.frame = CGRectMake(w-50, localY, 40, 40);
    cantonRank.textColor = [UIColor whiteColor];
    cantonRank.textAlignment = NSTextAlignmentLeft;
    cantonRank.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    cantonRank.text = cantonal;
    [rankView addSubview:cantonRank];
    
    localY += 30;
    
    UILabel * nationalLabel = [UILabel new];
    nationalLabel.frame = CGRectMake(20, localY, w-40, 40);
    nationalLabel.textColor = [UIColor whiteColor];
    nationalLabel.textAlignment = NSTextAlignmentLeft;
    nationalLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
    nationalLabel.text = @"Schweizweit";
    [rankView addSubview:nationalLabel];
    
    UILabel * nationalRank = [UILabel new];
    nationalRank.frame = CGRectMake(w-50, localY, 40, 40);
    nationalRank.textColor = [UIColor whiteColor];
    nationalRank.textAlignment = NSTextAlignmentLeft;
    nationalRank.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    nationalRank.text = national;
    [rankView addSubview:nationalRank];
    
    localY += 40;
    
    for (int n = 5; n > 0; n--){
        
        UIView * cell = [UIView new];
        cell.frame = CGRectMake(0, localY, w, 40);
        [rankView addSubview:cell];
        
        UILabel * label = [UILabel new];
        label.frame = CGRectMake(localX, 10, 20, 20);
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightBold];
        label.text = [NSString stringWithFormat:@"%i", n];
        [cell addSubview:label];
        
        localX += 20;
        
        UIImageView * iv = [UIImageView new];
        iv.frame = CGRectMake(localX, 9, 20, 20);
        iv.image = [[UIImage imageNamed:@"star_full-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        iv.tintColor = [UIColor whiteColor];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:iv];
        
        localX += 20 + 10;
        
        float trackLength = w-125;
        float trainLength = 0;
        NSString * voteText = @"(0)";
        NSString * key = [NSString stringWithFormat:@"%i", n];
        
        if (percentages[key]){
            trainLength = [percentages[key]floatValue] * trackLength / 100;
        }
        if (voteCount[key]){
            voteText = [NSString stringWithFormat:@"(%@)", voteCount[key]];
        }
        
        UIImageView * track = [UIImageView new];
        track.frame = CGRectMake(localX, 12, trackLength, 16);
        track.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
        [cell addSubview:track];

        UIImageView * train = [UIImageView new];
        train.frame = CGRectMake(0, 0, trainLength, 16);
        train.backgroundColor = _peacock.appColour;
        [track addSubview:train];
        
        localX += (w-125) + 10;
        
        UILabel * count = [UILabel new];
        count.frame = CGRectMake(localX, 10, 40, 20);
        count.textColor = [UIColor whiteColor];
        count.textAlignment = NSTextAlignmentLeft;
        count.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightBold];
        count.text = voteText;
        [cell addSubview:count];

        localY += 40;
        localX = 15;
    }
    
    localY += 10;

    UILabel * voteLabel = [UILabel new];
    voteLabel.frame = CGRectMake(20, localY, w-40, 40);
    voteLabel.textColor = [UIColor whiteColor];
    voteLabel.textAlignment = NSTextAlignmentLeft;
    voteLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    voteLabel.text = @"Deine Bewertung";
    [rankView addSubview:voteLabel];
    
    localY += 40;
    localX = 20;
    
    starSlider = [UIView new];
    starSlider.frame = CGRectMake(0, localY, w, 40);
    starSlider.userInteractionEnabled = true;
    [rankView addSubview:starSlider];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRate:)];
    [starSlider addGestureRecognizer:pan];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRate:)];
    [starSlider addGestureRecognizer:tap];
    
    for (int n = 0; n < 5; n++){
        
        UIImageView * starIV = [UIImageView new];
        starIV.frame = CGRectMake(localX, 0, 40, 40);
        starIV.contentMode = UIViewContentModeScaleAspectFit;
        starIV.image = [[UIImage imageNamed:@"star_full-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        starIV.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        [starSlider addSubview:starIV];
        localX += 40+5;
    }

    
    localY += 45;
    
    rateHintLabel = [UILabel new];
    rateHintLabel.frame = CGRectMake(20, localY, w-40, 20);
    rateHintLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    rateHintLabel.textColor = [UIColor whiteColor];
    rateHintLabel.text = @"Noch Keine Bewertung";
    [rankView addSubview:rateHintLabel];
    
    
}
-(void)panRate:(UIPanGestureRecognizer *)pan {
    float x = [pan locationInView:starSlider].x;
    int star = MIN((x / 45.0f), 4);
    [self updateRate:star];
}
-(void)tapRate:(UITapGestureRecognizer *)tap {
    float x = [tap locationInView:starSlider].x;
    int star = MIN((x / 45.0f), 4);
    [self updateRate:star];
}
-(void)updateRate:(int)rate {
    
    for (int n = 0; n<5; n++){
        UIImageView * starIV = starSlider.subviews[n];
        if (n<=rate){
            starIV.tintColor = _peacock.appleBlue;
        } else {
            starIV.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        }
    }
    
    NSArray * rateHints = @[@"Giftig",@"Braucht Arbeit",@"Durchschnittlich",@"Geschmackvoll",@"Köstlich"];
    rateHintLabel.text = rateHints[rate];
    
    [_dog voteOnRecipe:recipe[@"recipeID"]
            forVoterID:_donkey.deviceUser[@"userID"]
            forOwnerID:recipe[@"userID"]
              withVote:(rate+1)];
}



//MEDIA
-(void)layoutMediaViewAtOffset:(float)yOff {
    
    UIView * mediaView = [UIView new];
    mediaView.frame = CGRectMake(0, yOff, w, 280);
    mediaView.backgroundColor = [UIColor redColor];
    [contentView addSubview:mediaView];
    
    mediaIV = [UIImageView new];
    mediaIV.frame = CGRectMake(0, 0, w, 330);
    mediaIV.backgroundColor = [UIColor blackColor];
    mediaIV.contentMode = UIViewContentModeScaleAspectFill;
    mediaIV.clipsToBounds = true;
    mediaIV.image = [UIImage imageNamed:@"recipe.png"];
    [mediaView addSubview:mediaIV];
    
    UIImageView * cover = [UIImageView new];
    cover.frame = mediaView.bounds;
    cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    [mediaView addSubview:cover];
    
    CAGradientLayer * gradient = [CAGradientLayer layer];
    gradient.frame = cover.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, [[UIColor blackColor] colorWithAlphaComponent:1.0f].CGColor, nil];
    gradient.locations = @[@0.0,@0.5,@1.0];
    [cover.layer insertSublayer:gradient atIndex:0];
    
    UIButton * moreMediaButton = [UIButton new];
    moreMediaButton.frame = CGRectMake(w-140, 280-50, 120, 40);
    [moreMediaButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightThin]];
    [moreMediaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreMediaButton setTitle:@"Weitere Fotos" forState:UIControlStateNormal];
    moreMediaButton.layer.borderColor = [UIColor whiteColor].CGColor;
    moreMediaButton.layer.borderWidth = 1.0f;
    [mediaView addSubview:moreMediaButton];
    
}


//VIDEO
-(void)layoutVideoViewAtOffset:(float)yOff {
    
    UIView * videoView = [UIView new];
    videoView.frame = CGRectMake(0, yOff, w, 160);
    [mainScroller addSubview:videoView];
    
    /*
     videoView.layer.shadowColor = [UIColor blackColor].CGColor;
     videoView.layer.shadowOffset = CGSizeMake(0, 0);
     videoView.layer.shadowRadius = 1.0f;
     videoView.layer.shadowOpacity = 0.5f;
     */
    UIImageView * videoIV = [UIImageView new];
    videoIV.frame = CGRectMake(0, 0, w, 160);
    videoIV.backgroundColor = [UIColor blackColor];
    videoIV.contentMode = UIViewContentModeScaleAspectFill;
    videoIV.clipsToBounds = true;
    [videoView addSubview:videoIV];
    
    UIImageView * cover = [UIImageView new];
    cover.frame = videoIV.bounds;
    cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    //cover.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f].CGColor;
    //cover.layer.borderWidth = 2.0f;
    [videoIV addSubview:cover];
    
    UIImageView * playIV = [UIImageView new];
    playIV.frame = CGRectMake((w-60)/2, 50, 60, 60);
    playIV.contentMode = UIViewContentModeScaleAspectFit;
    playIV.image = [[UIImage imageNamed:@"play-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    playIV.tintColor = [UIColor whiteColor];
    [videoIV addSubview:playIV];
    
    UIButton * videoButton = [UIButton new];
    videoButton.frame = videoView.bounds;
    [videoButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [videoView addSubview:videoButton];
    
    videoIV.image = [UIImage imageNamed:@"recipe.png"];
    
}
-(void)playVideo {
    
}



//SCROLLING
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:mainScroller]){
        
        float travelDistance = h + 280;
        UIView * mediaView = mediaIV.superview;
        float mediaIVY = [contentView convertPoint:mediaView.frame.origin toView:self.view].y+280;
        float p = mediaIVY/travelDistance; //percentage complete of vertical journey
        mediaIV.transform = CGAffineTransformMakeTranslation(0, p*-50);

        travelDistance = h + 80;
        UIView * chefView = chefIV.superview;
        float chefIVY = [mainScroller convertPoint:chefView.frame.origin toView:self.view].y+80;
        p = chefIVY/travelDistance;
        chefIV.transform = CGAffineTransformMakeTranslation(0, p*-20);
        
    }
    
    
}


-(NSArray *)splitStringsForTitle:(NSString *)title {
    
    NSString * firstString = @"";
    NSString * secondString = @"";
    NSArray * strings;
    NSArray * splitters = @[@" mit", @" im", @" in", @" und", @" a la", @" à la", @" avec", @" with", @" and"];
    for (NSString * splitter in splitters){
        if ([title containsString:splitter]){
            
            NSLog(@"HIT");
            
            strings = [title componentsSeparatedByString:splitter];
            firstString = strings[0];
            secondString = [NSString stringWithFormat:@"%@%@", [splitter substringWithRange:NSMakeRange(1, [splitter length]-1)].capitalizedString, strings[1]];
            return @[firstString, secondString];
        }
    }
    
    
    if ([title containsString:@" "]){
        
        strings = [title componentsSeparatedByString:@" "];
        if (strings.count == 1){
            firstString = strings[0];
        } else if (strings.count == 2){
            firstString = [NSString stringWithFormat:@"%@ %@",strings[0], strings[1]];
        } else if (strings.count > 2){
            firstString = [NSString stringWithFormat:@"%@ %@", strings[0], strings[1]];
            secondString = strings[2];
            for (int n = 3; n<strings.count; n++){
                secondString = [secondString stringByAppendingString:[NSString stringWithFormat:@" %@", strings[n]]];
            }
        }
        
        return @[firstString, secondString];
        
    }
    
    return @[title, @""];
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
-(UIImageView *)breakerDotAtPoint:(CGPoint)point {
    
    UIImageView * dot = [UIImageView new];
    dot.frame = CGRectMake(point.x, point.y, 10, 10);
    dot.layer.cornerRadius = 5;
    dot.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    return dot;
}


//OTHER
-(void)popSelf {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopRecipeVC" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 UIImageView * bgIV = [UIImageView new];
 bgIV.frame = descriptionView.bounds;
 bgIV.image = [UIImage imageNamed:@"recipe.png"];
 bgIV.contentMode = UIViewContentModeScaleAspectFill;
 bgIV.clipsToBounds = true;
 [descriptionView addSubview:bgIV];
 
 UIVisualEffectView * vs = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
 vs.frame = bgIV.bounds;
 [bgIV addSubview:vs];
 */
@end
