//
//  ViewController.m
//  RESTNetworking
//
//  Created by Robert Walker on 5/24/12.
//  Copyright (c) 2012 Bennett International Group, LLC. All rights reserved.
//

#import "ViewController.h"
#import "QHTTPOperation.h"
#import "NetworkManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Actions

- (IBAction)sendRequest:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:@"https://gist.github.com/robertwalker/6944146/raw/b0348d212688bd0df9ffcc58cc4a342e4320e972/rest_networking_demo"];
    QHTTPOperation *op = [[QHTTPOperation alloc] initWithURL:url];
    [[NetworkManager sharedManager] addNetworkTransferOperation:op finishedTarget:self action:@selector(handleResponse:)];
}

#pragma mark - HTTP response handlers

- (void)handleResponse:(QHTTPOperation *)op
{
    NSData *responseBody = [op responseBody];
    NSString *responseString = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
    self.textView.text = responseString;
}

@end
