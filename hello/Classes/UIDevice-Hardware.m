//
//  UIDevice-Hardware.m
//  atvHelloWorld
//
//  Created by admin on 21-05-12.
//  Copyright 2012 Wayin Inc. All rights reserved.
//


/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.


#include <sys/socket.h> // definitions for second level network identifiers
#include <sys/sysctl.h> //definitions for top level identifiers, second level kernel and hardware identi-fiers, identifiers, and user level identifiers
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/cdefs.h>
#include <sys/types.h>
#include <sys/param.h>

#import <sys/types.h> 


#import <netinet/in.h>
#import <net/if_dl.h>
#import <netdb.h>
#import <arpa/inet.h>
//#import <unistd.hv> //onvindbaar
#import <ifaddrs.h>

#import <Foundation/NSObject.h> //tbv file info
#import <Foundation/NSFileManager.h>  
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <Foundation/NSURL.h>

#include <sys/param.h>  //tbv disk info
#include <sys/mount.h>  

#include <time.h> //tbv uptime
#include <errno.h>

#import "UIDevice-Hardware.h"

//#import <UIKit/UIKit.h>
//#import <Foundation/NSTask.h>




@implementation UIDevice (Hardware)
/*
 Platforms
 iFPGA -> ??
 
 iPhone1,1 -> iPhone 1G, M68
 iPhone1,2 -> iPhone 3G, N82
 iPhone2,1 -> iPhone 3GS, N88
 iPhone3,1 -> iPhone 4/AT&T, N89
 iPhone3,2 -> iPhone 4/Other Carrier?, ??
 iPhone3,3 -> iPhone 4/Verizon, TBD
 iPhone4,1 -> (iPhone 5/AT&T), TBD
 iPhone4,2 -> (iPhone 5/Verizon), TBD
 
 iPod1,1 -> iPod touch 1G, N45
 iPod2,1 -> iPod touch 2G, N72
 iPod2,2 -> Unknown, ??
 iPod3,1 -> iPod touch 3G, N18
 iPod4,1 -> iPod touch 4G, N80
 // Thanks NSForge
 iPad1,1 -> iPad 1G, WiFi and 3G, K48
 iPad2,1 -> iPad 2G, WiFi, K93
 iPad2,2 -> iPad 2G, GSM 3G, K94
 iPad2,3 -> iPad 2G, CDMA 3G, K95
 iPad3,1 -> (iPad 3G, GSM)
 iPad3,2 -> (iPad 3G, CDMA)
 
 AppleTV2,1 -> AppleTV 2, K66
 AppleTV3,1 -> AppleTV 2, K66
 
 
 i386, x86_64 -> iPhone Simulator
 */


#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = (char*)malloc(size); //char toegevoegd
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	
    free(answer);
    return results;
}

- (NSString *) platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*) malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
	
	
	
	
    return platform;
}

- (NSString *) hwmodel
{
    size_t size;
    sysctlbyname("hw.model", NULL, &size, NULL, 0);
    char *machine = (char*) malloc(size);
    sysctlbyname("hw.model", machine, &size, NULL, 0);
    NSString *hwmodel = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return hwmodel;
}




#pragma mark file system -- Thanks Joachim Bean!


