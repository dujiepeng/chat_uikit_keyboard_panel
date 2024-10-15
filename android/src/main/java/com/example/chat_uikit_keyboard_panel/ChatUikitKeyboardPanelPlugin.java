package com.example.chat_uikit_keyboard_panel;

import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** ChatUikitKeyboardPanelPlugin */
public class ChatUikitKeyboardPanelPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "chat_uikit_keyboard_panel");
    channel.setMethodCallHandler(this);
  }



  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    result.notImplemented();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    View rootView = binding.getActivity().findViewById(android.R.id.content);
    rootView.getViewTreeObserver().addOnGlobalLayoutListener(() -> {
      Rect rect = new Rect();
      rootView.getWindowVisibleDisplayFrame(rect);
      double keyboardHeight = rootView.getHeight() - rect.bottom;
      HashMap<String, Double> map = new HashMap<>();
      map.put("height", keyboardHeight);
      channel.invokeMethod("height", map);
    });
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
