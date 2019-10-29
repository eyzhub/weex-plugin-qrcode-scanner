# weex-plugin-qrcode-scanner
Allows Weex applications to read open camera and return QR code for iOS and Android

## Android example

```
const pluginQrcodeScanner = weex.requireModule('pluginQrcodeScanner');

....

pluginQrcodeScanner.scan(function(resp) {  
	console.log(resp);
	if (resp.success) {
    console.log(resp.code);
  }
});
```
