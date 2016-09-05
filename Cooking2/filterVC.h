//
//  filterVC.h
//  Cooking2
//
//  Created by Steinbock Applications on 04/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface filterVC : UIViewController <UIScrollViewDelegate>
-(void)beginWithFilter:(NSString *)filter withSelected:(NSString *)selected;
@end