- (NSNumber *) totalDiskSpace
{
	NSDictionary * fsAttributes = [ [NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
	NSNumber *totalSize = [fsAttributes objectForKey:NSFileSystemSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f GB",[totalSize floatValue] / 1073741824] ];
}

- (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
	NSNumber *totalSize = [fattributes objectForKey:NSFileSystemFreeSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f GB",[totalSize floatValue] / 1073741824] ];
}

- (NSNumber *) freeDiskSpacePct
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
	// return [fattributes objectForKey:NSFileSystemFreeSize];//original output wo format
	
	// Create formatter
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init]; 
	
	NSString *formattedOutput = [formatter stringFromNumber:[fattributes objectForKey:NSFileSystemFreeSize]];
	
	//--------------------------------------------
	// Format style as percentage, output to console
	//--------------------------------------------
	[formatter setNumberStyle:NSNumberFormatterPercentStyle];
	// Set to the current locale
	[formatter setLocale:[NSLocale currentLocale]];
	// Get percentage of system space that is available
	float percent = [[fattributes objectForKey:NSFileSystemFreeSize] floatValue] / [[fattributes objectForKey:NSFileSystemSize] floatValue];
	NSNumber *num = [NSNumber numberWithFloat:percent];
	formattedOutput = [formatter stringFromNumber:num];
	return [NSString stringWithFormat:@"percent free: %@",[formatter stringFromNumber:num]]; 
}

//--------------------------------------------
// / is the mount point for /dev/disk0s1s1
//--------------------------------------------

- (NSNumber *) tempTotalDiskSpace //size of the file system.
{
    //NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSTemporaryDirectory() error:nil];
    //return  [fattributes objectForKey:NSFileSystemSize];//werkt
	NSString *tempDisks1s1 = @"/";
	NSDictionary *fsAttributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:tempDisks1s1];
	NSNumber *totalSize = [fsAttributes objectForKey:NSFileSystemSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f MB",[totalSize floatValue] / 1048576] ];
}


- (NSNumber *) tempFreeDiskSpace //the amount of free space on the file system.
{
	NSString *tempDisks1s1 = @"/";
	NSDictionary *fattributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:tempDisks1s1];	
	NSNumber *totalSize = [fattributes objectForKey:NSFileSystemFreeSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f MB",[totalSize floatValue] / 1048576] ];
}



- (NSNumber *) pctFreeDiskSpace //the amount of free space on the file system.
{
	NSString *tempDisks1s1 = @"/";
	NSDictionary *fattributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:tempDisks1s1];

	// Create formatter
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init]; 
	
	NSString *formattedOutput = [formatter stringFromNumber:[fattributes objectForKey:NSFileSystemFreeSize]];
	
	//--------------------------------------------
	// Format style as percentage, output to console
	//--------------------------------------------
	[formatter setNumberStyle:NSNumberFormatterPercentStyle];
	
	// Set to the current locale
	[formatter setLocale:[NSLocale currentLocale]];
	
	// Get percentage of system space that is available
	float percent = [[fattributes objectForKey:NSFileSystemFreeSize] floatValue] / [[fattributes objectForKey:NSFileSystemSize] floatValue];
	NSNumber *num = [NSNumber numberWithFloat:percent];
	formattedOutput = [formatter stringFromNumber:num];
	
	return [NSString stringWithFormat:@"percent free: %@",[formatter stringFromNumber:num]]; 	
}


//--------------------------------------------
// /private/var is the mount point for /dev/disk0s1s2
//--------------------------------------------

- (NSNumber *) tempTotalDiskSpaceVar //size of the file system.
{
    //NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSTemporaryDirectory() error:nil];
    //return  [fattributes objectForKey:NSFileSystemSize];//werkt
	NSString *tempDisk0s1s2 = @"/private/var";
	NSDictionary *fsAttributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:tempDisk0s1s2];
	NSNumber *totalSize = [fsAttributes objectForKey:NSFileSystemSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f GB",[totalSize floatValue] / 1073741824] ];
}


- (NSNumber *) tempFreeDiskSpaceVar //the amount of free space on the file system.
{
	NSString *tempDisk0s1s2 = @"/private/var";
	NSDictionary *fattributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:tempDisk0s1s2];	
	NSNumber *totalSize = [fattributes objectForKey:NSFileSystemFreeSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f GB",[totalSize floatValue] / 1073741824] ];
}



- (NSNumber *) pctFreeDiskSpaceVar //the amount of free space on the file system.
{
	NSString *tempDisk0s1s2 = @"/private/var";
	NSDictionary *fattributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:tempDisk0s1s2];
	
	// Create formatter
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init]; 
	
	NSString *formattedOutput = [formatter stringFromNumber:[fattributes objectForKey:NSFileSystemFreeSize]];
	
	//--------------------------------------------
	// Format style as percentage, output to console
	//--------------------------------------------
	[formatter setNumberStyle:NSNumberFormatterPercentStyle];
	
	// Set to the current locale
	[formatter setLocale:[NSLocale currentLocale]];
	
	// Get percentage of system space that is available
	float percent = [[fattributes objectForKey:NSFileSystemFreeSize] floatValue] / [[fattributes objectForKey:NSFileSystemSize] floatValue];
	NSNumber *num = [NSNumber numberWithFloat:percent];
	formattedOutput = [formatter stringFromNumber:num];
	
	return [NSString stringWithFormat:@"percent free: %@",[formatter stringFromNumber:num]]; 	
}


//--------------------------------------------
// /dev is the mount point for devfs
//--------------------------------------------


- (NSNumber *) devFreeDiskSpace //the amount of free space on the file system.
{
	NSString *devfs = @"/dev";
	NSDictionary *fattributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:devfs];
	NSNumber *totalSize = [fattributes objectForKey:NSFileSystemFreeSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f KB",[totalSize floatValue] / 8192] ];	
}

