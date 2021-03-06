//
//  UIDevice-Hardware.h
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#define IFPGA_NAMESTRING @"iFPGA"

#define IPHONE_1G_NAMESTRING @"iPhone 1G"
#define IPHONE_3G_NAMESTRING @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING @"iPhone 3GS"
#define IPHONE_4_NAMESTRING @"iPhone 4"
#define IPHONE_5_NAMESTRING @"iPhone 5"
#define IPHONE_UNKNOWN_NAMESTRING @"Unknown iPhone"

#define IPOD_1G_NAMESTRING @"iPod touch 1G"
#define IPOD_2G_NAMESTRING @"iPod touch 2G"
#define IPOD_3G_NAMESTRING @"iPod touch 3G"
#define IPOD_4G_NAMESTRING @"iPod touch 4G"
#define IPOD_UNKNOWN_NAMESTRING @"Unknown iPod"

#define IPAD_1G_NAMESTRING @"iPad 1G"
#define IPAD_2G_NAMESTRING @"iPad 2G"
#define IPAD_3G_NAMESTRING @"iPad 3G"
#define IPAD_UNKNOWN_NAMESTRING @"Unknown iPad"

#define APPLETV_2G_NAMESTRING @"Apple A4"
#define APPLETV_3G_NAMESTRING @"Apple A5"

#define APPLETV_UNKNOWN_NAMESTRING @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE @"Unknown iOS device"

#define IPHONE_SIMULATOR_NAMESTRING @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPHONE_NAMESTRING @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPAD_NAMESTRING @"iPad Simulator"


typedef enum {
    UIDeviceUnknown,
    
    UIDeviceiPhoneSimulator,
    UIDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    UIDeviceiPhoneSimulatoriPad,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice5iPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    
    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDevice3GiPad,
    
    UIDeviceAppleTV2,
    UIDeviceUnknownAppleTV,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceIFPGA,
	
} UIDevicePlatform;

@interface UIDevice (Hardware)
- (NSString *) platform;
- (NSString *) hwmodel;
- (NSUInteger) platformType;
- (NSString *) platformString;

//- (NSUInteger) cpuFrequency;
//- (NSUInteger) busFrequency;
//- (NSUInteger) clockFrequency;

//- (NSUInteger) totalMemory;
//- (NSUInteger) userMemory;
//- (NSUInteger) imhoMemory; //test werkt

//- (NSUInteger) maxSocketBufferSize;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpacePct;
- (NSNumber *) freeDiskSpace;

//- (NSUInteger) userPOSIX; //test werkt 
//- (NSTimeInterval) kernBOOT; //test werkt

//- (NSString *) kernBOOTdata; // test

- (NSDate *) startTime;
- (NSString *)startTimeAsFormattedDateTime;

- (NSString *) macaddressW;
- (NSString *) macaddress;
//- (NSUInteger) myHostID;
//- (NSUInteger) myHostName;

// test data and os disk space
- (NSNumber *) tempTotalDiskSpace;
- (NSNumber *) tempFreeDiskSpace;
- (NSNumber *) pctFreeDiskSpace;

- (NSNumber *) tempTotalDiskSpaceVar;
- (NSNumber *) tempFreeDiskSpaceVar;
- (NSNumber *) pctFreeDiskSpaceVar;

- (NSNumber *) devFreeDiskSpace;
- (NSNumber *) devTotalDiskSpace;

+(float)getTotalDiskSpaceInBytes;
//- (NSString *) ownerAccountName;
//- (NSString *) ownerGroupAccountName;

- (NSNumber *) systemNumber;
- (NSNumber *) systemNodes;
- (NSNumber *) freeNodes;
- (NSNumber *) systemSize;

- (NSUInteger) logSize;
- (NSString *) logSize1;

- (NSString *) accountid;
- (NSString *) accountname;

- (NSString *) cachesSize1;
- (NSString *) cachesSize;



@end