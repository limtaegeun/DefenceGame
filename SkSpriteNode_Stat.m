//
//  SkSpriteNode_Stat.m
//  ninjaOri2
//
//  Created by 임태근 on 2014. 8. 28..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import "SkSpriteNode_Stat.h"

@implementation SkSpriteNode_Stat

    


-(void) attack: (SkSpriteNode_Stat*)counterNode
{
    if (counterNode.defense >= self.power) {
        
        //miss effect
        NSLog(@"miss");
        return;
    }
    
    counterNode.health -=  self.power - counterNode.defense;
}

-(void) heal
{
    self.health = self.max_health;
}

@end
