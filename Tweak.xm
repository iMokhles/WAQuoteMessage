#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import "MBProgressHUD.h"

@interface WAMessage : NSObject
@property(retain, nonatomic) NSString *text; // @dynamic text;
@end

@interface WAChatCellData : NSObject
- (id)message;
@end

@interface WAMessageCell : UITableViewCell
@property(readonly, nonatomic) WAChatCellData *cellData; // @synthesize cellData=_cellData;
- (id)referenceViewForPopupMenu;
- (CGRect)targetRectForPopupMenu;
- (id)popUpMenuItems;
- (void)willShowPopupMenu;
- (id)starMessagePopupMenuItemWithAction:(SEL)arg1;
- (id)parentMessageCell;
@end

@interface WAChatBar : UIView
@property(retain, nonatomic) WAMessage *quotedMessage;
@end

@interface WAChatBarManagerImpl : NSObject
@property(retain, nonatomic) WAMessage *quotedMessage;
@end

@interface ChatViewController : UIViewController 
@end

@interface WAMessageReplyContext : NSObject
@property(readonly, copy, nonatomic) WAMessage *quotedMessage;
@property(readonly, copy, nonatomic) NSAttributedString *attributedString;
@end

@interface WAMessageCellReplyContextView : UIView
@end

@interface WATableRow : NSObject
{
    _Bool _editable;
    _Bool _disabled;
    id _editHandler;
    id _handler;
    UITableViewCell *_cell;
}

@property(nonatomic) _Bool disabled; // @synthesize disabled=_disabled;
@property(nonatomic, getter=isEditable) _Bool editable; // @synthesize editable=_editable;
@property(retain, nonatomic) UITableViewCell *cell; // @synthesize cell=_cell;
@property(copy, nonatomic) id handler; // @synthesize handler=_handler;

@end

@interface WATableSection : NSObject
{
    NSMutableArray *_rows;
    NSString *_headerText;
    NSString *_footerText;
}

@property(retain, nonatomic) NSString *footerText; // @synthesize footerText=_footerText;
@property(retain, nonatomic) NSString *headerText; // @synthesize headerText=_headerText;
@property(retain, nonatomic) NSArray *rows; // @synthesize rows=_rows;
- (void)deleteRow:(id)arg1;
- (id)addTableRowWithCellStyle:(long long)arg1;
- (id)addDefaultTableRow;
- (void)addRow:(id)arg1;
- (id)init;

@end

@interface WAStaticTableViewController : UITableViewController
{
    NSMutableArray *_sections;
}

@property(retain, nonatomic) NSArray *sections; // @synthesize sections=_sections;
- (void)deselectActiveCell;
- (void)wa_fontSizeDidChange;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 willSelectRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 titleForFooterInSection:(int)arg2;
- (id)tableView:(id)arg1 titleForHeaderInSection:(int)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2;
- (int)numberOfSectionsInTableView:(id)arg1;
- (id)rowAtIndexPath:(id)arg1;
- (id)addSection;
- (void)setupTableView;
- (void)viewDidLoad;
- (id)initWithStyle:(int)arg1;

@end

@interface WAStaticTableViewController (WASendAny9)
- (WATableSection *)addSectionAtTop;
@end

@interface DebugViewController : WAStaticTableViewController
- (id)init;
@end

@interface WASettingsViewController : WAStaticTableViewController
@end

BOOL isLowerThanIOS7() {
	return [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0;
}

static WAMessage *quotedMsg;
static BOOL isQuotedTweak = NO;
UISwitch *switchview1;

BOOL GetBool(NSString *key)
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
}

%hook WAStaticTableViewController
%new
- (WATableSection *)addSectionAtTop {
    WATableSection *waeTableSection = [[objc_getClass("WATableSection") alloc] init];
    NSMutableArray *sectionsStatic = [self valueForKey:@"_sections"]; //&ZKHookIvar(self, NSMutableArray, "_sections"); //MSHookIvar<NSMutableArray *>(self, "_sections");
    [sectionsStatic insertObject:waeTableSection atIndex:1];
    return waeTableSection;
}
%end

%hook WASettingsViewController
- (void)setupTableView {
    
    %orig;

    WATableSection *waeTabSection = [(WASettingsViewController *)self addSectionAtTop];
    waeTabSection.headerText = @"WAQuoteMessage";
	waeTabSection.footerText = @"ENABLE ONLY IF YOU FACED ISSUE WITH THE TWEAK";

	NSString *waquoteMessage = @"Fix Quote Message";
	WATableRow *advancedRow = [objc_getClass("WATableRow") new];
	[advancedRow setHandler:^{
		[(WASettingsViewController *)self deselectActiveCell];
	        
	}];
	UITableViewCell *advancedCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WAQuoteMessageCell"];
	advancedCell.selectionStyle = UITableViewCellSelectionStyleNone;
	switchview1 = [UISwitch new];
	[switchview1 setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"waquote_options_bool"] boolValue] animated:NO];
	switchview1.tag = 34;
	[switchview1 addTarget:self action:@selector(_didToggleEnableDisable:) forControlEvents:UIControlEventValueChanged];
	advancedCell.accessoryView = switchview1;
	[advancedRow setCell:advancedCell];
	[advancedCell.textLabel setText:waquoteMessage];
	[advancedCell.textLabel setTextAlignment:NSTextAlignmentLeft];
	[waeTabSection addRow:advancedRow];

}

