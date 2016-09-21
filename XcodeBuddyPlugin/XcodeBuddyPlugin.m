//
//  XcodeBuddyPlugin.m
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/3/31.
//  Copyright © 2016年 crafthm. All rights reserved.
//

#import <objc/runtime.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <string.h>
#import "XcodeBuddyPlugin.h"
#import "XcodePrivate.h"
#import "CommContent.h"
#import "XcodeTheme.h"
#import "ConnectAlert.h"
#import "ClientSocket.h"
#import "SendProjectFilesWindowController.h"
#import "HelpWindowController.h"
#import "UserInfoKeys.h"
#import "DVTUserNotificationCenter+XcodeBuddy.h"

static void *XcodeBuddyMenuObserver = &XcodeBuddyMenuObserver;

//plist key
static NSString *const kHostAddressList= @"HostAddressList";

//Xcode UI String
NSString *const MenuItemTitleOpenWithxcBuddy = @"Open with xcBuddy";
NSString *const MenuItemTitleOpenWithExternalEditor= @"Open with External Editor";
NSString *const MenuItemTitleEdit=@"Edit";
NSString *const MenuItemTitleXcodeBuddy=@"XcodeBuddy";
NSString *const MenuItemTitleConnect=@"Connect";
NSString *const MenuItemTitleDisconnect=@"Disconnect";
NSString *const MenuItemTitleSendProjectFiles=@"Send All Project Files";


NSString *const ProjectNavigatorContextualMenu = @"Project navigator contextual menu";
NSString *const DisconnectORReconnect=@"Disconnect from %@,or Reconnect to there ?";

NSString *const XcodeBuddyPluginNewVersionNotification = @"XcodeBuddyPluginNewVersionNotification";

//常连ip列表的最大菜单项个数
NSUInteger const MaxCountOfHostArray=5;
ConnectAlert* connectAlert;

NSArray* IgnordDirectoryName;
NSArray*  CanSendedFileExtension;

@interface XcodeBuddyPlugin()

@property (nonatomic, assign) BOOL projectNavigatorContextualMenuIsOpened;

@property (nonatomic, strong) NSMutableSet *notificationSet;
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic,copy) NSURL *currentFileURL;
@property (nonatomic,strong) SendProjectFilesWindowController* sendProjectFilesWindowController;
@property (nonatomic,strong) HelpWindowController* helpWindowController;


@end

@implementation XcodeBuddyPlugin

@synthesize WorkSpaceFilePath;

ConnectAlert *connectAlert ;

NSMutableArray *hostarray;

NSMenuItem *XcodeBuddyMenuItem;
NSMenuItem *disconnectMenuItem;

NSInteger TagOfConnectMenuItem = 1;
NSInteger TagOfSendProjectMenuItem = 2;
NSInteger TagOfDisconnectMenuItem = 3;
NSInteger TagOfClearMenuItem = 4;
NSInteger TagOfHelpMenuItem = 5;
NSInteger TagOfHostAddrList = 6;

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}


- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didNSMenuDidChangeItemNotification:)
                                                     name:NSMenuDidChangeItemNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        CanSendedFileExtension=@[@"h",@"m",@"swift",@"mm",@"c",@"hpp",@"cpp",@"xcworkspace",@"pbxproj",@"xcscheme",@"xcbkptlist",@"plist"];
        IgnordDirectoryName=@[@"Frameworks",@"Resources"];
        [self compareVersion: plugin] ;
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    [self updateMainMenuItems];
}

#pragma mark - compare version

- (void) compareVersion:(NSBundle*)plugin {
    NSString *currentVersion = [plugin objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLatestVersion];
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kLatestVersion];
    if (lastVersion == nil || [currentVersion compare: lastVersion options:NSNumericSearch] == NSOrderedDescending) {
        NSUserNotification *notification = [NSUserNotification new] ;
        notification.title = [NSString stringWithFormat:@"XcodeBuddyPlugin updated to %@",currentVersion];
        notification.informativeText = @"View realease notes";
        notification.userInfo = @{XcodeBuddyPluginNewVersionNotification: @(YES)};
        notification.actionButtonTitle = @"View";
//        [notification setValue:@(YES) forKey:@"_showButtons"];
        notification.hasActionButton = YES;
        notification.actionButtonTitle = @"OK";
        notification.otherButtonTitle = @"Cancle";
        
        [[DVTUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kLatestVersion];
    }
}

