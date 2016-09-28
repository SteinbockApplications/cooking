//
//  userCell.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 08/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "userCell.h"
#import "Peacock.h"
@implementation userCell{
    
    Peacock * _peacock;
    
    float w;
    float h;
    
    UILabel * titleLabel;
    UILabel * subtitleLabel;
    UILabel * profileLabel;
    UILabel * noScoreLabel;
    UILabel * rankLabel;
    
}
@synthesize profileIV, button;
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _peacock = [Peacock sharedInstance];
        
        w = frame.size.width;
        h = frame.size.height;
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIView * profileCircle = [UIView new];
        profileCircle.frame = CGRectMake(10, 10, 60, 60);
        profileCircle.layer.cornerRadius = 30.0f;
        profileCircle.backgroundColor = _peacock.appleGrey;
        [self addSubview:profileCircle];
        
        profileLabel = [UILabel new];
        profileLabel.frame = profileCircle.bounds;
        profileLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
        profileLabel.textColor = [UIColor whiteColor];
        profileLabel.textAlignment = NSTextAlignmentCenter;
        [profileCircle addSubview:profileLabel];
        
        profileIV = [UIImageView new];
        profileIV.frame = profileCircle.bounds;
        profileIV.contentMode = UIViewContentModeScaleAspectFill;
        profileIV.clipsToBounds = true;
        profileIV.layer.cornerRadius = 30.0f;
        [profileCircle addSubview:profileIV];

        noScoreLabel = [UILabel new];
        noScoreLabel.frame = CGRectMake(80, 10, w-90, 20.0f);
        noScoreLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        noScoreLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self addSubview:noScoreLabel];
        
        rankLabel = [UILabel new];
        rankLabel.frame = CGRectMake(80, 10, w-90, 20.0f);
        rankLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        rankLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        rankLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:rankLabel];
        
        titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(80, 30, w-90, 20.0f);
        titleLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
        titleLabel.textColor = [UIColor blackColor];
        [self addSubview:titleLabel];
        
        subtitleLabel = [UILabel new];
        subtitleLabel.frame = CGRectMake(80, 50, w-90, 20.0f);
        subtitleLabel.font = [UIFont systemFontOfSize:13.0f weight:UIFontWeightThin];
        subtitleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self addSubview:subtitleLabel];
    
        UIImageView * div = [UIImageView new];
        div.frame = CGRectMake(0, 79.5, w, 0.5f);
        div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
        [self addSubview:div];
        
        button = [UIButton new];
        button.frame = self.bounds;
        [self addSubview:button];
        
    }
    return self;
}
-(void)updateForUser:(NSDictionary *)user atRank:(int)rank {
    
    //NSLog(@"user is %@", user);

    //pull data
    NSString * name = user[@"name"];
    NSString * location = user[@"location"];
    float score = [user[@"score"] floatValue];
    int votes = [user[@"votes"] intValue];
    
    //pull initials--> set label text
    NSString * first = [name substringToIndex:1];
    NSString * second = @"";
    NSArray * split = [name componentsSeparatedByString:@" "];
    if (split.count > 1){
        second = [split[split.count-1] substringToIndex:1];
    }
    profileLabel.text = [NSString stringWithFormat:@"%@%@", first, second];
    
    //set image
    //profileIV.image = [UIImage imageNamed:@"cookd.png"];
    // NSString * path = [NSString stringWithFormat:@"http://www.steinbockapplications.com/other/cooking/users/%@/profile_thumb.jpg",user[@"userID"]];
    // UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];
    // bgIV.image = image;
    
    
    //star view
    if (votes < 3){
        
        noScoreLabel.text = @"Zu wenige Bewertungen";
    
        //title label
        titleLabel.text = name;
        
        //subtitle
        subtitleLabel.text = location;
    
    } else {
        
        UIView * starView = [_peacock starViewWithScore:score ofColour:_peacock.appColour votes:votes ofColour:_peacock.appleDark forHeight:15.0f atPoint:CGPointMake(80, 10)];
        [self addSubview:starView];
        
        //rank label
        rankLabel.text = [NSString stringWithFormat:@"#%i", rank];
        
        //title label
        titleLabel.text = name;
        
        //subtitle
        subtitleLabel.text = location;
    }

    



}



@end
