#import "ChatUikitKeyboardPanelPlugin.h"

@interface ChatUikitKeyboardPanelPlugin()
{
    double _height;
}

@property (nonatomic, strong) FlutterMethodChannel* channel;

@end

@implementation ChatUikitKeyboardPanelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"chat_uikit_keyboard_panel"
            binaryMessenger:[registrar messenger]];
  ChatUikitKeyboardPanelPlugin* instance = [[ChatUikitKeyboardPanelPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
   result(FlutterMethodNotImplemented);
}

-(instancetype)init{
    if (self = [super init]) {
        [self addObserver];
        return self;
    }

    return nil;
}

- (void) addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardAction:(NSNotification*)sender{

     NSDictionary *useInfo = [sender userInfo];
     NSValue *value = [useInfo objectForKey:UIKeyboardFrameEndUserInfoKey];


     if([sender.name isEqualToString:UIKeyboardWillShowNotification]){
         if(_height == [value CGRectValue].size.height) {
             return;
         }
         _height = [value CGRectValue].size.height;
         [self.channel invokeMethod:@"height" arguments:@(_height)];
     }else if ([sender.name isEqualToString:UIKeyboardWillHideNotification]){
         [self.channel invokeMethod:@"height" arguments:[NSNumber numberWithDouble:0]];
         _height = 0;
     }
 }


@end
