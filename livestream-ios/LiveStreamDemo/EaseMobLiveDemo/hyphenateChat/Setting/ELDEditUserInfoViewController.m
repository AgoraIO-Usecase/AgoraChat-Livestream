//
//  ELDEditUserInfoViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/31.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDEditUserInfoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ELDEditUserInfoViewController.h"
#import "ELDUserHeaderView.h"
#import "LXCalendarOneController.h"
#import "MISDatePickerSheet.h"
#import "NSDate+GFCalendar.h"
#import "ELDSettingTitleValueAccessCell.h"


#define kInfoHeaderViewHeight 200.0
#define kHeaderInSection  30.0
#define kNickNameMaxLength 24

@interface ELDEditUserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) ELDUserHeaderView *userHeaderView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSString *myNickName;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSMutableDictionary *monthDic;

@end

@implementation ELDEditUserInfoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ViewControllerBgBlackColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavbar];
    [self.view addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setupNavbar {
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [ELDUtil customLeftButtonItem:@"Edit Profile" action:@selector(backAction) actionTarget:self];
}


#pragma mark actions
- (void)modifyAlias {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change Nick Name" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *messageTextField = alertController.textFields.firstObject;
        
        [self updateMyNickname:messageTextField.text];

    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)updateMyNickname:(NSString *)newName
{
    newName = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (newName.length > 0 && ![_myNickName isEqualToString:newName])
    {
        self.myNickName = newName;

        [[AgoraChatClient.sharedClient userInfoManager] updateOwnUserInfo:newName withType:AgoraChatUserInfoTypeNickName completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
            if (aError == nil) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.updateUserInfoBlock) {
                        self.updateUserInfoBlock(aUserInfo);
                    }
                    self.userInfo = aUserInfo;
                    [self.table reloadData];
                });
            }
        }];

    }
}


- (void)modifyGender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Gender" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *maleAction = [UIAlertAction actionWithTitle:@"Male" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self modifyGenderWithIndex:1];
    }];
    [maleAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *femaleAction = [UIAlertAction actionWithTitle:@"Female" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self modifyGenderWithIndex:2];
    }];
    [femaleAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"Other" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self modifyGenderWithIndex:3];
    }];
    [otherAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *secretAction = [UIAlertAction actionWithTitle:@"Secret" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self modifyGenderWithIndex:4];
    }];
    [secretAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancelAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    
    [alertController addAction:maleAction];
    [alertController addAction:femaleAction];
    [alertController addAction:otherAction];
    [alertController addAction:secretAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)modifyGenderWithIndex:(NSInteger)index {
     
    [[AgoraChatClient.sharedClient userInfoManager] updateOwnUserInfo:[@(index) stringValue] withType:AgoraChatUserInfoTypeGender completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
        if (aError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.updateUserInfoBlock) {
                    self.updateUserInfoBlock(aUserInfo);
                }

                self.userInfo = aUserInfo;
                [self.table reloadData];
            });

        }
    }];
}

- (void)modifyBirth {    
    MISDatePickerSheet* sheet = [[MISDatePickerSheet alloc] initWithDatePickerMode:UIDatePickerModeDate];
    sheet.minDate = [ELDUtil dateFromString:@"1900-01-01"];
    NSDate *todayDate = [NSDate date];
    
    NSDateFormatter  *dateformatter= [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateformatter stringFromDate:todayDate];
    sheet.maxDate = [ELDUtil dateFromString:dateString];

    [sheet setDateBlock:^(NSDate *date) {
        NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@",[@([date dateYear]) stringValue],[self  convert2StringWithInt:[date dateMonth]],[self convert2StringWithInt:[date dateDay]]];
        NSLog(@"dateString:%@",dateString);
        
        [[AgoraChatClient.sharedClient userInfoManager] updateOwnUserInfo:dateString withType:AgoraChatUserInfoTypeBirth completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
            if (aError == nil) {
                self.userInfo = aUserInfo;
                if (self.updateUserInfoBlock) {
                    self.updateUserInfoBlock(self.userInfo);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.table reloadData];
                });
            }else {
                [self showHint:aError.description];
            }
        }];
        
    }];
    [sheet show];

}

- (NSString *)convert2StringWithInt:(NSInteger)intValue {
    NSString *result = [@(intValue) stringValue];
    if (result.length == 1) {
        result = [NSString stringWithFormat:@"0%@",result];
    }
    return result;
}

- (NSString *)convert2StringFromBirthday:(NSString *)birthday {
    if (birthday.length == 0) {
        return @"";
    }
    
    NSArray *tArray = [birthday componentsSeparatedByString:@"-"];
    NSString *year = tArray[0];
    NSString *month = self.monthDic[@([tArray[1] integerValue])];
    NSString *day = tArray[2];

    NSString *result = [NSString stringWithFormat:@"%@ %@, %@",month,day,year];
    return result;
}


- (void)changeAvatarAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change Avatar" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self camerAction];
    }];
    [cameraAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"Upload Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self photoAction];
    }];
    [albumAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancelAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)photoAction {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    self.imagePicker.editing = YES;
    self.imagePicker.modalPresentationStyle = 0;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)camerAction {
#if TARGET_OS_IPHONE
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        self.imagePicker.editing = YES;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        self.imagePicker.modalPresentationStyle = 0;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
#endif
}

