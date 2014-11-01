//
//  NinjaOriScene.m
//  ninjaOri
//
//  Created by 임태근 on 2014. 8. 6..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import "NinjaOriScene.h"
#import "progressBar.h"
#import "SKNode+SKTDebugDraw.h"
#import "SkSpriteNode_Stat.h"
#import "chooseScene.h"


#define kSynthesisName @"sysnthesisHud"
#define kWaterName @"waterHud"
#define kSynthesisBar @"synthesisBar"
#define kWaterBar @"waterBar"
#define kFlyTrapName @"flyTrapNode"

#define kinformationName @"information"
//species
#define kCarnivoreName @"carnivoreNode"
#define kHerbivoreName @"herbivoreNode"
//동물 이름
#define kpikachuName @"pikachu"
#define kpikachuAtlas @"pikachuAtlas"
#define kpairiName @"pairi"

typedef NS_ENUM(int, layer)
{
    LayerBackground,
    LayerForeground,
    LayerEnermy,
    layerTree,
    layerEffect,
    LayerButton,
    LayerHud
};

typedef NS_OPTIONS(int, EntityCategory) {
    
    EntityCategoryTree = 0x1   <<0,
    EntityCategoryBugs = 0x1   <<1,
    EntityCategoryHerbivore =0x1  <<2,
    EntityCategoryCarnivore = 0x1 <<3,
    EntityCategoryGround =0x1  <<4,
    EntityCategoryTrap = 0x1   <<5,
    EntityCategoryFireBall = 0x1 <<6
};

@interface NinjaOriScene ()

@property BOOL sceneCreated;
@property NSArray *texture_Ani;
@property NSTimeInterval timeOfLast;
@property NSTimeInterval delay;
@property CGFloat synthesisValue;
@property CGFloat waterValue;
@property CGFloat synthesis_Max;
@property CGFloat water_Max;

@property SKSpriteNode* treeNode;
@property SKSpriteNode* badakNode;


@end


@implementation NinjaOriScene
{
    
    CGSize  _size;
    
    //버튼 노드
    SKSpriteNode* _plusLeafBtn;
    SKSpriteNode* _plusWaterBtn;
    SKSpriteNode* _GrowthBtn;
    SKSpriteNode* _shopBtn;
    SKSpriteNode* _item1Btn;
    SKSpriteNode* _item2Btn;
    SKSpriteNode* _item3Btn;
    SKSpriteNode* _item4Btn;
    //노드
    SKSpriteNode* _flyTrapNode;
    SKSpriteNode* _background;
    
    SKSpriteNode* _fireBall;
    
    //적
    SKSpriteNode* _bugsNode;
    SKSpriteNode* _herbivoreNode;
    SKSpriteNode* _carnivoreNode;
    
    NSUInteger _click;
    CGFloat _sWeight , _sPoints;
    CGFloat _wWeight , _wPoints;
    
    //스텟
    SkSpriteNode_Stat* _treeStat;
    SkSpriteNode_Stat* _herbiStat;
    SkSpriteNode_Stat* _carniStat;
    SkSpriteNode_Stat* _fireballStat;
    
    //레벨
    NSUInteger _flyTrapLev;
    int _level;
    
    //각종 frag
    
    BOOL _btn_swc;
    
    
    
}

-(void)didMoveToView:(SKView *)view
{
    
    
}

-(id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        
        
        //setup scene
        _size = size;
        
#pragma mark - setting
        // 변수 설정
        _sWeight = _wWeight= _sPoints = 1.0;
        _wPoints = -1.0;
        self.timeOfLast =0.0;
        self.delay = 1.0;
        _waterValue = 100.0;
        _synthesis_Max = _water_Max = 100.0;
        
        NSLog(@"SKScene : initWithSize %f x %f",size.width,size.height);
        
        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFill;
        // hud setting
        [self setupHud];
        
        [self createBar];
        
        //button setting
        
        [self setUpButton];
        
        
        // physicsworld setting
        self.physicsWorld.contactDelegate = self;
        
        
        
        
        
        //가이드라인
        //self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        // 바닥생성
        _badakNode = [self createBadak];
        _badakNode.position = CGPointMake(CGRectGetMidX(self.frame),
                                        _badakNode.size.height/2   );
        [self addChild:_badakNode];
        
        [_badakNode skt_attachDebugRectWithSize:CGSizeMake(_size.width, 10) color:[SKColor redColor]];
        //background
        
        _background = [self createBackground];
        _background.position = CGPointMake(_size.width/2, _size.height/2);
        [self addChild:_background];
        //반딧불
        
        NSString *fireflyPath = [[NSBundle mainBundle]
                                 pathForResource:@"fireflies"
                                 ofType:@"sks"];
        SKEmitterNode *fireflyNode = [NSKeyedUnarchiver unarchiveObjectWithFile:fireflyPath];
        
        fireflyNode.position = CGPointMake(_badakNode.position.x
                                           ,_badakNode.position.y  * 1.5);
        fireflyNode.zPosition = layerEffect;
        [self addChild:fireflyNode];

        //나무 생성
        _treeNode = [self createTreeNode];
        
        _treeNode.position = CGPointMake(CGRectGetMinX(self.frame)+55,
                                          + 50 + _treeNode.size.height/2);
        
        [self addChild:_treeNode];
        
        [self texture_Animation:@"sprout" Format:@"sprout%03d"];
        
        [_treeNode skt_attachDebugRectWithSize:_treeNode.size color:[SKColor redColor]];
       
        
        // 나루토가 서잇을 때 움직이는 에니메이션
        if (_treeNode != nil) {
            SKAction *tree_standAnimate = [SKAction animateWithTextures:self.texture_Ani timePerFrame:0.15];
            [_treeNode runAction:[SKAction repeatActionForever:tree_standAnimate] withKey:@"sproutAtlas"];
        }
        
        //create bug
        
        _bugsNode = [self creatbugs];
        
        
    }
    return self;

}

