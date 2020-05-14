#import <os/log.h>
#include <libgen.h>

#define hasPrefix(string, prefix) (strncmp(prefix, string, strlen(prefix)) == 0)

%hookf(void *, dlopen, const char *path, int mode) {
    if (hasPrefix(path, "/Library/MobileSubstrate/DynamicLibraries") || hasPrefix(path, "/usr/lib/TweakInject")) {

        int load = 1;
        
        size_t length(strlen(path));
        memcpy(path + length - 5, "plist", 5);

        CFURLRef plist(CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, reinterpret_cast<UInt8 *>(path), length, FALSE));

        CFDataRef data;
        if (!CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault, plist, &data, NULL, NULL, NULL))
            data = NULL;
        CFRelease(plist);

        CFDictionaryRef meta;
        if (data != NULL) {
            CFStringRef error;
            meta = reinterpret_cast<CFDictionaryRef>(CFPropertyListCreateFromXMLData(kCFAllocatorDefault, data, kCFPropertyListImmutable, &error));
            CFRelease(data);

            meta = CFDictionaryGetValue(meta, CFSTR("Filter"));

            CFDictionaryRef filter = reinterpret_cast<CFDictionaryRef>(CFDictionaryGetValue(meta, CFSTR("Filter")))

            if (CFArrayRef bundles = reinterpret_cast<CFArrayRef>(CFDictionaryGetValue(filter, CFSTR("Bundles"))))
            {
                int len = CFArrayGetCount(bundles) 
                if ( len )
                {
                    index = 0LL;
                    while ( 1 )
                    {
                        bundle = CFArrayGetValueAtIndex(bundles, index);
                        bStr = CFGetTypeID(bundle);
                        if ( bStr == CFStringGetTypeID() && CFEqual((CFStringRef)bundle, CFSTR("com.apple.UIKit")))
                        {
                            load = 0;
                            break;
                        }

                        if (length == ++index && load)
                            goto release;
                    }
                }
            }     

            const char *name = *(char **)_CFGetProgname()

            CFStringRef currentProgName;
            currentProgName = CFStringCreateWithCString(kCFAllocatorDefault,
                name,
                kCFStringEncodingUTF8);

            if (CFArrayRef executables = reinterpret_cast<CFArrayRef>(CFDictionaryGetValue(filter, CFSTR("Executables"))))
            {
                int len = CFArrayGetCount(executables) 
                if ( len )
                {
                    int index = 0;
                    while ( 1 )
                    {
                        iname = CFArrayGetValueAtIndex(executables, index);
                        bStr = CFGetTypeID(iname);
                        if ( bStr == CFStringGetTypeID() && CFEqual(currentProgName, iname))
                            goto release;

                        if (length == ++index)
                        {
                            load = 0;
                            break;
                        }
                    }
                }
            }

            release:
            CFRelease(meta);
        }

        if (load)
            goto YouShallPass;
        
        os_log(OS_LOG_DEFAULT, "stopcrashingpls: Loading of %{public}s was blocked.", path);
        return NULL;
    }

    YouShallPass:
    return %orig;
}
