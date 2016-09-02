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
@property NSDictionary * deviceUser;
@property User * currentUser;
@property NSArray * cantons;
@property NSArray * skillLevels;
@property NSArray * courses;

@property NSMutableDictionary * users;
@property NSMutableDictionary * recipes;

+(id)sharedInstance;
-(void)saveCurrentUser;
-(void)loadCurrentUser;

-(void)parseMeta:(NSDictionary *)meta;

-(void)sortUserByScore;
-(NSArray *)sortUsersByScoreForCanton:(NSString *)canton forRange:(int)days;
-(NSArray *)sortRecipesByScoreForCanton:(NSString *)canton forRange:(int)days;
@end