#pragma mark - Node
// 나무 생성
-(SKSpriteNode*)createTreeNode
{
    SKSpriteNode* treeNode = [[SKSpriteNode  alloc]
                                initWithImageNamed:@"sprout001.png"];
    
    treeNode.name = @"treeNode";
    treeNode.size = CGSizeMake(80, 100);
    treeNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:treeNode.size];
    //treeNode.anchorPoint = CGPointMake(0.5, 0);
    treeNode.zPosition = layerTree;
    treeNode.physicsBody.dynamic = NO;
    treeNode.physicsBody.categoryBitMask = EntityCategoryTree;
    treeNode.physicsBody.collisionBitMask = EntityCategoryHerbivore;
    treeNode.physicsBody.contactTestBitMask = EntityCategoryHerbivore;
    
    
    //stat
    _treeStat = [SkSpriteNode_Stat alloc];
    _treeStat.health = 100.0;
    _treeStat.power= 0;
    _treeStat.defense = 30.0;
    _treeStat.max_health =100.0;
    
    
    // 반딧불이
    
    
    
    return treeNode;
}
// 에니메이션
-(void)texture_Animation:(NSString*)name Format:(NSString*)format
{
    NSMutableArray * Frames = [NSMutableArray array];
    
    SKTextureAtlas *Atlas = [SKTextureAtlas atlasNamed:name];
    
    for (int i =1 ; i<= Atlas.textureNames.count ; ++i)
    {
        
        NSString *texture = [NSString stringWithFormat:format,i];
        
        [Frames addObject: [Atlas textureNamed:texture]];
         
    }
    self.texture_Ani = Frames;
}
// 바닥 생성 메소드
-(SKSpriteNode*) createBadak
{
    SKSpriteNode* badakNode = [[SKSpriteNode alloc]
                           initWithImageNamed:@"badak.png"];
    badakNode.size = CGSizeMake(CGRectGetWidth(self.frame),100);
    badakNode.name = @"badakNode";
    badakNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_size.width,
                                                                              10)];
    badakNode.physicsBody.affectedByGravity = NO;
    badakNode.physicsBody.dynamic = NO;
    //badakNode.anchorPoint = CGPointMake(0.5, 0);
    badakNode.physicsBody.categoryBitMask = EntityCategoryGround;
    badakNode.physicsBody.contactTestBitMask = EntityCategoryHerbivore | EntityCategoryCarnivore;
    badakNode.zPosition = LayerForeground;
    
    return badakNode;
    
}

//background

-(SKSpriteNode*)createBackground
{
    SKSpriteNode* backgroundNode = [[SKSpriteNode alloc]
                               initWithImageNamed:@"background.png"];
    backgroundNode.size = CGSizeMake(_size.width,_size.height);
    backgroundNode.name = @"backgroundNode";
    backgroundNode.zPosition = LayerBackground;
    backgroundNode.alpha = 0.5;
    
    return backgroundNode;
}
#pragma mark - cloud

//구름 생성 메소드

-(SKSpriteNode*)createCloud
{
    NSUInteger ran_num = [self randomValueBetweenInt:1 andValu:2];
    
    SKTexture* cloudTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"cloud%03lu",(unsigned long)ran_num]];
    SKSpriteNode* cloud = [[SKSpriteNode alloc]
                               initWithTexture:cloudTexture];
    cloud.size = CGSizeMake(150, 100);
    cloud.position = CGPointMake(_size.width, [self randomValueBetween:_size.height - 100 andValue:_size.height -70]);
    
    cloud.name = @"cloudNode";
    cloud.zPosition = LayerForeground;
    return cloud;
    
    
}
#pragma mark - trap
//flytrap
-(SKSpriteNode*) createFlyTrapNode
{
    SKSpriteNode* flyTrapNode = [[SKSpriteNode alloc]
                                 initWithImageNamed:@"flyTrap001.png"];
    flyTrapNode.name = kFlyTrapName;
    flyTrapNode.size = CGSizeMake(60, 150);
    flyTrapNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:flyTrapNode.size];
    flyTrapNode.zPosition = layerTree;
    //flyTrapNode.anchorPoint = CGPointMake(0.5, 0.35);
    
    //충돌설정
    flyTrapNode.physicsBody.categoryBitMask = EntityCategoryTrap;
    flyTrapNode.physicsBody.collisionBitMask = EntityCategoryGround ;
    flyTrapNode.physicsBody.contactTestBitMask = EntityCategoryBugs ;
    flyTrapNode.physicsBody.mass = 1;
    [flyTrapNode skt_attachDebugRectWithSize:flyTrapNode.size color:[SKColor redColor]];
    
    _flyTrapLev = 1;
    
    return flyTrapNode;
    
    
}

