//
//  ViewController.m
//  WKWebViewJs
//
//  Created by 王声远 on 2017/9/4.
//  Copyright © 2017年 王声远. All rights reserved.
//

#import "ViewController.h"
#import "BaseWKWebViewController.h"
#import "STKBaseWKWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-200)*0.5, 200, 200, 40)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"JS和原生通用交互" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(clickWebView) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *fbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fbtn.backgroundColor = [UIColor orangeColor];
    [fbtn setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-200)*0.5, CGRectGetMaxY(btn.frame)+30, 200, 40)];
    [fbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fbtn setTitle:@"WebViewJS架构交互" forState:UIControlStateNormal];
    fbtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:fbtn];
    [fbtn addTarget:self action:@selector(fBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickWebView {
    BaseWKWebViewController *vc = [[BaseWKWebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fBtnClick {
    STKBaseWKWebViewController *vc = [[STKBaseWKWebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
