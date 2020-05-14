#include <os/log.h>
#include <libgen.h>
#include <string.h>

#include <dlfcn.h>

#include <objc/runtime.h>
#include <crt_externs.h>

@import Foundation;

#define hasPrefix(string, prefix) (strncmp(prefix, string, strlen(prefix)) == 0)
#define checkFilter(filter, object) ( plist[@"Filter"][filter] && [plist[@"Filter"][filter] count] != 0 && [plist[@"Filter"][filter] containsObject:object] )
#define kProcessName (*(char ***)_NSGetArgv())[0]

#include <substrate.h>

__unused static void * (*original_dlopen)(const char *path, int mode);

__unused static void * hook_dlopen(const char *path, int mode) {

	if (hasPrefix(path, "/Library/MobileSubstrate/DynamicLibraries") || hasPrefix(path, "/usr/lib/TweakInject")) {

		char *pathName = (char *)malloc(strlen(path) + 1); 
		strcpy(pathName, path);
		
		size_t length(strlen(pathName));
		memcpy(pathName + length - 5, "plist", 5);

		NSString *plistFile = [NSString stringWithUTF8String:pathName];

		NSDictionary<NSString *, NSDictionary<NSString *, NSArray<NSString *> *> *> *plist = [NSDictionary dictionaryWithContentsOfFile:plistFile];

		// We only want to filter out situations where there is a UIKit bundle and the executable isn't specified properly.

		if (checkFilter(@"Bundles", @"com.apple.UIKit")
				&& (!checkFilter(@"Executables", [NSString stringWithUTF8String:basename(kProcessName)]))) {
			os_log(OS_LOG_DEFAULT, "stopcrashingpls: Loading of %{public}s was blocked.", path);
			return NULL;
		}
	}
	return original_dlopen(path, mode);
}

static __attribute__((constructor)) void StopCrashingInit() 
{
	char *argv = kProcessName;

	if ((hasPrefix(argv, "/usr") 
			|| hasPrefix(argv, "/System") 
			|| strstr(".framework/", argv) != NULL) 
		&& strstr(argv, "SpringBoard") == NULL ) {

		MSHookFunction((void *)dlopen, (void *)&hook_dlopen, (void **)&original_dlopen);
	} 
}
