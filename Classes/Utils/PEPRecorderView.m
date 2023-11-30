//
//  PEPRecorderView.m
//  Player
//
//  Created by 李沛倬 on 2017/6/10.
//  Copyright © 2017年 pep. All rights reserved.
//

#import "PEPRecorderView.h"
#import "PEPAVPlayer.h"
#import "PEPPlayer.h"


@interface PEPRecorderView () <AVAudioRecorderDelegate> {
    CGFloat _length;
}

@property (weak, nonatomic) IBOutlet UIView *recorderView;

@property (weak, nonatomic) IBOutlet UIView *toolBar;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) PEPAVPlayer *player;

@property (nonatomic, strong) UIView *recordCoverView;

@property (nonatomic, strong) CAShapeLayer *recordViewLayer;

@property (nonatomic, strong) CALayer *fillLayer;

//@property (nonatomic, copy) dispatch_source_t timer;

@property (nonatomic, weak) NSTimer *timer;


@end

@implementation PEPRecorderView

#pragma mark - init

- (instancetype)init {
    NSArray *nibAry = [[UINib nibWithNibName:@"PEPRecorderView" bundle:kAssetBundle] instantiateWithOwner:nil options:nil];
    self = nibAry.firstObject;
    
    [self initSubviews];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

#pragma mark - Config

- (void)setAudioSession {
    AVAudioSession *audioSeesion = [AVAudioSession sharedInstance];
    [audioSeesion setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSeesion setActive:true error:nil];
}

- (NSURL *)getSavePath {
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:@"record.caf"];
    PZLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //设置录音格式
    [dic setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dic setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用双声道
    [dic setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dic setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dic setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    return dic;
}

- (AVAudioRecorder *)recorder {
    if (_recorder) {
        return _recorder;
    }
    
    //创建录音文件保存路径
    NSURL *url=[self getSavePath];
    //创建录音格式设置
    NSDictionary *setting=[self getAudioSetting];
    //创建录音机
    NSError *error=nil;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
    recorder.delegate=self;
    recorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
    if (error) {
        PZLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
        return nil;
    }
    
    _recorder = recorder;
    return recorder;
}

- (PEPAVPlayer *)player {
    if (_player) {
        return _player;
    }
    
    NSURL *URL = [self getSavePath];
    PEPAVPlayer *player = [PEPAVPlayer defaultPlayer];
    player.URL = URL;
    
    _player = player;
    return player;
}


- (CATransition *)recordFillLayerAnimation {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.15;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    return animation;
}


-(NSTimer *)timer{
    if (!_timer) {
        PZWeakSelf;
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:weakSelf selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

//- (void)beginTimerWithInvalidateDelay:(NSTimeInterval)delay {
//    __block NSTimeInterval cancel = delay;
//    PZWeakSelf;
//    
//    dispatch_queue_t queue = dispatch_get_main_queue();
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delay/10 * NSEC_PER_SEC, NSEC_PER_MSEC * NSEC_PER_SEC);
//    dispatch_source_set_event_handler(timer, ^{
//        cancel -= delay/10;
//        if (cancel <= 0) {
//            dispatch_source_cancel(timer);
//            [weakSelf audioPowerChange];
//        }
//    });
//    dispatch_resume(timer);
//    
//    self.timer = timer;
//}


#pragma mark - init Subviews

- (void)initSubviews {
    [self configRecordButton];
    [self configRecorderView];
    
}

- (void)configRecordButton {
    CALayer *bgLayer = [[CALayer alloc] init];
    bgLayer.frame = CGRectMake(5, 5, self.recordButton.bounds.size.width-10, self.recordButton.bounds.size.height-10);
    bgLayer.cornerRadius = bgLayer.frame.size.width / 2.0;
    bgLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.recordButton.layer addSublayer:bgLayer];
    
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = [UIColor redColor];
    coverView.userInteractionEnabled = false;
    coverView.layer.cornerRadius = self.recordButton.layer.cornerRadius - 10.0;
    coverView.layer.masksToBounds = true;
    coverView.tag = 111;
    
    [self.recordButton addSubview:coverView];
    self.recordCoverView = coverView;
    
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(coverView.superview);
        make.width.height.equalTo(coverView.superview).offset(-20.0);
    }];

}


- (void)configRecorderView {
    UIImage *image = [UIImage imageNamed:@"microphone_black" inBundle:kAssetBundle compatibleWithTraitCollection:nil];
    _length = image.size.height;
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = CGRectMake((self.recorderView.bounds.size.width - _length)/2, (self.recorderView.bounds.size.height-_length)/2, _length, _length);
    layer.contents = (__bridge id)image.CGImage;
    layer.contentsGravity = kCAGravityResizeAspect;
    
    CALayer *fillLayer = [[CALayer alloc] init];
    fillLayer.frame = CGRectMake(0, _length, _length, 0.1);
    fillLayer.masksToBounds = true;
    UIImage *fillImage = [UIImage imageNamed:@"microphone_fill" inBundle:kAssetBundle compatibleWithTraitCollection:nil];
    fillLayer.contents = (__bridge id)fillImage.CGImage;
    fillLayer.contentsGravity = kCAGravityTop;
    fillLayer.contentsScale = fillImage.scale;
    [fillLayer addAnimation:[self recordFillLayerAnimation] forKey:@"transition"];
    
    [layer addSublayer:fillLayer];
    
    [self.recorderView.layer addSublayer:layer];
    self.recordViewLayer = layer;
    self.fillLayer = fillLayer;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.recordViewLayer.frame = CGRectMake((self.recorderView.bounds.size.width - _length)/2, (self.recorderView.bounds.size.height-_length)/2, _length, _length);
    
}

#pragma mark - Actions

- (IBAction)recordButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.recorder record];
        self.timer.fireDate = [NSDate distantPast];
        
    } else {
        [self.recorder pause];
        [self.playButton setEnabled:true];
        [self resetFillLayer];
        
        self.timer.fireDate = [NSDate distantFuture];
    }
    
    UIView *coverView = [sender viewWithTag:111];
    if (!coverView) { return; }
    
    coverView.layer.cornerRadius = sender.selected ? 8.0 : self.recordButton.layer.cornerRadius - 10.0;
    [UIView animateWithDuration:0.27 animations:^{
        coverView.transform = sender.selected ? CGAffineTransformMakeScale(0.5, 0.5) : CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)playButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    [sender setTitle:sender.selected ? @"⏸" : @"▶️" forState:UIControlStateNormal];
    self.recordButton.enabled = !sender.selected;
    
    if (sender.selected) {
        [self.player play];
    } else {
        [self.player pause];
    }
    
}


- (IBAction)doneButtonAction:(UIButton *)sender {
    
    [self.recorder stop];
    if (self.recordButton.selected) {
        [self recordButtonAction:self.recordButton];
    }
    self.timer.fireDate = [NSDate distantFuture];
}


-(void)audioPowerChange {
    [self.recorder updateMeters];//更新测量值
    float power = [self.recorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress = (1.0/160.0)*(power+160.0);
    
    CGRect newFrame = CGRectMake(0, (1-progress)*_length, _length, progress*_length);
    self.fillLayer.frame = newFrame;
    [self.fillLayer displayIfNeeded];

    PZLog(@"%f", progress);
}

- (void)resetFillLayer {
    self.fillLayer.frame = CGRectMake(0, _length, _length, 0.1);
}

@end

























