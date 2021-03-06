//
//  KeyboardViewController.m
//  GymojiKeyboard
//
//  Created by Bart on 7/14/16.
//  Copyright © 2016 bodytech. All rights reserved.
//

#import "KeyboardViewController.h"
#import "GymojiCell.h"
@import FirebaseStorage;

@interface KeyboardViewController ()<UICollectionViewDelegate,UICollectionViewDataSource, UIScrollViewDelegate>
{
    UICollectionViewFlowLayout *flowLayout;
}
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSMutableArray *sticker_selectedImages;
@property (nonatomic) CGFloat portraitHeight;
@property (nonatomic) CGFloat landscapeHeight;
@property (nonatomic) BOOL isLandscape;
@property (nonatomic) NSLayoutConstraint *heightConstraint;
@property (nonatomic) Boolean viewFlag;
@property (nonatomic) Boolean landscapeFlag;
@property (nonatomic) CGFloat keyboardHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imageCell;
@property (strong, nonatomic) UIView *tempView;
@property (strong, nonatomic) UIButton *tempButton;
@property (strong, nonatomic) UIImage *tempImage;
@property (nonatomic)int temp;
@property (nonatomic)int viewtemp;
@property (nonatomic)int increaseNumber;
@property (strong, nonatomic)NSMutableArray *stickers;
@property (strong, nonatomic)UILabel *downloadStringwithEquiment;
@property (strong, nonatomic)UILabel *downloadStringwithworkouts;
@property (strong, nonatomic)UILabel *downloadStringwithmuscles;
@property (strong, nonatomic)UILabel *downloadStringwithbodybuilding;
@property (strong, nonatomic)UILabel *downloadStringwithgymselfie;
@property (nonatomic)Boolean flagForRemoveDownloadStringwith;
@property (nonatomic, strong)UILabel *tempLabel;


@property (strong, nonatomic) FIRStorageReference *storageRef;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    // Add custom view sizing constraints here
    if(_viewFlag == false){
        return;
    }
    if (self.view.frame.size.width == 0 || self.view.frame.size.height == 0)
        return;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    float screenW = screenSize.width;
    float screenH = screenSize.height;
    
    
    CGSize keyboardSize = CGSizeMake(screenSize.width, screenSize.height * 0.36);
    
    float collectionViewHeight = keyboardSize.height * (320/480.0f);
    float collectionViewWidth = keyboardSize.width;
    
    float cellWidth = (collectionViewWidth) / 5.0f;
    float cellHeight = (collectionViewHeight-20) / 2.0;
    
    BOOL isLandscape = !(self.view.frame.size.width == (screenW*(screenW<screenH)) + (screenH*(screenW>screenH)));
    
    [self.view removeConstraint:self.heightConstraint];
    if (isLandscape) {
        self.landscapeFlag = true;
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenH * 0.36];
        
        [self.view addConstraint:self.heightConstraint];
        
        cellWidth = collectionViewWidth / 8.0f;
        cellHeight = collectionViewHeight / 1.5f;
        
    } else {

        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenH * 0.36];
        
        [self.view addConstraint:self.heightConstraint];
        
    }
    
    
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(cellWidth, cellHeight)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumLineSpacing = 0.0f;
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.bounces = YES;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.keyboardHeight = screenSize.height * 0.36;
    float screenW = screenSize.width;
    float screenH = screenSize.height;
    
    BOOL isLandscape = !(self.view.frame.size.width == (screenW*(screenW<screenH)) + (screenH*(screenW>screenH)));
    
    [self.view removeConstraint:self.heightConstraint];
    
    if (isLandscape) {
        self.landscapeFlag = true;
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenH * 0.5];
        
        [self.view addConstraint:self.heightConstraint];
        
    } else {
        self.landscapeFlag = false;
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenH * 0.36];
        
        [self.view addConstraint:self.heightConstraint];
    }
    
    self.viewFlag = true;
    
    [self setupBottomView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _increaseNumber = 0;

    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:2
                                    target:self
                                    selector:@selector(targetMethod:)
                                    userInfo:nil
                                    repeats:YES];

    self.stickers = [[NSMutableArray alloc]init];
    
    self.imagesArray = [[NSMutableArray alloc]init];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.bodytech.gymoji"];
    if([userDefaults objectForKey:@"imagePath0"]!=nil){
        
        for(int j=0;j<5;j++){
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:[userDefaults objectForKey:[NSString stringWithFormat:@"imagePath%d",j]]];
            NSMutableArray *imageArray = [[NSMutableArray alloc]init];
            for(int i=0;i<array.count;i++){
                
                UIImage *image = [UIImage imageWithData:[array objectAtIndex:i]];
                [imageArray addObject:image];
                
            }
            [self.stickers addObject:imageArray];
            
        }
        
        self.imagesArray = [self.stickers objectAtIndex:0];
        
    }else{
        
        UIImage *image = [UIImage imageNamed:@"placeholder.png"];
        [self.imagesArray addObject:image];
        _downloadStringwithEquiment = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, 20)];
        _downloadStringwithEquiment.text = @"Downloading images...";
        _downloadStringwithEquiment.textColor = [UIColor blackColor];
        
        self.tempLabel = _downloadStringwithEquiment;
        [self.view addSubview:_downloadStringwithEquiment];
        
    }
    
    self.sticker_selectedImages = [[NSMutableArray alloc]initWithObjects:@"equiment2.png",@"sticker2_selected.png",@"marcle2.png",@"sticker4_selected.png",@"sticker5_selected.png", nil];
    
    self.color = self.equiment_view.backgroundColor;
    self.equimentflag = true;
    self.marcleflag = false;
    self.equiment_view.userInteractionEnabled = YES;
    self.marcle_view.userInteractionEnabled = YES;
    
    
    for(UIView *view in self.CategoryView){
        
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        [view addGestureRecognizer:recognizer];
    }
    
}

