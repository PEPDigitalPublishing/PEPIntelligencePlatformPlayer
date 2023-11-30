//
//  PEPAVPlayer.m
//  Player
//
//  Created by 李沛倬 on 2017/6/6.
//  Copyright © 2017年 pep. All rights reserved.
//

#import "PEPAVPlayer.h"
#import "PEPPlayer.h"


@implementation PEPAVPlayer

#pragma mark - Life Cycle

+ (instancetype)defaultPlayer {
    static PEPAVPlayer *player = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[PEPAVPlayer alloc] init];
    });
    
    return player;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        self.requestLoader = [[PEPPlayerRequestLoader alloc] init];
    }
    return self;
}


- (instancetype)initWithURL:(NSURL *)URL {
    PEPPlayerRequestLoader *requestLoader = [[PEPPlayerRequestLoader alloc] init];
    NSURL *newURL = [requestLoader exchangeSchemeWithURL:URL];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:newURL options:nil];
    [asset.resourceLoader setDelegate:requestLoader queue:dispatch_get_main_queue()];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    if (self = [super initWithPlayerItem:playerItem]) {
        self.requestLoader = requestLoader;
    }
    
    return self;
}

+ (instancetype)playerWithURL:(NSURL *)URL {
    return [[PEPAVPlayer alloc] initWithURL:URL];
}

- (void)setURL:(NSURL *)URL {
    if (_URL != URL) {
        _URL = URL;

        NSURL *newURL = [self.requestLoader exchangeSchemeWithURL:URL];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:newURL options:nil];
        [asset.resourceLoader setDelegate:self.requestLoader queue:dispatch_get_main_queue()];
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        [self replaceCurrentItemWithPlayerItem:playerItem];
            
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    PZLog(@"%@ Dead!", self);
}


#pragma mark - Action

- (void)registNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appDidEnterBackground:(NSNotification *)noti {
    [self pause];
}

- (void)appDidBecomeActive:(NSNotification *)noti {
    
    
}


@end
























