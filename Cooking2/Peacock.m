//
//  Peacock.m
//  Surveyor
//
//  Created by Steinbock Applications on 10/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "Peacock.h"

@implementation Peacock {
    
    NSDateFormatter * df;
    NSDateFormatter * dfHour;
}
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
        
        korelessPurple = [self colourForHex:@"#AE49AB"];
        korelessPink = [self colourForHex:@"#A41838"];
        
        df = [NSDateFormatter new];
        [df setDateFormat:@"dd.MM.yyyy"];
        
        dfHour = [NSDateFormatter new];
        [dfHour setDateFormat:@"HH:mm"];
        
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
-(UIView *)starViewWithScore:(float)score ofColour:(UIColor *)colour forHeight:(float)height atPoint:(CGPoint)point {
    
    UIView * view = [UIView new];
    
    UIView * holder = [UIView new];
    holder.clipsToBounds = true;
    [view addSubview:holder];
    
    float localX = 0;
    for (int n = 0; n < 5; n++){
        UIImageView * starIV = [UIImageView new];
        starIV.frame = CGRectMake(localX, 0, height, height);
        starIV.contentMode = UIViewContentModeScaleAspectFit;
        starIV.image = [[UIImage imageNamed:@"star_full-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        starIV.tintColor = colour;
        [holder addSubview:starIV];
        localX += height+5;
    }
    
    float width = score * height + (int)score * 5;
    holder.frame = CGRectMake(0, 0, width, height);
    
    UILabel * scoreLabel = [UILabel new];
    scoreLabel.frame = CGRectMake(width+5, 0, 45, height);
    scoreLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightThin];
    scoreLabel.textColor = [colour colorWithAlphaComponent:0.8f];
    scoreLabel.text = [NSString stringWithFormat:@"(%.1f)", score];
    [view addSubview:scoreLabel];
    
    view.frame = CGRectMake(point.x, point.y, width + 50, height);
    
    return view;
}

-(UIView *)starViewWithScore:(float)score
                     ofColour:(UIColor *)sColour
                       votes:(int)votes
                     ofColour:(UIColor *)vColour
                   forHeight:(float)height
                     atPoint:(CGPoint)point {
    
    UIView * view = [UIView new];
    
    UIView * holder = [UIView new];
    holder.clipsToBounds = true;
    [view addSubview:holder];
    
    float localX = 0;
    for (int n = 0; n < 5; n++){
        UIImageView * starIV = [UIImageView new];
        starIV.frame = CGRectMake(localX, 0, height, height);
        starIV.contentMode = UIViewContentModeScaleAspectFit;
        starIV.image = [[UIImage imageNamed:@"star_full-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        starIV.tintColor = sColour;
        [holder addSubview:starIV];
        localX += height+5;
    }
    
    float width = score * height + (int)score * 5;
    holder.frame = CGRectMake(0, 0, width, height);
    
    UILabel * voteLabel = [UILabel new];
    voteLabel.frame = CGRectMake(width+5, 0, 45, height);
    voteLabel.font = [UIFont systemFontOfSize:height weight:UIFontWeightThin];
    voteLabel.textColor = vColour;
    voteLabel.text = [NSString stringWithFormat:@"(%i)", votes];
    [view addSubview:voteLabel];
    
    view.frame = CGRectMake(point.x, point.y, width + 50, height);
    
    return view;
}

-(UIImageView *)breakerDotOfColour:(UIColor *)colour atPoint:(CGPoint)point {
    
    UIImageView * dot = [UIImageView new];
    dot.frame = CGRectMake(point.x, point.y, 10, 10);
    dot.layer.cornerRadius = 5;
    dot.backgroundColor = colour;
    return dot;
}

-(NSString *)initialsForName:(NSString *)name {
    
    //pull initials--> set label text
    NSString * first = [name substringToIndex:1];
    NSString * second = @"";
    NSArray * split = [name componentsSeparatedByString:@" "];
    if (split.count > 1){
        second = [split[split.count-1] substringToIndex:1];
    }
 return [NSString stringWithFormat:@"%@%@", first, second];
}



-(NSString *)dateForTimestamp:(NSString *)ts {
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:ts.intValue];
    if ([[NSCalendar currentCalendar] isDateInToday:date]){
        return [NSString stringWithFormat:@"Heute %@", [dfHour stringFromDate:date]];
    } else if ([[NSCalendar currentCalendar] isDateInYesterday:date]){
        return [NSString stringWithFormat:@"Gestern %@", [dfHour stringFromDate:date]];
    }
    
    return [df stringFromDate:date];
    
    
}
-(void)updateStatusBarIsDark:(bool)isDark isHidden:(bool)isHidden {

    NSDictionary * d = @{@"isDark":[NSNumber numberWithBool:isDark],@"isHidden":[NSNumber numberWithBool:isHidden]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusBarUpdate" object:d];
}


@end