-(SKSpriteNode*)trapAttack
{
    if (_flyTrapNode == nil)  return nil;
    if (_flyTrapLev ==1 ) {
        SKSpriteNode *fireBallNode = [[SKSpriteNode alloc]initWithImageNamed:@"fireball.png"];
        
        fireBallNode.position = CGPointMake(_flyTrapNode.position.x
                                           ,_flyTrapNode.position.y  * 1.2);
        fireBallNode.zPosition = layerEffect;
        fireBallNode.size = CGSizeMake(50, 50);
        fireBallNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15 ];
        fireBallNode.physicsBody.affectedByGravity = NO;
        fireBallNode.physicsBody.categoryBitMask = EntityCategoryFireBall;
        fireBallNode.physicsBody.collisionBitMask = 0x0;
        fireBallNode.physicsBody.contactTestBitMask = EntityCategoryHerbivore | EntityCategoryCarnivore;
        [fireBallNode skt_attachDebugCircleWithRadius:15 color:[SKColor blueColor]];
        
        SKAction *rotation = [SKAction rotateByAngle:-3.14 duration:0.2];
        [fireBallNode runAction:[SKAction repeatActionForever:rotation]];
        
        //stat
        _fireballStat = [SkSpriteNode_Stat alloc];
        _fireballStat.power = 20;
        
        
        return fireBallNode;
    }
    return nil;
}

#pragma mark - environment
-(void)createRain
{
    NSString *rainPath = [[NSBundle mainBundle]
                          pathForResource:@"Rainny"
                          ofType:@"sks"];
    SKEmitterNode *rainNode = [NSKeyedUnarchiver unarchiveObjectWithFile:rainPath];
    
    rainNode.position = CGPointMake(_size.width/2, _size.height);
    
    [self addChild:rainNode];
}


#pragma mark - HUD

-(void)setupHud
{
    //폰트 설정
    SKLabelNode* synthesisLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    
    synthesisLabel.name = kSynthesisName;
    synthesisLabel.fontSize = 15;
    
    synthesisLabel.fontColor = [SKColor greenColor];
    synthesisLabel.text = [NSString stringWithFormat:@"광합성 : %f", _synthesisValue];
    synthesisLabel.position = CGPointMake(20 + synthesisLabel.frame.size.width/2, self.size.height - (25 + synthesisLabel.frame.size.height/2));
    synthesisLabel.zPosition = LayerHud;
    [self addChild:synthesisLabel];
    
    SKLabelNode* waterLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    
    waterLabel.name = kWaterName;
    waterLabel.fontSize = 15;
    
    waterLabel.fontColor = [SKColor blueColor];
    waterLabel.text = [NSString stringWithFormat:@"Water: %.1f%%", _waterValue];
    
    waterLabel.position = CGPointMake(waterLabel.frame.size.width/2 + 20, synthesisLabel.position.y - 20);
    waterLabel.zPosition = LayerHud;
    [self addChild:waterLabel];
}
-(void) adjustSysthesisBy:(CGFloat)points
{
    _synthesisValue += points;
    
    if (_synthesisValue >= _synthesis_Max) {
        _synthesisValue = _synthesis_Max ;
        
    }
    if (_synthesisValue <= 0 ) {
        _synthesisValue = 0;
    }
    SKLabelNode* systhesis = (SKLabelNode*)[self childNodeWithName:kSynthesisName];
    systhesis.text =[NSString stringWithFormat:@"광합성 : %.1f", _synthesisValue];
    
    //set progressBar
    progressBar* synthesisBar = (progressBar*)[self childNodeWithName:kSynthesisBar];
    [synthesisBar setProgress:_synthesisValue/_synthesis_Max];
    
    
}

-(void) adjustWaterBy:(CGFloat)points
{
    _waterValue += points;
    
    if(_waterValue >= _water_Max)
        _waterValue = _water_Max;
    
    else if(_waterValue <= 0)
        _waterValue = 0;
    
    SKLabelNode* water = (SKLabelNode*)[self childNodeWithName:kWaterName];
    water.text =[NSString stringWithFormat:@"Water: %.1f%%", _waterValue];
    
    //set progressBar
    progressBar* waterBar =(progressBar*)[self childNodeWithName:kWaterBar];
    [waterBar setProgress:_waterValue/_water_Max];
}

-(void)createBar
{
    progressBar* synthesisBar = [[progressBar alloc] init];
    [synthesisBar setTextureWithImageNamed:@"bar_synthesis.png"];
    synthesisBar.position = CGPointMake(20 + synthesisBar.frame.size.width/2, _size.height - 70);
    synthesisBar.name = kSynthesisBar;
    synthesisBar.zPosition = LayerHud;
    [self addChild:synthesisBar];
    
    progressBar* waterBar = [[progressBar alloc] init];
    [waterBar setTextureWithImageNamed:@"bar_water.png"];
    waterBar.position =CGPointMake(synthesisBar.position.x, synthesisBar.position.y - 30);
    waterBar.name = kWaterBar;
    waterBar.zPosition = LayerHud;
    [self addChild:waterBar];
    
}

-(void)createInformation:(NSString*)text
{
    SKLabelNode* information = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    
    information.name = kinformationName;
    information.fontSize = 15;
    
    information.fontColor =[SKColor blackColor];
    information.text = text;
    information.position = CGPointMake(_size.width/2, _size.height/1.2);
    information.zPosition = LayerHud;
    
    [self addChild:information];
    
    SKAction* wait = [SKAction waitForDuration:3];
    SKAction *remove = [SKAction runBlock:^{
        [information removeFromParent];
    }];
                        
    SKAction* sequence = [SKAction sequence:@[wait,remove]];
    
    [information runAction:sequence];
}





#pragma mark -  update 

-(void)countUpdate:(NSTimeInterval)currentTime
{
    CGFloat s_point=_sPoints * _sWeight;
    CGFloat w_point= _wPoints * _wWeight;
    if ((currentTime - _timeOfLast )<_delay  ) return;
    
    [self adjustSysthesisBy:s_point];
    [self adjustWaterBy:w_point];
    // NSLog(@"do");
    _timeOfLast = currentTime;
    
}