#pragma mark - main menu and context menu

-(void)updateMainMenuItems
{
    // Create menu items, initialize UI, etc.
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:MenuItemTitleEdit] ;
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        XcodeBuddyMenuItem = [[menuItem submenu] itemWithTitle:MenuItemTitleXcodeBuddy];
        if (XcodeBuddyMenuItem != nil) {
            [[XcodeBuddyMenuItem submenu] removeAllItems];
        } else {
            XcodeBuddyMenuItem = [[NSMenuItem alloc] initWithTitle:MenuItemTitleXcodeBuddy action:nil keyEquivalent:@""];
            NSMenu *subMenu=[[NSMenu alloc] init];
            XcodeBuddyMenuItem.submenu=subMenu;
            [[menuItem submenu] addItem:XcodeBuddyMenuItem];
        }
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        //        [mainMenuItem setTarget:self];
        
        //connect
        NSMenuItem *linkMenuItem=[[NSMenuItem alloc] initWithTitle:MenuItemTitleConnect action:@selector(doClickMenuItemAction:) keyEquivalent:@""];
        linkMenuItem.tag = TagOfConnectMenuItem;
        [linkMenuItem setTarget:self];
        [XcodeBuddyMenuItem.submenu addItem:linkMenuItem];
        
        //Send All Project Files
        NSMenuItem *sendMenuItem=[[NSMenuItem alloc] initWithTitle:MenuItemTitleSendProjectFiles action:@selector(doClickMenuItemAction:) keyEquivalent:@""];
        sendMenuItem.tag = TagOfSendProjectMenuItem;
        [sendMenuItem setTarget:self];
        [XcodeBuddyMenuItem.submenu addItem:sendMenuItem];
        
        //disconnect
        disconnectMenuItem=[[NSMenuItem alloc] initWithTitle:MenuItemTitleDisconnect action:@selector(doClickMenuItemAction:) keyEquivalent:@""];
        disconnectMenuItem.tag = TagOfDisconnectMenuItem;
        [disconnectMenuItem setTarget:self];
//        [disconnectMenuItem setAction:nil];
        [XcodeBuddyMenuItem.submenu addItem:disconnectMenuItem];
#ifdef DEBUG
        //clear menu
//        NSMenuItem *cleartMenuItem=[[NSMenuItem alloc] initWithTitle:@"Clear Menu" action:@selector(doClickMenuItemAction:) keyEquivalent:@""];
//        [cleartMenuItem setTarget:self];
//        [XcodeBuddyMenuItem.submenu addItem:cleartMenuItem];
#endif
        //help menu
        NSMenuItem *helpMenuItem = [[NSMenuItem alloc] initWithTitle:@"Help" action:@selector(doClickMenuItemAction:) keyEquivalent:@""];
        helpMenuItem.tag = TagOfHelpMenuItem;
        [helpMenuItem setTarget:self];
        [XcodeBuddyMenuItem.submenu addItem:helpMenuItem];
        
        //添加曾经连接过的IP
        [[XcodeBuddyMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        
        hostarray = [[NSMutableArray alloc] init];
        
        NSArray* tArray =[[NSUserDefaults standardUserDefaults] objectForKey:kHostAddressList];
        if (tArray != nil) {
            [hostarray addObjectsFromArray:tArray];
            for (NSString *parray in hostarray){
                NSMenuItem *mitem=[[NSMenuItem alloc] initWithTitle:parray action:@selector(doClickMenuItemAction:) keyEquivalent:@""];
                [mitem setTarget:self];
                [[XcodeBuddyMenuItem submenu] addItem:mitem];
            }
        }
        
    }
    /*
    menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
    if (menuItem) {
        NSMenuItem* menuItemOpenWithEE=[[menuItem submenu] itemWithTitle:MenuItemTitleOpenWithExternalEditor];
        NSUInteger index=[[menuItem submenu] indexOfItem:menuItemOpenWithEE];
        if (menuItemOpenWithEE) {
            NSMenuItem* menuItemOpenWithxcBuddy=[[NSMenuItem alloc] initWithTitle:MenuItemTitleOpenWithxcBuddy action: @selector(doOpenWithXcBuddyMenuAction) keyEquivalent:@""];
            [menuItemOpenWithxcBuddy setTarget:self];
            [[menuItem submenu] insertItem:menuItemOpenWithxcBuddy atIndex:index+1];
        }
    }*/
}