-(void)initwithfiles{
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.bodytech.gymoji"];
    if([userDefaults objectForKey:@"imagePath0"]!=nil){
        
        self.imagesArray = [[NSMutableArray alloc]init];
        self.stickers = [[NSMutableArray alloc]init];
        for(int j=0;j<5;j++){
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:[userDefaults objectForKey:[NSString stringWithFormat:@"imagePath%d",j]]];
            NSMutableArray *imageArray = [[NSMutableArray alloc]init];
            for(int i=0;i<array.count;i++){
                
                UIImage *image = [UIImage imageWithData:[array objectAtIndex:i]];
                [imageArray addObject:image];
                
            }
            [self.stickers addObject:imageArray];
            
        }
        
        self.imagesArray = [self.stickers objectAtIndex:0];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.bodytech.gymoji"];
    if([userDefaults objectForKey:@"imagePath4"]!=nil){
        
        [_downloadStringwithEquiment removeFromSuperview];
        self.tempLabel = [[UILabel alloc]init];
        [self.collectionView reloadData];
        
    }
//    if([userDefaults objectForKey:@"imagePath1"]!=nil){
//        
//        [_downloadStringwithworkouts removeFromSuperview];
//        self.tempLabel = [[UILabel alloc]init];
//        [self.collectionView reloadData];
//        
//    }
//    if([userDefaults objectForKey:@"imagePath2"]!=nil){
//        
//        [_downloadStringwithmuscles removeFromSuperview];
//        self.tempLabel = [[UILabel alloc]init];
//        [self.collectionView reloadData];
//        
//    }
//    if([userDefaults objectForKey:@"imagePath3"]!=nil){
//        
//        [_downloadStringwithbodybuilding removeFromSuperview];
//        self.tempLabel = [[UILabel alloc]init];
//        [self.collectionView reloadData];
//        
//    }
//    if([userDefaults objectForKey:@"imagePath4"]!=nil){
//        
//        [_downloadStringwithgymselfie removeFromSuperview];
//        self.tempLabel = [[UILabel alloc]init];
//        [self.collectionView reloadData];
//        
//    }

    self.pageControll.numberOfPages = 0;
    self.pageControll.currentPage = 0;
}