-(void)cloudUpdate:(NSTimeInterval)currentTime
{
    static NSTimeInterval timeoflast;
    static NSTimeInterval delay= 5;
    
    if(currentTime - timeoflast <delay) return;
    
    SKSpriteNode * cloudNode = [self createCloud];
    [self addChild:cloudNode];
    CGPoint location = CGPointMake(-60, cloudNode.position.y);
    SKAction *cloudMoveAction = [SKAction moveTo:location duration:10];
    
    [cloudNode runAction:cloudMoveAction];
    
    timeoflast = currentTime;
    
    
    
}

-(void)moveBugsUpdate:(NSTimeInterval)currentTime
{
    static NSTimeInterval timeoflast;
    static NSTimeInterval delay =1;
    CGFloat multiplierForDirection;
    if (!(0<_bugsNode.position.x <_size.width))
    {
        [_bugsNode removeFromParent];
        return;
    }
    
    
    if (currentTime - timeoflast < delay) return;
    
    CGPoint location = CGPointMake(_bugsNode.position.x + [self randomValueBetween:-40 andValue: 20],
                                   _bugsNode.position.y + [self randomValueBetween:-40 andValue: 20]);
    
    //CGPoint location1 = CGPointMake(0, _size.height/2);
    
    if (location.y> _size.height || location.y < 200){
        location.y = _bugsNode.position.y ;
    }
    
    if (_bugsNode.position.x < location.x) {
        //right
        multiplierForDirection =-1;
    }
    else
    {
        //left
        multiplierForDirection = 1;
    }
    _bugsNode.xScale = fabs(_bugsNode.xScale) * multiplierForDirection;
    
    SKAction* bugMoveAction = [SKAction moveTo:location duration:1 ];
    [_bugsNode runAction:bugMoveAction];
    
    timeoflast = currentTime;
    
}


-(void)update:(NSTimeInterval)currentTime
{
    
    [self cloudUpdate:currentTime];
    
    [self countUpdate:currentTime];
    if (_bugsNode !=nil) {
        [self moveBugsUpdate:currentTime];
    }
    if (_flyTrapNode != nil) {
        [self flytrapUpdate:currentTime];
    }
    [self removeUpdate];
    
}

-(void)situationUpdate:(NSTimeInterval)currentTime
{
    static NSTimeInterval timeoflast;
    static NSTimeInterval delay =1;
    
    if (currentTime - timeoflast < delay) return;
    NSUInteger env_num = [self randomValueBetweenInt:1 andValu:60];
    NSUInteger herbi_num = [self randomValueBetweenInt:1 andValu:30];
    NSUInteger carni_num = [self randomValueBetweenInt:1 andValu:40];
    
    //check
    
    NSLog(@"%lu, %lu , %lu", (unsigned long)env_num,(unsigned long)herbi_num, (unsigned long)carni_num );
    //=====
    
    if (env_num ==3| env_num== 26 | env_num== 59) {
        if (env_num ==3) {
            [self createRain];
            _treeStat.health = _treeStat.max_health;
        }
        else if(env_num ==26)
        {
            // 태풍
        }
        else
        {
            //가뭄
        }
    }
    
    if (herbi_num ==3) {
        switch (_level) {
            case 1:
                //level 1
                break;
                
                
            default:
                break;
        }
    }
    
    
    if (carni_num ==3) {
        switch (_level) {
            case 1:
                // level 1
                break;
                
            default:
                break;
        }
    }
    
    
    
    
    
    timeoflast = currentTime;

}

-(void)flytrapUpdate:(NSTimeInterval)currentTime;
{
    static NSTimeInterval timeoflast;
    static NSTimeInterval delay =2;
    static BOOL flag;
    
    if (currentTime - timeoflast < delay) return;
    
    if (_herbivoreNode!=nil && _carnivoreNode != nil) {
        if (flag == YES) {
            [self apearfunc:_herbivoreNode.position];
            NSLog(@"dd");
            flag =NO;
        }
        
        else
        {
            [self apearfunc:_carnivoreNode.position];
            flag = YES;

        }
        
        timeoflast = currentTime;
        
    }
    
    
    else if ( _herbivoreNode != nil) {
        [self apearfunc:_herbivoreNode.position];
        NSLog(@"only");
        timeoflast = currentTime;
        
    }
    
    else if (_carnivoreNode != nil) {
        
        [self apearfunc:_carnivoreNode.position];
        timeoflast = currentTime;
    }
    
    
}

