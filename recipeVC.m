//
//  recipeVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "recipeVC.h"
#import "Peacock.h"

@interface recipeVC () {
    
    Peacock * _peacock;
    float w;
    float h;
    
    UIScrollView * mainScroller;
    UIView * contentView;
    UIImageView * mediaIV;
    UIImageView * chefIV;
}

@end

@implementation recipeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
    [self begin];
}
-(void)setup{
    
    _peacock = [Peacock sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
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
    
    contentView = [UIView new];
    [mainScroller addSubview:contentView];
    
    UIButton * backButton = [UIButton new];
    backButton.frame = CGRectMake(10, 30, 30, 30);
    [backButton setImage:[[UIImage imageNamed:@"arrow_left_thin-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    float yOff = 0.0f;
    yOff += [self layoutTopView];
    
    [self layoutMediaViewAtOffset:yOff];
    yOff += 280;
    
    [self layoutPrepViewAtOffset:yOff];
    yOff += 400;
    
    [self layoutVideoViewAtOffset:yOff];
    yOff += 160.0f + 5;
    
    [self layoutChefViewAtOffset:yOff];
    yOff += 80.0f + 5;
    
    [self layoutRatingViewAtOffset:yOff];
    yOff += 120.0f + 10;
    
    contentView.frame = CGRectMake(0, 0, w, yOff+20);
    mainScroller.contentSize = CGSizeMake(w, yOff+20);
}
-(void)begin{
    
}

//TOP

-(float)layoutTopView {
    
    UIView * topView = [UIView new];
    topView.backgroundColor = [UIColor blackColor];
    [mainScroller addSubview:topView];
    
    //BACKGROUND
    UIImageView * recipeIV = [UIImageView new];
    recipeIV.frame = CGRectMake(0, 0, w, 400);
    recipeIV.contentMode = UIViewContentModeScaleAspectFill;
    recipeIV.clipsToBounds = true;
    recipeIV.image = [UIImage imageNamed:@"recipe.png"];
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
    timeLabel.text = @"105min";
    timeLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    timeLabel.textColor = [UIColor whiteColor];
    [timeView addSubview:timeLabel];
    
    //LAYOUT UPSIDE DOWN (text height is dynamic)
    float yOff = 400;
    float xOff = 20;
    
    //div marks mid point
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(xOff, yOff, w-2*xOff, 0.5f);
    div.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [topView addSubview:div];
    
    //TITLE
    NSString * name = @"Pan-Seared Carrot in Duck Sauce";
    NSArray * splitsies = [self splitStringsForTitle:name];
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
        
        yOff = yOff-nameLabel.frame.size.height-5;
        nameLabel.frame = CGRectMake(xOff, yOff, w-2*xOff, nameLabel.frame.size.height);
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
        
        yOff = yOff-nameLabel.frame.size.height;
        nameLabel.frame = CGRectMake(xOff, yOff, w-2*xOff, nameLabel.frame.size.height);
    }
    
    
    //STAR VIEW
    yOff -= 30;
    UIView * starView = [self starViewWithScore:5.0f ofColour:_peacock.appColour forHeight:30 atPoint:CGPointMake(xOff, yOff)];
    [topView addSubview:starView];
    
    
    //END REVERSE LAYOUT
    yOff = 410;
    
    //COURSE + DIFFICULTY LABEL
    UILabel * courseLabel = [UILabel new];
    courseLabel.frame = CGRectMake(xOff, yOff, 0, 20);
    courseLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    courseLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    courseLabel.text = @"Hauptgericht";
    [courseLabel sizeToFit];
    [topView addSubview:courseLabel];
    
    xOff += courseLabel.frame.size.width + 5;
    [topView addSubview:[self breakerDotAtPoint:CGPointMake(xOff, yOff+5)]];
    xOff += 15;
    
    UILabel * difficultyLabel = [UILabel new];
    difficultyLabel.frame = CGRectMake(xOff, yOff, 0, 20);
    difficultyLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    difficultyLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    difficultyLabel.text = @"Schwierig";
    [difficultyLabel sizeToFit];
    [topView addSubview:difficultyLabel];
    
    xOff = 20;
    yOff += 28;
    
    UIImageView * divB = [UIImageView new];
    divB.frame = CGRectMake(xOff, yOff, w-2*xOff, 0.5f);
    divB.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [topView addSubview:divB];
    
    yOff += 10;
    
    //DESCRIPTION
    UITextView * description = [UITextView new];
    description.frame = CGRectMake(xOff, yOff, w-2*xOff, 0);
    description.backgroundColor = [UIColor clearColor];
    description.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    description.textColor = [UIColor whiteColor];
    description.textContainer.lineFragmentPadding = 0;
    description.textContainerInset = UIEdgeInsetsZero;
    description.userInteractionEnabled = false;
    description.textAlignment = NSTextAlignmentJustified;
    description.text = @"It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.";
    [description sizeToFit];
    [topView addSubview:description];
    
    yOff += description.frame.size.height+10;
    
    //LAYOUT BUTTONS BELOW
    UIView * favouriteView = [UIView new];
    favouriteView.backgroundColor = _peacock.appColour;
    [topView addSubview:favouriteView];
    
    UILabel * favouriteLabel = [UILabel new];
    favouriteLabel.frame = CGRectMake(0, 0, 0, 40);
    favouriteLabel.text = @"In Favouriten";
    favouriteLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    favouriteLabel.textColor = [UIColor whiteColor];
    [favouriteLabel sizeToFit];
    [favouriteView addSubview:favouriteLabel];
    
    [favouriteLabel setFrame:CGRectMake(40, 0, favouriteLabel.frame.size.width, 40)];
    [favouriteView setFrame:CGRectMake(xOff, yOff, favouriteLabel.frame.size.width+50, 40)];
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
    
    
    xOff += favouriteView.frame.size.width + 10;
    
    //SHARE
    UIView * shareView = [UIView new];
    [topView addSubview:shareView];
    
    UILabel * shareLabel = [UILabel new];
    shareLabel.frame = CGRectMake(0, 0, 0, 40);
    shareLabel.text = @"Teilen";
    shareLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    shareLabel.textColor = [UIColor whiteColor];
    [shareLabel sizeToFit];
    [shareView addSubview:shareLabel];
    
    [shareLabel setFrame:CGRectMake(40, 0, shareLabel.frame.size.width, 40)];
    [shareView setFrame:CGRectMake(w-20-shareLabel.frame.size.width-50, yOff, shareLabel.frame.size.width+50, 40)];
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
    
    yOff += 60;
    
    //LAYOUT DESCRIPTION
    topView.frame = CGRectMake(0, 0, w, yOff);
    
    return yOff;
}
-(void)favourite {
    
}
-(void)share {
    
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

//PREP
-(void)layoutPrepViewAtOffset:(float)yOff {
    
    
    UIView * prepView = [UIView new];
    prepView.frame = CGRectMake(0, yOff, w, 400);
    prepView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    [mainScroller addSubview:prepView];
    
    UIView * menuBar = [UIView new];
    menuBar.frame = CGRectMake(0, 0, w, 50);
    menuBar.backgroundColor = [UIColor blackColor];
    [prepView addSubview:menuBar];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 0, w-40, 0.5f);
    div.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [menuBar addSubview:div];
    
    UIButton * ingredientsButton = [UIButton new];
    ingredientsButton.frame = CGRectMake(0, 0, w/2, 50);
    [ingredientsButton setTitle:@"Zutaten" forState:UIControlStateNormal];
    [ingredientsButton setTitleColor:_peacock.appColour forState:UIControlStateNormal];
    [ingredientsButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [ingredientsButton addTarget:self action:@selector(showIngredients) forControlEvents:UIControlEventTouchUpInside];
    [menuBar addSubview:ingredientsButton];
    
    UIButton * instructionsButton = [UIButton new];
    instructionsButton.frame = CGRectMake(w/2, 0, w/2, 50);
    [instructionsButton setTitle:@"Zubereitung" forState:UIControlStateNormal];
    [instructionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [instructionsButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightThin]];
    [instructionsButton addTarget:self action:@selector(showIngredients) forControlEvents:UIControlEventTouchUpInside];
    [menuBar addSubview:instructionsButton];
    
}
-(void)showIngredients {
    
}
-(void)showInstructions {
    
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

//CHEF
-(void)layoutChefViewAtOffset:(float)yOff {
    
    UIView * chefView = [UIView new];
    chefView.frame = CGRectMake(0, yOff, w, 80);
    chefView.backgroundColor = [UIColor blackColor];
    chefView.clipsToBounds = true;
    [mainScroller addSubview:chefView];
    
    chefIV = [UIImageView new];
    chefIV.frame =  CGRectMake(0, 0, w, 100);
    chefIV.image = [UIImage imageNamed:@"cookd.png"];
    chefIV.contentMode = UIViewContentModeScaleAspectFill;
    [chefView addSubview:chefIV];
    
    UIImageView * cover = [UIImageView new];
    cover.frame = chefView.bounds;
    cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    [chefView addSubview:cover];
    
    UIImageView * profileIV = [UIImageView new];
    profileIV.frame = CGRectMake(10, 10, 60, 60);
    profileIV.layer.cornerRadius = 30.0f;
    profileIV.contentMode = UIViewContentModeScaleAspectFill;
    profileIV.clipsToBounds = true;
    [chefView addSubview:profileIV];
    
    profileIV.image = [UIImage imageNamed:@"cookd.png"];
    
    UIView * starView = [self starViewWithScore:3.50f ofColour:_peacock.appColour forHeight:15 atPoint:CGPointMake(80, 10)];
    [chefView addSubview:starView];
    
    UILabel * nameLabel = [UILabel new];
    nameLabel.frame = CGRectMake(80, 28, w-120, 20);
    nameLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = @"Karin Sutterberg";
    [chefView addSubview:nameLabel];
    
    UILabel * recipeCountLabel = [UILabel new];
    recipeCountLabel.frame = CGRectMake(80, 50, w-120, 20);
    recipeCountLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    recipeCountLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    recipeCountLabel.text = @"22 Gerichte";
    [chefView addSubview:recipeCountLabel];
    
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
    
    NSLog(@"SHOW CHEF");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushChefVC" object:@"userID"];
}

//RATING
-(void)layoutRatingViewAtOffset:(float)yOff {
    
    UIView * ratingView = [UIView new];
    ratingView.frame = CGRectMake(0, yOff, w, 120);
    [mainScroller addSubview:ratingView];
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Deine Bewertung";
    [ratingView addSubview:label];
    
    float localX = 20;
    for (int n = 0; n < 5; n++){
        
        UIImageView * starIV = [UIImageView new];
        starIV.frame = CGRectMake(localX, 25, 40, 40);
        starIV.contentMode = UIViewContentModeScaleAspectFit;
        starIV.image = [[UIImage imageNamed:@"star_thin_empty-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        starIV.tintColor = [UIColor whiteColor];
        [ratingView addSubview:starIV];
        localX += 40+5;
        
    }
    
    UILabel * helperLabel = [UILabel new];
    helperLabel.frame = CGRectMake(20, 70, w-40, 20);
    helperLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    helperLabel.textColor = [UIColor whiteColor];
    helperLabel.text = @"Noch Keine Bewertung";
    [ratingView addSubview:helperLabel];
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
