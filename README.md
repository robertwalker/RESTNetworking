RESTNetworking
==============

This sample project contains operation queue managed networking and REST to Core Data support. It also contains a very basic demo which sends an HTTP request to get content from the Internet.

Part I - Networking
-------------------

### NetworkManager

This shared manager instance works in a similar fashion to the new NSURLSession class introduced in iOS 7, only not nearly as cool. It manages all currently running background HTTP requests and provides information about those requests. For example you can ask [NetworkManager sharedManager] whether or not there is any network activity.

    if ([[NetworkManager sharedManager] networkInUse]) {
        // We have current network activity
    }

You may also observe the networkInUse property to manage the netwrok activity indicator.

### AppDelegate.m

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        // Add an observer to the network manager's networkInUse property so that we can  
        // update the application's networkActivityIndicatorVisible property.  This has 
        // the side effect of starting up the NetworkManager singleton.
        [[NetworkManager sharedManager] addObserver:self forKeyPath:@"networkInUse" options:NSKeyValueObservingOptionInitial context:NULL];

        return YES;
    }

    #pragma mark - KVO handlers

    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        // When the network manager's networkInUse property changes, update the
        // application's networkActivityIndicatorVisible property accordingly.
        if ([keyPath isEqual:@"networkInUse"]) {
            assert(object == [NetworkManager sharedManager]);
            #pragma unused(change)
            assert(context == NULL);
            assert( [NSThread isMainThread] );
            [UIApplication sharedApplication].networkActivityIndicatorVisible = [NetworkManager sharedManager].networkInUse;
        } else if (NO) {   // Disabled because the super class does nothing useful with it.
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }

#### Tracking an HTTP Request's Progress

NetowrkManager also provides a property named "progress" that can be observed using KVO for tracking progress of a queued request.

    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        if ([object isKindOfClass:[QHTTPOperation class]]) {
            if ([keyPath isEqualToString:@"progress"]) {
                float progress = [[change valueForKey:NSKeyValueChangeNewKey] floatValue];
                if (progress > 0 && progress < 1) {
                    self.progressView.hidden = NO;
                    self.progressView.progress = progress;
                }
                else {
                    self.progressView.hidden = YES;
                    self.progressView.progress = 0.0;
                }
            }
        }
    }

### QHTTPOperation

Create instances of QHTTPOperation for each HTTP request you wish to send. The option will then be passed along to the shared NetworkManager instance using one of two operation modes:

    BOOL isReallyQuick = <true if the HTTP response is really small otherwise use transfer operations
    NSURL *url = <some url>
    QHTTPOperation *op = [[QHTTPOperation alloc] initWithURL:url];
    if (isReallyQuick) {
        [[NetworkManager sharedManager] addNetworkManagementOperation:op finishedTarget:self action:@selector(handleResponse:)];
    } else {
        [[NetworkManager sharedManager] addNetworkTransferOperation:op finishedTarget:self action:@selector(handleResponse:)];
    }

When an individual operation completely your responseHandler is called and passes the handler the QHTTPOperation that just finished.

    - (void)handleResponse:(QHTTPOperation *)op
    {
        NSData *responseBody = [op responseBody];
        NSString *responseString = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
        self.textView.text = responseString;
    }

That about wraps up the basics of using the Networking part of this demo.

Part II - REST

For now contact me if you are interested in more detail about my REST support. Note that is a work in progress although it does support basic use of REST services.