-(void)apearfunc:(CGPoint)position
{
    _fireBall = [self trapAttack];
    [self addChild:_fireBall];
    CGPoint location = position;
    CGPoint offset = rwSub(location, _fireBall.position);
    
    
    //  - Get the direction of where to shoot
    CGFloat length = rwLength(offset);
    
    
    //  - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(offset , _fireBall.position);
    
    //  - Create the actions
    float velocity = 200.0/1.0;
    float realMoveDuration = length / velocity;
    
    realDest.x -= _size.width / 10 * realMoveDuration;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [_fireBall runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    
    
    
}

-(void)removeUpdate
{
    if (_herbivoreNode == nil) {
        
        [_herbivoreNode removeAllActions];
    }
    if (_carnivoreNode == nil) {
        [_carnivoreNode removeAllActions];
    }
    
}

#pragma mark - button setting

// 업그레이드 버튼 SET
-(void) setUpButton
{
    _plusLeafBtn = [SKSpriteNode spriteNodeWithImageNamed:@"button_plus_leaf.png"];
    _plusLeafBtn.position = CGPointMake(_size.width-30, _size.height-40);
    _plusLeafBtn.zPosition = LayerHud;
    [self addChild:_plusLeafBtn];
    
    _plusWaterBtn = [SKSpriteNode spriteNodeWithImageNamed:@"button_plus_water.png"];
    _plusWaterBtn.position = CGPointMake(_plusLeafBtn.position.x,
                                         _plusLeafBtn.position.y - _plusWaterBtn.frame.size.height/2- _plusLeafBtn.frame.size.height/2 - 10);
    _plusWaterBtn.size = CGSizeMake(60, 60);
    _plusWaterBtn.zPosition = LayerHud;
    [self addChild:_plusWaterBtn];
    
    _GrowthBtn = [SKSpriteNode spriteNodeWithImageNamed:@"button_growth.png"];
    _GrowthBtn.position = CGPointMake(_plusLeafBtn.position.x,
                                      _plusWaterBtn.position.y - _GrowthBtn.frame.size.height/2 - _plusWaterBtn.frame.size.height/2 -10);
    _GrowthBtn.zPosition = LayerHud;
    [self addChild:_GrowthBtn];
    
    _shopBtn = [SKSpriteNode spriteNodeWithImageNamed:@"button_shop.png"];
    _shopBtn.position = CGPointMake(_plusLeafBtn.position.x - _plusLeafBtn.frame.size.width/2 - _shopBtn.frame.size.width/2 ,
                                    _plusLeafBtn.position.y);
    _shopBtn.zPosition = LayerHud;
    _shopBtn.size = CGSizeMake(50 ,50);
    [self addChild:_shopBtn];
    
    [self setShopButton];
}
// SHOP BUTTON SET
-(void) setShopButton
{
    _item1Btn = [SKSpriteNode spriteNodeWithImageNamed:@"button_item1.png"];
    _item1Btn.size = CGSizeMake(50, 50);
    _item1Btn.zPosition = LayerButton;
    _item1Btn.position = CGPointMake(_shopBtn.position.x, _shopBtn.position.y);
    [self addChild:_item1Btn];
    
    _item2Btn = [SKSpriteNode spriteNodeWithImageNamed:@"button_item2.png"];
    _item2Btn.size = CGSizeMake(50, 50);
    _item2Btn.zPosition = LayerButton;
    _item2Btn.position = CGPointMake(_shopBtn.position.x, _shopBtn.position.y);
    [self addChild:_item2Btn];
    
    _item3Btn = [SKSpriteNode spriteNodeWithImageNamed:@"button_item3.png"];
    _item3Btn.size = CGSizeMake(50, 50);
    _item3Btn.zPosition = LayerButton;
    _item3Btn.position = CGPointMake(_shopBtn.position.x, _shopBtn.position.y);
    [self addChild:_item3Btn];
    
    _item4Btn = [SKSpriteNode spriteNodeWithImageNamed:@"button_item4.png"];
    _item4Btn.size = CGSizeMake(50, 50);
    _item4Btn.zPosition = LayerButton;
    _item4Btn.position = CGPointMake(_shopBtn.position.x, _shopBtn.position.y);
    [self addChild:_item4Btn];
    
    _item1Btn.hidden = YES;
    _item2Btn.hidden = YES;
    _item3Btn.hidden = YES;
    _item4Btn.hidden = YES;
    
}
-(void) buttonAction
{
    static BOOL on_off ;
    
    
    
    if (!on_off) {
        
        int term = 10;
        
        _item1Btn.hidden = NO;
        _item2Btn.hidden = NO;
        _item3Btn.hidden = NO;
        _item4Btn.hidden = NO;
        
        
        CGPoint location1 = CGPointMake(_shopBtn.position.x - _item1Btn.frame.size.width/2 - _shopBtn.frame.size.width/2 - term*2 - _item2Btn.frame.size.width,
                                        _shopBtn.position.y);
        CGPoint location2 = CGPointMake(_shopBtn.position.x - _item2Btn.frame.size.width/2 - _shopBtn.frame.size.width/2 - term,
                                        _shopBtn.position.y);
        CGPoint location3 = CGPointMake(_shopBtn.position.x - _item1Btn.frame.size.width/2 - _shopBtn.frame.size.width/2 - term*2 - _item2Btn.frame.size.width,
                                        _shopBtn.position.y - _shopBtn.frame.size.height/2 - _item3Btn.frame.size.height/2 - term);
        CGPoint location4 = CGPointMake(_shopBtn.position.x - _item2Btn.frame.size.width/2 - _shopBtn.frame.size.width/2 - term,
                                        _shopBtn.position.y - _shopBtn.frame.size.height/2 - _item3Btn.frame.size.height/2 - term);
        
        
        SKAction *button1MoveAction = [SKAction moveTo:location1 duration:0.5];
        SKAction *button2MoveAction = [SKAction moveTo:location2 duration:0.5];
        SKAction *button3MoveAction = [SKAction moveTo:location3 duration:0.5];
        SKAction *button4MoveAction = [SKAction moveTo:location4 duration:0.5];
        
        [_item1Btn runAction:button1MoveAction];
        [_item2Btn runAction:button2MoveAction];
        [_item3Btn runAction:button3MoveAction];
        [_item4Btn runAction:button4MoveAction];
        
        _btn_swc = YES;
        on_off = YES;
    }
    
    else
    {
        CGPoint location_off = CGPointMake(_shopBtn.position.x, _shopBtn.position.y);
        
        SKAction *button1MoveAction = [SKAction moveTo:location_off duration:0.5];
        SKAction *button2MoveAction = [SKAction moveTo:location_off duration:0.5];
        SKAction *button3MoveAction = [SKAction moveTo:location_off duration:0.5];
        SKAction *button4MoveAction = [SKAction moveTo:location_off duration:0.5];
        
        SKAction* removeBtnAction = [SKAction runBlock:^{
            _item1Btn.hidden = YES;
            _item2Btn.hidden = YES;
            _item3Btn.hidden = YES;
            _item4Btn.hidden = YES;
        }];
        SKAction* sequence = [SKAction sequence:@[button4MoveAction, removeBtnAction]];
        
        [_item1Btn runAction:button1MoveAction];
        [_item2Btn runAction:button2MoveAction];
        [_item3Btn runAction:button3MoveAction];
        [_item4Btn runAction:sequence];
        
        
        
        
        
        on_off = NO;
    }
}


#pragma mark - touch method

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        if ([_plusLeafBtn containsPoint:location]) {
            NSLog(@" leaf upgrade");
            _click = 1;
            _plusLeafBtn.texture = [SKTexture textureWithImageNamed:@"button_plus_leaf_on.png"];
            
        }
        
        else if([_plusWaterBtn containsPoint:location])
        {
            NSLog(@" water upgrade");
            _click =2;
            _plusWaterBtn.texture = [SKTexture textureWithImageNamed:@"button_plus_water_on.png"];
        }
        
        else if([_GrowthBtn containsPoint:location])
        {
            NSLog(@" growth upgrade");
            _click =3;
            _GrowthBtn.texture = [SKTexture textureWithImageNamed:@"button_growth_on.png"];
        }
        else if([_shopBtn containsPoint:location])
        {
            NSLog(@" shop open");
            _click = 4;
            _shopBtn.texture = [SKTexture textureWithImageNamed:@"button_shop_on.png"];

        }
        else if(_btn_swc)
        {
            if ([_item1Btn containsPoint:location]) {
                NSLog(@" item 1 ");
                _click =5;
                _item1Btn.texture = [SKTexture textureWithImageNamed:@"button_item1_on.png"];
            }
            else if([_item2Btn containsPoint:location])
            {
                
                
                NSLog(@"item2");
                _click =6;
                _item2Btn.texture = [SKTexture textureWithImageNamed:@"button_item2_on.png"];
            }
            else if([_item3Btn containsPoint:location])
            {
                NSLog(@"item3");
                _click = 7;
                _item3Btn.texture = [SKTexture textureWithImageNamed:@"button_item3_on.png"];
            }
            else if([_item4Btn containsPoint:location])
            {
                NSLog(@"item4");
                _click = 8;
                _item4Btn.texture = [SKTexture textureWithImageNamed:@"button_item4_on.png"];
            }
            else
            {
                NSLog(@"nothing");
                _click = 0;
            }
            
        }
        else
        {
            NSLog(@"nothing");
            _click = 0;
        }
        
        

        
        
    }
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    
    for(UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        if ([_plusLeafBtn containsPoint:location]) {
            
            if (_click ==1) {
                NSLog(@" leaf upgrade end");
                [self adjustSysthesisBy:-50];
                _sPoints += 1;
                _wPoints -= 1;
            }
        }
        
        else if([_plusWaterBtn containsPoint:location])
        {
            if(_click ==2){
                NSLog(@" water upgrade end");
                [self adjustSysthesisBy:- 50];
                _wPoints += 1;
                
                
                
            }
        }
        
        else if([_GrowthBtn containsPoint:location])
        {
            if (_click==3) {
                if (_level <1) {
                    _level = 1;
                }
                _synthesis_Max += 10;
                _water_Max += 10;
                _level++;
                
                if (_level == 2) {
                    [self appearAnimal:kHerbivoreName name:kpikachuName];
                }
                
                if (_level ==3) {
                    [self appearAnimal:kCarnivoreName name:kpairiName];
                }
                
                
                if (_level == 4) {
                    SKSpriteNode* treeNode = (SKSpriteNode*)[self childNodeWithName:@"treeNode" ];
                    [self texture_Animation:@"tree" Format:@"tree%03d"];
                    
                    [treeNode removeAllActions];
                    SKAction *tree_standAnimate = [SKAction animateWithTextures:self.texture_Ani timePerFrame:0.15];
                    [treeNode runAction:[SKAction repeatActionForever:tree_standAnimate] withKey:@"treeAtlas"];
                    
                }
                
                
                
            }
           
        }
        else if([_shopBtn containsPoint:location])
        {
            if(_click == 4)
            {
                
                [self buttonAction];
                
            }
        }
        else if(_btn_swc)
        {
            if ([_item1Btn containsPoint:location]) {
                if (_click==5) {
                    
                    _flyTrapNode = [self createFlyTrapNode];
                    _flyTrapNode.position = CGPointMake(_treeNode.position.x + 100 , _flyTrapNode.size.height/2 + _badakNode.size.height );
                    
                    [self addChild:_flyTrapNode];
                    
                    
                    
                }
                
            }
            else if([_item2Btn containsPoint:location])
            {
                if (_click==6) {
                    
                    [self createRain];
                    [self createInformation:@" fuck fuck hae man"];
                    NSLog(@"bbuing bbuing");
                    
                    
                }
            }
            else if([_item3Btn containsPoint:location])
            {
                if (_click==7) {
                    NSLog(@"bbuing bbuing");
                    _herbivoreNode.physicsBody.velocity = CGVectorMake(-100.0, 0);

                }
            }
            else if([_item4Btn containsPoint:location])
            {
                if (_click==8) {
                    NSLog(@"bbuing bbuing");
                }
            }
            else
            {
                NSLog(@"nothing");
            }
            _item1Btn.texture = [SKTexture textureWithImageNamed:@"button_item1.png"];
            _item2Btn.texture = [SKTexture textureWithImageNamed:@"button_item2.png"];
            _item3Btn.texture = [SKTexture textureWithImageNamed:@"button_item3.png"];
            _item4Btn.texture = [SKTexture textureWithImageNamed:@"button_item4.png"];

        }
        else
        {
            NSLog(@"nothing");
        }
        
        _plusLeafBtn.texture = [SKTexture textureWithImageNamed:@"button_plus_leaf.png"];
        _plusWaterBtn.texture = [SKTexture textureWithImageNamed:@"button_plus_water.png"];
        _GrowthBtn.texture = [SKTexture textureWithImageNamed:@"button_growth.png"];
        _shopBtn.texture = [SKTexture textureWithImageNamed:@"button_shop.png"];
        
    }
}

