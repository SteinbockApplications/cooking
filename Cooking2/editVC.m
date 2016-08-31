//
//  editVC.m
//  Cooking2
//
//  Created by Duncan Geoghegan on 29/08/16.
//  Copyright © 2016 Steinbock Applications. All rights reserved.
//

#import "editVC.h"
#import "Peacock.h"
#import "Donkey.h"
#import "Recipe.h"
#import "Dog.h"
#import "cameraVC.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@interface editVC () {
    
    Peacock * _peacock;
    Donkey * _donkey;
    Dog * _dog;
    
    cameraVC * _cameraVC;
    
    float w;
    float h;
    
    //
    float keyboardY;
    UIView * activeField;
    UIColor * placeholderWhite;
    UIColor * divColour;
    bool nextButtonIsFinish;
    bool userCanPublish;
    int page;
    
    UIScrollView * mainScroller;
    UIScrollView * textScroller;
    UIScrollView * mediaScroller;
    UIView * publishView;
    
    UIPageControl * pager;
    UIView * nextButtonView;
    UILabel * nextButtonLabel;
    UIImageView * nextButtonIV;
    UIButton * nextButton;
    
    UITextField * titleTF;
    UITextField * hourTF;
    UITextField * minTF;
    UIPickerView * skillPicker;
    UIPickerView * coursePicker;
    UITextView * descriptionTV;
    UITextView * ingredientsTV;
    UITextView * instructionsTV;
    UILabel * selectedPlaceholder;
    
    NSMutableDictionary * mediaDictionary;
    UIImageView * heroIV;
    UIButton * heroDeleteButton;
    UIImageView * videoIV;
    UIButton * videoDeleteButton;
    UIImageView * selectedAdditionalView;
    
}

@end

@implementation editVC

