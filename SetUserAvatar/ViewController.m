//
//  ViewController.m
//  SetUserAvatar
//
//  Created by zivInfo on 17/2/7.
//  Copyright © 2017年 xiwangtech.com. All rights reserved.
//

/*
 * 在info.plist加上下面这一条就可以使我们调出来的相册显示出中文.
 * Localized resources can be mixed 设置为 YES。
 */
#import "ViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 3);
    backgroundView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:backgroundView];
    
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(120.0f, 50.0f, 80.0f, 80.0f);
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageView setClipsToBounds:YES];
    self.imageView.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(4.0f, 4.0f);
    self.imageView.layer.shadowOpacity = 0.5f;
    self.imageView.layer.shadowRadius = 2.0f;
    // 把图片设置成圆形
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2;
    self.imageView.layer.masksToBounds = YES;
    // 给图片加一个圆形边框
    self.imageView.layer.borderWidth = 2.0f;
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    // 允许用户交互
    self.imageView.userInteractionEnabled = YES;
    [backgroundView addSubview:self.imageView];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alterHeadPortrait:)];
    [self.imageView addGestureRecognizer:singleTap];
    
    ////////////////////////////////////////////////////////////
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagePath = [documentPath stringByAppendingString:@"/profileIcon.png"];
    UIImage *imageProfile = [self getImage:imagePath];
    
    //转换图片
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *midImage = [CIImage imageWithData:UIImagePNGRepresentation(imageProfile)];
    //图片开始处理
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:midImage forKey:kCIInputImageKey];
    //value 改变模糊效果值
    [filter setValue:@7.0f forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef outimage = [context createCGImage:result fromRect:[result extent]];
    //转换成UIimage
    UIImage *resultImage = [UIImage imageWithCGImage:outimage];
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:resultImage];

    if (imageProfile) {
        self.imageView.image = imageProfile;
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"profileIcon.png"];
    }

    
}

-(void)alterHeadPortrait:(UITapGestureRecognizer *) gesture
{
    // iOS 8 以前使用的方法。
    UIActionSheet *actionSheetPhoto = [[UIActionSheet alloc]initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相机选择", nil];
    [actionSheetPhoto dismissWithClickedButtonIndex:0 animated:YES];
    actionSheetPhoto.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheetPhoto showInView:self.view];
    
    
    // iOS 8 以后可以使用的方法。
    /*
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self sourceTypeCamera];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self sourceTypeSavedPhotosAlbum];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
    */
}

-(void)sourceTypeCamera
{
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerImage.allowsEditing = YES;
    pickerImage.delegate = self;
    [self presentViewController:pickerImage animated:YES completion:nil];
}

-(void)sourceTypeSavedPhotosAlbum
{
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerImage.allowsEditing = YES;
    pickerImage.delegate = self;
    [self presentViewController:pickerImage animated:YES completion:nil];
    
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self sourceTypeCamera];
    }
    else if (buttonIndex == 1) {
        [self sourceTypeSavedPhotosAlbum];
    }
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self saveImage:newPhoto WithName:@"profileIcon.png"];
    self.imageView.image = newPhoto;

    [self dismissViewControllerAnimated:YES completion:nil];

}

//保存图片
- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData *imageData = UIImagePNGRepresentation(tempImage);
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *totalPath = [documentPath stringByAppendingPathComponent:imageName];
    
    //保存到 document
    [imageData writeToFile:totalPath atomically:NO];
    
    //保存到 NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:totalPath forKey:@"ProfileIcon"];
    
}

//从document取得图片
- (UIImage *)getImage:(NSString *)urlStr
{
    return [UIImage imageWithContentsOfFile:urlStr];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