+ (void) updateHostListMenuItemState:(NSString*) ipAndPort state:(BOOL) state{
    NSMenuItem* item=[[XcodeBuddyMenuItem submenu] itemWithTitle:ipAndPort];
    if (item == nil) {
        item=[[NSMenuItem alloc] initWithTitle:ipAndPort action:@selector(doClickHostAddrList:) keyEquivalent:@""];
        [item setTarget:self];
        [[XcodeBuddyMenuItem submenu] addItem:item];
    }
    if (state == YES)
        [item setState:NSOnState];
    else
        [item setState:NSOffState];
}


//初始化右键菜单
- (void) didNSMenuDidChangeItemNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"NSMenuDidChangeItemNotification"]){
        
        NSMenu* mainMenu=(NSMenu*)notification.object;
        NSMenuItem* showInxcBuddyMenu=nil;
        if ([mainMenu.title isEqualToString:ProjectNavigatorContextualMenu]) {
            self.currentFileURL = [self currentContextNavigableItemURL];
            if (self.currentFileURL == nil)
                return ;
            showInxcBuddyMenu=[mainMenu itemWithTitle:MenuItemTitleOpenWithxcBuddy];
            if (showInxcBuddyMenu == nil){
                NSMenuItem* menuItemOpenWithEE=[mainMenu  itemWithTitle:MenuItemTitleOpenWithExternalEditor];
                NSUInteger index=[mainMenu  indexOfItem:menuItemOpenWithEE];
                showInxcBuddyMenu=[[NSMenuItem alloc] initWithTitle:MenuItemTitleOpenWithxcBuddy action:@selector(doOpenWithXcBuddyMenuAction) keyEquivalent:@""];
                showInxcBuddyMenu.target=self;
                //                [mainMenu addItem:[NSMenuItem separatorItem]];
                //                [mainMenu addItem:showInxcBuddyMenu];
                [mainMenu insertItem:showInxcBuddyMenu atIndex:index+1];
            }
            showInxcBuddyMenu.enabled= YES;
        }
    }
}


- (NSURL *)currentSelectedNavigableItemURL {
    IDEFileNavigableItem *item = [[self  selectedSourceCodeFileNavigableItems] firstObject];
    return [item fileURL];
}

- (NSURL *)currentContextNavigableItemURL{
    IDENavigableItem *item = [self contextSourceCodeFileNavigableItems ];
    if ([item isKindOfClass:[IDEFileNavigableItem class]]){
        return ((IDEFileNavigableItem*) item).fileURL;
    }
    return nil;
}


#pragma mark - menu item's selector

- (void)doOpenWithXcBuddyMenuAction{
    if (clientSocketObject.clientSocket != nil && [clientSocketObject.clientSocket isConnected]) {
       
    }
    else {
        [self doConnectMenuAction];
    }
    NSURL *currentFileURL = [self currentContextNavigableItemURL];
    if (currentFileURL != nil){
        //FIXME:文件过大的处理和测试
        //发送文件路径（包含文件名）
        [XcodeBuddyPlugin   sendFile:currentFileURL Type:kFileContent];
    }
}

+ (BOOL) sendFile:(NSURL*)filePath Type:(NSInteger) type{
    NSString* workspacePath=self.WorkSpaceFilePath;
    if(workspacePath == nil)
        return NO;
//    NSString* FileRelativePath=self.WorkSpaceFilePath.stringByDeletingLastPathComponent;
     NSString* FileRelativePath=self.WorkSpaceFilePath;
    NSString* ProjectName=[FileRelativePath lastPathComponent];
    NSString* RelativePath=[ProjectName stringByAppendingPathComponent: [filePath.path stringByReplacingOccurrencesOfString:FileRelativePath withString:@""]];

    CommContent* commContent=[[CommContent alloc] init];
    commContent.type=type;
    commContent.str=RelativePath;
    commContent.data=[[NSData alloc] initWithContentsOfFile:filePath.path];
    commContent.length=commContent.data.length;
//     [clientSocketObject.clientSocket writeData:[NSKeyedArchiver archivedDataWithRootObject:commContent] withTimeout:-1 tag:0];
    
    NSMutableData* sendData = [NSMutableData data];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:sendData];
    [archiver encodeObject:commContent forKey:@"objData"];
    [archiver finishEncoding];
    [clientSocketObject.clientSocket writeData:sendData withTimeout:-1 tag:0];
    return YES;
}