-(void)uploadCoverImageView:(void(^)(BOOL success))completion{
    [EaseHttpManager.sharedInstance uploadFileWithData:_fileData completion:^(NSString *url, BOOL success) {
        if (success) {
            self.userInfo.avatarUrl = url;
        }
        
        completion(success);
    }];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField {
    
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *pos = [textField positionFromPosition:selectedRange.start offset:0];
    if (selectedRange && pos) {
        return;
    }
    NSInteger realLength = textField.text.length;
    if (realLength > kNickNameMaxLength) {
        textField.text = [textField.text substringToIndex:kNickNameMaxLength];
    }

}


#pragma mark - UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (editImage) {
        self.currentImage = editImage;
        _fileData = UIImageJPEGRepresentation(editImage, 1.0);
        if (!_fileData) {
            _fileData = [NSData new];
        }

        [self uploadCoverImageView:^(BOOL success) {
            if (success) {
                if (self.updateUserInfoBlock) {
                    self.updateUserInfoBlock(self.userInfo);
                }
                
                //save userinfo
                [EaseUserInfoManagerHelper updateUserInfo:self.userInfo completion:^(AgoraChatUserInfo * _Nonnull aUserInfo) {
                                    
                }];
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ELDUserAvatarUpdateNotification object:self.currentImage];
                
                [self.userHeaderView.avatarImageView setImage:self.currentImage];
                [self.table reloadData];
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ELDSettingTitleValueAccessCell *cell = [tableView dequeueReusableCellWithIdentifier:[ELDSettingTitleValueAccessCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ELDSettingTitleValueAccessCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ELDSettingTitleValueAccessCell reuseIdentifier]];
    }

    if (indexPath.row == 0) {
        cell.nameLabel.text = @"Username";
        cell.detailLabel.text = self.userInfo.nickName ?:self.userInfo.userId;
        
        ELD_WS
        cell.tapCellBlock = ^{
            [weakSelf modifyAlias];
            [weakSelf.table reloadData];
        };
    }
    
    if (indexPath.row == 1) {
        cell.nameLabel.text = @"Gender";
        cell.detailLabel.text = [self genderString];
        ELD_WS
        cell.tapCellBlock = ^{
            [weakSelf modifyGender];
            [weakSelf.table reloadData];
        };
    }

    if (indexPath.row == 2) {
        cell.nameLabel.text = @"Brithday";
        cell.detailLabel.text = [self convert2StringFromBirthday:self.userInfo.birth];
        ELD_WS
        cell.tapCellBlock = ^{
            [weakSelf modifyBirth];
            [weakSelf.table reloadData];
        };
    }
    return cell;
}

- (NSString *)genderString {
    NSString *gender = @"";
    
    NSInteger genderIndex = self.userInfo.gender;
    switch (genderIndex) {
        case 1:
            gender = @"Male";
            break;
        case 2:
            gender = @"Female";
            break;
        case 3:
            gender = @"Other";
            break;
        case 4:
            gender = @"Serect";
            break;
        default:
            gender = @"Serect";
            break;
    }
    return gender;
}


#pragma mark getter and setter
- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = ViewControllerBgBlackColor;
        _table.tableHeaderView = [self headerView];
        [_table registerClass:[ELDSettingTitleValueAccessCell class] forCellReuseIdentifier:[ELDSettingTitleValueAccessCell reuseIdentifier]];
        _table.rowHeight = [ELDSettingTitleValueAccessCell height];
    }
    return _table;
}


- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kInfoHeaderViewHeight)];
        [_headerView addSubview:self.userHeaderView];
        [self.userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerView);
        }];
        _headerView.backgroundColor = UIColor.yellowColor;
    }
    return _headerView;
}


- (ELDUserHeaderView *)userHeaderView {
    if (_userHeaderView == nil) {
        _userHeaderView = [[ELDUserHeaderView alloc] initWithFrame:CGRectZero isEditable:YES];
        _userHeaderView.nameLabel.text = @"Click to Change Avatar";
        [_userHeaderView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:kDefultUserImage];

        ELD_WS
        _userHeaderView.tapHeaderViewBlock = ^{
            [weakSelf changeAvatarAction];
        };
    }
    return _userHeaderView;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
    
}

- (NSMutableDictionary *)monthDic {
    if (_monthDic == nil) {
        _monthDic = NSMutableDictionary.new;
        _monthDic[@(1)] = @"Jan";
        _monthDic[@(2)] = @"Feb";
        _monthDic[@(3)] = @"Mar";
        _monthDic[@(4)] = @"Apr";
        _monthDic[@(5)] = @"May";
        _monthDic[@(6)] = @"Jun";
        _monthDic[@(7)] = @"Jul";
        _monthDic[@(8)] = @"Aug";
        _monthDic[@(9)] = @"Sep";
        _monthDic[@(10)] = @"Oct";
        _monthDic[@(11)] = @"Nov";
        _monthDic[@(12)] = @"Dec";
    }
    return _monthDic;
}

@end
#undef kInfoHeaderViewHeight
#undef kHeaderInSection
#undef kNickNameMaxLength



