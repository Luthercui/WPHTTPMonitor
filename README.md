# WPHTTPMonitor

[![CI Status](http://img.shields.io/travis/luther.cui@gmail.com/WPHTTPMonitor.svg?style=flat)](https://travis-ci.org/luther.cui@gmail.com/WPHTTPMonitor)
[![Version](https://img.shields.io/cocoapods/v/WPHTTPMonitor.svg?style=flat)](http://cocoapods.org/pods/WPHTTPMonitor)
[![License](https://img.shields.io/cocoapods/l/WPHTTPMonitor.svg?style=flat)](http://cocoapods.org/pods/WPHTTPMonitor)
[![Platform](https://img.shields.io/cocoapods/p/WPHTTPMonitor.svg?style=flat)](http://cocoapods.org/pods/WPHTTPMonitor)

WPHTTPMonitor是一个网络调试库，可以监控App内HTTP请求并显示请求相关的详细信息，方便App开发的网络调试。
可以检测到包括网页，NSURLConnection,NSURLSession，AFNetworking,第三方库，第三方SDK等的HTTP请求，非常方便实用。并且可以统计App内流量。

## 用例

To run the example project, clone the repo, and run `pod install` from the Example directory first.
## 使用
注意请在DEBUG模式下使用WPHTTPMonitor
在AppDelegate.m里面加入下面代码就可以了
<pre>
#if defined(DEBUG)||defined(_DEBUG)
[WPHTTPMonitor setEnabled:YES];
#endif
</pre>
<pre>
显示详细界面
#if defined(DEBUG)||defined(_DEBUG)
WPHTTPViewController *vc=[[WPHTTPViewController alloc] init];
[self presentViewController:vc animated:YES completion:nil];
#endif
</pre>

## Podfile

```ruby
pod 'WPHTTPMonitor', '~> 1.3.0'
```