-(void)targetMethod:(NSTimer*)timer{
    
    [self initwithfiles];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.bodytech.gymoji"];
    if([userDefaults objectForKey:@"imagePath4"]!=nil){
        [timer invalidate];
        [self viewWillAppear:true];
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

-(void)setupBottomView{
    
    UIView * view = [self.view viewWithTag:6];
    view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [self.view viewWithTag:1];
    UIImage *image = button.currentImage;
    [button setImage:[UIImage imageNamed:[self.sticker_selectedImages objectAtIndex:0]] forState:UIControlStateNormal];
    self.temp = 1;
    self.viewtemp = 6;
    self.tempButton = button;
    self.tempView = view;
    self.tempImage = image;

}

#pragma mark - UICollectionView DataSource 

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    int sections = (int)self.imagesArray.count / 2;
    if (self.imagesArray.count % 2 == 1) {
        sections += 1;
    }
    
    return sections;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    int rows = 2;
    if ((section * 2 + 1) == self.imagesArray.count) {
        rows = 1;
    }
    return rows;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *identifier = @"gymojiCell";
    float row = [indexPath row];
    float section = [indexPath section];
    float index = section * 2 + row;
    
    GymojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if(self.imagesArray !=NULL){
        
        cell.imgGymoji.image = [self.imagesArray objectAtIndex:index];
    }
    
    
    int pages = ceil(self.collectionView.contentSize.width /
                     self.collectionView.frame.size.width);
    
    self.pageControll.numberOfPages = pages;
    
    return  cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    
    GymojiCell *cell = (GymojiCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:(void (^)(void)) ^{cell.imgGymoji.transform=CGAffineTransformMakeScale(1.2, 1.2);} completion:^(BOOL finished){
        cell.imgGymoji.transform = CGAffineTransformIdentity;
    }];
    
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

    NSData *data = UIImagePNGRepresentation(cell.imgGymoji.image);

    [pasteboard setData:data forPasteboardType:@"public.png"];
    
    if(pasteboard){
        
        //copy image to clipboard
        UIView *notificationView= [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.1, self.view.frame.size.width, 20)];
        notificationView.backgroundColor = [UIColor greenColor];
        UILabel *notification = [[UILabel alloc]initWithFrame: CGRectMake(0, 0, notificationView.frame.size.width, notificationView.frame.size.height)];
        notification.text = @"Gymoji copied to clipboard!";
        notification.textColor = [UIColor whiteColor];
        notification.textAlignment = NSTextAlignmentCenter;
        [notificationView addSubview:notification];
        
        [notificationView setAlpha:0.0f];
        
        //fade in
        [UIView animateWithDuration:1.0f animations:^{
            
            [notificationView setAlpha:1.0f];
            
        } completion:^(BOOL finished) {
            
            //fade out
            [UIView animateWithDuration:0.5f animations:^{
                
                [notificationView setAlpha:0.0f];
                
            } completion:nil];
            
        }];
        
        [self.view addSubview:notificationView];
    }
    

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat pagewidth = self.collectionView.frame.size.width;
    float currentPage = self.collectionView.contentOffset.x / pagewidth;
    
    self.pageControll.currentPage = self.collectionView.contentOffset.x/pagewidth;
    if (0.0f != fmodf(currentPage, 1.0f))
    {
        self.pageControll.currentPage = currentPage + 1;
    }
    else
    {
        self.pageControll.currentPage = currentPage;
    }

}

#pragma mark -
- (IBAction)pageControlTouched:(UIPageControl *)sender {
    
    CGRect bounds = self.collectionView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
    [self.collectionView scrollRectToVisible:bounds animated:YES];
}

-(UIImage*)resizeImage:(UIImage*)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 125.0;
    float maxWidth = 125.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 1.0;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}

// taped categories in bottom bar

-(void)tapView:(UITapGestureRecognizer *)sender{
    
    UIView *view = (UIView*)sender.view;
    if(self.viewtemp != view.tag && view.tag - 5 != self.temp){
        UIButton *button = [self.view viewWithTag:view.tag - 5];
        UIImage *image = button.currentImage;
        [button setImage:[UIImage imageNamed:[self.sticker_selectedImages objectAtIndex:view.tag - 6]] forState:UIControlStateNormal];
        if(self.tempButton !=nil){
            [self.tempButton setImage:self.tempImage forState:UIControlStateNormal];
        }
        UIColor *color = view.backgroundColor;
        if(self.tempView !=nil){
            self.tempView.backgroundColor = color;
        }
        
        view.backgroundColor = [UIColor whiteColor];
        self.tempView = view;
        self.tempButton = button;
        self.tempImage = image;
    }
    
    self.viewtemp = view.tag;
    self.temp = view.tag - 5;
    self.imagesArray = [[NSMutableArray alloc]init];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.bodytech.gymoji"];
    if([userDefaults objectForKey:[NSString stringWithFormat:@"imagePath%d",view.tag-6]]!=nil){
        
        self.imagesArray = [self.stickers objectAtIndex:view.tag - 6];
    }
    
    [self viewWillAppear:YES];
    
}

