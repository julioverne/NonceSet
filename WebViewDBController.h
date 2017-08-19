#import <UIKit/UIKit.h>

@interface WebViewDBController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> {
@private
    UIWebView *webView;
	NSString *startURL;
	NSString *returnURL;
	
	NSString *oauth_token;
	NSString *oauth_token_secret;
	
	int type;
}

@property (nonatomic, readonly) UIWebView *webView;
@property (nonatomic, retain) NSString *startURL;
@property (nonatomic, retain) NSString *returnURL;
@property (nonatomic, retain) NSString *oauth_token;
@property (nonatomic, retain) NSString *oauth_token_secret;
@property (nonatomic, readonly) UIActivityIndicatorView *loadingView;
@property (nonatomic, assign) int type;
- (id)initDropboxType:(int)type;
@end