- (NSNumber *) devTotalDiskSpace //the amount of free space on the file system.
{
	NSString *devfs = @"/dev";
	NSDictionary *fattributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath:devfs];
	NSNumber *totalSize = [fattributes objectForKey:NSFileSystemSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f KB",[totalSize floatValue] / 8192] ];	
}


- (NSNumber *) freeNodes //value indicates the number of free nodes in the file system.
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeNodes];//werkt
	//return [[fattributes objectForKey:NSFileSystemFreeNodes] LongValue];
}

- (NSNumber *) systemNodes //value indicates the number of nodes in the file system.
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemNodes];
}


- (NSNumber *) systemSize 
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    //return [fattributes objectForKey:NSFileSystemSize];
	NSNumber *totalSize = [fattributes objectForKey:NSFileSystemSize];
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f GB",[totalSize floatValue]/ 1073741824] ];	

}


- (NSNumber *) systemNumber  // indicates the filesystem number of the file system.
//is the keyed attribute that gives you the file system number for the mounted file system that contains the path
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemNumber];
}

///////////////////////////////////////////////////


- (NSString *) accountname
{
	NSError *error = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDictionary *attr = [fm attributesOfItemAtPath:@"/var/log/syslog" error:&error]; 
	NSString *fileOwnerAccountName = [attr objectForKey:NSFileOwnerAccountName];
	return [NSString stringWithFormat:@"%@", fileOwnerAccountName ];	
}

- (NSString *) accountid
{
	NSError *error = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDictionary *attr = [fm attributesOfItemAtPath:@"/var/log/syslog" error:&error]; 
	NSString *fileGroupOwnerAccountName = [attr objectForKey:NSFileGroupOwnerAccountName];
	return [NSString stringWithFormat:@"%@", fileGroupOwnerAccountName ];	
}


- (unsigned long long int) documentsFolderSize {
    NSFileManager *_manager = [NSFileManager defaultManager];
    NSArray *_documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *_documentsDirectory = [_documentPaths objectAtIndex:0];   
	
    NSArray *_documentsFileList;
    NSEnumerator *_documentsEnumerator;
    NSString *_documentFilePath;
    unsigned long long int _documentsFolderSize = 0;
	
    _documentsFileList = [_manager subpathsAtPath:_documentsDirectory];
    _documentsEnumerator = [_documentsFileList objectEnumerator];
    while (_documentFilePath = [_documentsEnumerator nextObject]) {
        NSDictionary *_documentFileAttributes = [_manager fileAttributesAtPath:[_documentsDirectory stringByAppendingPathComponent:_documentFilePath] traverseLink:YES];
        _documentsFolderSize += [_documentFileAttributes fileSize];
    }
	
    return _documentsFolderSize;
}



+(float)getTotalDiskSpaceInBytes { 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    struct statfs tStats;  
    statfs([[paths lastObject] cString], &tStats);  
    float totalSpace = (float)(tStats.f_blocks * tStats.f_bsize);  
	
    return totalSpace;  
} 



- (NSUInteger) logSize
{
	NSFileManager *fm = [[NSFileManager alloc] init];
	//NSFileManager *fm = [NSFileManager defaultManager];	
	
	return [[[fm attributesOfItemAtPath:[@"/var/log/syslog" stringByStandardizingPath] error:nil] 
			 objectForKey:NSFileSize] unsignedIntegerValue ];
}





//////////////////////////////////////////////
//
//  de  totale dir size voor de video cashes
//
//////////////////////////////////////////////


///rentals cache
- (NSString *) cachesSize
{
	//unsigned long long totalSize = 10;
	float totalSize = 0;
	NSString *folderPath = @"/private/var/mobile/Library/Caches/AppleTV/Video/LocalAndRental";
	NSArray *contents;
	NSEnumerator *enumerator;
	NSString *path;
	contents = [[NSFileManager defaultManager] subpathsAtPath:folderPath];
	enumerator = [contents objectEnumerator];
	while (path = [enumerator nextObject]) 
	{
		NSDictionary *fattrib = [[[NSFileManager alloc] init] fileAttributesAtPath:[folderPath stringByAppendingPathComponent:path] traverseLink:YES];
		totalSize +=[fattrib fileSize];
	}
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f MB", (totalSize / 1048576 )] ];
	if(contents != nil)
	{
	[contents release];
	[path release];
	}
}




