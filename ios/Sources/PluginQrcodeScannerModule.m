//  PluginQrcodeScannerModule.m

#import "PluginQrcodeScannerModule.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
#import <WeexSDK/WXSDKInstance.h>

#import <AVFoundation/AVFoundation.h>

#define NILABLE(obj) ((obj) != nil ? (NSObject *)(obj) : (NSObject *)[NSNull null])

@implementation PluginQrcodeScannerModule

@synthesize globalCallback;
@synthesize weexInstance;
WX_PlUGIN_EXPORT_MODULE(pluginQrcodeScanner, PluginQrcodeScannerModule)
WX_EXPORT_METHOD(@selector(show:))
/**
 shows alert box

 @param json items
 */
-(void) show: (NSString *)json{
	NSLog( @"-> show" );
    NSError *jsonError;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *args = [NSJSONSerialization JSONObjectWithData:objectData  options:NSJSONReadingMutableContainers error:&jsonError];
    // UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"%@", args[@"title"]] message: args[@"message"] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"dismiss", nil];
    UIAlertController *alertview = [UIAlertController
                alertControllerWithTitle:args[@"title"]
                message:args[@"message"]
                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
    [alertview addAction:defaultAction];
    [weexInstance.viewController presentViewController:alertview animated:YES completion:nil];
}

/**
 creates the overlay to show the title bar and camera

 @param callback callback
 */
WX_EXPORT_METHOD(@selector(scanQR:))
- (void)scanQR:(WXCallback)callback {
	NSLog( @"-> scanQR" );
	NSMutableDictionary *result = [NSMutableDictionary dictionary];

    globalCallback = callback;
    // [self show: [NSString stringWithFormat:@"%.20lf"s, weexInstance.viewController.view.frame.size.width] ];

    UIViewController *vc = [[UIViewController alloc] init];
    vc.title = @"Scan QR Code";
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:vc ];
    nav.navigationBar.barStyle=UIBarStyleBlack;

    NSUInteger fontSize = 28;
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    NSDictionary *attributes = @{NSFontAttributeName: font};

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"×"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(back:)];
    [barButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    // [barButtonItem setTag: 32];
    [nav.navigationBar.topItem setLeftBarButtonItem:barButtonItem ];
    nav.navigationBar.tintColor = [UIColor whiteColor];

    CGFloat statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        statusBarHeight = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame.size.height;
    } else { // Fallback on earlier versions
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    statusBarHeight += nav.navigationBar.frame.size.height;

    NSLog(@"-> Navframe Height=%f", nav.navigationBar.frame.size.height + statusBarHeight);
    UIView *scanningView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, weexInstance.viewController.view.frame.size.width, weexInstance.viewController.view.frame.size.height + statusBarHeight)];
    scanningView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [vc.view addSubview:scanningView];

    _scanner = [[MTBBarcodeScanner alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode] previewView:scanningView];

    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        NSLog( @"-> scanQR requestCameraPermissionWithSuccess %d", success );
        if (success) {
            [[weexInstance.viewController navigationController] presentViewController:nav animated:YES completion:nil];
            [self startScanning];
        } else {
            [self displayPermissionMissingAlert];
        }
    }];
}

/**
 Configures the back buttons of the UIview

 @param callback callback
 */
- (void) back:(UIBarButtonItem *)sender {
    NSLog(@"-> Back");
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self stopScanning];
    result[@"cancel"] = @YES;
    globalCallback(result);
}

/**
 Displays an alerts allowomg the user to go to the app settings privacy page of the camera

 */
- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    NSLog( @"-> displayPermissionMissingAlert" );

    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = @"This App Would like to Access the Camera";
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = @"This device does not have a camera.";
    } else {
        message = @"An unknown error occurred.";
    }
    NSLog( @"-> displayPermissionMissingAlert message %@", message );

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction 
        actionWithTitle:@"Don't Allow" 
        style:UIAlertActionStyleDefault 
        handler:^(UIAlertAction * action) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            result[@"cancel"] = @YES;
            globalCallback(result);
        }];
    [alertController addAction:action];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler: ^(UIAlertAction * action) {
            // Take the user to Settings app to possibly change permission.
            BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
            if (canOpenSettings) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url options:[NSMutableDictionary dictionary] completionHandler: nil];
                } else {
                    // Fallback on earlier versions
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    ];
    [alertController addAction:settingsAction];
    [weexInstance.viewController presentViewController:alertController animated:YES completion:nil];
}

/**
 Starts scanning the camera image for QR codes

 */
- (void)startScanning {
    NSError *error = nil;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
       for (AVMetadataMachineReadableCodeObject *code in codes) {
           NSLog(@"-> Found unique code: %@", code.stringValue);
           result[@"code"] = code.stringValue;
           result[@"success"] = @YES;
           globalCallback(result);
           [self stopScanning];
           return;
       }
    } error:&error];

    if (error) {
        NSLog(@"An error occurred: %@", error.localizedDescription);
    }
}

/**
 Stops scanning the camera for QR codes

 */
- (void)stopScanning {
    [self.scanner stopScanning];
    [[weexInstance.viewController navigationController] dismissViewControllerAnimated:YES completion:Nil];

}



@end
