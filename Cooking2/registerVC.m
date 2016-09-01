//
//  registerVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "registerVC.h"
#import "Peacock.h"
#import "Donkey.h"
#import "Dog.h"
#import "cameraVC.h"

@interface registerVC () {
    
    Peacock * _peacock;
    Donkey * _donkey;
    Dog * _dog;
    
    cameraVC * _cameraVC;
    
    float w;
    float h;
    
    float keyboardY;
    UIView * activeField;
    
    bool isNewUser;
    bool userCanSave;
    bool shouldLoginOnPop;
    
    NSMutableDictionary * profile;
    User * incomingUser;
    
    UIColor * placeholderWhite;
    UIColor * divColour;

    
    UIScrollView * mainScroller;
    UIView * contentView;
    UIView * uploadView;
    
    UIImageView * profileIV;
    UISegmentedControl * seg;
    UITextField * nameTF;
    UITextField * emailTF;
    UITextField * passwordTF;
    UIPickerView * picker;
    UITextView * bioTV;
    UILabel * bioPlaceholder;
    UISwitch * contactSwitch;
    UIButton * saveButton;
    
    
    UIImage * profileOriginal;
    UIImage * profileThumb;
}

@end

@implementation registerVC

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
}
-(void)setup{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated) name:@"kUserUpdateSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileFailedToUpdate) name:@"kUserUpdateFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popCameraVC:) name:@"kPopCameraVC" object:nil];
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    _dog = [Dog sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    
    placeholderWhite = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
    divColour = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
}
-(void)layout{
    
    self.view.backgroundColor = _peacock.appColour;

    mainScroller = [UIScrollView new];
    mainScroller.frame = self.view.bounds;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.delegate = self;
    mainScroller.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:mainScroller];
    
    contentView = [UIView new];
    [mainScroller addSubview:contentView];
    
    float yOff = 80;
    
    UIImageView * profileIVBG = [UIImageView new];
    profileIVBG.frame = CGRectMake((w-160)/2, yOff, 160, 160);
    profileIVBG.layer.cornerRadius = 80.0f;
    profileIVBG.clipsToBounds = true;
    profileIVBG.layer.borderColor = [UIColor whiteColor].CGColor;
    profileIVBG.layer.borderWidth = 1.0f;
    profileIVBG.userInteractionEnabled = true;
    [contentView addSubview:profileIVBG];
    
    profileIV = [UIImageView new];
    profileIV.frame = CGRectMake(-10, -10, 180, 180);
    profileIV.image = [[UIImage imageNamed:@"chef-512.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    profileIV.tintColor = [UIColor whiteColor];
    profileIV.contentMode = UIViewContentModeScaleAspectFit;
    [profileIVBG addSubview:profileIV];
    
    UIButton * cameraButton = [UIButton new];
    cameraButton.frame = profileIVBG.bounds;
    [cameraButton addTarget:self action:@selector(selectProfileImage) forControlEvents:UIControlEventTouchUpInside];
    [profileIVBG addSubview:cameraButton];
    
    yOff += 160.0f;
    yOff += 20;
    
    seg = [[UISegmentedControl alloc] initWithItems:@[@"Noob",@"Hausfrau",@"Profi"]];
    seg.frame = CGRectMake((w-260)/2, yOff, 260, 30);
    seg.tintColor = [UIColor whiteColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular] forKey:NSFontAttributeName];
    [seg setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [contentView addSubview:seg];
    yOff += 40;
    
    
    //NAME
    nameTF = [UITextField new];
    nameTF.frame = CGRectMake(10, yOff, w-20, 60);
    nameTF.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
    nameTF.textColor = [UIColor whiteColor];
    nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Hans Mustermann*" attributes:@{NSForegroundColorAttributeName:placeholderWhite}];
    nameTF.tintColor = [UIColor whiteColor];
    nameTF.autocorrectionType = UITextAutocorrectionTypeNo;
    nameTF.returnKeyType = UIReturnKeyNext;
    nameTF.delegate = self;
    [contentView addSubview:nameTF];
    yOff += 60;
    
    UIImageView * nameDiv = [UIImageView new];
    nameDiv.frame = CGRectMake(10, yOff, w-10, 0.5f);
    nameDiv.backgroundColor = divColour;
    [contentView addSubview:nameDiv];
    
    
    //EMAIL
    emailTF = [UITextField new];
    emailTF.frame = CGRectMake(10, yOff, w-20, 60);
    emailTF.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
    emailTF.textColor = [UIColor whiteColor];
    emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Hans@Mustermann.ch*" attributes:@{NSForegroundColorAttributeName:placeholderWhite}];
    emailTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailTF.tintColor = [UIColor whiteColor];
    emailTF.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTF.returnKeyType = UIReturnKeyNext;
    emailTF.delegate = self;
    [contentView addSubview:emailTF];
    yOff += 60;
    
    UIImageView * emailDiv = [UIImageView new];
    emailDiv.frame = CGRectMake(10, yOff, w-10, 0.5f);
    emailDiv.backgroundColor = divColour;
    [contentView addSubview:emailDiv];
    
    
    //PASSWORD
    passwordTF = [UITextField new];
    passwordTF.frame = CGRectMake(10, yOff, w-20, 60);
    passwordTF.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
    passwordTF.textColor = [UIColor whiteColor];
    passwordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Passwort*" attributes:@{NSForegroundColorAttributeName:placeholderWhite}];
    passwordTF.secureTextEntry = true;
    passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTF.tintColor = [UIColor whiteColor];
    passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTF.returnKeyType = UIReturnKeyNext;
    passwordTF.delegate = self;
    [contentView addSubview:passwordTF];
    yOff += 60;
    
    UIImageView * passwordDiv = [UIImageView new];
    passwordDiv.frame = CGRectMake(10, yOff, w-10, 0.5f);
    passwordDiv.backgroundColor = divColour;
    [contentView addSubview:passwordDiv];
    
    
    //CANTONS
    picker = [UIPickerView new];
    picker.frame = CGRectMake(10, yOff, w-20, 60);
    picker.delegate = self;
    [contentView addSubview:picker];
    yOff += 60;

    UIImageView * pickerDiv = [UIImageView new];
    pickerDiv.frame = CGRectMake(10, yOff, w-10, 0.5f);
    pickerDiv.backgroundColor = divColour;
    [contentView addSubview:pickerDiv];
    yOff += 10;
    
    //BIO
    bioTV = [UITextView new];
    bioTV.frame = CGRectMake(10, yOff, w-20, 140);
    bioTV.backgroundColor = [UIColor clearColor];
    bioTV.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
    bioTV.textColor = [UIColor whiteColor];
    bioTV.textContainer.lineFragmentPadding = 0;
    bioTV.textContainerInset = UIEdgeInsetsZero;
    bioTV.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    bioTV.autocorrectionType = UITextAutocorrectionTypeNo;
    bioTV.tintColor = [UIColor whiteColor];
    [bioTV setDelegate:self];
    [contentView addSubview:bioTV];
    
    bioPlaceholder = [UILabel new];
    bioPlaceholder.frame = CGRectMake(10, yOff, w-10, 0);
    bioPlaceholder.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
    bioPlaceholder.textColor = placeholderWhite;
    bioPlaceholder.text = @"Stellen Sie sich vor, e.g. was Sie gerne kochen oder was Sie lernen wollen.";
    bioPlaceholder.numberOfLines = 0;
    [bioPlaceholder sizeToFit];
    [contentView addSubview:bioPlaceholder];
    yOff += 140;
    
    UIImageView * bioDiv = [UIImageView new];
    bioDiv.frame = CGRectMake(10, yOff, w-10, 0.5f);
    bioDiv.backgroundColor = divColour;
    [contentView addSubview:bioDiv];
    

    //ALLOWS CONTACT
    UILabel * contactLabel = [UILabel new];
    contactLabel.frame = CGRectMake(10, yOff, w-80, 60);
    contactLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
    contactLabel.textColor = [UIColor whiteColor];
    contactLabel.text = @"Ich erlaube andere User kontakt mit mir aufzunehmen.";
    contactLabel.numberOfLines = 2;
    [contentView addSubview:contactLabel];
    
    contactSwitch = [UISwitch new];
    contactSwitch.frame = CGRectMake(w-61, yOff+15, 51, 31);
    contactSwitch.tintColor = [UIColor whiteColor];
    contactSwitch.onTintColor = [UIColor whiteColor];
    [contentView addSubview:contactSwitch];
    yOff += 60;
    
    UIImageView * contactDiv = [UIImageView new];
    contactDiv.frame = CGRectMake(10, yOff, w-10, 0.5f);
    contactDiv.backgroundColor = divColour;
    [contentView addSubview:contactDiv];
    
    //SAVE
    yOff += 40;
    saveButton = [UIButton new];
    saveButton.frame = CGRectMake((w-200)/2, yOff, 200, 40);
    [saveButton setTitle:@"Beitreten" forState:UIControlStateNormal];
    [saveButton setBackgroundColor:[UIColor whiteColor]];
    [saveButton setTitleColor:_peacock.appColour forState:UIControlStateNormal];
    [saveButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular]];
    [saveButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [saveButton.layer setBorderWidth:1.0f];
    [saveButton.layer setCornerRadius:20.0f];
    [saveButton addTarget:self action:@selector(updateProfile) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:saveButton];

    yOff += 40;
    yOff += 40;
    
    contentView.frame = CGRectMake(0, 0, w, yOff);
    mainScroller.contentSize = CGSizeMake(w, yOff);
    
    UIButton * closeButton = [UIButton new];
    closeButton.frame = CGRectMake(w-60, 15, 60, 60);
    [closeButton setImage:[[UIImage imageNamed:@"close-120.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [closeButton setTintColor:[UIColor whiteColor]];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [closeButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}
-(void)beginWithUser:(User *)user{
    
    if (user){
        
        //set the local var
        incomingUser = user;
        
        //update values
        nameTF.text = user.name;
        emailTF.text = user.email;
        [picker selectRow:[_donkey.cantons indexOfObject:user.location] inComponent:0 animated:false];
        bioTV.text = user.bio;
        [contactSwitch setOn:user.exposesContact.boolValue];
        
    } else {
        
        //it's a new registration
        isNewUser = true;
        seg.selectedSegmentIndex = 0;
        
    }

}

//PROFILE IMAGE
-(void)selectProfileImage {
    
    UIAlertController * action = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    action.view.tintColor = _peacock.appColour;
    [action addAction:[UIAlertAction actionWithTitle:@"Kamera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self pushCameraVC]; }]];
    [action addAction:[UIAlertAction actionWithTitle:@"Fotoalbum" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }]];
    [action addAction:[UIAlertAction actionWithTitle:@"Abbrechen" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }]];
    [self presentViewController:action animated:true completion:^{
        action.view.tintColor = _peacock.appColour;
    }];
    
}
-(void)pushCameraVC {
    
    _cameraVC = [cameraVC new];
    [self addChildViewController:_cameraVC];
    [self.view addSubview:_cameraVC.view];
    [_cameraVC beginWithType:3];

    _cameraVC.view.transform = CGAffineTransformMakeTranslation(0,h);
    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _cameraVC.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
-(void)popCameraVC:(NSNotification *)n {
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _cameraVC.view.transform = CGAffineTransformMakeTranslation(0,h);
                     }
                     completion:^(BOOL finished){
                         [_cameraVC removeFromParentViewController];
                         [_cameraVC.view removeFromSuperview];
                         _cameraVC = nil;
                     }];
    
    if (n.object){
        int type = [n.object intValue];
        if (type == 3){
            profileOriginal = (UIImage *)n.userInfo[@"original"];
            profileThumb = (UIImage *)n.userInfo[@"thumb"];
            profileIV.contentMode = UIViewContentModeScaleAspectFill;
            profileIV.image = profileThumb;
        }
        
    }
}

//TF
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
    if (keyboardY>0){
        [self updateForKeyboard];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)tf {
    activeField = nil;
    [tf resignFirstResponder];
}
-(void)textFieldDidChange:(UITextField *)tf {
}
-(BOOL)textFieldShouldReturn:(UITextField *)tf {
    
    if (tf == nameTF) {
        [emailTF becomeFirstResponder];
        return false;
    } else if (tf == emailTF){
        [passwordTF becomeFirstResponder];
        return false;
    } else if (tf == passwordTF){
        [bioTV becomeFirstResponder];
        return false;
    }
    return true;
}

//TV
-(BOOL)textViewShouldBeginEditing:(UITextView *)tv {
    return true;
}
-(void)textViewDidBeginEditing:(UITextView *)tv {
    activeField = tv;
    if (keyboardY>0){
        [self updateForKeyboard];
    }
}
-(void)textViewDidEndEditing:(UITextView *)tv {
    activeField = nil;
}
-(void)textViewDidChange:(UITextView *)tv {
    
    if (tv.text.length == 0){
        bioPlaceholder.alpha = 1.0f;
    } else {
        bioPlaceholder.alpha = 0.f;
    }
}

//KEYBOARD METHODS
-(void)willShow:(NSNotification *)n {
    keyboardY = [[n.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [self updateForKeyboard];
}
-(void)willHide:(NSNotification *)n {
    keyboardY = 0;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //textScroller.contentOffset = CGPointMake(0, 0);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
-(void)updateForKeyboard {
    
    float actualY = [activeField.superview convertRect:activeField.frame toView:mainScroller].origin.y;
    actualY = actualY + activeField.frame.size.height;
    if (actualY > keyboardY){
        float dif = keyboardY - actualY;
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             mainScroller.contentOffset = CGPointMake(0, -dif);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [nameTF resignFirstResponder];
    [emailTF resignFirstResponder];
    [passwordTF resignFirstResponder];
    [bioTV resignFirstResponder];
    
}

//LOCATION PICKER
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 24;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel * label = (UILabel *)view;
    
    if (!label){
        label = [UILabel new];
        label.frame = CGRectMake(10, 0, w-20, 60);
        label.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
    }
    
    label.text = _donkey.cantons[row];
    return label;
}

//DATA
-(void)checkFields {
    
    userCanSave = true;
    
}
-(void)updateProfile {
    
    //check if the user can save
    userCanSave = true;
    if (!userCanSave){
        
        //remind user of missing fields
    
        return;
    }
    
    //Update the ui
    [self showUploadView];
    
    if (isNewUser){
        
        //Temp
        profileThumb = [UIImage imageNamed:@"openBG.jpeg"];
        profileOriginal = [UIImage imageNamed:@"openBG.jpeg"];
        
        //Create profile dictionary
        profile = [NSMutableDictionary new];
        profile[@"timestamp"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        profile[@"userID"] = [NSString stringWithFormat:@"USER_%@", [_peacock uniqueID]];
        profile[@"name"] = nameTF.text;
        profile[@"email"] = emailTF.text;
        profile[@"password"] = passwordTF.text;
        profile[@"location"] = [_donkey.cantons objectAtIndex:[picker selectedRowInComponent:0]];
        profile[@"bio"] = bioTV.text;
        profile[@"skill"] = [_donkey.skillLevels objectAtIndex:seg.selectedSegmentIndex];
        profile[@"exposesContact"] = @"false"; if (contactSwitch.isOn){ profile[@"exposesContact"] = @"true";}
        profile[@"newUser"] = @"true";
        profile[@"thumb"] = profileThumb;
        profile[@"original"] = profileOriginal;
        [_dog updateUser:profile];
        
       
    } else {
        
        //only update the changed values
        
        
    }
    
    
}
-(void)profileUpdated {
    
    NSLog(@"profile updated");
    
    //if it's a new user add it to the user array
    if (isNewUser){
        
        incomingUser = [User new];
        incomingUser.userID = profile[@"userID"];
        incomingUser.email = profile[@"eamil"];
        incomingUser.name = profile[@"name"];
        incomingUser.location = profile[@"location"];
        incomingUser.bio = profile[@"bio"];
        incomingUser.skillLevel = @"amateur";
        incomingUser.exposesContact = profile[@"exposesContact"];
        incomingUser.followingArray = @[];
        incomingUser.favouriteArray = @[];
        incomingUser.recipeArray = @[];
   
        //add to the array
        
    } else { //if it's an existing user update the user array
        
        incomingUser.userID = profile[@"userID"];
        incomingUser.email = profile[@"eamil"];
        incomingUser.name = profile[@"name"];
        incomingUser.location = profile[@"location"];
        incomingUser.bio = profile[@"bio"];
        incomingUser.skillLevel = @"amateur";
        incomingUser.exposesContact = profile[@"exposesContact"];

        //update the array
    }
    
    
    //set the current user
    //_donkey.currentUser = incomingUser;
    //[_donkey saveCurrentUser];
    
    
    //pop self
    shouldLoginOnPop = true;
    [self popSelf];
    
}
-(void)profileFailedToUpdate {
    
    UIAlertController * action = [UIAlertController alertControllerWithTitle:@"Error" message:@"Ihr Profil konnte nicht aktualisiert werden. Überprüfen Sie Ihr Netzwerkanschluss oder probieren Sie es nachher wieder." preferredStyle:UIAlertControllerStyleAlert];
    action.view.tintColor = _peacock.appColour;
    [action addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self hideUploadView]; }]];
    [self presentViewController:action animated:true completion:^{
        action.view.tintColor = _peacock.appColour;
    }];
    
}

//UPLOAD VIEW
-(void)showUploadView {
    
    uploadView = [UIView new];
    uploadView.frame = self.view.bounds;
    [self.view addSubview:uploadView];
    
    UIVisualEffectView * vs = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    vs.frame = uploadView.bounds;
    [uploadView addSubview:vs];
    
    UIActivityIndicatorView * indy = [UIActivityIndicatorView new];
    indy.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indy.center = uploadView.center;
    [uploadView addSubview:indy];
    [indy startAnimating];

    uploadView.alpha = 0.0f;
    [UIView animateWithDuration:0.6f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         uploadView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                     }];
}
-(void)hideUploadView {
    
    [UIView animateWithDuration:0.6f
                          delay:0.5f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         uploadView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [uploadView removeFromSuperview];
                     }];
    
}


//OTHER
-(void)popSelf {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopRegisterVC" object:nil userInfo:@{@"shouldLogin":[NSString stringWithFormat:@"%i",shouldLoginOnPop]}];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
