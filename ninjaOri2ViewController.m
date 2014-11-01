//
//  ninjaOri2ViewController.m
//  ninjaOri2
//
//  Created by 임태근 on 2014. 8. 11..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import "ninjaOri2ViewController.h"

#import "NinjaOriScene.h"
#import "chooseScene.h"

@implementation ninjaOri2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [chooseScene sceneWithSize:skView.bounds.size];
    
    
    // Present the scene.
    [skView presentScene:scene];
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
