//
//  Dog.h
//  car4rep
//
//  Created by Duncan Geoghegan on 29/10/15.
//  Copyright © 2015 Steinbock Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface Dog : NSObject <NSURLSessionDelegate>
+(id)sharedInstance;
-(void)fetchMetaData;
-(void)fetchFile:(NSString *)filename fromFolder:(NSString *)folder callback:(NSString *)callback;

-(void)checkUsernameIsAvailable:(NSString *)username;
-(void)updateUser:(NSDictionary *)dictionary;
-(void)updateRecipe:(NSDictionary *)dictionary;





@end