#pragma mark - random method
-(float)randomValueBetween:(float)low andValue:(float)high
{
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) +low;
}

-(NSUInteger)randomValueBetweenInt:(NSUInteger)low andValu:(NSUInteger)high
{
    return low + arc4random()%high;
}

#pragma mark - enermy

-(SKSpriteNode*)creatbugs
{
    SKSpriteNode* bugsNode = [[SKSpriteNode alloc]initWithImageNamed:@"butterfree001"];
    
    bugsNode.size = CGSizeMake(20, 20);
    bugsNode.zPosition = LayerEnermy;
    bugsNode.position = CGPointMake(_size.width, [self randomValueBetween:_size.height - 100 andValue:_size.height -70]);
    bugsNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bugsNode.size.width/2 -1 ];
    bugsNode.physicsBody.affectedByGravity =NO;
    bugsNode.physicsBody.categoryBitMask = EntityCategoryBugs;
    bugsNode.physicsBody.collisionBitMask = EntityCategoryGround | EntityCategoryTree |EntityCategoryBugs |EntityCategoryHerbivore;
    
    
    bugsNode.name = @"bugsNode";
    
    [self addChild:bugsNode];
    
    [bugsNode skt_attachDebugCircleWithRadius:bugsNode.size.width/2 -1 color:[SKColor redColor]];
    
    [self texture_Animation:@"butterfree" Format:@"butterfree%03d"];
    
    if (bugsNode != nil) {
        SKAction *bugs_flyAnimate = [SKAction animateWithTextures:self.texture_Ani timePerFrame:0.15];
        [bugsNode runAction:[SKAction repeatActionForever:bugs_flyAnimate] withKey:@"butterfreeAtlas"];
    }
    
    return bugsNode;
    
    
        
}