//SETUP
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self layout];
    [self begin];
}
-(void)setup{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popCameraVC:) name:@"kPopCameraVC" object:nil];
    
    _peacock = [Peacock sharedInstance];
    _donkey = [Donkey sharedInstance];
    _dog = [Dog sharedInstance];
    
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    
    divColour = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    placeholderWhite = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
    page = 0;
    
}
-(void)layout{
    
    self.view.backgroundColor = _peacock.appColour;
    
    mainScroller = [UIScrollView new];
    mainScroller.frame = self.view.bounds;
    mainScroller.showsVerticalScrollIndicator = false;
    mainScroller.showsHorizontalScrollIndicator = false;
    mainScroller.delegate = self;
    mainScroller.pagingEnabled = true;
    mainScroller.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    mainScroller.contentSize = CGSizeMake(w*3, h);
    [self.view addSubview:mainScroller];
    
    //TEXT INPUTS
    textScroller = [UIScrollView new];
    textScroller.frame = CGRectMake(0, 70, w, h-70);
    textScroller.showsVerticalScrollIndicator = false;
    textScroller.showsHorizontalScrollIndicator = false;
    textScroller.delegate = self;
    textScroller.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [mainScroller addSubview:textScroller];
    
    float yOff = 0;
    yOff += [self layoutTitleViewAtOffset:yOff];
    yOff += [self layoutDurationViewAtOffset:yOff];
    yOff += [self layoutSkillViewAtOffset:yOff];
    yOff += [self layoutCourseViewAtOffset:yOff];
    yOff += [self layoutDescriptionViewAtOffset:yOff];
    yOff += [self layoutIngredientsViewAtOffset:yOff];
    yOff += [self layoutInstructionsViewAtOffset:yOff];
    yOff += 80;
    textScroller.contentSize = CGSizeMake(w, yOff);
    
    //MEDIA INPUTS
    mediaScroller = [UIScrollView new];
    mediaScroller.frame = CGRectMake(w, 70, w, h-70);
    mediaScroller.showsVerticalScrollIndicator = false;
    mediaScroller.showsHorizontalScrollIndicator = false;
    mediaScroller.delegate = self;
    mediaScroller.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [mainScroller addSubview:mediaScroller];
    
    yOff = 0;
    yOff += [self layoutHeroIVAtOffset:yOff];
    yOff += [self layoutVideoIVAtOffset:yOff];
    yOff += [self layoutAdditionalMediaAtOffset:yOff];
    yOff += 80;
    mediaScroller.contentSize = CGSizeMake(w, yOff);
    
  
    //PUBLISH VIEW
    publishView = [UIView new];
    publishView.frame = CGRectMake(2*w, 70, w, h-70);
    [mainScroller addSubview:publishView];
    
    
    
    //OTHER VIEWS
    pager = [UIPageControl new];
    pager.frame = CGRectMake(20, 35, 45, 20);
    pager.numberOfPages = 3;
    pager.tintColor = [UIColor whiteColor];
    [self.view addSubview:pager];
    
    UIButton * closeButton = [UIButton new];
    closeButton.frame = CGRectMake(w-60, 15, 60, 60);
    [closeButton setImage:[[UIImage imageNamed:@"add-120.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [closeButton setTintColor:[UIColor whiteColor]];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [closeButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45))];
    [self.view addSubview:closeButton];
    
    
    //NEXT BUTTON
    nextButtonView = [UIView new];
    nextButtonView.frame = CGRectMake(w-80, h-80, 60, 60);
    nextButtonView.backgroundColor = [UIColor whiteColor];
    nextButtonView.layer.cornerRadius = 30.0f;
    [self.view addSubview:nextButtonView];

    nextButtonIV = [UIImageView new];
    nextButtonIV.frame = CGRectMake(15, 15, 30, 30);
    nextButtonIV.image = [[UIImage imageNamed:@"arrow_right-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    nextButtonIV.tintColor = _peacock.appColour;
    [nextButtonView addSubview:nextButtonIV];

    nextButtonLabel = [UILabel new];
    nextButtonLabel.frame = CGRectMake(0, 0, 200, 40);
    nextButtonLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightRegular];
    nextButtonLabel.textColor = _peacock.appColour;
    nextButtonLabel.textAlignment = NSTextAlignmentCenter;
    nextButtonLabel.text = @"Publizieren";
    [nextButtonLabel setAlpha:0.0f];
    [nextButtonView addSubview:nextButtonLabel];

    nextButton = [UIButton new];
    nextButton.frame = nextButtonView.bounds;
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [nextButtonView addSubview:nextButton];

}
-(void)begin{
    
}

//TEXT SCROLLER
-(float)layoutTitleViewAtOffset:(float)yOff {
    
    UIView * titleView = [UIView new];
    titleView.frame = CGRectMake(0, yOff, w, 70);
    [textScroller addSubview:titleView];
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Rezept Titel*";
    [titleView addSubview:label];
    
    titleTF = [UITextField new];
    titleTF.frame = CGRectMake(20, 15, w-40, 40);
    titleTF.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
    titleTF.textColor = [UIColor whiteColor];
    titleTF.tintColor = [UIColor whiteColor];
    titleTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Sauce Bernaise" attributes:@{NSForegroundColorAttributeName:placeholderWhite}];
    titleTF.returnKeyType = UIReturnKeyNext;
    titleTF.autocorrectionType = UITextAutocorrectionTypeNo;
    [titleTF setDelegate:self];
    [titleTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [titleView addSubview:titleTF];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 60, w-40, 1.0f);
    div.backgroundColor = divColour;
    [titleView addSubview:div];
    
    return 70;
}
-(float)layoutDurationViewAtOffset:(float)yOff {
    
    UIView * durationView = [UIView new];
    durationView.frame = CGRectMake(0, yOff, w, 70);
    [textScroller addSubview:durationView];
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Vorbereitungszeit*";
    [durationView addSubview:label];
    
    float tfW = 40;
    
    hourTF = [UITextField new];
    hourTF.frame = CGRectMake(20, 15, tfW, 40);
    hourTF.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
    hourTF.textColor = [UIColor whiteColor];
    hourTF.tintColor = [UIColor whiteColor];
    hourTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0" attributes:@{NSForegroundColorAttributeName:placeholderWhite}];
    hourTF.textAlignment = NSTextAlignmentLeft;
    hourTF.keyboardType = UIKeyboardTypeNumberPad;
    [hourTF setDelegate:self];
    [hourTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [durationView addSubview:hourTF];
    
    UILabel * labelA = [UILabel new];
    labelA.frame = CGRectMake(20+tfW, 15, 50, 40);
    labelA.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    labelA.textColor = [UIColor whiteColor];
    labelA.text = @"STD.";
    labelA.textAlignment = NSTextAlignmentCenter;
    [durationView addSubview:labelA];
    
    minTF = [UITextField new];
    minTF.frame = CGRectMake(100+tfW, 15, tfW, 40);
    minTF.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
    minTF.textColor = [UIColor whiteColor];
    minTF.tintColor = [UIColor whiteColor];
    minTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"30" attributes:@{NSForegroundColorAttributeName:placeholderWhite}];
    minTF.textAlignment = NSTextAlignmentLeft;
    minTF.keyboardType = UIKeyboardTypeNumberPad;
    [minTF setDelegate:self];
    [minTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [durationView addSubview:minTF];
    
    UILabel * labelB = [UILabel new];
    labelB.frame = CGRectMake(100+tfW+tfW, 15, 50, 40);
    labelB.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    labelB.textColor = [UIColor whiteColor];
    labelB.text = @"MIN.";
    labelB.textAlignment = NSTextAlignmentCenter;
    [durationView addSubview:labelB];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 60, w-40, 1.0f);
    div.backgroundColor = divColour;
    [durationView addSubview:div];

    return 70;
}
-(float)layoutSkillViewAtOffset:(float)yOff {
    
    UIView * skillView = [UIView new];
    skillView.frame = CGRectMake(0, yOff, w, 90);
    [textScroller addSubview:skillView];
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Schwierigkeitsgrad";
    [skillView addSubview:label];
    
    skillPicker = [UIPickerView new];
    skillPicker.frame = CGRectMake(10, 15, w-20, 60);
    skillPicker.delegate = self;
    [skillView addSubview:skillPicker];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 80, w-40, 1.0f);
    div.backgroundColor = divColour;
    [skillView addSubview:div];
    
    return 90;
}
-(float)layoutCourseViewAtOffset:(float)yOff {
    
    UIView * courseView = [UIView new];
    courseView.frame = CGRectMake(0, yOff, w, 90);
    [textScroller addSubview:courseView];
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Kurs";
    [courseView addSubview:label];
    
    coursePicker = [UIPickerView new];
    coursePicker.frame = CGRectMake(10, 15, w-20, 60);
    coursePicker.delegate = self;
    [courseView addSubview:coursePicker];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 80, w-40, 1.0f);
    div.backgroundColor = divColour;
    [courseView addSubview:div];
    
    return 90;
}
-(float)layoutDescriptionViewAtOffset:(float)yOff {
    
    UIView * descriptionView = [UIView new];
    descriptionView.frame = CGRectMake(0, yOff, w, 210);
    [textScroller addSubview:descriptionView];
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Beschreibung*";
    [descriptionView addSubview:label];
    
    descriptionTV = [UITextView new];
    descriptionTV.frame = CGRectMake(20, 15, w-40, 175);
    descriptionTV.backgroundColor = [UIColor clearColor];
    descriptionTV.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
    descriptionTV.textColor = [UIColor whiteColor];
    descriptionTV.tintColor = [UIColor whiteColor];
    descriptionTV.textContainer.lineFragmentPadding = 0;
    descriptionTV.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    descriptionTV.autocorrectionType = UITextAutocorrectionTypeNo;
    [descriptionTV setDelegate:self];
    [descriptionView addSubview:descriptionTV];
    
    UILabel * placeholderLabel = [UILabel new];
    placeholderLabel.frame = CGRectMake(20, 23, w-40, 0);
    placeholderLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];;
    placeholderLabel.textColor = placeholderWhite;
    placeholderLabel.text = @"e.g. eine warme Buttersauce der klassischen französischen Küche...";
    placeholderLabel.numberOfLines = 0;
    [placeholderLabel sizeToFit];
    [descriptionView addSubview:placeholderLabel];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 195, w-40, 1.0f);
    div.backgroundColor = divColour;
    [descriptionView addSubview:div];
 
    return 210;
}
-(float)layoutIngredientsViewAtOffset:(float)yOff {
    
    UIView * ingredientsView= [UIView new];
    ingredientsView.frame = CGRectMake(0, yOff, w, 210);
    [textScroller addSubview:ingredientsView];
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Zutaten*";
    [ingredientsView addSubview:label];
    
    ingredientsTV = [UITextView new];
    ingredientsTV.frame = CGRectMake(20, 15, w-40, 175);
    ingredientsTV.backgroundColor = [UIColor clearColor];
    ingredientsTV.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
    ingredientsTV.textColor = [UIColor whiteColor];
    ingredientsTV.tintColor = [UIColor whiteColor];
    ingredientsTV.textContainer.lineFragmentPadding = 0;
    ingredientsTV.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    ingredientsTV.autocorrectionType = UITextAutocorrectionTypeNo;
    [ingredientsTV setDelegate:self];
    [ingredientsView addSubview:ingredientsTV];
    
    UILabel * placeholderLabel = [UILabel new];
    placeholderLabel.frame = CGRectMake(20, 23, w-40, 0);
    placeholderLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];;
    placeholderLabel.textColor = placeholderWhite;
    placeholderLabel.text = @"2 Eier\n150gr Butter\n...";
    placeholderLabel.numberOfLines = 0;
    [placeholderLabel sizeToFit];
    [ingredientsView addSubview:placeholderLabel];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 195, w-40, 1.0f);
    div.backgroundColor = divColour;
    [ingredientsView addSubview:div];
    
    return 210;
}
-(float)layoutInstructionsViewAtOffset:(float)yOff {
    
    UIView * instructionsView = [UIView new];
    instructionsView.frame = CGRectMake(0, yOff, w, 210);
    [textScroller addSubview:instructionsView];
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 0, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Zubereitung*";
    [instructionsView addSubview:label];
    
    instructionsTV = [UITextView new];
    instructionsTV.frame = CGRectMake(20, 15, w-40, 175);
    instructionsTV.backgroundColor = [UIColor clearColor];
    instructionsTV.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
    instructionsTV.textColor = [UIColor whiteColor];
    instructionsTV.tintColor = [UIColor whiteColor];
    instructionsTV.textContainer.lineFragmentPadding = 0;
    instructionsTV.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    instructionsTV.autocorrectionType = UITextAutocorrectionTypeNo;
    [instructionsTV setDelegate:self];
    [instructionsView addSubview:instructionsTV];
    
    UILabel * placeholderLabel = [UILabel new];
    placeholderLabel.frame = CGRectMake(20, 23, w-40, 0);
    placeholderLabel.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];;
    placeholderLabel.textColor = placeholderWhite;
    placeholderLabel.text = @"1. Erster Schritt\n2. Zweiter Scrhitt\n...";
    placeholderLabel.numberOfLines = 0;
    [placeholderLabel sizeToFit];
    [instructionsView addSubview:placeholderLabel];
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, 195, w-40, 1.0f);
    div.backgroundColor = divColour;
    [instructionsView addSubview:div];
 
    return 210;
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

    if (tf == titleTF) {
        [hourTF becomeFirstResponder];
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
    
    selectedPlaceholder = tv.superview.subviews[2];
    if (tv.text.length == 0){
        selectedPlaceholder.alpha = 1.0f;
    } else {
        selectedPlaceholder.alpha = 0.f;
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
    
    float actualY = [activeField.superview convertRect:activeField.frame toView:textScroller].origin.y;
    actualY = actualY + activeField.frame.size.height + 30;
    if (actualY > keyboardY){
        float dif = keyboardY - actualY;
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             textScroller.contentOffset = CGPointMake(0, -dif);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}

//PICKER
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:skillPicker]){
        return _donkey.skillLevels.count;
    }
    return _donkey.courses.count;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return w-40;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    //NB. potentially put keybord dismiss in here
    
    UILabel * label = (UILabel *)view;
    if (!label){
        label = [UILabel new];
        label.frame = CGRectMake(0, 0, w-40, 60);
        label.font = [UIFont systemFontOfSize:20.0f weight:UIFontWeightBold];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
    }
    
    if ([pickerView isEqual:skillPicker]){
        label.text = _donkey.skillLevels[row];
        return label;
    }
    
    label.text = _donkey.courses[row];
    return label;
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //dismiss keyboard
    if (titleTF.isFirstResponder || hourTF.isFirstResponder || minTF.isFirstResponder){
        [titleTF resignFirstResponder];
        [hourTF resignFirstResponder];
        [minTF resignFirstResponder];
    }
    
}

