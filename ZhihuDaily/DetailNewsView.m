//
//  DetailNewsView.m
//  ZhihuDaily
//
//  Created by 钟武 on 16/8/10.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "DetailNewsView.h"
#import "DetailNewsHeaderView.h"
#import "DetailNewsResponseModel.h"
#import "NewsDetailViewController.h"

#define DetailHeaderViewHeight 190.0f

@interface DetailNewsView () <UIScrollViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) DetailNewsHeaderView *headerView;
@property (nonatomic, strong) DetailNewsResponseModel *newsModel;
@property (nonatomic, strong) UILabel *nextLabel;

@end

@implementation DetailNewsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    
    return self;
}

- (void)initUI{
    self.webView = [UIWebView new];
    _webView.scrollView.delegate = self;
    _webView.scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_webView];
    
    [_webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    
    self.headerView = [[DetailNewsHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, DetailHeaderViewHeight)];
    [_webView.scrollView addSubview:_headerView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.center = CGPointMake(kScreenWidth/2, -20);
    [label setText:@"载入上一篇"];
    [_webView.scrollView addSubview:label];
    
    self.nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    _nextLabel.center = CGPointMake(kScreenWidth/2, kScreenHeight + 20);
    [_nextLabel setText:@"载入下一篇"];
    [_webView.scrollView addSubview:_nextLabel];
    
    _webView.delegate = self;
}

- (void)updateNewsWithModel:(DetailNewsResponseModel *)model{
    if ([model isEqual:_newsModel] || !model) {
        return;
    }
    
    self.newsModel = model;
    
    [_webView loadHTMLString:[NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" href=%@></head><body>%@</body></html>",[model.css firstObject],model.body] baseURL:nil];
    [_headerView updateNewsWithModel:model];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset = scrollView.contentOffset.y;
    if (yOffset <= 0) {
        CGRect f = _headerView.frame;
        f.origin.y = yOffset;
        f.size.height = DetailHeaderViewHeight - yOffset;
        _headerView.frame = f;
        
        if (yOffset < -40) {
            [scrollView setContentOffset:CGPointMake(0, -40) animated:NO];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat yoffset = scrollView.contentOffset.y;
    
    if (yoffset <= -40) {
        if ([self.delegate respondsToSelector:@selector(switchToPreviousNews)]) {
            [self.delegate switchToPreviousNews];
        }
    }
    else if (yoffset + kScreenHeight - 35 >= scrollView.contentSize.height + 40){
        if ([self.delegate respondsToSelector:@selector(switchToNextNews)]) {
            [self.delegate switchToNextNews];
        }
    }
}

- (void)dealloc{
    DDLogDebug(@"DetailNewsView dealloc");
    _webView.delegate = nil;
    _webView = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    _nextLabel.center = CGPointMake(kScreenWidth/2, webView.scrollView.contentSize.height + 20);
}

@end