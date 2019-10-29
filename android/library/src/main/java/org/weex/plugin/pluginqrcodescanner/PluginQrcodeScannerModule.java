package org.weex.plugin.pluginqrcodescanner;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.widget.Toast;

import com.alibaba.weex.plugin.annotation.WeexModule;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.vision.barcode.Barcode;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.common.WXModule;

import org.weex.plugin.pluginqrcodescanner.barcode.BarcodeCaptureActivity;

import java.util.HashMap;
import java.util.Map;

@WeexModule(name = "pluginQrcodeScanner")
public class PluginQrcodeScannerModule extends WXModule {

    private static final String TAG = "ScannerModule";

    // Define the callback
    JSCallback jsCallback;

    // Current activity
    Activity thisActivity;

    // Our repsonse map
    private Map<String, Object> response = new HashMap();

    //sync ret example
    //TODO: Auto-generated method example
    @JSMethod(uiThread = true)
    public String syncRet(String param) {
        return param;
    }

    //async ret example
    //TODO: Auto-generated method example
    @JSMethod(uiThread = true)
    public void asyncRet(String param, JSCallback callback) {
        callback.invoke(param);
    }

    @JSMethod(uiThread = true)
    public void show() {
        Log.d(TAG, "Showing!!!");

        Toast.makeText(
                mWXSDKInstance.getContext(),
                "Module pluginQrcodeScanner Loaded",
                Toast.LENGTH_SHORT
        ).show();
    }

    @JSMethod(uiThread = true)
    public void scan(JSCallback jsCallback) {
        Log.d(TAG, "Scanning");

        this.jsCallback = jsCallback;
        this.thisActivity = ((Activity) mWXSDKInstance.getContext());

        if (ContextCompat.checkSelfPermission(thisActivity,
                Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            thisActivity.requestPermissions(new String[]{Manifest.permission.CAMERA}, 1011);
        } else {
            this.startActivity();
        }
    }

    /**
     * Handle when user denies Camera permission.
     */
    private void handleNoPermission() {
        response.put("code", null);
        response.put("success", false);
        response.put("details", "No permission");

        Toast.makeText(mWXSDKInstance.getContext(), "Permission to use Camera is required", Toast.LENGTH_SHORT).show();

        Log.d("response", response.toString());

        this.jsCallback.invoke(response);
    }

    /**
     * Start the camera activity
     */
    private void startActivity() {
        Context context = mWXSDKInstance.getContext();
        Intent intent = new Intent(context, BarcodeCaptureActivity.class);

        thisActivity.startActivityForResult(intent, 101);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 1011: {

                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    this.startActivity();
                } else {
                    this.handleNoPermission();
                }
                return;
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        Log.d("requestCode", String.valueOf(requestCode));

        if (data != null) {
            Log.d("response", data.toString());
        }

        if (requestCode == 101) {
            if (resultCode == CommonStatusCodes.SUCCESS) {
                if (data != null) {
                    Log.d("data", data.toString());

                    Barcode barcode = data.getParcelableExtra(BarcodeCaptureActivity.BarcodeObject);
                    String qrcode = barcode.displayValue;

                    Log.i(TAG, "onActivityResult: qrcode >>" + qrcode);
                    response.put("code", qrcode);
                    response.put("success", true);

                    Toast.makeText(mWXSDKInstance.getContext(), "Success", Toast.LENGTH_SHORT).show();
                }
            } else {
                response.put("code", null);
                response.put("success", false);
            }
        } else {
            response.put("code", null);
            response.put("success", false);
        }

        Log.d("response", response.toString());

        this.jsCallback.invoke(response);
    }

}