- (NSString *) cachesSize1 //other
{
	float totalSize = 0;
	NSString *folderPath = @"/private/var/mobile/Library/Caches/AppleTV/Video/Other";
	NSArray *contents;
	NSEnumerator *enumerator;
	NSString *path;
	contents = [[NSFileManager defaultManager] subpathsAtPath:folderPath];
	enumerator = [contents objectEnumerator];
	while (path = [enumerator nextObject]) 
	{
		NSDictionary *fattrib2 = [[[NSFileManager alloc] init] fileAttributesAtPath:[folderPath stringByAppendingPathComponent:path] traverseLink:YES];
		totalSize +=[fattrib2 fileSize];		
	}//end while
	return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"\n\n %3.2f MB", (totalSize / 1048576 )] ];
	if(contents != nil){
	[contents release];
		[path release];}
}


#pragma mark platform type and name utils
- (NSUInteger) platformType
{
    NSString *platform = [self platform];
	
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"]) return UIDeviceIFPGA;

    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"]) return UIDeviceAppleTV2;

	// Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceiPhoneSimulatoriPhone : UIDeviceiPhoneSimulatoriPad;
    }
	
    return UIDeviceUnknown;
}

- (NSString *) platformString
{
    switch ([self platformType])
    {
    
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
		case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
	//aangepast was en0, dat gaf mac van LAN ipv wifi  LAN=1 WIFI=0
    if ((mib[5] = if_nametoindex("en1")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }

    if ((buf = (char*)malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
	}
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    //NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
      //                     *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
     NSString *outstring = [NSString stringWithFormat:@"%02X-%02X-%02X-%02X-%02X-%02X",
							*ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
	
    return outstring;
}

- (NSString *) macaddressW
{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
	//aangepast was en0, dat gaf mac van LAN ipv wifi  LAN=1 WIFI=0 (of andersom?)
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
	
    if ((buf = (char*)malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
	}
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    //NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
	//                     *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	NSString *outstring = [NSString stringWithFormat:@"%02X-%02X-%02X-%02X-%02X-%02X",
						   *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
	
    return outstring;
}


- (NSDate*)startTime //De huidige tijd opvragen in milsecs
{
	//toegevoegd als test om tijd in sec op te vragen zodat het de datum van nu geeft
	double theLoggedInTokenTimestampDateEpochSeconds = [[NSDate date] timeIntervalSince1970];
	//nu ingevoegd om de start tijd vast te leggen
    return [NSDate dateWithTimeIntervalSince1970:theLoggedInTokenTimestampDateEpochSeconds];
}


- (NSString*)startTimeAsFormattedDateTime //de starttijd omzetten naar leesbare string
{
	//struct kinfo_proc *process = NULL;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	NSDate *date = [self startTime];

	// Retrieve the date as a string.
    return [dateFormatter stringFromDate:date];
}


// Illicit Bluetooth check -- cannot be used in App Store
/*
//void loop() {
- (NSString*) bluetoothx {
	
 Class btclass = NSClassFromString(@"GKBluetoothSupport");
 if (
	 [btclass respondsToSelector:@selector(bluetoothStatus)]
	 )
 {
	 //printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
	 return [NSString stringWithFormat : @"BT status_: ", (int)[btclass performSelector:@selector(bluetoothStatus)]] ;
//	 return [NSString stringWithFormat : @"BT status_: %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)]  & 1) != 0];
	 
	 //[NSString stringWithFormat: @"kernBOOT_: %d", 
	 
	 //BOOL bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
	 
	 
	 //printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
	 //return [NSString stringWithFormat: @"BT_: %s enabled\n", bluetooth ? "is" : "isn't"];
	 
 }
}
 



- (NSString*) bluetoothy {
	
	Class btclass = NSClassFromString(@"GKBluetoothSupport");
	if (
		[btclass respondsToSelector:@selector(bluetoothStatus)]
		)
	{
		//printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
		//return [NSString stringWithFormat : @"BT status_: %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)]  & 1) != 0];
		
		//[NSString stringWithFormat: @"kernBOOT_: %d", 
		
		BOOL bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
		
		
		//printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
		//return [NSString stringWithFormat: @"BT_: ", @selector(bluetoothStatus) ];
		return [NSString stringWithFormat: @"BT_: ", bluetooth ];

		//		return [NSString stringWithFormat: @"BT_: %s enabled\n", bluetooth ? "is" : "isn't"];
		
	}
}

*/
@end










