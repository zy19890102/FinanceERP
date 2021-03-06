//
//  ZYCustomerDetailViewController.m
//  FinanceERP
//
//  Created by zhangyu on 16/5/13.
//  Copyright © 2016年 张昱. All rights reserved.
//

#import "ZYCustomerDetailViewController.h"
#import "ZYTopTabBar.h"
#import "ZYCustomerWorkInfoSections.h"
#import "ZYCustomerSocialSecuritySections.h"
#import "ZYCustomerFamilyInfoSections.h"
#import "ZYCustomerAccountSections.h"
#import "ZYCustomerCompanyInfoSections.h"
#import "ZYCustomerCreditInfoSections.h"
#import "ZYCustomerRelationInfoSections.h"

#define BUTTON_HEIGHT 50

@interface ZYCustomerDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *topTabScrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContentWidth;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@end

@implementation ZYCustomerDetailViewController
{
    NSInteger steps;
    CGFloat stepWidth;
    
    ZYTopTabBar *topBar;
    
    ZYTableViewCell *firstResponderCell;
}
ZY_VIEW_MODEL_GET(ZYCustomerDetailViewModel)

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;///关闭手势返回 防止误操作
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.scrollViewContentWidth.constant = 1.5*FUll_SCREEN_WIDTH;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
    [self blendViewModel];
}
- (void)buildUI
{
    self.singelLoad = YES;
    [self buildDatePickerView];
    [self buildPickerView];
    self.pickerViewTapBlankHidden = YES;
    self.datePickerViewTapBlankHidden = YES;
    
    steps = self.viewModel.customerDetailTabTitles.count;
    topBar = [[ZYTopTabBar alloc] initWithTabs:self.viewModel.customerDetailTabTitles frame:CGRectMake(0, 0, 1.5*FUll_SCREEN_WIDTH, 50)];
    topBar.backgroundColor = [UIColor whiteColor];
    [topBar.tabButtonPressedSignal subscribeNext:^(NSNumber *index) {
        [self changePage:index.longLongValue];
    }];
    stepWidth = topBar.tabWidth+GAP;
    [self.scrollBackView addSubview:topBar];
    
}
- (void)blendViewModel
{
    [RACObserve(self, selecedRow) subscribeNext:^(NSNumber *index) {
        if([firstResponderCell isKindOfClass:[ZYSelectCell class]])
        {
            [(ZYSelectCell*)firstResponderCell setSelecedIndex:index.longLongValue];
        }
        if([firstResponderCell isKindOfClass:[ZYInputCell class]])
        {
            [(ZYSelectCell*)firstResponderCell setSelecedIndex:index.longLongValue];
        }
    }];
    [RACObserve(self, selecedObj) subscribeNext:^(id obj) {
        if([firstResponderCell isKindOfClass:[ZYSelectCell class]])
        {
            [(ZYSelectCell*)firstResponderCell setSelecedObj:obj];
        }
        if([firstResponderCell isKindOfClass:[ZYInputCell class]])
        {
            [(ZYInputCell*)firstResponderCell setSelecedObj:obj];
        }
    }];
    [RACObserve(self, selecedDate) subscribeNext:^(NSDate *date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [formatter stringFromDate:date];
        if([firstResponderCell isKindOfClass:[ZYSelectCell class]])
        {
            [(ZYSelectCell*)firstResponderCell setCellText:dateStr];
        }
        if([firstResponderCell isKindOfClass:[ZYInputCell class]])
        {
            [(ZYInputCell*)firstResponderCell setCellText:dateStr];
        }
    }];
    
    RACChannelTo(self.viewModel,customer) = RACChannelTo(self,customer);
    
    [RACObserve(self, edit) subscribeNext:^(id x) {
        [self.editButton setTitle:self.edit?@"取消":@"编辑" forState:UIControlStateNormal];
    }];
    
    
    [RACObserve(self.viewModel, loading) subscribeNext:^(NSNumber *loading) {
        if(loading.boolValue)
        {
            [self loading:YES];
        }
        else
        {
            [self stop];
        }
    }];
    [RACObserve(self.viewModel, error) subscribeNext:^(NSString *error) {
        [self tip:error touch:NO];
    }];
    
    [self buildTableViewController];
}
- (IBAction)editButtonPressed:(UIButton *)sender {
    self.edit = !self.edit;
    [self reloadTableViewAtIndex:self.currentPage];
}
- (void)picker:(RACTuple*)value
{
    if([value.first isKindOfClass:[ZYSelectCell class]])
    {
        firstResponderCell = (ZYSelectCell*)value.first;
        self.selecedRow = [(ZYSelectCell*)firstResponderCell selecedIndex];
    }
    if([value.first isKindOfClass:[ZYInputCell class]])
    {
        firstResponderCell = (ZYInputCell*)value.first;
        self.selecedRow = [(ZYInputCell*)firstResponderCell selecedIndex];
    }
    
    NSString *showKey = value.third;
    self.pickerShowValueKey = showKey;
    if([value.second isKindOfClass:[NSArray class]])
    {
        NSArray *dataSource = value.second;
        self.components = @[dataSource];
    }
    else if([value.second isKindOfClass:[RACSignal class]])
    {
        RACSignal *signal = value.second;
        [signal subscribeNext:^(NSArray *dataSource) {
            self.components = @[dataSource];
        }];
    }
    [self showPickerView:YES];
}
- (ZYSections*)buildSection:(NSInteger)index
{
    if(index==0)
    {
        ZYCustomerWorkInfoSections *sections = [[ZYCustomerWorkInfoSections alloc] initWithTitle:@"工作信息"];
        RACChannelTo(sections,edit) = RACChannelTo(self,edit);
        [sections blendModel:self.viewModel];
        [sections.pickerBySignalSignal subscribeNext:^(id x) {
            [self picker:x];
        }];
        [sections.datePickerSignal subscribeNext:^(RACTuple *value) {
            self.showDateBefore = ![value.second boolValue];
            firstResponderCell = (ZYSelectCell*)value.first;
            [self showDatePickerView:YES];
        }];
        [sections.nextStepSignal subscribeNext:^(RACTuple *value) {
            NSString *error = value.first;
            if(error)
            {
                [self tip:error touch:NO];
            }
            else
            {
                [self.viewModel updateCustomerInfoDetailFirst];
            }
        }];
        return sections;
    }
    if(index==1)
    {
        ZYCustomerSocialSecuritySections *sections = [[ZYCustomerSocialSecuritySections alloc] initWithTitle:@"社保信息"];
        RACChannelTo(sections,edit) = RACChannelTo(self,edit);
        [sections blendModel:self.viewModel];
        [sections.datePickerSignal subscribeNext:^(RACTuple *value) {
            self.showDateBefore = ![value.second boolValue];
            firstResponderCell = (ZYSelectCell*)value.first;
            [self showDatePickerView:YES];
        }];
        [sections.nextStepSignal subscribeNext:^(RACTuple *value) {
            NSString *error = value.first;
            if(error)
            {
                [self tip:error touch:NO];
            }
            else
            {
                [self.viewModel updateCustomerInfoDetailFirst];
            }
        }];
        return sections;
    }
    if(index==2)
    {
        ZYCustomerFamilyInfoSections *sections = [[ZYCustomerFamilyInfoSections alloc] initWithTitle:@"家庭信息"];
        RACChannelTo(sections,edit) = RACChannelTo(self,edit);
        [sections blendModel:self.viewModel];
        [sections.pickerBySignalSignal subscribeNext:^(id x) {
            [self picker:x];
        }];
        [sections.nextStepSignal subscribeNext:^(RACTuple *value) {
            NSString *error = value.first;
            if(error)
            {
                [self tip:error touch:NO];
            }
            else
            {
                [self.viewModel updateCustomerInfoDetailFirst];
            }
        }];
        return sections;
    }
    if(index==3)
    {
        ZYCustomerAccountSections *sections = [[ZYCustomerAccountSections alloc] initWithTitle:@"开户信息"];
        RACChannelTo(sections,edit) = RACChannelTo(self,edit);
        [sections blendModel:self.viewModel];
        [sections.pickerBySignalSignal subscribeNext:^(id x) {
            [self picker:x];
        }];
        [sections.nextStepSignal subscribeNext:^(RACTuple *value) {
            NSString *error = value.first;
            if(error)
            {
                [self tip:error touch:NO];
            }
            else
            {
                [self.viewModel updateCustomerInfoDetailSecond];
            }
        }];
        return sections;
    }
    if(index==4)
    {
        ZYCustomerCompanyInfoSections *sections = [[ZYCustomerCompanyInfoSections alloc] initWithTitle:@"公司信息"];
        RACChannelTo(sections,edit) = RACChannelTo(self,edit);
        [sections blendModel:self.viewModel];
        [sections.nextStepSignal subscribeNext:^(RACTuple *value) {
            NSString *error = value.first;
            if(error)
            {
                [self tip:error touch:NO];
            }
            else
            {
                [self.viewModel updateCustomerInfoDetailSecond];
            }
        }];
        return sections;
    }
    if(index==5)
    {
        ZYCustomerRelationInfoSections *sections = [[ZYCustomerRelationInfoSections alloc] initWithTitle:@"关系人信息"];
        RACChannelTo(sections,edit) = RACChannelTo(self,edit);
        [sections.pickerBySignalSignal subscribeNext:^(id x) {
            [self picker:x];
        }];
        [sections blendModel:self.viewModel];
        
        [sections.nextStepSignal subscribeNext:^(RACTuple *value) {
            NSString *error = value.first;
            if(error)
            {
                [self tip:error touch:NO];
            }
            else
            {
                [self.viewModel updateCustomerInfoDetailSecond];
            }
        }];
        return sections;
    }
    if(index==6)
    {
        ZYCustomerCreditInfoSections *sections = [[ZYCustomerCreditInfoSections alloc] initWithTitle:@"征信信息"];
        RACChannelTo(sections,edit) = RACChannelTo(self,edit);
        [sections blendModel:self.viewModel];
        [sections.datePickerSignal subscribeNext:^(RACTuple *value) {
            self.showDateBefore = ![value.second boolValue];
            firstResponderCell = (ZYSelectCell*)value.first;
            [self showDatePickerView:YES];
        }];
        [sections.nextStepSignal subscribeNext:^(RACTuple *value) {
            NSString *error = value.first;
            if(error)
            {
                [self tip:error touch:NO];
            }
            else
            {
                [self.viewModel updateCustomerInfoDetailSecond];
            }
        }];
        return sections;
    }
    return nil;
}
- (ZYSections*)sliderController:(ZYSliderViewController*)controller sectionsWithPage:(NSInteger)page
{
    return [self buildSection:page];
}
- (NSInteger)countOfControllerSliderController:(ZYSliderViewController *)controller
{
    return self.viewModel.customerDetailTabTitles.count;
}
- (CGRect)sliderController:(ZYSliderViewController*)controller frameWithPage:(NSInteger)page
{
    return CGRectMake(page*FUll_SCREEN_WIDTH, 0, FUll_SCREEN_WIDTH, FUll_SCREEN_HEIGHT-64-50);
}
- (CGRect)frameOfScrollViewSliderController:(ZYSliderViewController *)controller
{
    return CGRectMake(0, 50+64, FUll_SCREEN_WIDTH, FUll_SCREEN_HEIGHT-64-50);
}
- (UIView*)sliderController:(ZYSliderViewController *)controller customViewWithpage:(NSInteger)page
{
    return nil;
}
- (void)sliderController:(ZYSliderViewController *)controller changingPage:(NSInteger)index direction:(ZYSliderDirection)direction rate:(CGFloat)rate
{
    topBar.rate = rate;
}
- (void)sliderController:(ZYSliderViewController *)controller didChangePage:(NSInteger)index direction:(ZYSliderDirection)direction
{
    topBar.highlightIndex = index;
    
    CGPoint point = _topTabScrollView.contentOffset;
    if(index>=2&&index<steps-2)
    {
        point.x = (index-2)*stepWidth;
        [_topTabScrollView setContentOffset:point animated:YES];
    }
    else
    {
        if(index<2)
        {
            point.x = 0;
            [_topTabScrollView setContentOffset:point animated:YES];
        }
        if(index>=steps-2)
        {
            point.x = 0.5*FUll_SCREEN_WIDTH;
            [_topTabScrollView setContentOffset:point animated:YES];
        }
    }
}

@end
