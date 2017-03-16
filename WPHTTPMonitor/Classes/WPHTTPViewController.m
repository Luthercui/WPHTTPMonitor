//
//  WPHTTPViewController.m
//  Pods
//
//  Created by cui liang on 2017/3/13.
//
//

#import "WPHTTPViewController.h"

#import "WPHTTPModel.h"
#import "WPHTTPModelManager.h"
#import "WPHTTPDetailViewController.h"

@interface WPHTTPViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UIAlertViewDelegate> {
    UITableView *mainTableView;
    NSArray *httpRequests;
    UISearchBar *mySearchBar;
    UISearchDisplayController *mySearchDisplayController;
    NSArray *filterHTTPRequests;
    UILabel *titleText;
}
@end

@implementation WPHTTPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    
    mainTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64) style:UITableViewStylePlain];
    [self.view addSubview:mainTableView];
    
    titleText = [[UILabel alloc] initWithFrame: CGRectMake(([[UIScreen mainScreen] bounds].size.width-120)/2, 20, 120, 44)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor blackColor];
    titleText.textAlignment=NSTextAlignmentCenter;
    titleText.numberOfLines=0;
    [self updateTitleText];

    UINavigationBar *bar=[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 64)];
    [self.view addSubview:bar];
    bar.barTintColor=[UIColor whiteColor];
        
        
    UIButton *backBt=[UIButton buttonWithType:UIButtonTypeCustom];
    backBt.frame=CGRectMake(10, 27, 40, 30);
    [backBt setTitle:@"返回" forState:UIControlStateNormal];
    backBt.titleLabel.font=[UIFont systemFontOfSize:15];
    [backBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBt addTarget:self action:@selector(backBtAction) forControlEvents:UIControlEventTouchUpInside];
    [bar addSubview:backBt];
    
    UIButton *settingsBt=[UIButton buttonWithType:UIButtonTypeCustom];
    settingsBt.frame=CGRectMake([[UIScreen mainScreen] bounds].size.width-80, 27, 70, 30);
    [settingsBt setTitle:@"清除记录" forState:UIControlStateNormal];
    settingsBt.titleLabel.font=[UIFont systemFontOfSize:13];
    [settingsBt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [settingsBt addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [bar addSubview:settingsBt];
    
    mainTableView.frame=CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
    [bar addSubview:titleText];
    
    
    [self setupSearch];
    mainTableView.dataSource=self;
    mainTableView.delegate=self;
    httpRequests=[[[[WPHTTPModelManager defaultManager] allobjects] reverseObjectEnumerator] allObjects];
}

-(void)updateTitleText{
    double flowCount=[[[NSUserDefaults standardUserDefaults] objectForKey:kFlowCount] doubleValue];
    if (!flowCount) {
        flowCount=0.0;
    }
    UIColor *titleColor=[UIColor blackColor];
    UIFont *titleFont=[UIFont systemFontOfSize:12.0];
    UIColor *detailColor=[UIColor blackColor];
    UIFont *detailFont=[UIFont systemFontOfSize:10.0];
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"WPHTTPMonitor\n"
                                                                                    attributes:@{
                                                                                                 NSFontAttributeName : titleFont,
                                                                                                 NSForegroundColorAttributeName: titleColor
                                                                                                 }];
    
    NSMutableAttributedString *flowCountString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"流量共%.3lfMB",flowCount]
                                                                                        attributes:@{
                                                                                                     NSFontAttributeName : detailFont,
                                                                                                     NSForegroundColorAttributeName: detailColor
                                                                                                     }];
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] init];
    [attrText appendAttributedString:titleString];
    [attrText appendAttributedString:flowCountString];
    titleText.attributedText=attrText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    httpRequests=[[[[WPHTTPModelManager defaultManager] allobjects] reverseObjectEnumerator] allObjects];
    [mainTableView reloadData];
}

