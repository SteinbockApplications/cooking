//
//  filterVC.m
//  Cooking2
//
//  Created by Steinbock Applications on 04/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "filterVC.h"
#import "Peacock.h"
#import "Donkey.h"
@interface filterVC () {
    
    
    Peacock * _peacock;
    Donkey * _donkey;
    
    float w;
    float h;
    
    NSMutableArray * filters;
    UIScrollView * mainScroller;
    
}

@end

@implementation filterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
}
-(void)setup {
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    
    
}
-(void)layout {
    
    self.view.backgroundColor = _peacock.appColour;
    
    UIButton * closeButton = [UIButton new];
    closeButton.frame = CGRectMake(w-60, 15, 60, 60);
    [closeButton setImage:[[UIImage imageNamed:@"close-120.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [closeButton setTintColor:[UIColor whiteColor]];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [closeButton addTarget:self action:@selector(popSelfWithFilter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = CGRectMake(0, 70, w, h-70);
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.delegate = self;
    mainScroller.alwaysBounceVertical = true;
    mainScroller.userInteractionEnabled = true;
    [self.view addSubview:mainScroller];

    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(0, 70, w, 0.5f);
    div.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div];
    

}
-(void)beginWithFilter:(NSString *)filter withSelected:(NSString *)selected {

    NSLog(@"begin with filter: %@", filter);
    
    filters = [NSMutableArray arrayWithArray:_donkey.ranges];
    if ([filter isEqualToString:@"canton"]){
        filters = [NSMutableArray arrayWithArray:_donkey.cantons];
        [filters insertObject:@"Schweizweit" atIndex:0];
    }
    
    float yOff = 0;
    for (NSString * filter in filters){
        UIView * cell = [UIView new];
        cell.frame = CGRectMake(0, yOff, w, 60);
        [mainScroller addSubview:cell];
        
        UIImageView * radioIV = [UIImageView new];
        radioIV.frame = CGRectMake(10, 20, 20, 20);
        radioIV.layer.cornerRadius = 10.0f;
        radioIV.layer.borderColor = [UIColor whiteColor].CGColor;
        radioIV.layer.borderWidth = 1.0f;
        [cell addSubview:radioIV];
        
        //if selected
        if ([filter isEqualToString:selected]){
            UIImageView * dot = [UIImageView new];
            dot.frame = CGRectMake(5, 5, 10, 10);
            dot.layer.cornerRadius = 5.0f;
            dot.backgroundColor = [UIColor whiteColor];
            [radioIV addSubview:dot];
        }
        
        UILabel * label = [UILabel new];
        label.frame = CGRectMake(40, 0, w-50, 60);
        label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
        label.textColor = [UIColor whiteColor];
        label.text = filter;
        [cell addSubview:label];
        
        UIImageView * div = [UIImageView new];
        div.frame = CGRectMake(10, 59, w-10, 1.0f);
        div.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
        [cell addSubview:div];
        
        UIButton * button = [UIButton new];
        button.frame = cell.bounds;
        [button addTarget:self action:@selector(filterSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
        
        yOff += 60;
    }
    
    mainScroller.contentSize = CGSizeMake(w, yOff);
}
-(void)filterSelected:(UIButton *)button {
    [self popSelfWithFilter:filters[[mainScroller.subviews indexOfObject:button.superview]]];
}
-(void)popSelfWithFilter:(NSString *)filter {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopFilterVC" object:filter];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
