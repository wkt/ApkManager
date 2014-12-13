#include <stdio.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>

#include "UsbUtils.h"

typedef struct MyPrivateData {
    io_object_t				notification;
    IOUSBDeviceInterface	**deviceInterface;
    CFStringRef				deviceName;
    UInt32					locationID;
} MyPrivateData;

static IONotificationPortRef	gNotifyPort;
static io_iterator_t			gAddedIter;


static NSMutableArray *MonitorsArray = Nil;


static inline void notificationAdded(UInt32					locationID)
{
    for(int i=0;i<MonitorsArray.count;i++)
    {
        [[MonitorsArray objectAtIndex:i] added:locationID];
    }
}

static inline void notificationRemoved(UInt32					locationID)
{
    for(int i=0;i<MonitorsArray.count;i++)
    {
        [[MonitorsArray objectAtIndex:i] removed:locationID];
    }
}

//================================================================================================
//
//	DeviceNotification
//
//	This routine will get called whenever any kIOGeneralInterest notification happens.  We are
//	interested in the kIOMessageServiceIsTerminated message so that's what we look for.  Other
//	messages are defined in IOMessage.h.
//
//================================================================================================
static void DeviceNotification(void *refCon, io_service_t service, natural_t messageType, void *messageArgument)
{
    kern_return_t	kr;
    MyPrivateData	*privateDataRef = (MyPrivateData *) refCon;
    
    if (messageType == kIOMessageServiceIsTerminated) {
        
        // Dump our private data to stderr just to see what it looks like.
		CFShow(privateDataRef->deviceName);
        notificationRemoved(privateDataRef->locationID);
        // Free the data we're no longer using now that the device is going away
        CFRelease(privateDataRef->deviceName);
        
        if (privateDataRef->deviceInterface) {
            kr = (*privateDataRef->deviceInterface)->Release(privateDataRef->deviceInterface);
        }
        
        kr = IOObjectRelease(privateDataRef->notification);
        
        free(privateDataRef);
    }
}

//================================================================================================
//
//	DeviceAdded
//
//	This routine is the callback for our IOServiceAddMatchingNotification.  When we get called
//	we will look at all the devices that were added and we will:
//
//	1.  Create some private data to relate to each device (in this case we use the service's name
//	    and the location ID of the device
//	2.  Submit an IOServiceAddInterestNotification of type kIOGeneralInterest for this device,
//	    using the refCon field to store a pointer to our private data.  When we get called with
//	    this interest notification, we can grab the refCon and access our private data.
//
//================================================================================================
static void DeviceAdded(void *refCon, io_iterator_t iterator)
{
    kern_return_t		kr;
    io_service_t		usbDevice;
    IOCFPlugInInterface	**plugInInterface = NULL;
    SInt32				score;
    HRESULT 			res;
    
    while ((usbDevice = IOIteratorNext(iterator))) {
        io_name_t		deviceName;
        CFStringRef		deviceNameAsCFString;
        MyPrivateData	*privateDataRef = NULL;
        UInt32			locationID;
        
        // Add some app-specific information about this device.
        // Create a buffer to hold the data.
        privateDataRef = malloc(sizeof(MyPrivateData));
        bzero(privateDataRef, sizeof(MyPrivateData));
        
        // Get the USB device's name.
        kr = IORegistryEntryGetName(usbDevice, deviceName);
		if (KERN_SUCCESS != kr) {
            deviceName[0] = '\0';
        }
        
        deviceNameAsCFString = CFStringCreateWithCString(kCFAllocatorDefault, deviceName,
                                                         kCFStringEncodingASCII);
        
        // Dump our data to stderr just to see what it looks like.
        // CFShow(deviceNameAsCFString);
        
        // Save the device's name to our private data.
        privateDataRef->deviceName = deviceNameAsCFString;
        
        // Now, get the locationID of this device. In order to do this, we need to create an IOUSBDeviceInterface
        // for our device. This will create the necessary connections between our userland application and the
        // kernel object for the USB Device.
        kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
                                               &plugInInterface, &score);
        
        if ((kIOReturnSuccess != kr) || !plugInInterface) {
            fprintf(stderr, "IOCreatePlugInInterfaceForService returned 0x%08x.\n", kr);
            continue;
        }
        
        // Use the plugin interface to retrieve the device interface.
        res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                                 (LPVOID*) &privateDataRef->deviceInterface);
        
        // Now done with the plugin interface.
        (*plugInInterface)->Release(plugInInterface);
        
        if (res || privateDataRef->deviceInterface == NULL) {
            fprintf(stderr, "QueryInterface returned %d.\n", (int) res);
            continue;
        }
        
        // Now that we have the IOUSBDeviceInterface, we can call the routines in IOUSBLib.h.
        // In this case, fetch the locationID. The locationID uniquely identifies the device
        // and will remain the same, even across reboots, so long as the bus topology doesn't change.
        
        kr = (*privateDataRef->deviceInterface)->GetLocationID(privateDataRef->deviceInterface, &locationID);
        if (KERN_SUCCESS != kr) {
            fprintf(stderr, "GetLocationID returned 0x%08x.\n", kr);
            continue;
        }else {
            //fprintf(stderr, "Location ID: 0x%x\n\n", (unsigned int)locationID);
        }
        
        privateDataRef->locationID = locationID;
        notificationAdded(privateDataRef->locationID);

        // Register for an interest notification of this device being removed. Use a reference to our
        // private data as the refCon which will be passed to the notification callback.
        kr = IOServiceAddInterestNotification(gNotifyPort,						// notifyPort
											  usbDevice,						// service
											  kIOGeneralInterest,				// interestType
											  DeviceNotification,				// callback
											  privateDataRef,					// refCon
											  &(privateDataRef->notification)	// notification
											  );
        
        if (KERN_SUCCESS != kr) {
            printf("IOServiceAddInterestNotification returned 0x%08x.\n", kr);
        }
        
        // Done with this USB device; release the reference added by IOIteratorNext
        kr = IOObjectRelease(usbDevice);
    }
}

@implementation UsbUtils

+(void) setupUSB
{
    CFMutableDictionaryRef 	matchingDict;
    CFRunLoopSourceRef		runLoopSource;
    CFRunLoopRef            gRunLoop;
    kern_return_t			kr;
    
    if(MonitorsArray)return;
    
    matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    gNotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
    runLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
    
    gRunLoop = CFRunLoopGetMain();
    CFRunLoopAddSource(gRunLoop, runLoopSource, kCFRunLoopDefaultMode);
    
    // Now set up a notification to be called when a device is first matched by I/O Kit.
    kr = IOServiceAddMatchingNotification(gNotifyPort,					// notifyPort
                                          kIOFirstMatchNotification,	// notificationType
                                          matchingDict,					// matching
                                          DeviceAdded,					// callback
                                          NULL,							// refCon
                                          &gAddedIter					// notification
                                          );
    if(MonitorsArray == Nil){
        MonitorsArray = [NSMutableArray arrayWithCapacity:0];
    }
    DeviceAdded(NULL,gAddedIter);
    
    //CFRunLoopRun();
    
}

+(void) addUsbMonitor:(id<AMUsbMonitor>) monitor
{
    if([MonitorsArray containsObject:monitor])return;
    [MonitorsArray addObject:monitor];
}

+(void) removeUsbMonitor:(id<AMUsbMonitor>) monitor
{
    [MonitorsArray removeObject:monitor];
}

@end;
