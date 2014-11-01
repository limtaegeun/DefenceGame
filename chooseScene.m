//
//  chooseScene.m
//  ninjaOri2
//
//  Created by 임태근 on 2014. 9. 15..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import "chooseScene.h"
#import "NinjaOriScene.h"

@interface chooseScene ()

@property int choosePlant;
@property int chooseMap;

@end

typedef NS_ENUM(int, Plant)
{
    PlantTree
    
    
};

typedef NS_ENUM(int, Map)
{
    tropics
    
    
};

@implementation chooseScene
{
    SKSpriteNode* _1Btn;
    SKSpriteNode* _2Btn;
    SKSpriteNode* _3Btn;
    SKSpriteNode* _4Btn;
    SKSpriteNode* _gameBtn;
    CGSize _size;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        _size = size;
        [self setButton];
    }
    
    return self;
}

-(void) setButton
{
    _1Btn = [SKSpriteNode spriteNodeWithImageNamed:@"button_item1.png"];
    _1Btn.size = CGSizeMake(50, 50);
    _1Btn.position = CGPointMake(_size.height/3, _size.width/2);
    [self addChild:_1Btn];
    
    _2Btn = [SKSpriteNode spriteNodeWithImageNamed:@"button_item2.png"];
    _2Btn.size = CGSizeMake(50, 50);
    _2Btn.position = CGPointMake(_size.height/1.5, _size.width/2);
    [self addChild:_2Btn];
    
    _3Btn = [SKSpriteNode spriteNodeWithImageNamed:@"button_item3.png"];
    _3Btn.size = CGSizeMake(50, 50);
    _3Btn.position = CGPointMake(_size.height/3, _size.width/4);
    [self addChild:_3Btn];
    
    _4Btn = [SKSpriteNode spriteNodeWithImageNamed:@"button_item4.png"];
    _4Btn.size = CGSizeMake(50, 50);
    _4Btn.position = CGPointMake(_size.height/1.5,_size.width/4);
    [self addChild:_4Btn];
    
    _gameBtn = [SKSpriteNode spriteNodeWithImageNamed:@"button_plus_leaf.png"];
    _gameBtn.size = CGSizeMake(50, 50);
    _gameBtn.position = CGPointMake(_size.width - _gameBtn.size.width/2 - 50,
                                    _gameBtn.size.height/2 + 50);
    
    [self addChild:_gameBtn];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        
        
        if ([_1Btn containsPoint:location]) {
            
            if (_choosePlant == 0) {
                _2Btn.texture = [SKTexture  textureWithImageNamed:@"button_item2.png"];
            }
            
            _1Btn.texture = [SKTexture  textureWithImageNamed:@"button_item1_on.png"];
            _choosePlant = PlantTree;
            
            
            
        }
        
        if ([_2Btn containsPoint:location]) {
            
            if (_choosePlant == 0) {
                _1Btn.texture = [SKTexture  textureWithImageNamed:@"button_item1.png"];
            }
            
            _2Btn.texture = [SKTexture textureWithImageNamed:@"button_item2_on.png"];
            _choosePlant = PlantTree;
            
        }
        
        if ([_3Btn containsPoint:location]) {
            
            if (_choosePlant == 0) {
                _4Btn.texture = [SKTexture  textureWithImageNamed:@"button_item4.png"];
            }
            
            _3Btn.texture = [SKTexture textureWithImageNamed:@"button_item3_on.png"];
            _chooseMap = tropics;
            
            
            
        }
        
        if ([_4Btn containsPoint:location]) {
            
            if (_choosePlant == 0) {
                _3Btn.texture = [SKTexture  textureWithImageNamed:@"button_item3.png"];
            }
            
            _4Btn.texture = [SKTexture textureWithImageNamed:@"button_item4_on.png"];
            _chooseMap = tropics;
            
            
        }
        
        
        if ([_gameBtn containsPoint:location]) {
            SKScene* GameScene = [NinjaOriScene sceneWithSize:self.size];
            GameScene.scaleMode = SKSceneScaleModeAspectFill;
            
            
            
            SKTransition* move = [SKTransition moveInWithDirection:SKTransitionDirectionDown duration:1];
            
            [self.view presentScene:GameScene transition:move];
        }
        
        
    }

}



@end
