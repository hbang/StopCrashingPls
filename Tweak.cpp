#include <os/log.h>
#include <libgen.h>
#include <stdio.h>
#include <string.h>
#include <CoreFoundation/CoreFoundation.h>


#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <dlfcn.h>
#include <unistd.h>

#include <objc/runtime.h>
#include <crt_externs.h>

#define hasPrefix(string, prefix) (strncmp(prefix, string, strlen(prefix)) == 0)

#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif


__unused static void * (*_logos_orig$_ungrouped$dlopen)(const char *path, int mode); __unused static void * _logos_function$_ungrouped$dlopen(const char *path, int mode) {
    if (hasPrefix(path, "/Library/MobileSubstrate/DynamicLibraries") || hasPrefix(path, "/usr/lib/TweakInject")) {

        int load = 1;
        const char *name;

        char *pathName = (char *)malloc(strlen(path) + 1); 
        strcpy(pathName, path);
        
        size_t length(strlen(pathName));
        memcpy(pathName + length - 5, "plist", 5);

        CFURLRef plist(CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, reinterpret_cast<UInt8 *>(pathName), length, FALSE));

        CFDataRef data;
        if (!CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault, plist, &data, NULL, NULL, NULL))
            data = NULL;
        CFRelease(plist);

        CFDictionaryRef meta;
        if (data != NULL) {
            CFStringRef error;
            meta = reinterpret_cast<CFDictionaryRef>(CFPropertyListCreateFromXMLData(kCFAllocatorDefault, data, kCFPropertyListImmutable, &error));
            CFRelease(data);

            //meta = CFDictionaryGetValue(meta, CFSTR("Filter"));

            CFDictionaryRef filter = reinterpret_cast<CFDictionaryRef>(CFDictionaryGetValue(meta, CFSTR("Filter")));

            if (CFArrayRef bundles = reinterpret_cast<CFArrayRef>(CFDictionaryGetValue(filter, CFSTR("Bundles"))))
            {
                int len = CFArrayGetCount(bundles);
                if ( len )
                {
                    int index = 0LL;
                    while ( 1 )
                    {
                        CFTypeRef bundle = CFArrayGetValueAtIndex(bundles, index);
                        CFTypeID bStr = CFGetTypeID(bundle);
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

            // ;-;
            name = basename((*(char ***)_NSGetArgv())[0]);

            CFStringRef currentProgName;
            currentProgName = CFStringCreateWithCString(kCFAllocatorDefault,
                name,
                kCFStringEncodingUTF8);

            if (CFArrayRef executables = reinterpret_cast<CFArrayRef>(CFDictionaryGetValue(filter, CFSTR("Executables"))))
            {
                int len = CFArrayGetCount(executables);
                if ( len )
                {
                    int index = 0;
                    while ( 1 )
                    {
                        CFTypeRef iname = CFArrayGetValueAtIndex(executables, index);
                        CFTypeID bStr = CFGetTypeID(iname);
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
    return _logos_orig$_ungrouped$dlopen(path, mode);
}

static __attribute__((constructor)) void _logosLocalInit() {
{ MSHookFunction((void *)dlopen, (void *)&_logos_function$_ungrouped$dlopen, (void **)&_logos_orig$_ungrouped$dlopen);} }
