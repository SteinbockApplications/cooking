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
        
        profileIV = [UIImageView new];
        profileIV.frame = CGRectMake(10, 10, 60, 60);
        profileIV.contentMode = UIViewContentModeScaleAspectFill;
        profileIV.clipsToBounds = true;
        profileIV.layer.cornerRadius = 30.0f;
        profileIV.backgroundColor = _peacock.appleDark;
        [self addSubview:profileIV];

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
-(void)updateForUser:(NSDictionary *)user {
    
    NSLog(@"user is %@", user);
    
    //profile iv
    profileIV.image = [UIImage imageNamed:@"cookd.png"];
    // NSString * path = [NSString stringWithFormat:@"http://www.steinbockapplications.com/other/cooking/users/%@/profile_thumb.jpg",user[@"userID"]];
    // UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];
    // bgIV.image = image;
    
    
    //star view
    UIView * starView = [_peacock starViewWithScore:4.70f ofColour:_peacock.appColour forHeight:15.0f atPoint:CGPointMake(80, 10)];
    [self addSubview:starView];
    
    //rank label
    rankLabel.text = @"#1";
    
    //title label
    titleLabel.text = user[@"name"];

    //subtitle
    subtitleLabel.text = user[@"location"];


}

@end
