//
//  HelloWorldMainMenu.m
//  atvHelloWorld
//
//  Created by Michael Gile on 9/11/11.
//  Copyright 2011 Michael Gile. All rights reserved.
//

#import "MemoryMainMenu.h"
#import "ApplianceConfig.h"
//#import "ApplianceConfig.h"
#import "BRImageManager.h"


#import "UIDevice-Hardware.h"
#import "UIDevice-Reachability.h"
#import "UIDevice-Uptime.h"
#import "UIDevice-KERN.h"

#include <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <IOKit/IOKitLib.h>

//nodig voor MACadress
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <netinet/in.h>
#import <net/if_dl.h>
#import <netdb.h>
#import <errno.h>
#import <arpa/inet.h>
//#import <unistd.hv> //onvindbaar
#import <ifaddrs.h>


//ingevoegd voor uptime

#import <assert.h>
#import <errno.h>
#import <stdbool.h>
#import <stdlib.h>
#import <stdio.h>
//#import <sys/sysctl.h>
//#import <sys/time.h>
#import <mach/host_info.h>
#import <mach/mach_init.h>
#import <mach/mach_host.h>
#import <SystemConfiguration/SystemConfiguration.h>


#if !defined(IFT_ETHER)
#define IFT_ETHER 0x6
#endif

#define CFN(X) [self commasForNumber:X]


@class BRWebView;

@implementation   MemoryMainMenu


- (id)init

{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	BOOL   success;
	struct ifaddrs *addrs;
	const struct ifaddrs *cursor;
	const struct if_data *networkStatisc; 
	//char buf[64];
	
	NSString *name=[[[NSString alloc]init]autorelease];
	
	success = getifaddrs(&addrs) == 0;
	if (success) 
	{
		cursor = addrs;
		while (cursor != NULL) 
		{
			name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
			//NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
			// names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN 
			
			if (cursor->ifa_addr->sa_family == AF_LINK) 
			{
				if ([name hasPrefix:@"en"]) 
				{
					networkStatisc = (const struct if_data *) cursor->ifa_data;
					
				}
				
				if ([name hasPrefix:@"pdp_ip"]) 
				{
					networkStatisc = (const struct if_data *) cursor->ifa_data;
					
				} 
			}
			
			cursor = cursor->ifa_next;
		}
		
		freeifaddrs(addrs);
	}       
	
	NSString *address = @"error"; 
	struct ifaddrs *interfaces = NULL; 
	struct ifaddrs *temp_addr = NULL; int success1 = 0; 
	// retrieve the current interfaces - returns 0 on success 
	success1 = getifaddrs(&interfaces); 
	if (success1 == 0) { 
		// Loop through linked list of interfaces 
		temp_addr = interfaces; 
		while(temp_addr != NULL) 
		{ 
			if(temp_addr->ifa_addr->sa_family == AF_INET) 
			{
				// Check if interface is en0 which is the wifi connection on the iPhone
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) 
				{ 
					// Get NSString from C String 
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; 
				}
			} temp_addr = temp_addr->ifa_next; } 
	} 
	
	
	
	self = [super init];
	if (self)
	{
		// Initialization code here.
		[self setListTitle:MEMORY_CATEGORY_NAME];
		
		BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];		
		[self setListIcon:sp horizontalOffset:1.0 kerningFactor:1.0];
		
		_names = [[NSMutableArray alloc] init];
		if ([[UIDevice currentDevice] networkAvailable])//begrijp niet wat if, de Erica code nog eens nakijken
		[_names addObject:@"**** iOS filesystem '/private/var' ****"];	//100
		[_names addObject: [NSString stringWithFormat: @"System Total		: %@", [[UIDevice currentDevice] totalDiskSpace]]];//101
		[_names addObject: [NSString stringWithFormat: @"System Free		: %@", [[UIDevice currentDevice] freeDiskSpace]]];//102
		[_names addObject: [NSString stringWithFormat: @"System		 %@", [[UIDevice currentDevice] freeDiskSpacePct]]];//103
		[_names addObject:@"**** User filesystem '/'    ****"];	//104
		[_names addObject: [NSString stringWithFormat: @"User total: %@", [[UIDevice currentDevice] tempTotalDiskSpace]]];//105
		[_names addObject: [NSString stringWithFormat: @"User free : %@", [[UIDevice currentDevice] tempFreeDiskSpace]]];//106
		[_names addObject: [NSString stringWithFormat: @"/dev/disk0s1s1  %@", [[UIDevice currentDevice] pctFreeDiskSpace]]];//107
		//keep you syslog within limits
		if ([[UIDevice currentDevice] logSize] > 4000000 ){
			
			//font color change is still ToDo
			[_names addObject:@"**** Please rotate your syslog !"];//108
		}
		[_names addObject: [NSString stringWithFormat: @"Log file in bytes	: %u", [[UIDevice currentDevice] logSize]]];//109
		
		[_names addObject: [NSString stringWithFormat: @"caches rentals: %@", [[UIDevice currentDevice] cachesSize]]];//110
		[_names addObject: [NSString stringWithFormat: @"caches other  : %@", [[UIDevice currentDevice] cachesSize1]]];//111

		
		
		//[_names addObject: [NSString stringWithFormat: @"Free  /dev			: %@", [[UIDevice currentDevice] devFreeDiskSpace]]];
		//[_names addObject: [NSString stringWithFormat: @"Total /dev			: %@", [[UIDevice currentDevice] devTotalDiskSpace]]];
		[_names addObject: [NSString stringWithFormat: @"Maximum RAM in MB	: %d", [[UIDevice currentDevice] totalMemory]]];//112 
		[_names addObject: [NSString stringWithFormat: @"Free User RAM in MB: %d", [[UIDevice currentDevice] userMemory]]];//113
		[_names addObject: [NSString stringWithFormat: @"Standard RAM in MB	: %d", [[UIDevice currentDevice] imhoMemory]]];//114
		[_names addObject: [NSString stringWithFormat: @"Buffer  size		: %d", [[UIDevice currentDevice] maxSocketBufferSize]]];//115
		

		
		//[_names addObject: [NSString stringWithFormat: @"%d",cursor]];//werkt echter geeft (null)
		//[_names addObject: [NSString stringWithFormat: @"cache   d : %d", [[UIDevice currentDevice] cachesSize33]]];//werkt niet in een UIDevice omgeving
		//[_names addObject: [NSString stringWithFormat: @"documents: %ull", [[UIDevice currentDevice] documentsFolderSize]]];//werkt niet in een UIDevice omgeving
		//[_names addObject: [NSString stringWithFormat: @"Total /dev/disk0s1s2: %@", [[UIDevice currentDevice] tempFreeDiskSpaceVar]]];		
		//[_names addObject: [NSString stringWithFormat: @"Free  /dev/disk0s1s2: %@", [[UIDevice currentDevice] tempTotalDiskSpaceVar]]];
		//[_names addObject: [NSString stringWithFormat: @"/dev/disk0s1s2 %@", [[UIDevice currentDevice] pctFreeDiskSpaceVar]]];
		//[_names addObject: [NSString stringWithFormat: @"total disk in bytes f %f", [[UIDevice currentDevice] getTotalDiskSpaceInBytes]]];
		//[_names addObject: [NSString stringWithFormat: @"User mem: %@", [[UIDevice currentDevice] userMemory]]];
		//[_names addObject:[NSNumber numberWithBool:[[UIDevice currentDevice] activeWLAN]]];
		[[self list] setDatasource:self];
		return self;
	}
	
	return self;
	
	// Free memory
    
    //imho
    /*
	freeifaddrs(interfaces); 
	return address; 
	
	*/
    
	[pool release];
	return 0;
	
}


