#import <dlfcn.h>
#import <objc/runtime.h>
#import <sys/stat.h>
#import <Social/Social.h>
#import <Foundation/NSTask.h>
#import <prefs.h>

@interface NonceSetApplication : UIApplication <UIApplicationDelegate> {
	UIWindow *_window;
	UIViewController *_viewController;
}
@property (nonatomic, retain) UIWindow *window;
@end
@implementation NonceSetApplication
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_viewController = [[UINavigationController alloc] initWithRootViewController:[[objc_getClass("NonceSetController") alloc] init]];
	[_window addSubview:_viewController.view];
	_window.rootViewController = _viewController;
	[_window makeKeyAndVisible];
}
@end

__attribute__((constructor))
int main(int argc, char **argv)
{
	setgid(0);
	setuid(0);
	@autoreleasepool {
		return UIApplicationMain(argc, argv, @"NonceSetApplication", @"NonceSetApplication");
	}
}

@interface UIProgressHUD : UIView
- (void) showInView:(UIView *)view;
- (void) setText:(NSString *)text;
- (void) done;
- (void) hide;
@end

@interface NSString (NonceSet)
- (NSString *)runAsCommand;
@end

@implementation NSString (NonceSet)
- (NSString*)runAsCommand
{
	NSPipe* pipe = [NSPipe pipe];
	NSTask* task = [[NSTask alloc] init];
	[task setLaunchPath: @"/bin/sh"];
	[task setArguments:@[@"-c", [NSString stringWithFormat:@"%@", self]]];
	[task setStandardOutput:pipe];
	NSFileHandle* file = [pipe fileHandleForReading];
	[task launch];
	return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}
@end



@interface NonceSetController : PSListController
@end

@implementation NonceSetController
- (id)specifiers {
	if (!_specifiers) {
		NSMutableArray* specifiers = [NSMutableArray array];
		PSSpecifier* spec;
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"boot-nonce"
					      target:self
						 set:NULL
						 get:@selector(readNonceValue:)
					      detail:Nil
						cell:PSTitleValueCell
						edit:Nil];
		[spec setProperty:@"boot-nonce" forKey:@"key"];
		[spec setProperty:@"" forKey:@"default"];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Set/Change Nonce"
						      target:self
											  set:Nil
											  get:Nil
					      detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Set/Change Nonce" forKey:@"label"];
		[spec setProperty:@"Nonce is set via nvram command." forKey:@"footerText"];
		[specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"boot-nonce:"
					      target:self
											  set:@selector(setNonceValue:specifier:)
											  get:@selector(readValue:)
					      detail:Nil
											  cell:PSEditTextCell
											  edit:Nil];
		[spec setProperty:@"NonceSet" forKey:@"key"];
		[specifiers addObject:spec];
		
		spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:@"NonceSet © 2017 julioverne" forKey:@"footerText"];
        [specifiers addObject:spec];
		_specifiers = [specifiers copy];
	}
	return _specifiers;
}
- (void)refresh:(UIRefreshControl *)refresh
{
	[self reloadSpecifiers];
	if(refresh) {
		[refresh endRefreshing];
	}	
}
- (void)showErrorFormat
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title message:@"Nonce has wrong format.\n\nFormat accept:\n0xabcdef1234567890" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}
- (void)setNonceValue:(id)value specifier:(PSSpecifier *)specifier
{
	@autoreleasepool {
		if(value&&[value length]>0) {
			value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSError *error = NULL;
			NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"0x[0-9a-f]{%@}", @([value length]-2)] options:0 error:&error];
			NSUInteger numberOfMatches = [regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])];
			if(!error && numberOfMatches > 0) {
				NSString* comd = [[NSString stringWithFormat:@"nvram com.apple.System.boot-nonce=%@", value] runAsCommand];
				NSString* nonce = [self readNonceValue:nil];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title message:[NSString stringWithFormat:(comd&&nonce&&[value isEqualToString:nonce])?@"Nonce (%@) has been successfully set.":@"Error in set Nonce (%@).", value] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			} else {
				[self showErrorFormat];
			}
		} else {
			[self showErrorFormat];
		}
		[self refresh:nil];
	}
}
- (id)readValue:(PSSpecifier*)specifier
{
	return nil;
}
- (id)readNonceValue:(PSSpecifier*)specifier
{
	@autoreleasepool {
		NSString* comd = [@"nvram com.apple.System.boot-nonce" runAsCommand];
		if(comd) {
			NSRange firstR = [comd rangeOfString:@"com.apple.System.boot-nonce"];
			if(NSNotFound != firstR.location) {
				comd = [comd stringByReplacingCharactersInRange:firstR withString:@""];
			}
			comd = [comd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		}
		return comd;
	}
}
- (void)_returnKeyPressed:(id)arg1
{
	[super _returnKeyPressed:arg1];
	[self.view endEditing:YES];
}

- (void) loadView
{
	[super loadView];
	self.title = @"NonceSet";	
	static __strong UIRefreshControl *refreshControl;
	if(!refreshControl) {
		refreshControl = [[UIRefreshControl alloc] init];
		[refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
		refreshControl.tag = 8654;
	}	
	if(UITableView* tableV = (UITableView *)object_getIvar(self, class_getInstanceVariable([self class], "_table"))) {
		if(UIView* rem = [tableV viewWithTag:8654]) {
			[rem removeFromSuperview];
		}
		[tableV addSubview:refreshControl];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refresh:nil];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0);
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setString:cell.textLabel.text];
    }
}				
@end

