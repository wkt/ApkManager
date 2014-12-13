#ifndef __USB_UTILS_H____
#define __USB_UTILS_H____


@protocol AMUsbMonitor

- (void)added:(UInt32)locationID;
- (void)removed:(UInt32)locationID;

@end

@interface UsbUtils : NSObject

+(void) addUsbMonitor:(id<AMUsbMonitor>) monitor;
+(void) removeUsbMonitor:(id<AMUsbMonitor>) monitor;

+(void) setupUSB;

@end


#endif ///__USB_UTILS_H____