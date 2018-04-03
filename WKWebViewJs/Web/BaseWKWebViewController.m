//
//  BaseWKWebViewController.m
//  Tronker
//
//  Created by soffice-Jimmy on 2017/4/12.
//  Copyright © 2017年 Shenzhen Soffice Software. All rights reserved.
//

#import "BaseWKWebViewController.h"
#import <WebKit/WebKit.h>
#import "UIViewController+NavigationTool.h"
#import "WeakScriptMessageDelegate.h"

#define WEAKSELF typeof(self) __weak weakSelf = self;
#define phoneWidth  [[UIScreen mainScreen] bounds].size.width
#define phoneHeight [[UIScreen mainScreen] bounds].size.height

#define FILEString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#ifdef DEBUG
#define DLog(...) printf("%s 第%d行: %s\n", [FILEString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define DLog(...)
#endif

@interface BaseWKWebViewController() <WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) WKWebView                 *wkwebView;
@property (strong, nonatomic) WKUserContentController   *userContentController;

//进度条
@property (strong, nonatomic) CAGradientLayer    *changeColorLayer;
@property (strong, nonatomic) NSArray               *jsMethodArray;

@end

@implementation BaseWKWebViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    WEAKSELF
    [self addNavigationLeft:nil clickBlock:^{
        if ([weakSelf.wkwebView canGoBack]) {
            [weakSelf.wkwebView goBack];
        }else{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [self.view.layer addSublayer:self.changeColorLayer];
    [self initWKWebView];
    
    [self addNavigationRight:@"JsMethod" clickBlock:^{
        [weakSelf runJs:@"alertMyName('苹果原生发过来的消息')" handler:^(id _Nullable i, NSError * _Nullable error) {
            DLog(@"error: %@ - %@",error,i);
        }];
    }];
    
//    [self addNavigationRight:@"RunJs" clickBlock:^{
//        [weakSelf runJs:@"window.webkit.messageHandlers.gotoLogin.postMessage({'sex':'mens','name':'wangshengyuans'});" handler:nil];
//    }];
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
    
    [self.wkwebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];//注册observer 拿到加载进度
    [self.wkwebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];//注册observer 拿到标题
    [self request];
}

- (void)dealloc
{
    for (NSString *jsMethod in self.jsMethodArray) {
        [[self.wkwebView configuration].userContentController removeScriptMessageHandlerForName:jsMethod];
    }
    [self.wkwebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkwebView removeObserver:self forKeyPath:@"title"];
}

// 监听事件处理进度和网页标题
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if([keyPath isEqualToString:@"estimatedProgress"]){
        self.changeColorLayer.hidden = NO;
        CGFloat  progress = [change[@"new"] floatValue];
        DLog(@"progress >> %f",progress);
        self.changeColorLayer.frame = CGRectMake(0, 64, phoneWidth * progress,  4);
        if (progress == 1.0) {
            self.changeColorLayer.hidden =YES;
        }
    } else if ([keyPath isEqualToString:@"title"]){
        DLog(@"title >> %@  --  %@",self.wkwebView.title,change[@"new"]);
        
        NSString *title = [NSString stringWithFormat:@"%@", change[@"new"]];
        [self addNavigationTitle:title];
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 刷新
- (void)request
{
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
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
    
    DLog(@"js调用的oc方法了: \n 参数名=%@\n 参数body=%@",message.name, message.body);

    NSDictionary *dict = message.body;
    if (dict == nil) {
        return;
    }
    
    NSMutableString *str = [[NSMutableString alloc] init];
    for (NSString *key in dict) {
        [str appendString:[NSString stringWithFormat:@"%@ > %@",key,dict[key]]];
        [str appendString:@"\n"];
    }
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:message.name message:str preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
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
    [self.activityIndicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    DLog(@"页面加载完成 url = %@", self.wkwebView.URL.absoluteString);
    [self.activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    DLog(@"页面加载失败 Url = %@", webView.URL.absoluteString);
    [self.activityIndicator stopAnimating];
}

#pragma mark - Getter

- (CAGradientLayer *)changeColorLayer{
    if (!_changeColorLayer) {
        _changeColorLayer = [CAGradientLayer layer];
        _changeColorLayer.frame = CGRectMake(0, 64, 0, 4);
        _changeColorLayer.startPoint = CGPointMake(0, 1);
        _changeColorLayer.endPoint   = CGPointMake(1, 1);
        _changeColorLayer.colors     = @[(__bridge id)[UIColor orangeColor].CGColor,
                                         (__bridge id)[UIColor redColor].CGColor];
    }
    return _changeColorLayer;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        _activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
        [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:_activityIndicator];
    }
    return _activityIndicator;
}

- (void)runJs:(NSString *)js handler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler
{
    [self.wkwebView evaluateJavaScript:js completionHandler:completionHandler];
}

@end