- (void) doClickMenuItemAction:(id)sender {

    if ([sender isKindOfClass:[NSMenuItem class]]) {
        NSMenuItem *mItem = (NSMenuItem*)sender;
        if (mItem.tag == TagOfConnectMenuItem) {
            [self doConnectMenuAction];
        }
        else if (mItem.tag == TagOfSendProjectMenuItem) {
            if(self.sendProjectFilesWindowController == nil) {
                self.sendProjectFilesWindowController=[[SendProjectFilesWindowController alloc] initWithWindowNibName:@"SendProjectFilesWindowController"];
            }
            self.sendProjectFilesWindowController.window.title=@"XcodeBuddy";
            [self.sendProjectFilesWindowController.window makeKeyAndOrderFront:nil];
        }
        else if (mItem.tag  == TagOfDisconnectMenuItem) {
             [clientSocketObject disconnect];
        }
        else if (mItem.tag == TagOfClearMenuItem) {
            for(NSString* host in hostarray){
                NSMenuItem* item=[[XcodeBuddyMenuItem submenu] itemWithTitle:host];
                if (item!=nil) {
                    [[XcodeBuddyMenuItem submenu] removeItem:item];
                    item=nil;
                }
            }
            [hostarray removeAllObjects];
            [[NSUserDefaults standardUserDefaults] setObject:hostarray forKey:kHostAddressList];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if (mItem.tag == TagOfHelpMenuItem) {
            if (self.helpWindowController == nil) {
               self.helpWindowController = [[HelpWindowController alloc] initWithWindowNibName:@"HelpWindowController"];
            }
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            [self.helpWindowController.window makeKeyAndOrderFront:nil];
        }
        else if (mItem.tag == TagOfHostAddrList) {
            [self doClickHostAddrList:mItem];
        }
    }

}

- (void)doConnectMenuAction
{
    BOOL isConnected=NO;
    if (clientSocketObject.clientSocket != nil && clientSocketObject.clientSocket.isConnected)
        isConnected=YES;
    connectAlert =[[ConnectAlert alloc] init:isConnected];
    [connectAlert runModal];
}

- (void) doClickHostAddrList:(NSMenuItem*) menuitem {
    NSString* ip;
    UInt16 port;
    NSArray *array=[menuitem.title componentsSeparatedByString:@":"];
    ip =[array[0] stringValue];
    port=[array[1] intValue];
    if ((clientSocketObject.clientSocket.isConnected) && ([clientSocketObject.clientSocket.connectedHost isEqualToString:ip]) && (clientSocketObject.clientSocket.connectedPort==port)) {
        NSAlert *alert= [[NSAlert alloc] init];
        alert.informativeText=[[NSString alloc] initWithFormat:DisconnectORReconnect,menuitem.title];
        alert.messageText=@"XcodeBuddy";
        alert.showsHelp=NO;
        [alert addButtonWithTitle:@"Reconnect"];
        [alert addButtonWithTitle:@"Disconnect"];
        [alert addButtonWithTitle:@"Cancle"];
        NSModalResponse respTag=[alert runModal];
        switch (respTag) {
            case NSAlertFirstButtonReturn:
                [clientSocketObject connectToHost:ip andPort:port];
                break;
            case NSAlertSecondButtonReturn:
                [clientSocketObject disconnect];
                break;
            case NSAlertThirdButtonReturn:
                break;
        }
    }
    else {
        [clientSocketObject connectToHost:ip andPort:port];
    }
}

+(void) addToHostList:(NSString*) ip port:(UInt16)port {
    if (hostarray == nil) {
        hostarray=[[NSMutableArray alloc] init];
    }
    NSString* addStr=[[NSString alloc] initWithFormat:@"%@:%d" ,ip,port ];
    NSUInteger count=[hostarray count];
    NSLog(@"hostarray:%@",hostarray);
    if ([hostarray containsObject:addStr]== NO){
        if (count < MaxCountOfHostArray)
            [hostarray addObject:addStr];
        else {
            [hostarray removeObjectAtIndex:0];
            [hostarray addObject:addStr];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:hostarray forKey:kHostAddressList];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[self class] updateHostListMenuItemState:addStr state:YES];
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSArray *)selectedSourceCodeFileNavigableItems {
    NSMutableArray *mutableArray = [NSMutableArray array];
    id currentWindowController = [[NSApp keyWindow] windowController];
    
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = currentWindowController;
        IDEWorkspaceTabController *workspaceTabController = [workspaceController activeWorkspaceTabController];
        IDENavigatorArea *navigatorArea = [workspaceTabController navigatorArea];
        id currentNavigator = [navigatorArea currentNavigator];
        
        if ([currentNavigator isKindOfClass:NSClassFromString(@"IDEStructureNavigator")]) {
            IDEStructureNavigator *structureNavigator = currentNavigator;
            for (id selectedObject in structureNavigator.selectedObjects) {
                NSArray *arrayOfFiles = [self recursivlyCollectFileNavigableItemsFrom:selectedObject];
                
                if ([arrayOfFiles count]) {
                    [mutableArray addObjectsFromArray:arrayOfFiles];
                }
            }
        }
    }
    
    if ([mutableArray count]) {
        return [NSArray arrayWithArray:mutableArray];
    }
    
    return nil;
}


