//
//  User.h
//  Cooking
//
//  Created by Duncan Geoghegan on 26/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property NSString * userID;
@property NSString * email;
@property NSString * name;

@property NSString * location;
@property NSString * bio;
@property NSString * skillLevel;
@property NSString * exposesContact;

@property NSArray * followingArray;
@property NSArray * favouriteArray;
@property NSArray * recipeArray;

@end
