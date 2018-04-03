//
//  ViewController.m
//  WKWebViewJs
//
//  Created by 王声远 on 2017/9/4.
//  Copyright © 2017年 王声远. All rights reserved.
//

#import "ViewController.h"
#import "BaseWKWebViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.backgroundColor = [UIColor orangeColor];
    [self.btn setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100)*0.5, 200, 100, 40)];
    [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn setTitle:@"调用网页" forState:UIControlStateNormal];
    self.btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.btn];
    [self.btn addTarget:self action:@selector(clickWebView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickWebView {
    BaseWKWebViewController *vc = [[BaseWKWebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