-(SKSpriteNode*)createHerbivore: (NSString*)name
{
    
    SKSpriteNode* herbivoreNode = [[SKSpriteNode alloc]initWithImageNamed:@"pikachu001.png"];
    herbivoreNode.size = CGSizeMake(50, 25);
    herbivoreNode.zPosition =LayerEnermy;
    herbivoreNode.position = CGPointMake(_size.width/1.1 + 10,
                                          _badakNode.size.height + herbivoreNode.size.height/2 );
    herbivoreNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:herbivoreNode.size ];
    herbivoreNode.physicsBody.categoryBitMask = EntityCategoryHerbivore;
    herbivoreNode.physicsBody.collisionBitMask = EntityCategoryBugs | EntityCategoryGround |EntityCategoryTree | EntityCategoryCarnivore;
    
    herbivoreNode.physicsBody.mass = 1;
    //weakAnimalNode.physicsBody.usesPreciseCollisionDetection = YES;
    
    //weakAnimalNode.xScale = fabs(weakAnimalNode.xScale) * -1;
    herbivoreNode.name = kpikachuName;
    
    //stat
    _herbiStat = [SkSpriteNode_Stat alloc];
    _herbiStat.health =_herbiStat.max_health= 100.0;
    _herbiStat.power = 20.0;
    _herbiStat.defense = 10.0;
    
    
    [herbivoreNode skt_attachDebugRectWithSize:herbivoreNode.size color:[SKColor redColor]];
    
    [self texture_Animation:name Format:[NSString stringWithFormat:@"%@%%03d",name]];
    
    if (herbivoreNode != nil) {
        SKAction *weakanimal_moveAnimate = [SKAction animateWithTextures:self.texture_Ani timePerFrame:0.15];
        [herbivoreNode runAction:[SKAction repeatActionForever:weakanimal_moveAnimate] withKey:name];
    }
    
    return herbivoreNode;
}

-(SKSpriteNode*)createCarnivore: (NSString*)name
{
    SKSpriteNode* carnivoreNode = [[SKSpriteNode alloc]initWithImageNamed:@"pairi.jpg"];
    carnivoreNode.size = CGSizeMake(60, 60);
    carnivoreNode.zPosition = LayerEnermy;
    carnivoreNode.position = CGPointMake(_size.width/1.1 +10, _badakNode.size.height/1.5 + carnivoreNode.size.height/2);
    
    carnivoreNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:carnivoreNode.size];
    carnivoreNode.physicsBody.categoryBitMask = EntityCategoryCarnivore;
    carnivoreNode.physicsBody.collisionBitMask = EntityCategoryGround |EntityCategoryHerbivore |EntityCategoryBugs;
    carnivoreNode.physicsBody.contactTestBitMask = EntityCategoryHerbivore |EntityCategoryCarnivore;
    
    carnivoreNode.physicsBody.mass = 1;
    carnivoreNode.name = kCarnivoreName;
    
    [carnivoreNode skt_attachDebugRectWithSize:carnivoreNode.size color:[SKColor redColor]];
    
    //애니메이션
    
    
    
    // ======
    //stat
    _carniStat = [SkSpriteNode_Stat alloc];
    _carniStat.health =_herbiStat.max_health= 100.0;
    _carniStat.power = 20.0;
    _carniStat.defense = 10.0;
    
    
    
    
    return carnivoreNode;
    
    
}

