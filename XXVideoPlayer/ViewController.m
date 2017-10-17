//
//  ViewController.m
//  XXVideoPlayer
//
//  Created by summerxx on 16/10/19.
//  Copyright © 2016年 summerxx. All rights reserved.
//

#import "ViewController.h"
#import "XTVideoPlayerViewController.h"
@interface ViewController ()
@property (nonatomic, strong) XTVideoPlayerViewController *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPlay.frame = CGRectMake(0, 20, 88, 88);
    btnPlay.backgroundColor = [UIColor blueColor];
    [btnPlay setTitle:@"play video" forState:UIControlStateNormal];
    [btnPlay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPlay addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    btnPlay.center = self.view.center;
    [self.view addSubview:btnPlay];
    
}


- (void)playVideo
{
    // http://cntv.hls.cdn.myqcloud.com/asp/hls/450/0303000a/3/default/6bf196011e874904ab5a35d8022b2142/450.m3u8
    // http://krtv.qiniudn.com/150522nextapp
    // http://112.74.218.80//gcrcsUploadFile/2016/11/15/094231/%E6%9C%89%E7%82%B9%E7%94%9C.mp3
    NSURL *videoURL = [NSURL URLWithString:@"http://flv2.bn.netease.com/tvmrepo/2017/3/K/I/ECF9KFDKI/SD/ECF9KFDKI-mobile.mp4"];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.player = [[XTVideoPlayerViewController alloc] initWithFrame:CGRectMake(0, 0, width, width * 9.0 / 16.0) playFormURL:videoURL];
    __weak typeof(self)weakSelf = self;
    self.player.dismissCompleteBlock = ^(){
        weakSelf.player = nil;
    };
    [self.player xx_ShowInWindow];
    [self.player xx_VideoPlay];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
