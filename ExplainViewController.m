//
//  ExplainViewController.m
//  ninjaOri
//
//  Created by 임태근 on 2014. 8. 5..
//  Copyright (c) 2014년 임태근. All rights reserved.
//

#import "ExplainViewController.h"

@interface ExplainViewController ()

@end

@implementation ExplainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int i =0;
    for (  ; i<3; i++) {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"explain%d.png",i+1]];
        UIImageView * imageview = [[UIImageView alloc]initWithImage:image];
        imageview.frame =CGRectMake(_scrollView.frame.size.width*i, 0, _scrollView.frame.size.width,_scrollView.frame.size.height);
        
        [_scrollView addSubview:imageview];
        
    }
    
    
    //이미지 세개를 가로로 나열한 전체 크기로 scrollview사이즈를 설정
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width*i  ,_scrollView.frame.size.height)];
    //scrollview 에 필요한 옵션 설정
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.showsHorizontalScrollIndicator=YES;
    //_scrollView.alwaysBounceHorizontal;
    //_scrollView.alwaysBounceVertical;
    _scrollView.pagingEnabled=YES; //페이징 가능 여부 yes
    _scrollView.delegate =self;
    
    
    //pagecontol 옵션 적용
    _pageControl.currentPage =0;
    _pageControl.numberOfPages = 3;
    
    [_pageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_pageControl];
    
    
}


//페이지 컨트롤 값이 변경될때, 스크롤뷰 위치선정
-(void) pageChangeValue:(id)sender
{
    UIPageControl *pControl = (UIPageControl*)sender;
    [_scrollView setContentOffset:CGPointMake(pControl.currentPage*320, 0) animated:YES];
    
}
//스크롤이 변경될때 page의 currentPage설정
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    _pageControl.currentPage = floor((_scrollView.contentOffset.x - pageWidth/3)/pageWidth)+1;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [_scrollView flashScrollIndicators];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
