//
//  viewWaveformViewController.m
//  Soundshop
//
//  Created by Govinda Ram Pingali on 4/1/13.
//  Copyright (c) 2013 GTCMT. All rights reserved.
//

#import "viewWaveformViewController.h"

#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)

@interface viewWaveformViewController ()

@end

@implementation viewWaveformViewController

@synthesize waveformImageView;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NO];
}


@end
