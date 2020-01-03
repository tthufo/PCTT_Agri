//
//  EM_MenuView.m
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_MenuView.h"

@interface EM_MenuView ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSMutableArray * dataList, * tempList;
    
    NSMutableDictionary * extraInfo, * multiSection;
    
    NSTimer * timer;
    
    NSString * gName, * uName;
    
    NSMutableArray *years;
}

@end

@implementation EM_MenuView

@synthesize menuCompletion;

- (id)initWithLoc:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateLocView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateLocView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 460)];
    
    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][5];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    
//    [(UIImageView*)[self withView:contentView tag:11] imageUrl:dict[@"url"]];
    
//    [(UIImageView*)[self withView:contentView tag:11] withBorder:@{@"Bwidth":@(1), @"Bcolor": [UIColor brownColor]}];
    
    [(UIButton*)[self withView:contentView tag:12] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self close];
    }];
    
  
    
    [contentView actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        //self.menuCompletion(0, dict, self);
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (NSDictionary*) lang
{
    BOOL isVi = [[self getValue:@"lang"]  isEqualToString: @"vi"] ? YES : NO;
    
    NSDictionary * vi = @{@"1":@"Tuỳ chọn", @"2":@"English",@"3":@"Cài đặt thông báo", @"4":@"Giới thiệu 3DART",@"5":@"Hướng dẫn tham quan", @"6":@"Thoát"};
    
    NSDictionary * en = @{@"1":@"Options", @"2":@"Vietnamese",@"3":@"Notification", @"4":@"3DART's introduction",@"5":@"Tour instruction", @"6":@"Exit"};
    
    return isVi ? vi : en ;
}

- (id)initWithPop:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreatePopView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreatePopView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 309)];
    
    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][4];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    [contentView setBackgroundColor:[UIColor clearColor]];

    [self setBackgroundColor:[UIColor clearColor]];

    ((UILabel*)[self withView:contentView tag:1]).text = [dict getValueFromKey:@"ten"];
        
    ((UILabel*)[self withView:contentView tag:2]).text = [NSString stringWithFormat:@"Chiêu cao: %@ m", [dict getValueFromKey:@"chieu_cao"]];

    ((UILabel*)[self withView:contentView tag:3]).text = [NSString stringWithFormat:@"Số tầng: %@", [dict getValueFromKey:@"so_tang"]];

    ((UILabel*)[self withView:contentView tag:4]).text = [NSString stringWithFormat:@"Số phòng: %@", [dict getValueFromKey:@"so_phong"]];

    ((UILabel*)[self withView:contentView tag:5]).text = [NSString stringWithFormat:@"Diện tích: %@ m2", [dict getValueFromKey:@"dien_tich"]];

    [contentView actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        self.menuCompletion(0, dict, self);
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithMenu:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateMenuView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateMenuView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 155)];
    
    [commentView withBorder:@{@"Bcolor": [UIColor clearColor], @"Bcorner":@(5), @"Bwidth":@(0)}];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][0];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    for(UIView * v in contentView.subviews)
    {
        if([v isKindOfClass:[UIButton class]])
        {
            [(UIButton*)[self withView:contentView tag:v.tag] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
                [self close];
        
                self.menuCompletion(v.tag, nil, self);
            }];
        } else {
            [((UIView*)v) withShadow];
        }
    }

    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithNotification:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateNotificationView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateNotificationView:(NSDictionary*)dict
{
    dataList = [[NSMutableArray alloc] initWithArray:dict[@"data"]];
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, dataList.count == 0 ? 100 : dataList.count >= 4 ? (4 * 60) + 40 : (dataList.count * 60) + 40)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][1];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    
    
    UITableView * tableView = (UITableView*)[self withView:contentView tag:11];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;

    
    ((UILabel*)[self withView:contentView tag:1]).text = [[self getValue:@"lang"] isEqualToString:@"vi"] ? @"Thông báo" : @"Notification";
    
    [(UIButton*)[self withView:contentView tag:2] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self close];
    }];
    
    
    [commentView addSubview:contentView];
    
    [tableView reloadData];
    
    [tableView cellVisible];
    
    return commentView;
}

- (id)initWithDate:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateDateView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (NSDate *)getDateFromDateString:(NSString *)dateString
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

- (UIView*)didCreateDateView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 247)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][3];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    UIDatePicker * datePicker = ((UIDatePicker*)[self withView:contentView tag:11]);

    if([dict responseForKey:@"date"])
    {
        [datePicker setDate:[self getDateFromDateString:dict[@"date"]] animated:YES];
    }
    
    
    UISwitch * show = (UISwitch*)[self withView:contentView tag:18];
    
    [show setOn:[[dict getValueFromKey:@"show"] isEqualToString:@"1"]];

    
    DropButton * gender = (DropButton*)[self withView:contentView tag:12];
    
    NSArray * data = @[@{@"title":@"Nam", @"id":@"0"}, @{@"title":@"Nữ", @"id":@"1"}];
    
    __block NSString * genderId = @"0";
    
    if([dict responseForKey:@"gender"])
    {
        int numb = [dict[@"gender"] intValue];
        
        [gender setTitle:data[numb][@"title"] forState:UIControlStateNormal];
        
        genderId = dict[@"gender"];
    }
    
    [gender actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [gender didDropDownWithData:@[@{@"title":@"Nam", @"id":@"0"}, @{@"title":@"Nữ", @"id":@"1"}] andCompletion:^(id object) {
            if(object)
            {
                [gender setTitle:object[@"data"][@"title"] forState:UIControlStateNormal];
                
                genderId = object[@"data"][@"id"];
            }
        }];
    }];
    
    [(UIButton*)[self withView:contentView tag:14] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
    }];
    
    [(UIButton*)[self withView:contentView tag:15] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {            
            self.menuCompletion(0, @{@"date":[datePicker.date stringWithFormat:@"dd/MM/yyyy"], @"gender":genderId, @"show": show.isOn ? @"1" : @"0"}, self);
        }
        
        [self close];
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (EM_MenuView*)showWithCompletion:(MenuCompletion)_completion
{
    menuCompletion = _completion;
    
    [self show];
    
    id tableView = [self withView:self tag:11];

    if([tableView isKindOfClass:[UITableView class]])
    {
        [self performSelector:@selector(didScroll:) withObject:tableView afterDelay:0.3];
    }
    
    return self;
}

- (void)didScroll:(UITableView*)tableView
{
//    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[extraInfo[@"active"] intValue] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [tableView cellVisible];
}

- (void)close
{
    [super close];
    
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
}

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [years count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [years objectAtIndex:row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? 60 : tableView.tag == 11 ? 60 : 60;
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier: dataList.count == 0 ? @"E_Empty_Music" : @"presetCell"];
    
    if (!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][2];
    }

    if(dataList.count == 0)
    {
        ((UILabel*)[self withView:cell tag:11]).text = [[self getValue:@"lang"] isEqualToString:@"vi"] ? @"Danh sách thông báo trống" : @"Notification list is empty" ;

        return cell;
    }
    
    NSDictionary * dict = dataList[indexPath.row];
    
    [(UILabel*)[self withView:cell tag:11] setText:dict[@"title"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(dataList.count == 0)
    {
        [self close];
        
        return;
    }

    NSDictionary * dict = dataList[indexPath.row];

    if(self.menuCompletion)
        self.menuCompletion(12, @{@"data":dict}, self);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}

@end


@implementation NSMutableArray (Convenience)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    // Optional toIndex adjustment if you think toIndex refers to the position in the array before the move (as per Richard's comment)
    if (fromIndex < toIndex) {
        toIndex--; // Optional
    }
    
    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end
