//
//  Donkey.h
//  Cooking
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Donkey : NSObject
@property User * currentUser;
@property NSArray * cantons;
@property NSArray * skillLevels;
@property NSArray * courses;

@property NSMutableArray * users;
@property NSMutableArray * recipes;
@property NSMutableArray * scores;

+(id)sharedInstance;
-(void)saveCurrentUser;
-(void)loadCurrentUser;

-(void)parseMeta:(NSDictionary *)meta;
@end