- (void)setupSearch {
    
    filterHTTPRequests=[[NSArray alloc] init];
    mySearchBar = [[UISearchBar alloc] init];
    
    mySearchBar.delegate = self;
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [mySearchBar sizeToFit];
    mainTableView.tableHeaderView = mySearchBar;
    mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    [mySearchDisplayController setDelegate:self];
    [mySearchDisplayController setSearchResultsDataSource:self];
    [mySearchDisplayController setSearchResultsDelegate:self];
    
}
- (void)backBtAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)rightAction{
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"清楚记录" message:@"是否清除所有记录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alertView.tag=101;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    if(alertView.tag ==101){
        if(buttonIndex==0){
            [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:kFlowCount];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[WPHTTPModelManager defaultManager] removeAllMapObjects];
            [[WPHTTPModelManager defaultManager] deleteAllItem];
            httpRequests=[[[[WPHTTPModelManager defaultManager] allobjects] reverseObjectEnumerator] allObjects];
            [self updateTitleText];
            [mainTableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource  &UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == mySearchDisplayController.searchResultsTableView) {
        return filterHTTPRequests.count;
    }
    return httpRequests.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    NSString *cellId=@"CellId";
    cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.font=[UIFont systemFontOfSize:12];
    cell.textLabel.textColor=[UIColor colorWithRed:0.24f green:0.51f blue:0.78f alpha:1.00f];
    WPHTTPModel *currenModel=[self modelForTableView:tableView atIndexPath:indexPath];
    
    cell.textLabel.text=currenModel.requestURLString;
    
    NSAttributedString *responseStatusCode;
    NSAttributedString *requestHTTPMethod;
    UIColor *titleColor=[UIColor colorWithRed:0.96 green:0.15 blue:0.11 alpha:1];
    if (currenModel.responseStatusCode == 200) {
        titleColor=[UIColor colorWithRed:0.11 green:0.76 blue:0.13 alpha:1];
    }
    UIFont *titleFont=[UIFont systemFontOfSize:12.0];
    UIColor *detailColor=[UIColor blackColor];
    UIFont *detailFont=[UIFont systemFontOfSize:12.0];
    responseStatusCode = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d   ",currenModel.responseStatusCode]
                                                                attributes:@{
                                                                             NSFontAttributeName : titleFont,
                                                                             NSForegroundColorAttributeName: titleColor
                                                                             }];
    
    requestHTTPMethod = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   %@   %@",currenModel.requestHTTPMethod,currenModel.responseMIMEType,[((WPHTTPModel *)((httpRequests)[indexPath.row])).startDateString substringFromIndex:5]]
                                                               attributes:@{
                                                                            NSFontAttributeName : detailFont,
                                                                            NSForegroundColorAttributeName: detailColor
                                                                            }];
    NSMutableAttributedString *detail=[[NSMutableAttributedString alloc] init];
    [detail appendAttributedString:responseStatusCode];
    [detail appendAttributedString:requestHTTPMethod];
    cell.detailTextLabel.attributedText=detail;
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WPHTTPDetailViewController *detail = [[WPHTTPDetailViewController alloc] init];
    detail.model = [self modelForTableView:tableView atIndexPath:indexPath];
    [self presentViewController:detail animated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([self.navigationController viewControllers].count>0) {
        return YES;
    }
    [UIView animateWithDuration:0.2 animations:^{
        mainTableView.frame = CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20);
        
    }];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([self.navigationController viewControllers].count>0) {
        return YES;
    }
    if (searchBar.text.length<1) {
        [UIView animateWithDuration:0.2 animations:^{
            mainTableView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
        }];
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.navigationController viewControllers].count>0) {
        return ;
    }
    [UIView animateWithDuration:0.2 animations:^{
        mainTableView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
    }];
}
#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self updateSearchResultsWithSearchString:searchString];
    return YES;
}

- (void)updateSearchResultsWithSearchString:(NSString *)searchString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *tempFilterHTTPRequests = [httpRequests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(WPHTTPModel *httpRequest, NSDictionary *bindings) {
            return [[NSString stringWithFormat:@"%@ %d %@ %@",httpRequest.requestURLString,httpRequest.responseStatusCode,httpRequest.requestHTTPMethod,httpRequest.responseMIMEType] rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0;
        }]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([mySearchDisplayController.searchBar.text isEqual:searchString]) {
                filterHTTPRequests = tempFilterHTTPRequests;
                [mySearchDisplayController.searchResultsTableView reloadData];
            }
        });
    });
}


#pragma mark - private methods
- (WPHTTPModel *)modelForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    WPHTTPModel *currenModel=[[WPHTTPModel alloc] init];
    if (tableView == mySearchDisplayController.searchResultsTableView) {
        currenModel=(WPHTTPModel *)((filterHTTPRequests)[indexPath.row]);
    }else{
        currenModel=(WPHTTPModel *)((httpRequests)[indexPath.row]);
    }
    return currenModel;
}


@end
