//
//  PEPAVPlayer.h
//  Player
//
//  Created by 李沛倬 on 2017/6/6.
//  Copyright © 2017年 pep. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PEPPlayerRequestLoader.h"

@interface PEPAVPlayer : AVPlayer

@property (nonatomic, strong) PEPPlayerRequestLoader *requestLoader;

@property (nonatomic, strong) NSURL *URL;

+ (instancetype)defaultPlayer;

- (instancetype)initWithURL:(NSURL *)URL;

+ (instancetype)playerWithURL:(NSURL *)URL;


@end
