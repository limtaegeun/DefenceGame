//
//  progressBar.m
//  ninjaOri2
//
//  Created by 임태근 on 2014. 8. 22..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import "progressBar.h"

@implementation progressBar

-(id)init
{
    if (self = [super init]) {
        self.maskNode = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(300 ,20 )];
    }
    return self;
}

-(void)setTextureWithImageNamed:(NSString *)name
{
    SKSpriteNode * sprite = [SKSpriteNode spriteNodeWithImageNamed:name];
    sprite.size = CGSizeMake(300, 20);
    sprite.anchorPoint = CGPointMake(0.0, 0.5);
    [self addChild:sprite];
    
}

-(void) setProgress:(CGFloat)progress
{
    self.maskNode.xScale = progress*2;
}
@end