-(void) appearAnimal:(NSString*)species name:(NSString*)name
{
    
    if ([kHerbivoreName  isEqual: species]) {
        
        _herbivoreNode = [self createHerbivore:name];
        
        [self addChild:_herbivoreNode];
        
        SKAction* moveAction = [SKAction moveToX:_treeNode.position.x duration:10];
        [_herbivoreNode runAction:moveAction];
        
        
        
    }
    
    if ([kCarnivoreName isEqual:species]) {
        _carnivoreNode = [self createCarnivore:name];
        
        [self addChild:_carnivoreNode];
        
        SKAction* moveAction = [SKAction moveToX:_treeNode.position.x duration:10];
        [_carnivoreNode runAction:moveAction];
    }
    
    
    
    
    
    
    
}


#pragma mark - contact delegate method

-(void) didBeginContact:(SKPhysicsContact *)contact
{
    SKSpriteNode* firstNode, *secondNode;
    
    firstNode = (SKSpriteNode*) contact.bodyA.node;
    secondNode = (SKSpriteNode*) contact.bodyB.node;
    
    if ((contact.bodyA.categoryBitMask == EntityCategoryTrap)
        && (contact.bodyB.categoryBitMask == EntityCategoryBugs)) {
        
        [_bugsNode removeFromParent];
        
        
        
    }
    
    if (contact.bodyA.categoryBitMask == EntityCategoryTree
        && contact.bodyB.categoryBitMask == EntityCategoryHerbivore) {
        NSLog(@"contact");
        [_herbivoreNode removeAllActions];
        
        SKAction* attack = [SKAction runBlock:^{
            [_herbiStat attack:_treeStat];
            NSLog(@"attack");
            NSLog(@"%f", _treeStat.health);
            if (_treeStat.health <= 0) {
                [self removeActionForKey:@"attack_tree"];
                [_treeNode removeFromParent];
            }
        }];
        SKAction* wait = [SKAction waitForDuration:1];
        SKAction* sequence = [SKAction sequence:@[attack,wait]];
        [_herbivoreNode runAction:[SKAction repeatActionForever:sequence] withKey:@"attack_tree"];
        
    }
    
    if (contact.bodyA.categoryBitMask == EntityCategoryHerbivore
        && contact.bodyB.categoryBitMask == EntityCategoryCarnivore ) {
        
        NSLog(@"eat");
        [_herbivoreNode removeAllActions];
        [_carnivoreNode removeAllActions];
        
    }
    
    if (contact.bodyA.categoryBitMask ==EntityCategoryCarnivore
        && contact.bodyB.categoryBitMask == EntityCategoryCarnivore) {
        NSLog(@"fight");
        [_herbivoreNode removeAllActions];
    }
    
    if (contact.bodyA.categoryBitMask == EntityCategoryGround
        && contact.bodyB.categoryBitMask == EntityCategoryHerbivore) {
        NSLog(@"herbibore appear");
        
        
        
    }
    
    if (contact.bodyA.categoryBitMask == EntityCategoryGround
        && contact.bodyB.categoryBitMask == EntityCategoryCarnivore) {
        
    }
    
    if (contact.bodyB.categoryBitMask == EntityCategoryFireBall
        && contact.bodyA.categoryBitMask == EntityCategoryHerbivore) {
        
        NSLog(@"bbang1");
        [_fireBall removeFromParent];
        [_fireballStat attack:_herbiStat];
        NSLog(@"hervi health : %f",_herbiStat.health);
        
        if (_herbiStat.health<=0) {
            [_herbivoreNode removeFromParent];
            _herbivoreNode = nil;
        }
        
        
            
    }
    
    if (contact.bodyB.categoryBitMask == EntityCategoryFireBall
        && contact.bodyA.categoryBitMask == EntityCategoryCarnivore) {
        
        NSLog(@"bbang2");
        
        [_fireBall removeFromParent];
        [_fireballStat attack:_carniStat];
        
        if (_carniStat.health <=0) {
            
            [_carnivoreNode removeFromParent];
            _carnivoreNode = nil;
        }
        
        
    }
    
    
    
}

-(void) didEndContact:(SKPhysicsContact *)contact
{
    SKSpriteNode* firstNode, *secondNode;
    
    firstNode = (SKSpriteNode*) contact.bodyA.node;
    secondNode = (SKSpriteNode*) contact.bodyB.node;
    
    if ((contact.bodyA.categoryBitMask == EntityCategoryTrap)
        && (contact.bodyB.categoryBitMask == EntityCategoryBugs)) {
        
        
        
        
        
    }
    
    if (contact.bodyA.categoryBitMask == EntityCategoryTree
        && contact.bodyB.categoryBitMask == EntityCategoryHerbivore) {
        NSLog(@"contac end");
        
        
    }
    
    if (contact.bodyA.categoryBitMask == EntityCategoryHerbivore
        && contact.bodyB.categoryBitMask == EntityCategoryCarnivore ) {
        
        NSLog(@"eat end");
        
    }
    
    if (contact.bodyA.categoryBitMask ==EntityCategoryCarnivore
        && contact.bodyB.categoryBitMask == EntityCategoryCarnivore) {
        NSLog(@"fight end");
    }
    
    if (contact.bodyA.categoryBitMask == EntityCategoryGround
        && contact.bodyB.categoryBitMask == EntityCategoryHerbivore) {
        NSLog(@"herbibore disappear");
        
        
        
    }
    
    if (contact.bodyA.categoryBitMask == EntityCategoryGround
        && contact.bodyB.categoryBitMask == EntityCategoryCarnivore) {
        
    }
    
}


#pragma mark - Math

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}
/*
static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}
*/
static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}
/*
// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}
*/
@end
