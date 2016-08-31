//
//  registerVC.h
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface registerVC : UIViewController <UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate>
-(void)beginWithUser:(User *)user;
@end
