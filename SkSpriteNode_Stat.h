//
//  SkSpriteNode_Stat.h
//  ninjaOri2
//
//  Created by 임태근 on 2014. 8. 28..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkSpriteNode_Stat : NSObject

@property CGFloat health;
@property CGFloat max_health;
@property CGFloat power;
@property CGFloat defense;
@property NSUInteger level;

-(void) attack: (SkSpriteNode_Stat*) counterNode;
-(void) heal ;
@end
