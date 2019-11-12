//  PluginQrcodeScannerModule.h

#import <Foundation/Foundation.h>
#import <WeexSDK/WeexSDK.h>

@interface PluginQrcodeScannerModule : NSObject<WXModuleProtocol>
typedef void (^IAPCallback)(id result);
+ (id)singletonManger;

- (void)show:(NSString *)json;
- (void)scanQR:(NSString *)pid :(IAPCallback)callback;

@end
