//
//  FormatTimeTool.m
//  Player
//
//  Created by 李沛倬 on 2017/6/5.
//  Copyright © 2017年 pep. All rights reserved.
//

#import "FormatTimeTool.h"

@implementation FormatTimeTool

+ (NSString *)getFormatedTimeStringWithCurrentTime:(CMTime)currentTime duration:(CMTime)duration {
    NSString *formatedString = @"";
    
    CGFloat durationS = CMTimeGetSeconds(duration);
    CGFloat currentS = CMTimeGetSeconds(currentTime);
    
    currentS = currentS < 0 ? 0 : (currentS > durationS ? durationS : currentS);
    
    NSString *durationText = [self formatterTimeWith:durationS];
    NSString *currentText = [self formatterTimeWith:currentS];
    
    formatedString = [NSString stringWithFormat:@"%@/%@", currentText, durationText];
    
    return formatedString;
}

+ (CGFloat)getProgressWithCurrentTime:(CMTime)currentTime duration:(CMTime)duration {
    
    CGFloat durationS = CMTimeGetSeconds(duration);
    CGFloat currentS = CMTimeGetSeconds(currentTime);
    
    currentS = currentS < 0 ? 0 : (currentS > durationS ? durationS : currentS);
    
    return currentS /durationS;
}

+ (NSString *)formatterTimeWith:(CGFloat)seconds {
    if (seconds < 0) { return @""; }
    
    NSInteger time = (NSInteger)seconds;
    
    NSString *timeString = @"";
    
    NSInteger h = time / 3600;
    NSInteger remainder = time % 3600;
    
    NSInteger min = remainder / 60;
    NSInteger s = remainder % 60;
    
    if (h > 0) {
        timeString = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", h, min, s];
    } else {
        timeString = [NSString stringWithFormat:@"%.2ld:%.2ld", min, s];
    }
    
    return timeString;
}

@end
