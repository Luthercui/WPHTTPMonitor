//
//  WPHTTPModel.m
//  Pods
//
//  Created by cui liang on 2017/3/10.
//
//

#import "WPHTTPModel.h"

@implementation WPHTTPModel
@synthesize wp_request,wp_response;

-(void)setWp_request:(NSURLRequest *)wp_request_new{
    wp_request=wp_request_new;
    self.requestURLString=[wp_request.URL absoluteString];
    
    switch (wp_request.cachePolicy) {
        case 0:
            self.requestCachePolicy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 1:
            self.requestCachePolicy=@"NSURLRequestReloadIgnoringLocalCacheData";
            break;
        case 2:
            self.requestCachePolicy=@"NSURLRequestReturnCacheDataElseLoad";
            break;
        case 3:
            self.requestCachePolicy=@"NSURLRequestReturnCacheDataDontLoad";
            break;
        case 4:
            self.requestCachePolicy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 5:
            self.requestCachePolicy=@"NSURLRequestReloadRevalidatingCacheData";
            break;
        default:
            self.requestCachePolicy=@"";
            break;
    }
    
    self.requestTimeoutInterval=[[NSString stringWithFormat:@"%.1lf",wp_request.timeoutInterval] doubleValue];
    self.requestHTTPMethod=wp_request.HTTPMethod;
    
    for (NSString *key in [wp_request.allHTTPHeaderFields allKeys]) {
        self.requestAllHTTPHeaderFields=[NSString stringWithFormat:@"%@%@:%@\n",self.requestAllHTTPHeaderFields,key,[wp_request.allHTTPHeaderFields objectForKey:key]];
    }
    if (self.requestAllHTTPHeaderFields.length>1) {
        if ([[self.requestAllHTTPHeaderFields substringFromIndex:self.requestAllHTTPHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.requestAllHTTPHeaderFields=[self.requestAllHTTPHeaderFields substringToIndex:self.requestAllHTTPHeaderFields.length-1];
        }
    }
    if (self.requestAllHTTPHeaderFields.length>6) {
        if ([[self.requestAllHTTPHeaderFields substringToIndex:6] isEqualToString:@"(null)"]) {
            self.requestAllHTTPHeaderFields=[self.requestAllHTTPHeaderFields substringFromIndex:6];
        }
    }
    
    if ([wp_request HTTPBody].length>512) {
        self.requestHTTPBody=@"requestHTTPBody too long";
    }else{
        self.requestHTTPBody=[[NSString alloc] initWithData:[wp_request HTTPBody] encoding:NSUTF8StringEncoding];
    }
    if (self.requestHTTPBody.length>1) {
        if ([[self.requestHTTPBody substringFromIndex:self.requestHTTPBody.length-1] isEqualToString:@"\n"]) {
            self.requestHTTPBody=[self.requestHTTPBody substringToIndex:self.requestHTTPBody.length-1];
        }
    }
    
}

- (void)setWp_response:(NSHTTPURLResponse *)wp_response_new {
    
    wp_response=wp_response_new;
    
    self.responseMIMEType=@"";
    self.responseExpectedContentLength=@"";
    self.responseTextEncodingName=@"";
    self.responseSuggestedFilename=@"";
    self.responseStatusCode=200;
    self.responseAllHeaderFields=@"";
    
    self.responseMIMEType=[wp_response MIMEType];
    self.responseExpectedContentLength=[NSString stringWithFormat:@"%lld",[wp_response expectedContentLength]];
    self.responseTextEncodingName=[wp_response textEncodingName];
    self.responseSuggestedFilename=[wp_response suggestedFilename];
    self.responseStatusCode=(int)wp_response.statusCode;
    
    for (NSString *key in [wp_response.allHeaderFields allKeys]) {
        NSString *headerFieldValue=[wp_response.allHeaderFields objectForKey:key];
        if ([key isEqualToString:@"Content-Security-Policy"]) {
            if ([[headerFieldValue substringFromIndex:12] isEqualToString:@"'none'"]) {
                headerFieldValue=[headerFieldValue substringToIndex:11];
            }
        }
        self.responseAllHeaderFields=[NSString stringWithFormat:@"%@%@:%@\n",self.responseAllHeaderFields,key,headerFieldValue];
        
    }
    
    if (self.responseAllHeaderFields.length>1) {
        if ([[self.responseAllHeaderFields substringFromIndex:self.responseAllHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.responseAllHeaderFields=[self.responseAllHeaderFields substringToIndex:self.responseAllHeaderFields.length-1];
        }
    }
    
}
@end