- (IDENavigableItem *)contextSourceCodeFileNavigableItems {
    id currentWindowController = [[NSApp keyWindow] windowController];
    
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = currentWindowController;
        id currentNavigator = [[[workspaceController activeWorkspaceTabController] navigatorArea] currentNavigator];
        __block IDENavigableItem* item=nil;
        if ([currentNavigator isKindOfClass:NSClassFromString(@"IDEStructureNavigator")]) {
            IDEStructureNavigator *structureNavigator = currentNavigator;
            NSIndexSet *indexSet=[[structureNavigator outlineView] contextMenuSelectedRowIndexes];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                item= [[structureNavigator outlineView] itemAtRow:idx];
            }];
            return item;
        }
    }
    
    
    
    return nil;
}

+(NSString*) WorkSpaceFilePath {
//    id currentWindowController = [[NSApp keyWindow] windowController];
//    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")])
//    {
//        IDEWorkspaceWindowController *workspaceController = currentWindowController;
//        return [[[workspaceController valueForKey:@"_workspace"] valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
//    }
//    return nil;
    for (NSDocument *document in [NSApp orderedDocuments]) {
        @try {
            //        _workspace(IDEWorkspace) -> representingFilePath(DVTFilePath) -> relativePathOnVolume(NSString)
            NSURL *workspaceDirectoryURL = [[[document valueForKeyPath:@"_workspace.representingFilePath.fileURL"] URLByDeletingLastPathComponent] filePathURL];
            
            if(workspaceDirectoryURL) {
                return workspaceDirectoryURL.path;
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"OROpenInAppCode Xcode plugin: Raised an exception while asking for the documents '_workspace.representingFilePath.relativePathOnVolume' key path: %@", exception);
        }
    }
    
    return nil;
    
}


- (NSArray *)recursivlyCollectFileNavigableItemsFrom:(IDENavigableItem *)selectedObject {
    id items = nil;
    
    if ([selectedObject isKindOfClass:NSClassFromString(@"IDEGroupNavigableItem")]) {
        NSMutableArray *mItems = [NSMutableArray array];
        IDEGroupNavigableItem *groupNavigableItem = (IDEGroupNavigableItem *)selectedObject;
        
        for (IDENavigableItem *child in groupNavigableItem.childItems) {
            NSArray *childItems = [self recursivlyCollectFileNavigableItemsFrom:child];
            
            if (childItems.count) {
                [mItems addObjectsFromArray:childItems];
            }
        }
        
        items = mItems;
    }
    else if ([selectedObject isKindOfClass:NSClassFromString(@"IDEFileNavigableItem")]) {
        IDEFileNavigableItem *fileNavigableItem = (IDEFileNavigableItem *)selectedObject;
        NSString *uti = [[fileNavigableItem documentType] identifier];
        
        if ([[NSWorkspace sharedWorkspace] type:uti conformsToType:(NSString *)kUTTypeSourceCode]) {
            items = @[fileNavigableItem];
        }
    }
    
    return items;
}


@end