-(void)dealloc {
	[_names release];
	[super dealloc];
}

- (id)previewControlForItem:(long)item {
	BRImage* previewImage = nil;
	
	switch (item) {
		case 0://build
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"100" ofType:@"png"]];
			break;
		case 1://product
			//previewImage = [[BRThemeInfo sharedTheme] appleTVIconOOB];
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"101" ofType:@"png"]];
			break;
		case 2://ATV
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"102" ofType:@"png"]];
			break;
		case 3://Machine
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"103" ofType:@"png"]];
			break;
		case 4://ID
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"104" ofType:@"png"]];
			break;
		case 5://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"105" ofType:@"png"]];			
			break;		
		case 6://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"106" ofType:@"png"]];			
			break;	
		case 7://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"107" ofType:@"png"]];			
			break;
		case 8://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"108" ofType:@"png"]];			
			break;	
		case 9://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"109" ofType:@"png"]];			
			break;	
		case 10://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"110" ofType:@"png"]];			
			break;	
		case 11://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"111" ofType:@"png"]];			
			break;	
		case 12://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"112" ofType:@"png"]];			
			break;	
		case 13://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"113" ofType:@"png"]];			
			break;	
		case 14://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"114" ofType:@"png"]];			
			break;	
		case 15://system
			previewImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[MemoryMainMenu class]] pathForResource:@"115" ofType:@"png"]];			
			break;
	}
	
	BRImageAndSyncingPreviewController *controller = [[BRImageAndSyncingPreviewController alloc] init];
	[controller setImage:previewImage];
	
	return controller;
}

- (void)itemSelected:(long)selected;{ 
	
	NSDictionary *currentObject = [_names objectAtIndex:selected];
	NSLog(@"%s (%d) item selected: %@", __PRETTY_FUNCTION__, __LINE__, currentObject);
	
	if (selected == 0) {
        //int result = system("");
		system("echo reboot");//test 
    }
	else if (selected == 1) {
		//int result = system("hostname > File.txt");
    }
}

- (float)heightForRow:(long)row {
	return 0.0f;
}

- (long)itemCount {
	return [_names count];
}

- (id)itemForRow:(long)row {
	
	if(row > [_names count])
		return nil;
	
	BRMenuItem* menuItem	= [[BRMenuItem alloc] init];
	NSString* menuTitle		= [_names objectAtIndex:row];
	
	[menuItem setText:menuTitle withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
	
	switch (row) {
			
		case 0:
			[menuItem addAccessoryOfType:0];
			break;
			
		case 1: 
			[menuItem addAccessoryOfType:0];
			break;
			
		default:
			[menuItem addAccessoryOfType:0];
			break;
	}
	
	return menuItem;
}

- (BOOL)rowSelectable:(long)selectable {
	return YES;
}

- (id)titleForRow:(long)row {
	return [_names objectAtIndex:row];
}

- (BOOL) brEventAction:(BREvent*)event {
	
	NSLog(@"%s (%d): Remote action = %d", __PRETTY_FUNCTION__, __LINE__, [event remoteAction]);
	NSLog(@"%s (%d): Remote value = %d", __PRETTY_FUNCTION__, __LINE__, [event value]);
	NSLog(@"%s (%d): eventDictionary = %@", __PRETTY_FUNCTION__, __LINE__, [[event eventDictionary] description]);
	
	switch ([event remoteAction]) {
		case BREventMenuButtonAction:
			[[self stack] popController];
			break;
		case BREventOKButtonAction:
		case BREventUpButtonAction:
		case BREventDownButtonAction:
		case BREventLeftButtonAction:
		case BREventRightButtonAction:
		case BREventPlayPauseButtonAction:
			/* fallthrough */
		default:
			[super brEventAction:event];
			break;
	}
	
	return YES;
}

@end