- (IBAction)categorybuttonsPresssed:(UIButton *)sender {
    
    if(self.temp != sender.tag && sender.tag + 5 != self.viewtemp){
        
        UIImage *image = sender.currentImage;
        [sender setImage:[UIImage imageNamed:[self.sticker_selectedImages objectAtIndex:sender.tag - 1] ] forState:UIControlStateNormal];
        
        if(self.tempButton !=nil){
            [self.tempButton setImage:self.tempImage forState:UIControlStateNormal];
        }
        
        UIView *view =  [self.view viewWithTag:sender.tag + 5];
        UIColor *color = view.backgroundColor;
        if(self.tempView !=nil){
            self.tempView.backgroundColor = color;
        }
        view.backgroundColor = [UIColor whiteColor];
        self.tempView = view;
        self.tempButton = sender;
        self.tempImage = image;
    }
    
    self.temp = sender.tag;
    self.viewtemp = sender.tag + 5;
    
    self.imagesArray = [[NSMutableArray alloc]init];
//    if([self.stickers objectAtIndex:sender.tag -1] !=NULL){
//        self.imagesArray = [self.stickers objectAtIndex:sender.tag - 1];
//    }
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.bodytech.gymoji"];
    if([userDefaults objectForKey:[NSString stringWithFormat:@"imagePath%d",sender.tag-1]]!=nil){
        
        self.imagesArray = [self.stickers objectAtIndex:sender.tag - 1];
//    }else{
//
//        switch (sender.tag-1) {
//            case 1:
//            {
//                if(self.tempLabel.text.length==0){
//                    
//                    _downloadStringwithworkouts = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, 20)];
//                    _downloadStringwithworkouts.text = @"Downloading images...";
//                    _downloadStringwithworkouts.textColor = [UIColor blackColor];
//                    
//                    [self.view addSubview:_downloadStringwithworkouts];
//                }
//                
//            }
//                break;
//            case 2:
//            {
//                if(self.tempLabel.text.length == 0){
//                    
//                    _downloadStringwithmuscles = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, 20)];
//                    _downloadStringwithmuscles.text = @"Downloading images...";
//                    _downloadStringwithmuscles.textColor = [UIColor blackColor];
//                    
//                    [self.view addSubview:_downloadStringwithmuscles];
//                }
//                
//            }
//                break;
//            case 3:
//            {
//                if(self.tempLabel.text.length == 0){
//                    
//                    _downloadStringwithbodybuilding = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, 20)];
//                    _downloadStringwithbodybuilding.text = @"Downloading images...";
//                    _downloadStringwithbodybuilding.textColor = [UIColor blackColor];
//                    
//                    [self.view addSubview:_downloadStringwithbodybuilding];
//                }
//                
//            }
//                break;
//            case 4:
//            {
//                if(self.tempLabel.text.length == 0){
//                    
//                    _downloadStringwithgymselfie = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.25, self.view.frame.size.height * 0.1, self.view.frame.size.width * 0.5, 20)];
//                    _downloadStringwithgymselfie.text = @"Downloading images...";
//                    _downloadStringwithgymselfie.textColor = [UIColor blackColor];
//                    
//                    [self.view addSubview:_downloadStringwithgymselfie];
//                }
//                
//            }
//                break;
//                
//            default:
//                break;
//        }
    }
    [self viewWillAppear:YES];
    
   }

- (IBAction)backspaceKeyPressed:(id)sender {
    
    [self.textDocumentProxy deleteBackward];
}

- (IBAction)globeKeyPreseed:(id)sender {
    
    [self advanceToNextInputMode];
}

- (IBAction)gymoji_1Pressed:(id)sender {
    
    
}
@end
