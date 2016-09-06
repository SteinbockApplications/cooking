//
//  Peacock.m
//  Surveyor
//
//  Created by Steinbock Applications on 10/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "Peacock.h"

@implementation Peacock
static Peacock *sharedInstance = nil;
@synthesize appleDark, appleGrey, appleWhite, appleBlue, tedRed, soundCloudOrange, appColour;
@synthesize korelessPink, korelessPurple;

+ (Peacock *)sharedInstance {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}
- (id)init {
    self = [super init];
    if (self) {
     
        appleDark = [self colourForHex:@"#999999"];
        appleGrey = [self colourForHex:@"#F2F2F2"];
        appleWhite = [self colourForHex:@"#FAFAFA"];
        appleBlue = [self colourForHex:@"#007AFF"];
        tedRed = [self colourForHex:@"#E62B1D"];
        soundCloudOrange = [self colourForHex:@"#FF3F1B"];
        //appColour = [self colourForHex:@"#365F18"];
        //appColour = [self colourForHex:@"#5C00E6"];
        appColour = soundCloudOrange;
        
        //koreless purple #773275
        //koreless pink #A41838
        
        korelessPurple = [self colourForHex:@"#773275"];
        korelessPink = [self colourForHex:@"#A41838"];
    }
    return self;
}

-(NSString *)uniqueID {
    
    //semi-unique
    return [NSString stringWithFormat:@"%.0f_%i%c",[[NSDate date] timeIntervalSince1970]*1000,arc4random()%10000,arc4random_uniform(26) + 'a'];
}
-(UIColor*)colourForHex:(NSString*)hex {
    

    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    /* if([self checkNamedColours:cString]){
     cString = [self checkNamedColours:cString];
     }*/
    
    NSString *lowerCase = [hex lowercaseString];
    if ([lowerCase isEqualToString:@"clear"] || [lowerCase isEqualToString:@""] || [lowerCase isEqualToString:@"none"] || [lowerCase isEqualToString:@"transparent"]){
        return [UIColor clearColor];
    }
    
    cString = [cString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
    
}


//IMAGES
-(UIImage *)applyFilterToImage:(UIImage *)image {

    CIImage * startImage = [CIImage imageWithData:UIImageJPEGRepresentation(image, 1.0)];
    CIContext * context = [CIContext contextWithOptions:nil];
    CIFilter * ciFilter = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, startImage, nil];
    CIImage * outputImage = [ciFilter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage * filteredImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return filteredImage;
}
-(UIImage *)scaleImage:(UIImage *)image toMaxDimension:(float)max {
    
    float width = image.size.width;
    float height = image.size.height;
    float largestSide = MAX(width, height);
    float factor = largestSide / max;
    width = width/factor;
    height = height/factor;
    
    CGSize newSize = CGSizeMake(width, height);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}
-(UIImage*)unrotateImage:(UIImage*)image {
    
    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width ,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)rotateImage:(UIImage *)image byDegree:(float)degrees {

    UIView * tempBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    tempBox.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    
    NSLog(@"temp box is %@", tempBox);
    
    CGSize rotatedSize = tempBox.frame.size;
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
@end
