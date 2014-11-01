//
//  progressBar.h
//  ninjaOri2
//
//  Created by 임태근 on 2014. 8. 22..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface progressBar : SKCropNode

-(id)init;
-(void)setTextureWithImageNamed:(NSString*)name;
-(void) setProgress:(CGFloat)progress;


@end