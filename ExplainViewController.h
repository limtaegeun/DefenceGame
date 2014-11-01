//
//  ExplainViewController.h
//  ninjaOri
//
//  Created by 임태근 on 2014. 8. 5..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExplainViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;


@end
