//
//  connectAlert.m
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/3/23.
//  Copyright © 2016年 craftman. All rights reserved.
//

#import "ConnectAlert.h"
#import "XcodeBuddyPlugin.h"
#import "ClientSocket.h"

@implementation ConnectAlert

@synthesize IPInputTextField,PortInputTextField,linkButton;

- (id)init:(BOOL) isConnected {
    if (self=[super init]) {
        NSTextField* IPTextField=[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [IPTextField setBezeled:NO];
        [IPTextField setDrawsBackground:NO];
        [IPTextField setEditable:NO];
        [IPTextField setSelectable:NO];
        IPTextField.stringValue=@"IP: ";
        [IPTextField setBackgroundColor: [NSColor redColor]];
        
        IPInputTextField=[[NSTextField alloc] initWithFrame:NSMakeRect(20, 0, 100, 20)];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(inputTextFieldDidChangeForIP:)
                                                     name:NSControlTextDidChangeNotification
                                                   object:IPInputTextField];
        
        NSTextField* PortTextField=[[NSTextField alloc] initWithFrame:NSMakeRect(125, 0, 50, 20)];
        [PortTextField setBezeled:NO];
        [PortTextField setDrawsBackground:NO];
        [PortTextField setEditable:NO];
        [PortTextField setSelectable:NO];
        PortTextField.stringValue=@"Port:";
        
        
        PortInputTextField=[[NSTextField alloc] initWithFrame:NSMakeRect(165, 0, 50, 20)];
        PortInputTextField.stringValue=@"9100";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(inputTextFieldDidChangeForPort:)
                                                     name:NSControlTextDidChangeNotification
                                                   object:PortInputTextField];
        
        linkButton=[[NSButton alloc] initWithFrame:NSMakeRect(220, -5, 100, 30)];
    
        if ( isConnected == NO) {
            self.linkButton.title=@"Connect";
            [self setInformativeText:@"Disconncted"];
        }
        else {
            self.linkButton.title=@"Disconnect";
            [self setInformativeText:@"Connected"];
        }
     
        linkButton.bezelStyle = NSRoundedBezelStyle;
        [linkButton setTarget:self];
        [linkButton setAction:@selector(onClickConnectButton:)];
        
        
        NSView  *accessoryview=[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 350, 30)];
        [accessoryview addSubview:IPTextField];
        [accessoryview addSubview:IPInputTextField];
        [accessoryview addSubview:PortTextField];
        [accessoryview addSubview:PortInputTextField];
        [accessoryview addSubview:linkButton];
        
        self.accessoryView=accessoryview;
        [self addButtonWithTitle:@"OK"];
        self.alertStyle=NSInformationalAlertStyle;
        [self setMessageText:@"please open xcBuddy app on your ipad!"];
    }
    return self;
}

- (void) alertUIChange{
    if (clientSocketObject.clientSocket==nil || (clientSocketObject.clientSocket !=nil&& clientSocketObject.clientSocket.isConnected == NO)) {
        [self setInformativeText:@"Disconnected!"];
        [linkButton setTitle:@"Connect"];
    }
    else {
        [self setInformativeText:@"Connected!"];
        [linkButton setTitle:@"Disconnect"];
    }
}

#pragma mark - button action


- (void) onClickConnectButton:(id)sender{
    NSString * IP= [IPInputTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * Port=[PortInputTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([IP length]==0 || [Port length]==0)
        return;
    if (clientSocketObject != nil) {
        if (clientSocketObject.clientSocket != nil) {
           if (clientSocketObject.clientSocket.isConnected == NO)
               [clientSocketObject connectToHost:IP andPort:Port.intValue];
            else
                [clientSocketObject disconnect];
        }
    }
}

#pragma mark - NSTextField Delegate

- (void) inputTextFieldDidChangeForIP:(NSNotification*)noti{
    NSTextField* textField=(NSTextField*)[noti object];
    NSCharacterSet* characterSet=[NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    textField.stringValue=[textField.stringValue stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    if (textField.stringValue.length > 15){
        textField.stringValue=[textField.stringValue substringWithRange:NSMakeRange(0, 15)];
    }
}

-(void) inputTextFieldDidChangeForPort:(NSNotification*)noti{
    NSTextField* textField=(NSTextField*)[noti object];
    NSCharacterSet* characterSet=[NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    textField.stringValue=[textField.stringValue stringByTrimmingCharactersInSet:[characterSet invertedSet]];
}


@end
