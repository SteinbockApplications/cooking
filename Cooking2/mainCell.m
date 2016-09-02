//
//  mainCell.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 02/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "mainCell.h"
#import "Peacock.h"

@implementation mainCell {
    
    float w;
    float h;
    
    UIView * starView;
    UILabel * scoreLabel;
    Peacock * _peacock;
    
}
@synthesize bgIV, titleLabel, subtitleLabel, button;
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _peacock = [Peacock sharedInstance];
        
        self.clipsToBounds = true;
        
        w = frame.size.width;
        h = frame.size.height;
        
        bgIV = [UIImageView new];
        bgIV.frame = CGRectMake(0, 0, w, h+50);
        bgIV.contentMode = UIViewContentModeScaleAspectFill;
        bgIV.clipsToBounds = true;
        [self addSubview:bgIV];
        
        UIImageView * cover = [UIImageView new];
        cover.frame = self.bounds;
        cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self addSubview:cover];
        
        scoreLabel = [UILabel new];
        scoreLabel.frame = CGRectMake(10, 10, 300, 20.0f);
        scoreLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        scoreLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
        [self addSubview:scoreLabel];
        
        
        titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(0, 0, 300, 0.0f);
        titleLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightRegular];
        titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
        [self addSubview:titleLabel];
        
        subtitleLabel = [UILabel new];
        subtitleLabel.frame = CGRectMake(0, 0, 300, 0.0f);
        subtitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        subtitleLabel.numberOfLines = 0;
        subtitleLabel.textAlignment = NSTextAlignmentJustified;
        subtitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
        [self addSubview:subtitleLabel];

        starView = [UIView new];
        starView.clipsToBounds = true;
        [self addSubview:starView];
        
        button = [UIButton new];
        button.frame = self.bounds;
        [self addSubview:button];
        
        
    }
    return self;
}
-(void)updateForUser:(NSDictionary *)user {
    
    scoreLabel.text = @"#1 von 103 in Basel";
   // NSLog(@"user is %@", user);
    
    NSString * path = [NSString stringWithFormat:@"http://www.steinbockapplications.com/other/cooking/users/%@/profile_thumb.jpg",user[@"userID"]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];
    bgIV.image = image;
    
    float starHeight = 0;
    if (user[@"score"]){
        
        float xOff = 0;
        for (int n = 0; n < 5; n++){
            UIImageView * starIV = [UIImageView new];
            starIV.frame = CGRectMake(xOff, 0, 30, 30);
            starIV.contentMode = UIViewContentModeScaleAspectFit;
            starIV.image = [[UIImage imageNamed:@"star_full-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            starIV.tintColor = _peacock.appColour;
            [starView addSubview:starIV];
            xOff += 35;
        }
        float score = [user[@"score"] floatValue];
        float width = score * 30 + (int)score * 5;
        starView.frame = CGRectMake(10, h-40, width, 30);
        starHeight = 30;
    }
    
    //SUBTITLE
    NSString * location = user[@"location"];
    NSString * skill = user[@"skill"];
    subtitleLabel.text = [NSString stringWithFormat:@"%@    %@", location, skill];
    [subtitleLabel sizeToFit];
    
    float subtitleHeight = subtitleLabel.frame.size.height;
    [subtitleLabel setFrame:CGRectMake(10, h-starHeight-15-subtitleHeight, 300, subtitleHeight)];
    
    //TITLE
    titleLabel.text = user[@"name"];
    [titleLabel sizeToFit];
    
    float titleHeight = titleLabel.frame.size.height;
    [titleLabel setFrame:CGRectMake(10, h-starHeight-15-subtitleHeight-titleHeight, 300, titleHeight)];
}
-(void)updateForRecipe:(NSDictionary *)recipe {
    
    NSLog(@"recipe is %@", recipe);
    scoreLabel.text = @"#1 in Basel";

    
    NSString * path = [NSString stringWithFormat:@"http://www.steinbockapplications.com/other/cooking/users/%@/%@/hero.jpg",recipe[@"userID"],recipe[@"recipeID"]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];
    bgIV.image = image;
    
    float starHeight = 0;
    if (recipe[@"score"]){
        
        float xOff = 0;
        for (int n = 0; n < 5; n++){
            UIImageView * starIV = [UIImageView new];
            starIV.frame = CGRectMake(xOff, 0, 30, 30);
            starIV.contentMode = UIViewContentModeScaleAspectFit;
            starIV.image = [[UIImage imageNamed:@"star_full-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            starIV.tintColor = _peacock.appColour;
            [starView addSubview:starIV];
            xOff += 35;
        }
        float score = [recipe[@"score"] floatValue];
        float width = score * 30 + (int)score * 5;
        starView.frame = CGRectMake(10, h-40, width, 30);
        starHeight = 30;
    }
    
    //SUBTITLE
    NSString * course = recipe[@"course"];
    NSString * difficulty = recipe[@"difficulty"];
    subtitleLabel.text = [NSString stringWithFormat:@"%@    %@", course, difficulty];
    [subtitleLabel sizeToFit];
    
    float subtitleHeight = subtitleLabel.frame.size.height;
    [subtitleLabel setFrame:CGRectMake(10, h-starHeight-15-subtitleHeight, 300, subtitleHeight)];
    
    //TITLE
    titleLabel.text = recipe[@"recipeName"];
    [titleLabel sizeToFit];
    
    float titleHeight = titleLabel.frame.size.height;
    [titleLabel setFrame:CGRectMake(10, h-starHeight-15-subtitleHeight-titleHeight, 300, titleHeight)];

}
-(void)updateLayoutForTitle:(NSString *)title subtitle:(NSString *)subtitle {
    



    

    
}
@end
