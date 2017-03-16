//
//  WPHTTPMonitor.m
//  Pods
//
//  Created by cui liang on 2017/3/10.
//
//
//
//
//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖镇楼                  BUG辟易
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？

#import "WPHTTPMonitor.h"

#import "WPHTTPModel.h"
#import "WPURLSessionConfiguration.h"
#import "WPHTTPModelManager.h"

#define NETWORKENABLE  @"__NetworkEnable"

@interface WPHTTPMonitor ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) WPHTTPModel *httpModel;

@end
@implementation WPHTTPMonitor

#pragma mark - public
+ (void)setEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setDouble:enabled forKey:NETWORKENABLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    WPURLSessionConfiguration * sessionConfiguration=[WPURLSessionConfiguration defaultConfiguration];
    
    if (enabled) {
        [NSURLProtocol registerClass:[WPHTTPMonitor class]];
        if (![sessionConfiguration isSwizzle]) {
            [sessionConfiguration load];
        }
    }else{
        [NSURLProtocol unregisterClass:[WPHTTPMonitor class]];
        if ([sessionConfiguration isSwizzle]) {
            [sessionConfiguration unload];
        }
    }
    
}
+ (BOOL)isEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NETWORKENABLE] boolValue];
}

#pragma mark - superclass methods
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void)load {
    
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:@"WPHTTPMonitor" inRequest:request] ) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:@"WPHTTPMonitor"
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
    self.startDate = [NSDate date];
    self.data = [NSMutableData data];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
#pragma clang diagnostic pop
    
    self.httpModel=[[WPHTTPModel alloc] init];
    self.httpModel.wp_request=self.request;
    self.httpModel.startDateString=[self stringWithDate:[NSDate date]];
    
    NSTimeInterval myID=[[NSDate date] timeIntervalSince1970];
    double randomNum=((double)(arc4random() % 100))/10000;
    self.httpModel.myID=myID+randomNum;
}

- (void)stopLoading {
    [self.connection cancel];
    self.httpModel.wp_response=(NSHTTPURLResponse *)self.response;
    self.httpModel.endDateString=[self stringWithDate:[NSDate date]];
    NSString *mimeType = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        self.httpModel.receiveJSONData = [self responseJSONFromData:self.data];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        // try to parse json if it is jsonp request
        NSString *jsonString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        // formalize string
        if ([jsonString hasSuffix:@")"]) {
            jsonString = [NSString stringWithFormat:@"%@;", jsonString];
        }
        if ([jsonString hasSuffix:@");"]) {
            NSRange range = [jsonString rangeOfString:@"("];
            if (range.location != NSNotFound) {
                range.location++;
                range.length = [jsonString length] - range.location - 2;
                jsonString = [jsonString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                self.httpModel.receiveJSONData = [self responseJSONFromData:jsonData];
            }
        }
        
    }else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]){
        NSString *xmlString = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length>0) {
            self.httpModel.receiveJSONData = xmlString;// http://webservice.webxml.com.cn/webservices/qqOnlineWebService.asmx/qqCheckOnline?qqCode=2121
        }
    }
    double flowCount=[[[NSUserDefaults standardUserDefaults] objectForKey:kFlowCount] doubleValue];
    if (!flowCount) {
        flowCount=0.0;
    }
    flowCount=flowCount+self.response.expectedContentLength/(1024.0*1024.0);
    [[NSUserDefaults standardUserDefaults] setDouble:flowCount forKey:kFlowCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[WPHTTPModelManager defaultManager] addModel:self.httpModel];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    NSString *mimeType = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        NSArray *allMapRequests = [[WPHTTPModelManager defaultManager] allMapObjects];
        for (NSInteger i=0; i < allMapRequests.count; i++) {
            WPHTTPModel *req = [allMapRequests objectAtIndex:i];
            if ([[self.httpModel.wp_request.URL absoluteString] containsString:req.mapPath]) {
                NSData *jsonData = [req.mapJSONData dataUsingEncoding:NSUTF8StringEncoding];
                [[self client] URLProtocol:self didLoadData:jsonData];
                [self.data appendData:jsonData];
                return;
                
            }
        }
    }
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

#pragma mark - Utils

-(id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        NSLog(@"JSON Parsing Error: %@", error);
        return nil;
    }
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)stringWithDate:(NSDate *)date {
    NSString *destDateString = [[WPHTTPMonitor defaultDateFormatter] stringFromDate:date];
    return destDateString;
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    });
    return staticDateFormatter;
}


@end
