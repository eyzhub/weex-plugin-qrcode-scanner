//  PluginQrcodeScannerModule.h

#import <Foundation/Foundation.h>
#import <WeexSDK/WeexSDK.h>
#import "MTBBarcodeScanner.h"

typedef void (^WXCallback)(id result);
@interface PluginQrcodeScannerModule : NSObject<WXModuleProtocol>
@property (nonatomic, copy) WXCallback globalCallback;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;

+ (id)singletonManger;

- (void)show:(NSString *)json;
- (void)scanQR:(WXCallback)callback;

@end