%new
- (void)_didToggleEnableDisable:(UISwitch *)sw {
    if (sw.tag == 34) {
    	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sw.on] forKey:@"waquote_options_bool"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
%end

%hook WAMessageCell
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if (isLowerThanIOS7() == YES) {
    	if ( action == @selector(replyToMessage:) || action == @selector(messageDetails:)) {
	        return YES;
	    } else {
	    	return %orig;
	    }
    } else {
    	if ( action == @selector(replyToMessage:) || action == @selector(messageDetails:)) {
	        return YES;
	    } else {
	    	return %orig;
	    }
    }
	
    return %orig;
}
%end

%hook ChatViewController

- (void)replyToMessageInCell:(WAMessageCell *)arg1 {

	if (isLowerThanIOS7() == YES) {
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		hud.mode = MBProgressHUDModeAnnularDeterminate;
		hud.labelText = @"saved";
		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
	        
	        dispatch_async(dispatch_get_main_queue(), ^{
	        	WAChatBarManagerImpl *chatBarManager = [self valueForKey:@"_chatBarManager"];
				[chatBarManager setQuotedMessage:arg1.cellData.message];
				quotedMsg = arg1.cellData.message;
				isQuotedTweak = YES;
				NSLog(@"isQuotedTweak = YES");
	            [hud hide:YES];
	        });
	    });
	} else {
		if (GetBool(@"waquote_options_bool")) {
			MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
			hud.mode = MBProgressHUDModeAnnularDeterminate;
			hud.labelText = @"saved";
			dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		        
		        dispatch_async(dispatch_get_main_queue(), ^{
		        	WAChatBarManagerImpl *chatBarManager = [self valueForKey:@"_chatBarManager"];
					[chatBarManager setQuotedMessage:arg1.cellData.message];
					quotedMsg = arg1.cellData.message;
					isQuotedTweak = YES;
					NSLog(@"isQuotedTweak = YES");
		            [hud hide:YES];
		        });
		    });
		} else {
			isQuotedTweak = NO;
			NSLog(@"isQuotedTweak = NO");
			%orig;
		}
		
	}
	
}
- (void)chatBarManager:(id)arg1 userDidSubmitText:(id)arg2 metadata:(id)arg3 completion:(id)arg4 {

	%orig();
	if (isLowerThanIOS7() == YES) {
		isQuotedTweak = NO;
		NSLog(@"isQuotedTweak = NO");
	}
	
}
%end

%hook WAChatStorage
- (id)sendMessageWithText:(id)arg1 metadata:(id)arg2 replyingToMessage:(id)arg3 inChatSession:(id)arg4 {

	if (isQuotedTweak) {
		return %orig(arg1, arg2, quotedMsg, arg4);
	} else {
		return %orig(arg1, arg2, arg3, arg4);
	}

}

- (void)sendDocumentAttachment:(id)arg1 replyingToMessage:(id)arg2 inChatSession:(id)arg3 completion:(id)arg4 {
	if (isQuotedTweak) {
		return %orig(arg1, quotedMsg, arg3, arg4);
	} else {
		return %orig(arg1, arg2, arg3, arg4);
	}
}

- (void)sendAudioTrack:(id)arg1 replyingToMessage:(id)arg2 inChatSession:(id)arg3 completion:(id)arg4 {
	if (isQuotedTweak) {
		return %orig(arg1, quotedMsg, arg3, arg4);
	} else {
		return %orig(arg1, arg2, arg3, arg4);
	}
}

- (void)sendVCard:(id)arg1 replyingToMessage:(id)arg2 inChatSession:(id)arg3 {
	if (isQuotedTweak) {
		return %orig(arg1, quotedMsg, arg3);
	} else {
		return %orig(arg1, arg2, arg3);
	}
}

- (void)sendPlace:(id)arg1 replyingToMessage:(id)arg2 inChatSession:(id)arg3 completion:(id)arg4 {
	if (isQuotedTweak) {
		return %orig(arg1, quotedMsg, arg3, arg4);
	} else {
		return %orig(arg1, arg2, arg3, arg4);
	}
}

- (void)sendVideoAtURL:(id)arg1 caption:(id)arg2 collectionID:(id)arg3 index:(long long)arg4 count:(long long)arg5 replyingToMessage:(id)arg6 inChatSession:(id)arg7 completion:(id)arg8 {
	if (isQuotedTweak) {
		return %orig(arg1, arg2, arg3, arg4, arg5, quotedMsg, arg7, arg8);
	} else {
		return %orig(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	}
}
- (void)sendMessageWithImage:(id)arg1 caption:(id)arg2 collectionID:(id)arg3 index:(long long)arg4 count:(long long)arg5 replyingToMessage:(id)arg6 inChatSession:(id)arg7 completion:(id)arg8 {
	if (isQuotedTweak) {
		return %orig(arg1, arg2, arg3, arg4, arg5, quotedMsg, arg7, arg8);
	} else {
		return %orig(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	}
}
- (void)sendMessageWithImage:(id)arg1 caption:(id)arg2 replyingToMessage:(id)arg3 inChatSession:(id)arg4 completion:(id)arg5 {
	if (isQuotedTweak) {
		return %orig(arg1, arg2, quotedMsg, arg4, arg5);
	} else {
		return %orig(arg1, arg2, arg3, arg4, arg5);
	}
}
%end
