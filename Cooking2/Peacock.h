//
//  Peacock.h
//  Surveyor
//
//  Created by Steinbock Applications on 10/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Peacock : NSObject
@property UIColor * appleDark;
@property UIColor * appleGrey;
@property UIColor * appleWhite;
@property UIColor * appleBlue;
@property UIColor * tedRed;
@property UIColor * soundCloudOrange;
@property UIColor * appColour;

@property UIColor * korelessPink;
@property UIColor * korelessPurple;


+(id)sharedInstance;
-(NSString *)uniqueID;
-(UIColor *)colourForHex:(NSString *)hex;

-(UIImage *)applyFilterToImage:(UIImage *)image;
-(UIImage *)scaleImage:(UIImage *)image toMaxDimension:(float)max;
-(UIImage *)rotateImage:(UIImage *)image byDegree:(float)degrees;
-(UIImage*)unrotateImage:(UIImage*)image;

//
-(UIView *)starViewWithScore:(float)score ofColour:(UIColor *)colour forHeight:(float)height atPoint:(CGPoint)point;
-(UIView *)starViewWithScore:(float)score ofColour:(UIColor *)sColour votes:(int)votes ofColour:(UIColor *)vColour forHeight:(float)height atPoint:(CGPoint)point;


-(NSString *)initialsForName:(NSString *)name;

-(UIImageView *)breakerDotOfColour:(UIColor *)colour atPoint:(CGPoint)point;

-(void)updateStatusBarIsDark:(bool)isDark isHidden:(bool)isHidden;
-(NSString *)dateForTimestamp:(NSString *)ts;
@end
