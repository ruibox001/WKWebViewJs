//
//  STKBaseWKWebViewController.m
//  WKWebViewJs
//
//  Created by 王声远 on 2018/8/25.
//  Copyright © 2018年 王声远. All rights reserved.
//

#import "STKBaseWKWebViewController.h"
#import <WebKit/WebKit.h>
#import "UIViewController+NavigationTool.h"
#import "WeakScriptMessageDelegate.h"
#import "JSBase.h"

#define WEAKSELF typeof(self) __weak weakSelf = self;
#define phoneWidth  [[UIScreen mainScreen] bounds].size.width
#define phoneHeight [[UIScreen mainScreen] bounds].size.height

#define FILEString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#ifdef DEBUG
#define DLog(...) printf("%s 第%d行: %s\n", [FILEString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define DLog(...)
#endif

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface STKBaseWKWebViewController() <WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (strong, nonatomic) WKWebView                 *wkwebView;
@property (strong, nonatomic) WKUserContentController   *userContentController;
@property (strong, nonatomic) NSArray                   *jsMethodArray;

@end

@implementation STKBaseWKWebViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self addNavigationTitle:@"交互范例"];
    
    WEAKSELF
    [self addNavigationLeft:@"Back" clickBlock:^{
        if ([weakSelf.wkwebView canGoBack]) {
            [weakSelf.wkwebView goBack];
        }else{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [self initWKWebView];
    
    [self addNavigationLeft:@"CallJs" clickBlock:^{
        [weakSelf runJs:@"callBackFunc({'msg':'原色执行完成回调JS','code':'200'})" handler:^(id _Nullable i, NSError * _Nullable error) {
            DLog(@"native call js finish callback: error=%@ - obj=%@",error,i);
        }];
    }];
    
}

- (void)initWKWebView{
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    self.jsMethodArray = @[@"jsControl"];
    
    //注册供js调用的方法
    _userContentController = [[WKUserContentController alloc] init];
    
    // 必须使用 STKWeakScriptMessageDelegate 弱化,否则会不释放
    for (NSString *jsMethod in self.jsMethodArray) {
        [_userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:jsMethod];
    }
    
    configuration.userContentController = _userContentController;
    configuration.preferences.javaScriptEnabled = YES;
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    // 测试嵌入JS
    //    WKUserScript *script = [[WKUserScript alloc] initWithSource:@"var param = {'key':'value'}; if(window.webkit){window.alert('test alert'); window.webkit.messageHandlers.gotoLogin.postMessage(param)}" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    //    [_userContentController addUserScript:script];
    
    self.wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, phoneWidth, phoneHeight) configuration:configuration];
    self.wkwebView.backgroundColor = [UIColor clearColor];
    self.wkwebView.UIDelegate = self;
    self.wkwebView.navigationDelegate = self;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        self.wkwebView.allowsLinkPreview = YES; //允许预览链接
    }
    
    [self.view addSubview:self.wkwebView];
    [self request];
}

- (void)dealloc
{
    for (NSString *jsMethod in self.jsMethodArray) {
        [[self.wkwebView configuration].userContentController removeScriptMessageHandlerForName:jsMethod];
    }
}

// 刷新
- (void)request
{
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"normal" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:urlStr encoding:NSUTF8StringEncoding error:nil];
    [self.wkwebView loadHTMLString:html baseURL:nil];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    DLog(@"Url = %@", webView.URL.absoluteString);
    DLog(@"navigationActionUrl = %@", navigationAction.request.URL.absoluteString);
    decisionHandler(WKNavigationActionPolicyAllow);
}

//接收到服务器响应 后决定是否允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    DLog(@"接收到响应后 allow 跳转 Url = %@", self.wkwebView.URL.absoluteString);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKScriptMessageHandler

//实现注册的供js调用的oc方法 （如果这里没调用，请检查后台JS window.webkit.messageHandlers.调用名称.postMessage是否调用）
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    DLog(@"js调用的原生方法了: \n 控制手柄=%@\n 参数=%@",message.name, message.body);
    
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary* dic = message.body;
        if (!dic || !dic.allKeys || dic.allKeys.count == 0) {
            return;
        }
        NSString* className = [dic objectForKey:classNameKey];
        NSString* functionName = [[dic objectForKey:funcNameKey] stringByAppendingFormat:@":"];
        NSDictionary *p = [dic objectForKey:parameterKey];
        NSString* callBackFunc = [dic objectForKey:callBackFuncKey];
        
        Class cls = NSClassFromString(className);
        if (!cls) {
            DLog(@"找不到实现的类: %@",className);
            return;
        }
        
        SEL functionSelector = NSSelectorFromString(functionName);
        if (!functionSelector) {
            DLog(@"找不到方法: %@",functionName);
            return;
        }
        
        NSObject* obj = [[cls alloc] init];
        if (![obj respondsToSelector:functionSelector]) {
            DLog(@"在[%@]中找不到实现的方法: %@",className,functionName);
            return;
        }
        
        if ([obj isKindOfClass:[JSBase class]]) {
            JSBase *jsbase = (JSBase *)obj;
            jsbase.webView = self.wkwebView;
            jsbase.callBackFunc = callBackFunc;
            jsbase.className = className;
            jsbase.functionName = functionName;
        }
        
        SuppressPerformSelectorLeakWarning(
            [obj performSelector:functionSelector withObject:p];
        );
    
    }
}

//兼容alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    DLog(@"页面加载开始 url = %@", self.wkwebView.URL.absoluteString);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    DLog(@"页面加载完成 url = %@", self.wkwebView.URL.absoluteString);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    DLog(@"页面加载失败 Url = %@", webView.URL.absoluteString);
}

- (void)runJs:(NSString *)js handler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler
{
    [self.wkwebView evaluateJavaScript:js completionHandler:completionHandler];
}

@end