//MEDIA SCROLLER
-(float)layoutHeroIVAtOffset:(float)yOff{
    
    UIView * heroView = [UIView new];
    [mediaScroller addSubview:heroView];
    
    float localY = 0;
    
    heroIV = [UIImageView new];
    heroIV.frame = CGRectMake(20, localY, w-40, 140);
    heroIV.contentMode = UIViewContentModeScaleAspectFill;
    heroIV.clipsToBounds = true;
    heroIV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    heroIV.userInteractionEnabled = true;
    [heroView addSubview:heroIV];
    
    UIButton * heroButton = [UIButton new];
    heroButton.frame = heroIV.bounds;
    heroButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    [heroButton addTarget:self action:@selector(selectHero) forControlEvents:UIControlEventTouchUpInside];
    [heroIV addSubview:heroButton];
    
    UIImageView * heroIVAdd = [UIImageView new];
    heroIVAdd.frame = CGRectMake((w-40-30)/2, (140-30)/2, 30, 30);
    heroIVAdd.image = [[UIImage imageNamed:@"camera-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    heroIVAdd.tintColor = [UIColor whiteColor];
    heroIVAdd.contentMode = UIViewContentModeScaleAspectFit;
    heroIVAdd.userInteractionEnabled = false;
    [heroIV addSubview:heroIVAdd];
    
    heroDeleteButton = [UIButton new];
    heroDeleteButton.frame = CGRectMake(w-40-60, 0, 60, 60);
    heroDeleteButton.backgroundColor = [UIColor redColor];
    heroDeleteButton.alpha = 0.0f;
    [heroIV addSubview:heroDeleteButton];
    
    localY += 150;
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, localY, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Hauptbild*";
    [heroView addSubview:label];
    
    localY += 25;
    
    UILabel * helpLabel = [UILabel new];
    helpLabel.frame = CGRectMake(20, localY, w-40, 0);
    helpLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
    helpLabel.textColor = [UIColor whiteColor];
    helpLabel.text = @"Machen Sie ein Foto des fertigen Gerichts. Dieses Bild wird der erste Eindruck von Ihrem Rezept sein.";
    helpLabel.numberOfLines = 0;
    [helpLabel sizeToFit];
    [heroView addSubview:helpLabel];
    
    localY += helpLabel.frame.size.height + 10;
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, localY, w-40, 1.0f);
    div.backgroundColor = divColour;
    [heroView addSubview:div];
    
    localY += 20;
    heroView.frame = CGRectMake(0, yOff, w, localY);
    
    return localY;
}
-(float)layoutVideoIVAtOffset:(float)yOff {
    
    UIView * videoView = [UIView new];
    [mediaScroller addSubview:videoView];
    
    float localY = 0;
    
    videoIV = [UIImageView new];
    videoIV.frame = CGRectMake(20, localY, w-40, 140);
    videoIV.contentMode = UIViewContentModeScaleAspectFill;
    videoIV.clipsToBounds = true;
    videoIV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    videoIV.userInteractionEnabled = true;
    [videoView addSubview:videoIV];
    
    UIButton * videoButton = [UIButton new];
    videoButton.frame = heroIV.bounds;
    videoButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    [videoButton addTarget:self action:@selector(selectVideo) forControlEvents:UIControlEventTouchUpInside];
    [videoIV addSubview:videoButton];
    
    UIImageView * videoIVAdd = [UIImageView new];
    videoIVAdd.frame = CGRectMake((w-40-30)/2, (140-30)/2, 30, 30);
    videoIVAdd.image = [[UIImage imageNamed:@"video-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    videoIVAdd.tintColor = [UIColor whiteColor];
    videoIVAdd.contentMode = UIViewContentModeScaleAspectFit;
    videoIVAdd.userInteractionEnabled = false;
    [videoIV addSubview:videoIVAdd];
    
    videoDeleteButton = [UIButton new];
    videoDeleteButton.frame = CGRectMake(w-40-60, 0, 60, 60);
    videoDeleteButton.backgroundColor = [UIColor redColor];
    videoDeleteButton.alpha = 0.0f;
    [videoIV addSubview:videoDeleteButton];
    
    localY += 150;
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, localY, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Zubereitungsfilm";
    [videoView addSubview:label];
    
    localY += 25;
    
    UILabel * helpLabel = [UILabel new];
    helpLabel.frame = CGRectMake(20, localY, w-40, 0);
    helpLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
    helpLabel.textColor = [UIColor whiteColor];
    helpLabel.text = @"Erklären Sie kurz Ihrem Publikum wie man Ihr Gericht zubereited, inklusiv hilfreiche Tips wie aufplattieren.";
    helpLabel.numberOfLines = 0;
    [helpLabel sizeToFit];
    [videoView addSubview:helpLabel];
    
    localY += helpLabel.frame.size.height + 10;
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, localY, w-40, 1.0f);
    div.backgroundColor = divColour;
    [videoView addSubview:div];
    
    
    localY += 20;
    videoView.frame = CGRectMake(0, yOff, w, localY);
    
    return localY;
}
-(float)layoutAdditionalMediaAtOffset:(float)yOff {
    
    UIView * additionalView = [UIView new];
    [mediaScroller addSubview:additionalView];
    
    float localY = 0;
    float localX = 20;
    float addW = (w-60)/2;
    for (int n = 0; n < 4; n++){
        
        UIImageView * iv = [UIImageView new];
        iv.frame = CGRectMake(localX, localY, addW, 100);
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = true;
        iv.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        iv.userInteractionEnabled = true;
        [iv setTag:n];
        [additionalView addSubview:iv];
        
        UIButton * addButton = [UIButton new];
        addButton.frame = iv.bounds;
        addButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        [addButton addTarget:self action:@selector(selectMedia:) forControlEvents:UIControlEventTouchUpInside];
        [iv addSubview:addButton];
        
        UIImageView * addIV = [UIImageView new];
        addIV.frame = CGRectMake((addW-30)/2, (100-30)/2, 30, 30);
        addIV.image = [[UIImage imageNamed:@"camera-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        addIV.tintColor = [UIColor whiteColor];
        addIV.contentMode = UIViewContentModeScaleAspectFit;
        addIV.userInteractionEnabled = false;
        [iv addSubview:addIV];
        
        UIButton * deleteButton = [UIButton new];
        deleteButton.frame = CGRectMake(addW-60, 0, 60, 60);
        deleteButton.backgroundColor = [UIColor redColor];
        deleteButton.alpha = 0.0f;
        [iv addSubview:deleteButton];
        
        localX += addW+20;
        
        if (n == 1){
            localX = 20;
            localY += 120;
        }
    }
    
    localY += 110;
    
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, localY, w-40, 20);
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.text = @"Weitere Bilder";
    [additionalView addSubview:label];
    
    localY += 25;
    
    UILabel * helpLabel = [UILabel new];
    helpLabel.frame = CGRectMake(20, localY, w-40, 0);
    helpLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
    helpLabel.textColor = [UIColor whiteColor];
    helpLabel.text = @"Verwenden Sie diese Bilder um die Zutaten zu zeigen oder die wichtigen Schritte in der Zubereitung Ihrer Gericht.";
    helpLabel.numberOfLines = 0;
    [helpLabel sizeToFit];
    [additionalView addSubview:helpLabel];
    
    localY += helpLabel.frame.size.height + 10;
    
    UIImageView * div = [UIImageView new];
    div.frame = CGRectMake(20, localY, w-40, 1.0f);
    div.backgroundColor = divColour;
    [additionalView addSubview:div];
    
    localY += 20;
    additionalView.frame = CGRectMake(0, yOff, w, localY);
    
    return localY;
    
}

//MEDIA
-(void)selectHero {
    
    UIAlertController * action = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    action.view.tintColor = _peacock.appColour;
    [action addAction:[UIAlertAction actionWithTitle:@"Kamera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self pushCameraVCForType:0]; }]];
    [action addAction:[UIAlertAction actionWithTitle:@"Fotoalbum" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }]];
    [action addAction:[UIAlertAction actionWithTitle:@"Abbrechen" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }]];
    [self presentViewController:action animated:true completion:^{
        action.view.tintColor = _peacock.appColour;
    }];
    
}
-(void)selectVideo {
    
    UIAlertController * action = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    action.view.tintColor = _peacock.appColour;
    [action addAction:[UIAlertAction actionWithTitle:@"Kamera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self pushCameraVCForType:2]; }]];
    [action addAction:[UIAlertAction actionWithTitle:@"Fotoalbum" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }]];
    [action addAction:[UIAlertAction actionWithTitle:@"Abbrechen" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }]];
    [self presentViewController:action animated:true completion:^{
        action.view.tintColor = _peacock.appColour;
    }];
}
-(void)selectMedia:(UIButton *)button {
    
    selectedAdditionalView = button.superview;
    UIAlertController * action = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    action.view.tintColor = _peacock.appColour;
    [action addAction:[UIAlertAction actionWithTitle:@"Kamera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self pushCameraVCForType:1]; }]];
    [action addAction:[UIAlertAction actionWithTitle:@"Fotoalbum" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }]];
    [action addAction:[UIAlertAction actionWithTitle:@"Abbrechen" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }]];
    [self presentViewController:action animated:true completion:^{
        action.view.tintColor = _peacock.appColour;
    }];
    
}
-(void)pushCameraVCForType:(int)type {
    
    _cameraVC = [cameraVC new];
    [self addChildViewController:_cameraVC];
    [self.view addSubview:_cameraVC.view];
    [_cameraVC beginWithType:type]; //0 --> photo, 1 --> photo user, 2 --> video

    
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
    
    if (!mediaDictionary){  mediaDictionary = [NSMutableDictionary new]; }
    
    if (n.object){
        int type = [n.object intValue];
        NSDictionary * userInfo = n.userInfo;
        if (type == 0){ //main pic
            
            mediaDictionary[@"heroOriginal"] = (UIImage *)userInfo[@"original"];
            mediaDictionary[@"heroThumb"] = (UIImage *)userInfo[@"thumb"];
            heroIV.image = mediaDictionary[@"heroOriginal"];
            
        } else if (type == 1){ //additional photo
            
            int index = (int)selectedAdditionalView.tag;
            NSString * originalKey = [NSString stringWithFormat:@"aOriginal_%i", index];
            NSString * thumbKey = [NSString stringWithFormat:@"aThumb_%i",index];
            mediaDictionary[originalKey] = (UIImage *)userInfo[@"original"];
            mediaDictionary[thumbKey] = (UIImage *)userInfo[@"thumb"];
            selectedAdditionalView.image = mediaDictionary[originalKey];
            
        } else if (type == 2){ //video

            mediaDictionary[@"videoThumb"] = (UIImage *)userInfo[@"thumb"];
            videoIV.image = mediaDictionary[@"videoThumb"];
            
        }
        
        

        
 
        
        
    }
}


//NEXT BUTTON
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:mainScroller]){
        
        float xOff = mainScroller.contentOffset.x;
        float fPage = xOff / w;
        page = roundf(fPage);
        pager.currentPage = page;

        if (page == 2){
            [self animateNextButtonToFinish];
        } else {
            [self animateFinishButtonToNext];
        }
        
        /*
         
         int previousPage = page;
         
         if (previousPage == 1 && page == 0){
         [descriptionTV resignFirstResponder];
         [self moveNextButtonDown];
         } else if (previousPage == 0 && page == 1){
         [descriptionTV becomeFirstResponder];
         } else if (previousPage == 1 && page == 2){
         [ingredientsTV becomeFirstResponder];
         } else if (previousPage == 2 && page == 3){
         [instructionsTV becomeFirstResponder];
         } else if (previousPage == 3 && page == 4){
         [instructionsTV resignFirstResponder];
         [self moveNextButtonDown];
         }
         */
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [titleTF resignFirstResponder];
    [hourTF resignFirstResponder];
    [minTF resignFirstResponder];
    [descriptionTV resignFirstResponder];
    [ingredientsTV resignFirstResponder];
    [instructionsTV resignFirstResponder];

}
-(void)next {
    
    if (page!=4){
        page++;
        [mainScroller setContentOffset:CGPointMake(page*w, 0) animated:true];
    } else {
        [self publish];
    }
}
-(void)moveNextButtonUp {
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         nextButtonView.transform = CGAffineTransformMakeTranslation(0, -210);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}
-(void)moveNextButtonDown {

    [UIView animateWithDuration:0.6f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         nextButtonView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
-(void)animateNextButtonToFinish {
    
    if (!nextButtonIsFinish){
        nextButtonIsFinish = true;

        nextButtonLabel.alpha = 0.0f;
        nextButtonLabel.transform = CGAffineTransformMakeTranslation(100, 0);
        [UIView animateWithDuration:0.6f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             nextButtonLabel.alpha = 1.0f;
                             nextButtonLabel.transform = CGAffineTransformIdentity;
                             nextButtonIV.transform = CGAffineTransformMakeTranslation(-60, -10);
                             nextButtonView.frame = CGRectMake((w-200)/2, h-80, 200, 40);

                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        CABasicAnimation * corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        corner.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        corner.toValue = @(20.0f);
        corner.duration = 0.3f;
        corner.removedOnCompletion = false;
        corner.fillMode = kCAFillModeForwards;
        [nextButtonView.layer addAnimation:corner forKey:@"corner"];

    }

}
-(void)animateFinishButtonToNext {
    

    if (nextButtonIsFinish){
        nextButtonIsFinish = false;
        [UIView animateWithDuration:0.6f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             nextButtonLabel.alpha = 0.0f;
                             nextButtonLabel.transform = CGAffineTransformMakeTranslation(100, 0);
                             nextButtonIV.transform = CGAffineTransformIdentity;
                             nextButtonView.frame = CGRectMake(w-80, h-80, 60, 60);

                         }
                         completion:^(BOOL finished){

                         }];
        
        CABasicAnimation * corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        corner.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        corner.fromValue = @(20.0f);
        corner.toValue = @(30.0f);
        corner.duration = 0.6f;
        corner.removedOnCompletion = false;
        corner.fillMode = kCAFillModeForwards;
        [nextButtonView.layer addAnimation:corner forKey:@"corner"];
        
    }
}


//DATA
-(void)checkFields {
    
    userCanPublish = false;
    
}
-(void)publish {
    
    NSLog(@"publish");
    
    //check all fields filled out
    
    
    //create new id if none exists
    Recipe * recipe = [Recipe new];
    recipe.recipeID = [NSString stringWithFormat:@"RECIPE_%@_%@", [_peacock uniqueID],_donkey.currentUser.userID];
    recipe.timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    recipe.recipeName = titleTF.text;
    recipe.duration = [NSString stringWithFormat:@"%i", hourTF.text.intValue * 60 + minTF.text.intValue];
    recipe.difficulty = _donkey.skillLevels[[skillPicker selectedRowInComponent:0]];
    recipe.course = _donkey.courses[[coursePicker selectedRowInComponent:0]];
    recipe.introduction = descriptionTV.text;
    recipe.ingredients = ingredientsTV.text;
    recipe.instructions = instructionsTV.text;
    recipe.scores = @[];
    [_dog updateRecipe:recipe];
    
    
    
}

//OTHER
-(void)popSelf {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPopEditVC" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

