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
@end
