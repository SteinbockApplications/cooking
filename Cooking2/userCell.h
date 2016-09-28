//
//  userCell.h
//  Cooking2
//
//  Created by Duncan Geoghegan on 08/09/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userCell : UIView
@property UIImageView * profileIV;
@property UIButton * button;
-(void)updateForUser:(NSDictionary *)user atRank:(int)rank;
@end
